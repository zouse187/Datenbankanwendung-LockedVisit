<?php
// Startet die Session, um Daten (wie Loginstatus) sitzungsübergreifend zu speichern
session_start();

// Lädt die Datenbank-Verbindungsdatei (aus dem vorherigen Schritt)
require_once __DIR__ . '/../config/db.php';

// Prüft, ob das Formular per POST gesendet wurde. Wenn nicht, Abbruch und Zurückleitung
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../public/db_login.php');
    exit;
}

// Holt Username (ohne Leerzeichen am Rand) und Passwort aus dem abgesendeten Formular
$username = trim($_POST['username'] ?? '');
$password = $_POST['password'] ?? '';

// Ruft die Verbindungsfunktion mit den eingegebenen Daten auf
$result = db_connect($username, $password);

// Wenn die Verbindung zur Datenbank erfolgreich war...
if ($result['success']) {
    // Speichert die Zugangsdaten in der Session, um eingeloggt zu bleiben
    $_SESSION['db_user'] = $username;
    $_SESSION['db_pass'] = $password;
    $_SESSION['connected'] = true;

    // Weiterleitung zur eigentlichen Login-Seite für den Benutzer
    header('Location: ../public/user_login.php');
    exit;
}

// Wenn die Verbindung fehlschlägt: Fehlermeldung in der Session merken...
$_SESSION['login_error'] = 'Verbindung fehlgeschlagen: ' . $result['error'];
// ...und zurück zum Datenbank-Login leiten
header('Location: ../public/db_login.php');
exit;
