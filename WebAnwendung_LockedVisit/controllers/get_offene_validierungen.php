<?php
// Startet die Session, falls sie noch nicht aktiv ist
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Prüft, ob die benötigten Sitzungsdaten vorhanden sind
if (
    !isset($_SESSION['person_id']) ||
    !isset($_SESSION['db_user']) ||
    !isset($_SESSION['db_pass'])
) {
    header(
        'Location: ../public/user_login.php?error=' .
        urlencode('Bitte zuerst anmelden')
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

// Initialisiert das Array für die offenen Validierungsanträge und die Fehlermeldung
$offeneValidierungen = [];
$db_error = null;

// Prüft, ob die Verbindung zur Datenbank erfolgreich war
if (!$connResult['success']) {
    $db_error = 'Datenbankverbindung für die Datenabfrage fehlgeschlagen.';
} else {
    // Holt das aktive Oracle-Verbindungsobjekt
    $conn = $connResult['conn'];

    // Bereitet den Aufruf der Stored Procedure vor
    $sql = '
        BEGIN
            GET_OFFENE_VALIDIERUNGSANTRAEGE(
                :p_person_id,
                :p_cursor
            );
        END;
    ';

    $stid = oci_parse($conn, $sql);

    // Erstellt den Cursor für die zurückgegebenen offenen Validierungsanträge
    $p_cursor = oci_new_cursor($conn);

    // Bindet die Person-ID und den Rückgabe-Cursor an die Prozedur
    oci_bind_by_name(
        $stid,
        ':p_person_id',
        $_SESSION['person_id']
    );

    oci_bind_by_name(
        $stid,
        ':p_cursor',
        $p_cursor,
        -1,
        OCI_B_CURSOR
    );

    // Führt die Prozedur und anschließend den Rückgabe-Cursor aus
    if (oci_execute($stid) && oci_execute($p_cursor)) {
        // Speichert alle offenen Validierungsanträge im Array
        while ($row = oci_fetch_assoc($p_cursor)) {
            $offeneValidierungen[] = $row;
        }
    } else {
        $e = oci_error($stid);
        if (!$e) { $e = oci_error($conn); }
        $db_error = 'Oracle-Fehler: ' . $e['message'];
    }

    // Gibt die verwendeten Oracle-Ressourcen wieder frei
    oci_free_statement($p_cursor);
    oci_free_statement($stid);
}