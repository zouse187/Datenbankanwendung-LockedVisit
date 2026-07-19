<?php
// Session starten, falls noch nicht geschehen
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Datenbank-Verbindung einbinden
require_once __DIR__ . '/../config/db.php';

/**
 * Holt alle offenen Anträge für das Dashboard
 */
function getOffeneAntraege() {
    // Zugriffsschutz: Nur für Mitarbeiter
    if (!isset($_SESSION['person_id']) || $_SESSION['rolle'] !== 'ANGESTELLTER') {
        return [];
    }

    $connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);
    $antraege = [];

    if ($connResult['success']) {
        $conn = $connResult['conn'];
        
        // Stored Procedure vorbereiten und Cursor für die Datenmenge erstellen
        $stmt = oci_parse($conn, "BEGIN GET_OFFENE_ANTRAEGE(:p_cursor); END;");
        $cursor = oci_new_cursor($conn);
        
        // Cursor an den Parameter binden
        oci_bind_by_name($stmt, ':p_cursor', $cursor, -1, OCI_B_CURSOR);
        
        // Prozedur ausführen und Daten aus dem Cursor in ein Array laden
        if (oci_execute($stmt)) {
            oci_execute($cursor);
            while ($row = oci_fetch_assoc($cursor)) {
                $antraege[] = $row;
            }
            oci_free_statement($cursor);
        }
        oci_free_statement($stmt);
        oci_close($conn);
    }
    return $antraege;
}

/**
 * Verarbeitet das Annehmen oder Ablehnen eines Antrags (POST)
 */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_type']) && $_POST['action_type'] === 'bearbeiten') {
    
    // Zugriffsschutz im Backend
    if (!isset($_SESSION['person_id']) || $_SESSION['rolle'] !== 'ANGESTELLTER') {
        header("Location: ../public/user_login.php?error=" . urlencode("Zugriff verweigert"));
        exit;
    }

    // Eingabedaten filtern und Aktion bestimmen (1 = annehmen, 0 = ablehnen)
    $besucherId   = filter_input(INPUT_POST, 'besucher_id', FILTER_VALIDATE_INT);
    $gefangenerId = filter_input(INPUT_POST, 'gefangener_id', FILTER_VALIDATE_INT);
    $action       = $_POST['action'] ?? '';
    $entscheidung = ($action === 'annehmen') ? 1 : 0;

    if (!$besucherId || !$gefangenerId || !in_array($action, ['annehmen', 'ablehnen'])) {
        header('Location: ../public/dashboard_mitarbeiter.php?error=' . urlencode('Ungültige Daten.'));
        exit;
    }

    // DB-Verbindung aufbauen
    $connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);
    $conn = $connResult['conn'];

    // Prozedur zur Bearbeitung aufrufen
    $plsql = 'BEGIN VALIDIERUNGSANTRAG_BEARBEITEN(:p_bes_id, :p_gef_id, :p_entscheid, :p_ok, :p_meldung); END;';
    $stid = oci_parse($conn, $plsql);

    $ok = 0;
    $meldung = '';

    // Parameter binden (inkl. OUT-Parameter für Rückmeldung aus der DB)
    oci_bind_by_name($stid, ':p_bes_id', $besucherId);
    oci_bind_by_name($stid, ':p_gef_id', $gefangenerId);
    oci_bind_by_name($stid, ':p_entscheid', $entscheidung);
    oci_bind_by_name($stid, ':p_ok', $ok, 10);
    oci_bind_by_name($stid, ':p_meldung', $meldung, 500);

    oci_execute($stid);

    oci_free_statement($stid);
    oci_close($conn);

    // Mit Erfolgs- oder Fehlermeldung zurück zum Dashboard leiten
    $param = ($ok === 1) ? 'success' : 'error';
    header('Location: ../public/dashboard_mitarbeiter.php?' . $param . '=' . urlencode($meldung));
    exit;
}