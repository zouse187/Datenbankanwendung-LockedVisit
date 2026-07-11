<?php
// Bindet die Backend-Logik ein. Der Controller prüft auch direkt die Session-Rechte.
require_once __DIR__ . '/../controllers/get_gefangene.php';
require_once __DIR__ . '/../controllers/get_validierung_gefangene.php';
require_once __DIR__ . '/../controllers/get_offene_validierungen.php';

$successMessage = $_GET['success'] ?? '';
$errorMessage = $_GET['error'] ?? '';
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
    <div class="login-container">
        <h1>Willkommen Besucher!</h1>

        <p>Ihre Person-ID lautet: <strong><?php echo htmlspecialchars($_SESSION['person_id']); ?></strong></p>

        <?php if ($successMessage !== ''): ?>
            <div class="success">
                <?php echo htmlspecialchars($successMessage); ?>
            </div>
        <?php endif; ?>

        <?php if ($errorMessage !== ''): ?>
            <div class="error">
                <?php echo htmlspecialchars($errorMessage); ?>
            </div>
        <?php endif; ?>

        <?php if ($db_error): ?>
            <div class="error">
                <?php echo htmlspecialchars($db_error); ?>
            </div>
        <?php else: ?>
        
            <h2>Validierungsantrag stellen</h2>

        <?php if (empty($gefangeneFuerValidierung)): ?>

        <p>Es stehen keine weiteren Gefangenen zur Auswahl.</p>

        <?php else: ?>

    <form
        action="../controllers/validation_request.php"
        method="post"
    >

<label for="gefangenerId">Gefangenen auswählen</label>

<select
    id="gefangenerId"
    name="gefangener_id"
    required
>
    <option value="" selected disabled>Bitte auswählen</option>

    <?php foreach ($gefangeneFuerValidierung as $gefangener): ?>
        <option value="<?php echo (int) $gefangener['GEFANGENER_ID']; ?>">
            <?php
            echo htmlspecialchars(
                $gefangener['VORNAME'] . ' ' . $gefangener['NACHNAME']
            );
            ?>
        </option>
    <?php endforeach; ?>
    </select>

        <button type="submit">
            Validierungsantrag stellen
        </button>
    </form>

<?php endif; ?>

        <h2>Offene Validierungsanträge</h2>

        <?php if (empty($offeneValidierungen)): ?>

            <p>Sie haben aktuell keine offenen Anträge.</p>

        <?php else: ?>
            <div class="gefangene-liste">
                <?php foreach ($offeneValidierungen as $g): ?>
                    <div class="gefangene-box">
                        <?php
                            echo htmlspecialchars(
                            $g['VORNAME'] . ' ' . $g['NACHNAME']
                            );
                        ?>

                    <span class="status-offen">
                    Antrag ausstehend
                </span>
            </div>
        <?php endforeach; ?>
        </div>

        <?php endif; ?>

        <h2>Gefangene, für die Sie validiert sind</h2>
        <?php if (empty($gefangene)): ?>
            <div class="error">
                Hinweis: Sie müssen sich zuerst für einen Gefangenen validieren lassen.
            </div>
            
        <?php else: ?>
            
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
        
        <?php endif; ?>

        <a href="user_logout.php" class="logout-link">Logout</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"></script>

<script>
const gefangenenAuswahl = document.getElementById('gefangenerId');

if (gefangenenAuswahl) {
    new TomSelect(gefangenenAuswahl, {
        create: false,
        sortField: {
            field: 'text',
            direction: 'asc'
        },
        maxOptions: 1000,
        placeholder: 'Gefangenen suchen oder auswählen...'
    });
}
</script>
</body>
</html>