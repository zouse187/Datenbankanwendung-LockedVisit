<?php
// Startet die Session, um auf die person_id und die Rolle zuzugreifen
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/*
 * 1) Sicherheitsprüfungen: Ist der Nutzer eingeloggt und ein Besucher?
 */
if (!isset($_SESSION['person_id']) || !isset($_SESSION['rolle'])) {
    header("Location: ../public/user_login.php?error=" . urlencode("Bitte zuerst anmelden"));
    exit;
}

if ($_SESSION['rolle'] !== 'BESUCHER') {
    header("Location: ../public/user_login.php?error=" . urlencode("Zugriff verweigert"));
    exit;
}

// Lädt die Datei für die Datenbankverbindung aus dem config-Ordner
require_once __DIR__ . '/../config/db.php';

// Verbindet sich mit der Oracle-Datenbank über die Session-Zugangsdaten
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

// Initialisierung der Variablen für das dashboard
$gefangene = []; 
$db_error = null;

if (!$connResult['success']) {
    $db_error = "Datenbankverbindung für Datenabfrage fehlgeschlagen.";
} else {
    // Holt das aktive Verbindungsobjekt
    $conn = $connResult['conn'];
    
    /*
     * 2) Aufruf der Stored Procedure (Ermittlung & Cursor-Generierung passieren intern in Oracle)
     */
    $sql = 'BEGIN GET_VALIDIERTE_GEFANGENE(:p_person_id, :p_cursor); END;';
    $stid = oci_parse($conn, $sql);
    
    // Erstellt eine neue Cursor-Ressource für die Ergebnismenge von Oracle
    $p_cursor = oci_new_cursor($conn);
    
    // Bindet die Parameter: Wir übergeben die PERSON_ID direkt aus der Session an die Prozedur
    oci_bind_by_name($stid, ':p_person_id', $_SESSION['person_id']);
    oci_bind_by_name($stid, ':p_cursor', $p_cursor, -1, OCI_B_CURSOR);
    
    // Führt die Prozedur aus
    oci_execute($stid);
    
    // Aktiviert den Cursor, damit die Zeilen gelesen werden können
    oci_execute($p_cursor);
    
    // Holt alle Datensätze zeilenweise ab und speichert sie im Array
    while ($row = oci_fetch_assoc($p_cursor)) {
        // Falls der NO_DATA_FOUND Fall eingetreten ist, wird die Dummy-Zeile ausgefiltert
        if ($row['GEFANGENER_ID'] !== null) {
            $gefangene[] = $row;
        }
    }
    
    // Gibt die belegten Oracle-Ressourcen im Speicher wieder frei
    oci_free_statement($p_cursor);
    oci_free_statement($stid);
}
