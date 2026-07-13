<?php
session_start();

if (!isset($_SESSION['person_id'])) {
    header("Location: ../public/user_login.php");
    exit;
}

// Daten aus dem Formular holen
$personId = filter_input(INPUT_POST, 'person_id', FILTER_VALIDATE_INT);
$gefangenerId = filter_input(INPUT_POST, 'gefangener_id', FILTER_VALIDATE_INT);

if (!$personId || !$gefangenerId) {
    header('Location: ../public/dashboard_besucher.php?error=' . urlencode('Fehlende Parameter beim Absenden.'));
    exit;
}

// Datenbankverbindung
require_once __DIR__ . '/../config/db.php';
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

if (!$connResult['success']) {
    header('Location: ../public/dashboard_besucher.php?error=' . urlencode('Datenbankverbindung fehlgeschlagen.'));
    exit;
}
$conn = $connResult['conn'];

// Aufruf der Stored Procedure
$plsql = 'BEGIN VALIDIERUNGSANTRAG_STELLEN(:p_person_id, :p_gefangener_id, :p_ok, :p_meldung); END;';
$stid = oci_parse($conn, $plsql);

$ok = 0;
$meldung = '';

oci_bind_by_name($stid, ':p_person_id', $personId);
oci_bind_by_name($stid, ':p_gefangener_id', $gefangenerId);
oci_bind_by_name($stid, ':p_ok', $ok, 10);
oci_bind_by_name($stid, ':p_meldung', $meldung, 500);

// Falls die Ausführung auf einen harten Datenbankfehler stößt
if (!@oci_execute($stid)) {
    $e = oci_error($stid);
    if (!$e) { $e = oci_error($conn); }
    $meldung = 'Oracle-Fehler: ' . $e['message'];
    $ok = 0;
}

oci_free_statement($stid);
oci_close($conn);

// Leitet zurück zum Dashboard und gibt Erfolg oder den genauen Fehler aus
$parameter = ((int)$ok === 1) ? 'success' : 'error';
header('Location: ../public/dashboard_besucher.php?' . $parameter . '=' . urlencode($meldung));
exit;