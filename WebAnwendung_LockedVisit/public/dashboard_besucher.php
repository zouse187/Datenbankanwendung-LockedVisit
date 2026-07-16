<?php
// Bindet die Backend-Logik ein.
require_once __DIR__ . '/../controllers/get_gefangene.php';
require_once __DIR__ . '/../controllers/get_validierung_gefangene.php';
require_once __DIR__ . '/../controllers/get_offene_validierungen.php';

$successMessage = $_GET['success'] ?? '';
$errorMessage = $_GET['error'] ?? '';

// Falls die Verbindung vorliegt, holen wir uns das Verbindungsobjekt für optionale Direktabfragen
require_once __DIR__ . '/../config/db.php';
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);
$conn = $connResult['success'] ? $connResult['conn'] : null;
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/css/tom-select.css" rel="stylesheet">
    <meta charset="UTF-8">
    <title>Besucher Dashboard</title>
    <link rel="stylesheet" href="../assets/style.css">
</head>
<body>
    <div class="login-container" style="max-width: 700px;"> <h1>Willkommen Besucher!</h1>
        <p>Ihre Person-ID lautet: <strong><?php echo htmlspecialchars($_SESSION['person_id']); ?></strong></p>

        <?php if ($successMessage !== ''): ?>
            <div class="success"><?php echo htmlspecialchars($successMessage); ?></div>
        <?php endif; ?>

        <?php if ($errorMessage !== ''): ?>
            <div class="error"><?php echo htmlspecialchars($errorMessage); ?></div>
        <?php endif; ?>


        <!-- BEREICH 1: Weitere Gefangene validieren (Mit Suchfeld) -->
        <div class="dashboard-section" style="margin-top: 20px; padding: 15px; background: #333; border-radius: 4px; border: 1px solid #4a4a4a;">
            <h2>Weitere Gefangene validieren</h2>
            <p style="font-size: 0.9em; color: #ccc; margin-bottom: 15px;">Suchen Sie nach einem Gefangenen, um einen neuen Validierungsantrag zu senden.</p>

            <?php if (empty($gefangeneFuerValidierung)): ?>
                <p style="color: #888; font-style: italic;">Aktuell stehen keine weiteren Gefangenen zur Auswahl.</p>
            <?php else: ?>
                <form action="../controllers/validation_request.php" method="post">
                    <input type="hidden" name="person_id" value="<?php echo (int)$_SESSION['person_id']; ?>">
                    
                    <label for="neuerGefangenerId" style="margin-bottom: 5px; display: block;">Gefangenen suchen:</label>
                    <select id="neuerGefangenerId" name="gefangener_id" required style="width: 100%; box-sizing: border-box;">
                        <option value="" selected disabled>Name eingeben zum Suchen...</option>
                        <?php foreach ($gefangeneFuerValidierung as $gefangener): ?>
                            <option value="<?php echo (int)$gefangener['GEFANGENER_ID']; ?>">
                                <?php echo htmlspecialchars($gefangener['VORNAME'] . ' ' . $gefangener['NACHNAME'] . ' (ID: ' . $gefangener['GEFANGENER_ID'] . ')'); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>

                    <button type="submit" style="margin-top: 15px; background: #FE731F; width: 100%; padding: 10px; color: white; border: none; border-radius: 4px; cursor: pointer;">
                        Validierungsantrag absenden
                    </button>
                </form>
            <?php endif; ?>
        </div>


        <div class="dashboard-section" style="margin-top: 20px; padding: 15px; background: #333; border-radius: 4px;">
            <h2>Offene Validierungsanträge</h2>
            <?php 
            // Falls get_offene_validierungen.php gescheitert ist, zeigen wir den Fehler NUR hier an
            if (isset($db_error) && strpos($db_error, 'offenen') !== false): ?>
                <div class="error" style="margin-bottom: 0;"><?php echo htmlspecialchars($db_error); ?></div>
            <?php else: ?>
                <?php if (empty($offeneValidierungen)): ?>
                    <p>Sie haben aktuell keine offenen Anträge.</p>
                <?php else: ?>
                    <div class="gefangene-liste">
                        <?php foreach ($offeneValidierungen as $g): ?>
                            <div class="gefangene-box" style="display: flex; justify-content: space-between; align-items: center;">
                                <span><?php echo htmlspecialchars($g['VORNAME'] . ' ' . $g['NACHNAME']); ?></span>
                                <span class="status-offen">Antrag ausstehend</span>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            <?php endif; ?>
        </div>  
        


        <div class="dashboard-section" style="margin-top: 20px; padding: 15px; background: #333; border-radius: 4px;">
            <h2>Gefangene, für die Sie validiert sind</h2>
        
        <?php if (empty($gefangene)): ?>
            <div class="info-box" style="background: rgba(254, 115, 31, 0.1); border-left: 4px solid #FE731F; padding: 10px;">
                Hinweis: Sie müssen sich zuerst für einen Gefangenen validieren lassen oder auf die Freigabe warten.
            </div>
        <?php else: ?>
            <div class="gefangene-liste">
                <?php foreach ($gefangene as $g): ?>
                    <details class="gefangene-box">
                        <summary>
                            <?php echo htmlspecialchars($g['VORNAME'] . ' ' . $g['NACHNAME']); ?>
                            <span class="status-validiert" style="margin-left: auto;">Berechtigt</span>
                        </summary>
                        
                        <div class="gefangene-box-inhalt" style="padding-top: 10px;">
                            <?php
                            $g_id = (int)$g['GEFANGENER_ID'];
                            
                            include '../controllers/get_termine.php'; 
                            ?>

                            <?php if (!$hatUeberhauptSlots || empty($dropdownOptions)): ?>
                                <p style="color: #ccc; font-style: italic;">Dieser Gefangener ist zur Zeit leider nicht besuchbar.</p>
                            <?php else: ?>
                                <form action="../controllers/termin_buchen.php" method="post" style="border-top: 1px solid #444; padding-top: 10px;">
                                    <input type="hidden" name="gefangener_id" value="<?php echo $g_id; ?>">
                                    
                                    <label for="datum_<?php echo $g_id; ?>" style="margin-bottom: 5px; display:block;">Verfügbare Termine:</label>
                                    
                                    <select id="datum_<?php echo $g_id; ?>" name="datum" required style="margin-bottom: 12px; background: #ffffff; color: #000000; padding: 8px; border-radius: 4px; border: 1px solid #ccc; width: 100%; box-sizing: border-box;">
                                        <option value="" selected disabled>Bitte Termin auswählen...</option>
                                        <?php echo $dropdownOptions; ?>
                                    </select>
                                    
                                    <button type="submit" style="background: #32b450; width: 100%; padding: 10px; color: white; border: none; border-radius: 4px; cursor: pointer;">Termin verbindlich buchen</button>
                                </form>
                            <?php endif; ?>
                        </div> 
                    </details> 
                <?php endforeach; ?> 
            </div> 
        <?php endif; ?> 
        
        <a href="user_logout.php" class="logout-link">Logout</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"></script>
    <script>
    // ==========================================
    // Logik für das Such-Dropdown (TomSelect)
    // ==========================================
    const gefangenenAuswahl = document.getElementById('gefangenerId');
    if (gefangenenAuswahl) {
        new TomSelect(gefangenenAuswahl, {
            create: false,
            sortField: { field: 'text', direction: 'asc' },
            maxOptions: 1000,
            placeholder: 'Gefangenen suchen oder auswählen...'
        });
    }
    </script>
</body>
</html>