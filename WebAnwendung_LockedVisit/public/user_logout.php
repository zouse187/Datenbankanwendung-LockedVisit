<?php
// Aktiviert den Zugriff auf die aktuelle Sitzung (Session)
session_start();

// Nur User-Login-Daten löschen, NICHT die DB-Daten, sonst schlägt die DB-Verbindung fehl, solange man nicht neu startet
unset($_SESSION['person_id']);
unset($_SESSION['rolle']);

// Leitet den Browser automatisch zurück zur Login-Seite des Benutzers weiter
header("Location: user_login.php");

// Beendet das Skript sofort, damit kein weiterer Code ausgeführt wird
exit;
