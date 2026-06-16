<?php
// Startet die Sitzung, um Session-Daten zu nutzen oder zu speichern
session_start();
// Lädt die Datei für die Datenbankverbindung
require_once __DIR__ . '/../config/db.php';

// Speichert die eingegebenen Formulardaten in Variablen (falls leer, wird '' oder null genutzt)
$vorname      = $_POST['vorname']      ?? '';
$nachname     = $_POST['nachname']     ?? '';
$geburtsdatum = $_POST['geburtsdatum'] ?? '';
$geschlecht   = $_POST['geschlecht']   ?? '';
$telefon      = $_POST['telefon']      ?? '';
$email        = $_POST['email']        ?? '';
$passwort     = $_POST['passwort']     ?? '';

// Prüft, ob das Häkchen bei "Mitarbeiter" gesetzt ist (1 = Ja, 0 = Nein)
$ist_mitarb   = isset($_POST['ist_mitarbeiter']) ? 1 : 0;

// Speichert die spezifischen Adressdaten für Besucher
$bes_strasse  = $_POST['bes_strasse']  ?? '';
$bes_plz      = $_POST['bes_plz']      ?? '';
$bes_ort      = $_POST['bes_ort']      ?? '';

// Speichert die spezifischen Job- und Adressdaten für Angestellte
$ang_standort_id = $_POST['ang_standort_id']    ?? null;
$ang_rolle    = $_POST['ang_rolle']    ?? '';
$ang_strasse  = $_POST['ang_strasse']  ?? '';
$ang_plz      = $_POST['ang_plz']      ?? '';
$ang_ort      = $_POST['ang_ort']      ?? '';

// Verbindet sich mit der Datenbank unter Verwendung der gespeicherten Session-Zugangsdaten
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

// Wenn die Verbindung fehlschlägt, leite mit Fehlermeldung zurück zum Registrierungsformular
if (!$connResult['success']) {
    $error = urlencode('DB-Verbindung fehlgeschlagen');
    header("Location: ../public/register.php?error=$error");
    exit; 
}
// Holt das aktive Verbindungsobjekt aus dem Ergebnis
$conn = $connResult['conn'];

// Bereitet den Aufruf einer fertigen Datenbank-Prozedur (REGISTRIERE_PERSON) mit Platzhaltern (beginnend mit Doppelpunkt) vor
$plsql = 'BEGIN REGISTRIERE_PERSON(
    :p_vorname, :p_nachname, :p_geburtsdatum, :p_geschlecht, :p_telefon,
    :p_email, :p_passwort, :p_ist_mitarb,
    :p_bes_strasse, :p_bes_plz, :p_bes_ort,
    :p_ang_standort_id, :p_ang_rolle, :p_ang_strasse, :p_ang_plz, :p_ang_ort,
    :p_person_id
); END;';

// Meldet den PL/SQL-Befehl bei der Oracle-Datenbank an
$stid = oci_parse($conn, $plsql);

// Verknüpft die PHP-Variablen mit den Platzhaltern im SQL-Befehl (Schutz vor Hackern)
oci_bind_by_name($stid, ':p_vorname',      $vorname);
oci_bind_by_name($stid, ':p_nachname',     $nachname);
oci_bind_by_name($stid, ':p_geburtsdatum', $geburtsdatum);
oci_bind_by_name($stid, ':p_geschlecht',   $geschlecht);
oci_bind_by_name($stid, ':p_telefon',      $telefon);
oci_bind_by_name($stid, ':p_email',        $email);
oci_bind_by_name($stid, ':p_passwort',     $passwort);
oci_bind_by_name($stid, ':p_ist_mitarb',   $ist_mitarb);

// Verknüpft die Besucher-Daten mit den SQL-Platzhaltern
oci_bind_by_name($stid, ':p_bes_strasse',  $bes_strasse);
oci_bind_by_name($stid, ':p_bes_plz',      $bes_plz);
oci_bind_by_name($stid, ':p_bes_ort',      $bes_ort);

// Verknüpft die Angestellten-Daten mit den SQL-Platzhaltern
oci_bind_by_name($stid, ':p_ang_standort_id',    $ang_standort_id);
oci_bind_by_name($stid, ':p_ang_rolle',    $ang_rolle);
oci_bind_by_name($stid, ':p_ang_strasse',  $ang_strasse);
oci_bind_by_name($stid, ':p_ang_plz',      $ang_plz);
oci_bind_by_name($stid, ':p_ang_ort',      $ang_ort);

// Verknüpft einen Platzhalter, in den Oracle die neu erstellte Person-ID hineinschreibt (max. 40 Zeichen)
oci_bind_by_name($stid, ':p_person_id',    $person_id, 40);

// Führt den gesamten Datenbank-Befehl aus (@ unterdrückt Fehlermeldungen im Browser)
$ok = @oci_execute($stid);

// Wenn das Ausführen in der Datenbank geklappt hat...
if ($ok) {
    // Startet zur Sicherheit die Session erneut (eigentlich oben schon erledigt)
    session_start();
    // Speichert die von der Datenbank generierte Person-ID in der Session
    $_SESSION['person_id'] = $person_id;
    // Setzt den Session-Status "rolle" passend zum Nutzertyp
    $_SESSION['rolle']     = $ist_mitarb ? 'ANGESTELLTER' : 'BESUCHER';

    // Leitet den Nutzer je nach Rolle auf das richtige Dashboard weiter
    if ($ist_mitarb) {
        header('Location: ../public/dashboard_mitarbeiter.php');
    } else {
        header('Location: ../public/dashboard_besucher.php');
    }
    exit; 
} else {
    // Wenn beim Ausführen in der Datenbank ein Fehler aufgetreten ist:
    $e = oci_error($stid); // Holt die Oracle-Fehlermeldung ab
    $error = urlencode('Registrierung fehlgeschlagen: ' . $e['message']); // Macht den Text URL-sicher
    header("Location: ../public/register.php?error=$error"); // Leitet zurück zum Formular mit der Fehlermeldung
    exit;
}
