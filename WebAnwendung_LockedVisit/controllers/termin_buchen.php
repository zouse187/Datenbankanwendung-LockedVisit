<?php
// Startet die Session, um Zugriff auf die person_id und die DB-Verbindung zu haben
session_start();

/*
 * 1) Sicherheitsprüfungen: Eingeloggt und Rolle korrekt?
 */
if (!isset($_SESSION['person_id']) || $_SESSION['rolle'] !== 'BESUCHER') {
    header("Location: ../public/user_login.php?error=" . urlencode("Zugriff verweigert"));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// Formulardaten auslesen
$gefangenerId = filter_input(INPUT_POST, 'gefangener_id', FILTER_VALIDATE_INT);
$datumInput   = $_POST['datum'] ?? ''; // Format des HTML-Feldes: YYYY-MM-DDTHH:MM

if (!$gefangenerId || empty($datumInput)) {
    header('Location: ../public/dashboard_besucher.php?error=' . urlencode('Bitte füllen Sie alle Felder aus.'));
    exit;
}

// HTML-Format ('2026-07-14T10:00') in ein Standard-Format konvertieren ('2026-07-14 10:00:00')
$formattedDatum = str_replace('T', ' ', $datumInput) . ':00';

// Verbindungsaufbau zur Oracle-Datenbank
require_once __DIR__ . '/../config/db.php';
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

if (!$connResult['success']) {
    header('Location: ../public/dashboard_besucher.php?error=' . urlencode('Datenbankverbindung fehlgeschlagen.'));
    exit;
}

$conn = $connResult['conn'];

/*
 * 2) Aufruf der neuen Stored Procedure TERMIN_BUCHEN
 */
$plsql = 'BEGIN TERMIN_BUCHEN(:p_person_id, :p_gefangener_id, :p_datum_str, :p_ok, :p_meldung); END;';
$stid = oci_parse($conn, $plsql);

// Variablen für die OUT-Parameter definieren
$personId = (int)$_SESSION['person_id'];
$ok = 0;
$meldung = '';

// Parameter an die Platzhalter binden
oci_bind_by_name($stid, ':p_person_id', $personId);
oci_bind_by_name($stid, ':p_gefangener_id', $gefangenerId);
oci_bind_by_name($stid, ':p_datum_str', $formattedDatum);
oci_bind_by_name($stid, ':p_ok', $ok, 10);
oci_bind_by_name($stid, ':p_meldung', $meldung, 500);

// Prozedur ausführen
if (!oci_execute($stid)) {
    $ok = 0;
    $meldung = 'Die Buchungsprozedur konnte in der Datenbank nicht ausgeführt werden.';
}

// Ressourcen freigeben
oci_free_statement($stid);
oci_close($conn);

/*
 * 3) Weiterleitung basierend auf dem Rückgabewert p_ok der Prozedur
 */
$parameter = ((int)$ok === 1) ? 'success' : 'error';

header('Location: ../public/dashboard_besucher.php?' . $parameter . '=' . urlencode($meldung));
exit;