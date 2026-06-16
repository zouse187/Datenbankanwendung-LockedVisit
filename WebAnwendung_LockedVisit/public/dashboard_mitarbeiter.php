<?php
// Session starten
session_start();

/*
 * 1) Prüfen, ob der Benutzer eingeloggt ist
 */
if (!isset($_SESSION['person_id']) || !isset($_SESSION['rolle'])) {
    header("Location: user_login.php?error=Bitte zuerst anmelden");
    exit;
}

/*
 * 2) Prüfen, ob der Benutzer ein Mitarbeiter ist
 */
if ($_SESSION['rolle'] !== 'ANGESTELLTER') {
    header("Location: user_login.php?error=Zugriff verweigert");
    exit;
}

// Ab hier wissen wir: Benutzer ist eingeloggt UND Mitarbeiter
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Mitarbeiter Dashboard</title>
    <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
    <div class="login-container">
        <h1>Willkommen Mitarbeiter!</h1>

        <!-- Person-ID anzeigen -->
        <p>Ihre Person-ID lautet: <strong><?php echo htmlspecialchars($_SESSION['person_id']); ?></strong></p>

        <p>Die Anmeldung war erfolgreich. Dies ist das Mitarbeiter-Dashboard.</p>

        <!-- Später kommen hier echte Funktionen hin -->
        <p>(Hier werden später Validierungsprozesse, Besucherfreigaben, Gefangenenstatus usw. erscheinen.)</p>

        <a href="user_logout.php">Logout</a>
    </div>
</body>
</html>
