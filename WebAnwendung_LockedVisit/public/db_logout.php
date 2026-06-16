<?php
// Aktiviert den Zugriff auf die aktuelle Sitzung (Session)
session_start();

// Löscht alle in der Session gespeicherten Daten und meldet den Nutzer damit ab
session_destroy();

// Leitet den Browser automatisch zur Login-Seite weiter
header('Location: db_login.php');

// Beendet das Skript sofort, damit kein weiterer Code mehr ausgeführt wird
exit;
