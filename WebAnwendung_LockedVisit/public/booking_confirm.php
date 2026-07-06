<?php
session_start();

// Prüfen, ob es eine pending booking gibt
if (empty($_SESSION['pending_booking'])) {
    header('Location: dashboard_besucher.php?error=Keine+ausstehende+Buchung');
    exit;
}

$b = $_SESSION['pending_booking'];
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="utf-8">
    <title>Buchung bestätigen</title>
    <link rel="stylesheet" href="../assets/style.css">
    <style>.container{max-width:600px;margin:40px auto}</style>
</head>
<body>
<div class="container">
    <h1>Buchung bestätigen</h1>

    <p>Besucher-ID: <strong><?php echo htmlspecialchars($b['besucher_id']); ?></strong></p>
    <p>Gefangenen-ID: <strong><?php echo htmlspecialchars($b['gefangener_id']); ?></strong></p>
    <p>Dies ist eine lokale Simulation: Die Validierung wurde durchgeführt und die Buchungsdaten sind bereit.</p>

    <form action="../controllers/confirm_booking.php" method="post">
        <button type="submit">Buchung final bestätigen (Simulation)</button>
    </form>

    <p><a href="dashboard_besucher.php">Zurück zum Dashboard</a></p>
</div>
</body>
</html>
