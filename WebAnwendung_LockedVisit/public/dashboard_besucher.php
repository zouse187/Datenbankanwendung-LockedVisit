<?php
// Session starten, um auf gespeicherte Login-Daten zuzugreifen
session_start();

/*
 * 1) Prüfen, ob der Benutzer eingeloggt ist
 *    Wenn nicht → zurück zur Login-Seite
 */
if (!isset($_SESSION['person_id']) || !isset($_SESSION['rolle'])) {
    header("Location: user_login.php?error=Bitte zuerst anmelden");
    exit;
}

/*
 * 2) Prüfen, ob der Benutzer ein Besucher ist
 *    Falls jemand versucht, diese Seite als Mitarbeiter aufzurufen → blockieren
 */
if ($_SESSION['rolle'] !== 'BESUCHER') {
    header("Location: user_login.php?error=Zugriff verweigert");
    exit;
}

// Ab hier wissen wir: Benutzer ist eingeloggt UND Besucher
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Besucher Dashboard</title>
    <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
    <div class="login-container">
        <h1>Willkommen Besucher!</h1>

        <!-- Person-ID anzeigen, damit du siehst, dass die Session funktioniert -->
        <p>Ihre Person-ID lautet: <strong><?php echo htmlspecialchars($_SESSION['person_id']); ?></strong></p>

        <p>Die Anmeldung war erfolgreich. Dies ist das Besucher-Dashboard.</p>

        <!-- Später kommen hier echte Funktionen hin -->
        <p>(Hier werden später Besuchszeiten, Validierungen, Gefangenen-Auswahl usw. erscheinen.)</p>

        <a href="user_logout.php">Logout</a>
    </div>
</body>
</html>
