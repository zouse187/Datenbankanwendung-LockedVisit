<?php
// Bindet die Backend-Logik ein. Der Controller prüft auch direkt die Session-Rechte.
require_once __DIR__ . '/../controllers/get_gefangene.php';
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

        <p>Ihre Person-ID lautet: <strong><?php echo htmlspecialchars($_SESSION['person_id']); ?></strong></p>

        <?php if ($db_error): ?>
            <div class="error">
                <?php echo htmlspecialchars($db_error); ?>
            </div>
        
        <?php elseif (empty($gefangene)): ?>
            <div class="error">
                Hinweis: Sie müssen sich zuerst für einen Gefangenen validieren lassen.
            </div>
            
        <?php else: ?>
            <p><strong>Ihre freigeschalteten Gefangenen:</strong></p>
            
            <div class="gefangene-liste">
                <?php foreach ($gefangene as $g): ?>
                    <details class="gefangene-box">
                        <summary>
                            <?php echo htmlspecialchars($g['VORNAME'] . ' ' . $g['NACHNAME']); ?>
                        </summary>
                        <div class="gefangene-box-inhalt">
                            <p>Hier stehen später die Termine, an denen der Gefangene Zeit hat.</p>
                        </div>
                    </details>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>

        <a href="user_logout.php" class="logout-link">Logout</a>
    </div>
</body>
</html>