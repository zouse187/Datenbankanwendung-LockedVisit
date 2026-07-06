<?php
// Simulierter Abschluss der Buchung: legt keine DB-Zeile an, markiert aber Sitzung als erfolgreich.
session_start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../public/dashboard_besucher.php');
    exit;
}

if (empty($_SESSION['pending_booking'])) {
    header('Location: ../public/dashboard_besucher.php?error=Keine+ausstehende+Buchung');
    exit;
}

// In einer echten Anwendung würde hier die Einfüge-Query in die Tabelle BESUCH erfolgen.
// Da keine verlässliche SEQUENCE für BESUCH_ID im Projekt vorhanden ist, machen wir eine Simulation.
$booking = $_SESSION['pending_booking'];

// Markieren als erfolgreich und entfernen die pending-Daten
unset($_SESSION['pending_booking']);
$_SESSION['booking_success'] = 'Buchung erfolgreich simuliert für ' . htmlspecialchars($booking['besuch_datum']);

header('Location: ../public/dashboard_besucher.php');
exit;
