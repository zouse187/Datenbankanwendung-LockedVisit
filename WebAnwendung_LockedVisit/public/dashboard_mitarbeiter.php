<?php
session_start();
// Binde den Controller ein, der die Daten holt und Aktionen verarbeitet
require_once __DIR__ . '/../controllers/antrag_bearbeiten.php';

// Absicherung direkt im View
if (!isset($_SESSION['person_id']) || $_SESSION['rolle'] !== 'ANGESTELLTER') {
    header("Location: user_login.php?error=Bitte als Mitarbeiter anmelden");
    exit;
}

// Daten holen via Controller-Funktion (Reines Frontend-Daten-Binding)
$antraege = getOffeneAntraege();
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Mitarbeiter Dashboard - Validierungen</title>
    <link rel="stylesheet" href="../assets/style.css">
    <link rel="stylesheet" href="../assets/dashboard_mitarbeiter.css">
</head>
<body>
    <div class="login-container" style="max-width: 750px;">
        <h1>Mitarbeiter Dashboard</h1>
        <p style="color: #ccc;">Eingeloggt als Mitarbeiter-ID: <strong><?= htmlspecialchars($_SESSION['person_id']) ?></strong></p>
        
        <?php if (!empty($_GET['success'])): ?>
            <div class="success"><?= htmlspecialchars($_GET['success']) ?></div>
        <?php endif; ?>
        <?php if (!empty($_GET['error'])): ?>
            <div class="error"><?= htmlspecialchars($_GET['error']) ?></div>
        <?php endif; ?>

        <div class="dashboard-section" style="margin-top: 20px;">
            <h2>Offene Validierungsanträge</h2>
            <p style="font-size: 0.9em; color: #ccc; margin-bottom: 15px;">
                Hier sehen Sie die Anträge von Besuchern, die eine Freigabe für einen Gefangenen angefordert haben.
            </p>
            
            <?php if (empty($antraege)): ?>
                <p style="color: #888; font-style: italic;">Es liegen aktuell keine offenen Anträge vor.</p>
            <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>Besucher (ID)</th>
                            <th>Gefangener (ID)</th>
                            <th>Aktion</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($antraege as $antrag): ?>
                            <tr>
                                <td>
                                    <strong style="color: #fff;"><?= htmlspecialchars($antrag['BESUCHER_NAME']) ?></strong> 
                                    <br><span style="font-size: 0.85em; color: #aaa;">ID: <?= $antrag['BESUCHER_ID'] ?></span>
                                </td>
                                <td>
                                    <strong style="color: #fff;"><?= htmlspecialchars($antrag['GEFANGENER_NAME']) ?></strong> 
                                    <br><span style="font-size: 0.85em; color: #aaa;">ID: <?= $antrag['GEFANGENER_ID'] ?></span>
                                </td>
                                <td>
                                    <form action="../controllers/antrag_bearbeiten.php" method="post" class="action-form">
                                        <input type="hidden" name="action_type" value="bearbeiten">
                                        <input type="hidden" name="besucher_id" value="<?= $antrag['BESUCHER_ID'] ?>">
                                        <input type="hidden" name="gefangener_id" value="<?= $antrag['GEFANGENER_ID'] ?>">
                                        
                                        <button type="submit" name="action" value="annehmen" class="btn-green">Annehmen</button>
                                        <button type="submit" name="action" value="ablehnen" class="btn-red">Ablehnen</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
        
        <a href="user_logout.php" class="logout-link">Logout</a>
    </div>
</body>
</html>
