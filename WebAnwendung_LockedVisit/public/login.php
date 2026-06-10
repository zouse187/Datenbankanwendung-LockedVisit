<?php
session_start();
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Oracle Login</title>
    <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
    <div class="login-container">
        <h1>DB-Login</h1>

        <?php if (!empty($_SESSION['login_error'])): ?>
            <div class="error">
                <?= htmlspecialchars($_SESSION['login_error']) ?>
            </div>
            <?php unset($_SESSION['login_error']); ?>
        <?php endif; ?>

        <form action="login_check.php" method="post">
            <label for="username">DB-User</label>
            <input type="text" id="username" name="username" required>

            <label for="password">Passwort</label>
            <input type="password" id="password" name="password" required>

            <button type="submit">Verbinden</button>
        </form>
    </div>
</body>
</html>
