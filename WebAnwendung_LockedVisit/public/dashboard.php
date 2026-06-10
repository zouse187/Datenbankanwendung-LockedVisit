<?php
session_start();
if (empty($_SESSION['connected'])) {
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
</head>
<body>
    <h1>Willkommen, <?= htmlspecialchars($_SESSION['db_user']) ?></h1>
    <p>Die Verbindung zur Oracle-Datenbank wurde beim Login erfolgreich aufgebaut.</p>

    <p>Hier könnt ihr später eure Businessprozesse (PL/SQL, Views, PHP-Seiten) einhängen.</p>

    <a href="logout.php">Logout</a>
</body>
</html>
