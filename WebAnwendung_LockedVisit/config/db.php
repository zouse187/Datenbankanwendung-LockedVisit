<?php
// Definiert eine Funktion, die Benutzername und Passwort für die Datenbank erwartet
function db_connect($username, $password) {
    
    // Die Netzwerkadresse zum Oracle-Datenbankserver der FH Bielefeld
    $connStr = "rs03-db-inf-min.ad.fh-bielefeld.de:1521/orcl.rs03-db-inf-min.ad.fh-bielefeld.de";

    // Versucht die Verbindung aufzubauen (@ unterdrückt Fehlermeldungen im Browser)
    $conn = @oci_connect($username, $password, $connStr, 'AL32UTF8');

    // Wenn die Verbindung fehlgeschlagen ist...
    if (!$conn) {
        $e = oci_error(); // Holt den genauen Fehlercode ab
        // Gibt "Erfolg: nein" und die Fehlermeldung zurück
        return ['success' => false, 'error' => $e['message']];
    }

    // Wenn alles geklappt hat: Gibt "Erfolg: ja" und die aktive Verbindung zurück
    return ['success' => true, 'conn' => $conn];
}