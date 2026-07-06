<?php
// Validierungs-Controller für Besuchs-Buchungen
// Ziel: Serverseitige Prüfungen durchführen und bei Erfolg zur Bestätigungsseite weiterleiten.

session_start();
require_once __DIR__ . '/../config/db.php';

// Nur POST-Anfragen akzeptieren
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// Prüfung: Eingeloggt und Rolle = BESUCHER
if (!isset($_SESSION['person_id']) || !isset($_SESSION['rolle']) || $_SESSION['rolle'] !== 'BESUCHER') {
    header('Location: ../public/user_login.php?error=Bitte+anmelden');
    exit;
}

// Eingabewerte vom Formular lesen
$gefangener_id = intval($_POST['gefangener_id'] ?? 0);
$gebaeude_id   = intval($_POST['gebaeude_id'] ?? 0);
$besuch_datum  = trim($_POST['besuch_datum'] ?? ''); // erwartet Format YYYY-MM-DD

// Einfache Server-seitige Validierung (Format / Grundregeln)
$errors = [];
if ($gefangener_id <= 0) {
    $errors[] = 'Ungültige Gefangenen-ID.';
}

if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $besuch_datum)) {
    $errors[] = 'Datum ungültig. Bitte im Format YYYY-MM-DD eingeben.';
} else {
    // Datum darf nicht in der Vergangenheit liegen
    $today = date('Y-m-d');
    if ($besuch_datum < $today) {
        $errors[] = 'Datum liegt in der Vergangenheit.';
    }
}

if (!empty($errors)) {
    // Fehler in Session speichern und zurück zum Dashboard
    $_SESSION['booking_error'] = implode(' ', $errors);
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// DB-Verbindung herstellen (verwendet die im DB-Login gespeicherten Credentials)
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);
if (!$connResult['success']) {
    $_SESSION['booking_error'] = 'Datenbank-Verbindung fehlgeschlagen.';
    header('Location: ../public/dashboard_besucher.php');
    exit;
}
$conn = $connResult['conn'];

// 1) Prüfen: Ist der eingeloggte Nutzer tatsächlich als BESUCHER registriert?
$stid = oci_parse($conn, 'SELECT BESUCHER_ID FROM BESUCHER WHERE PERSON_ID = :pid');
oci_bind_by_name($stid, ':pid', $_SESSION['person_id']);
oci_execute($stid);
$row = oci_fetch_assoc($stid);
if (!$row) {
    $_SESSION['booking_error'] = 'Sie sind nicht als Besucher registriert.';
    header('Location: ../public/dashboard_besucher.php');
    exit;
}
$besucher_id = $row['BESUCHER_ID'];

// 2) Prüfen: Darf der Besucher diesen Gefangenen besuchen?
$stid = oci_parse($conn, '
    SELECT g.SICHERHEITSSTUFE
    FROM VALIDIERTE_BESUCHER vb
    JOIN GEFANGENER g ON vb.GEFANGENER_ID = g.GEFANGENER_ID
    WHERE vb.BESUCHER_ID = :bid
      AND vb.GEFANGENER_ID = :gid');
oci_bind_by_name($stid, ':bid', $besucher_id);
oci_bind_by_name($stid, ':gid', $gefangener_id);
oci_execute($stid);
$row = oci_fetch_assoc($stid);
if (!$row) {
    $_SESSION['booking_error'] = 'Sie dürfen diesen Gefangenen nicht besuchen.';
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// Beispielregel: Wenn die Sicherheitsstufe 'hoch' ist, verweigern wir vorerst Besuche
$sicherheitsstufe = $row['SICHERHEITSSTUFE'] ?? '';
if (strtolower((string)$sicherheitsstufe) === 'hoch') {
    $_SESSION['booking_error'] = 'Besuch für diesen Gefangenen derzeit nicht möglich.';
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// 3) Prüfen: Gibt es bereits einen Besuch für denselben Gefangenen am selben Tag?
$stid = oci_parse($conn, "SELECT COUNT(*) AS CNT FROM BESUCH WHERE GEFANGENER_ID = :gid AND TRUNC(BESUCHSDATUM) = TO_DATE(:d,'YYYY-MM-DD')");
oci_bind_by_name($stid, ':gid', $gefangener_id);
oci_bind_by_name($stid, ':d', $besuch_datum);
oci_execute($stid);
$row = oci_fetch_assoc($stid);
if ($row && intval($row['CNT']) > 0) {
    $_SESSION['booking_error'] = 'Für diesen Tag gibt es bereits einen Besuch für den Gefangenen.';
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// Wenn alle Prüfungen bestanden sind, speichern wir die Pending-Booking-Daten in der Session
// (Damit die finale Buchung später bestätigt oder von einem Mitarbeiter angelegt werden kann)
$_SESSION['pending_booking'] = [
    'besucher_id'    => $besucher_id,
    'gefangener_id'  => $gefangener_id,
    'gebaeude_id'    => $gebaeude_id,
    'besuch_datum'   => $besuch_datum,
    'erstellt_am'    => date('c')
];

// Weiterleitung zur Bestätigungsseite
header('Location: ../public/booking_confirm.php');
exit;
