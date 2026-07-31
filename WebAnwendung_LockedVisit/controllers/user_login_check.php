<?php
// Startet die Sitzung, um Session-Daten zu nutzen oder zu speichern
session_start();

// Lädt die Datei für die Datenbankverbindung
require_once __DIR__ . '/../config/db.php';

// Holt E-Mail und Passwort aus dem abgesendeten Login-Formular
$email    = $_POST['email']    ?? '';
$passwort = $_POST['password'] ?? '';

// Verbindet sich mit der Datenbank über die im vorherigen Login gespeicherten Session-Daten
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

// Wenn die Verbindung fehlschlägt, leite mit Fehlermeldung zurück zum User-Login
if (!$connResult['success']) {
    $error = urlencode('DB-Verbindung fehlgeschlagen');
    header("Location: ../public/user_login.php?error=$error");
    exit; 
}

// Speichert die aktive Verbindung in der Variable $conn
$conn = $connResult['conn'];

// Bereitet den Aufruf der Datenbank-Prozedur (LOGIN_PERSON) mit Platzhaltern vor
$stid = oci_parse($conn, 'BEGIN LOGIN_PERSON(:p_email, :p_passwort, :p_person_id, :p_rolle, :p_ok); END;');

// Übergibt die eingegebene E-Mail und das Passwort an die SQL-Platzhalter
oci_bind_by_name($stid, ':p_email', $email);
oci_bind_by_name($stid, ':p_passwort', $passwort);

// Definiert Variablen, in die Oracle das Ergebnis (ID, Rolle, Status) zurückschreiben soll
oci_bind_by_name($stid, ':p_person_id', $person_id, 40); 
oci_bind_by_name($stid, ':p_rolle', $rolle, 40);         
oci_bind_by_name($stid, ':p_ok', $ok, 10);              

// Führt die Login-Prüfung in der Oracle-Datenbank aus
oci_execute($stid);

// Wenn die Datenbank zurückmeldet, dass die Login-Daten korrekt sind (Status ist 1)...
if ($ok == 1) {
    // Speichert die ID und Rolle des Nutzers dauerhaft in der Session
    $_SESSION['person_id'] = $person_id;
    $_SESSION['rolle']     = $rolle;

    // Leitet den Nutzer je nach seiner Rolle auf das passende Dashboard weiter
    if ($rolle === 'ANGESTELLTER') {
        // Weiterleitung direkt auf das Mitarbeiter-Dashboard im public-Ordner
        header('Location: ../public/dashboard_mitarbeiter.php');
        exit;
    } elseif ($rolle === 'BESUCHER') {
        header('Location: ../public/dashboard_besucher.php');
        exit;
    } else {
        // Falls die Rolle aus der Datenbank ungültig ist
        $error = urlencode('Rolle unbekannt');
        header("Location: ../public/user_login.php?error=$error");
        exit;
    }
    
} else {
    // Wenn die Login-Daten falsch waren ($ok ist nicht 1), leite zurück mit Fehlermeldung
    $error = urlencode('E-Mail oder Passwort falsch');
    header("Location: ../public/user_login.php?error=$error");
    exit;
}
?>