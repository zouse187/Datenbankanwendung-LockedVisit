<?php

// Startet die Session, falls sie noch nicht aktiv ist
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Prüft, ob der Nutzer eingeloggt ist
if (!isset($_SESSION['person_id']) || !isset($_SESSION['rolle'])) {
    header(
        'Location: ../public/user_login.php?error=' .
        urlencode('Bitte zuerst anmelden')
    );
    exit;
}

// Prüft, ob der eingeloggte Nutzer ein Besucher ist
if ($_SESSION['rolle'] !== 'BESUCHER') {
    header(
        'Location: ../public/user_login.php?error=' .
        urlencode('Zugriff verweigert')
    );
    exit;
}

// Prüft, ob das Formular per POST gesendet wurde
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

// Liest die ausgewählte Gefangenen-ID aus dem Formular aus
$gefangenerId = filter_input(
    INPUT_POST,
    'gefangener_id',
    FILTER_VALIDATE_INT
);

// Prüft, ob ein Gefangener ausgewählt wurde
if (!$gefangenerId) {
    header(
        'Location: ../public/dashboard_besucher.php?error=' .
        urlencode('Bitte wählen Sie einen Gefangenen aus.')
    );
    exit;
}

// Lädt die Datei für die Datenbankverbindung
require_once __DIR__ . '/../config/db.php';

// Stellt mit den gespeicherten Zugangsdaten eine Datenbankverbindung her
$connResult = db_connect(
    $_SESSION['db_user'],
    $_SESSION['db_pass']
);

// Prüft, ob die Verbindung zur Datenbank erfolgreich war
if (!$connResult['success']) {
    header(
        'Location: ../public/dashboard_besucher.php?error=' .
        urlencode('Datenbankverbindung fehlgeschlagen.')
    );
    exit;
}

// Holt das aktive Oracle-Verbindungsobjekt
$conn = $connResult['conn'];

// Bereitet den Aufruf der Stored Procedure vor
$stid = oci_parse(
    $conn,
    'BEGIN VALIDIERUNGSANTRAG_STELLEN(
        :p_person_id,
        :p_gefangener_id,
        :p_ok,
        :p_meldung
    ); END;'
);

// Initialisiert die benötigten Variablen
$personId = (int) $_SESSION['person_id'];
$ok = 0;
$meldung = '';

// Bindet die Parameter an die Stored Procedure
oci_bind_by_name($stid, ':p_person_id', $personId);
oci_bind_by_name($stid, ':p_gefangener_id', $gefangenerId);
oci_bind_by_name($stid, ':p_ok', $ok, 10);
oci_bind_by_name($stid, ':p_meldung', $meldung, 500);

// Führt die Stored Procedure aus
if (!oci_execute($stid)) {
    $ok = 0;
    $meldung = 'Der Antrag konnte nicht ausgeführt werden.';
}

// Gibt die verwendeten Oracle-Ressourcen wieder frei
oci_free_statement($stid);
oci_close($conn);

// Legt abhängig vom Ergebnis den Rückgabeparameter fest
$parameter = ((int) $ok === 1) ? 'success' : 'error';

// Leitet den Besucher mit der Erfolg- oder Fehlermeldung zurück zum Dashboard
header(
    'Location: ../public/dashboard_besucher.php?' .
    $parameter . '=' . urlencode($meldung)
);

exit;