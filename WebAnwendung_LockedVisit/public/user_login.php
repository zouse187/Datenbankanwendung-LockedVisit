<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Anmeldung</title>
    <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
<div class="login-container">
    <h1>Anmeldung</h1>

    <?php if (!empty($_GET['error'])): ?>
        <div class="error">
            <?= htmlspecialchars($_GET['error']) ?>
        </div>
    <?php endif; ?>

    <form action="../controllers/user_login_check.php" method="post">
        <label for="email">E-Mail</label>
        <input type="email" id="email" name="email" required>

        <label for="password">Passwort</label>
        <input type="password" id="password" name="password" required>

        <button type="submit">Anmelden</button>
    </form>

    <p>Noch kein Konto? <a href="register.php">Jetzt registrieren</a></p>
</div>
</body>
</html>