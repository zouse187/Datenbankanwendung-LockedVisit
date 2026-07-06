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
// Zusätzlich: Lade die Liste aller validierten Gefangenen für diesen Besucher
require_once __DIR__ . '/../config/db.php';
$validGefangene = [];
$bookingErrorMessage = '';

$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);
if ($connResult['success']) {
    $conn = $connResult['conn'];
    $stid = oci_parse($conn, 'SELECT b.BESUCHER_ID FROM BESUCHER b WHERE b.PERSON_ID = :pid');
    oci_bind_by_name($stid, ':pid', $_SESSION['person_id']);
    oci_execute($stid);
    $besucherRow = oci_fetch_assoc($stid);

    if ($besucherRow) {
        $besucherId = $besucherRow['BESUCHER_ID'];
        $stid = oci_parse($conn, '
            SELECT g.GEFANGENER_ID, p.VORNAME, p.NACHNAME
            FROM VALIDIERTE_BESUCHER vb
            JOIN GEFANGENER g ON vb.GEFANGENER_ID = g.GEFANGENER_ID
            JOIN PERSON p ON g.PERSON_ID = p.PERSON_ID
            WHERE vb.BESUCHER_ID = :bid
            ORDER BY p.NACHNAME, p.VORNAME');
        oci_bind_by_name($stid, ':bid', $besucherId);
        oci_execute($stid);

        while (($row = oci_fetch_assoc($stid)) !== false) {
            $validGefangene[] = $row;
        }
    } else {
        $bookingErrorMessage = 'Ihre Besucher-ID konnte nicht geladen werden.';
    }
} else {
    $bookingErrorMessage = 'Datenbank-Verbindung zum Laden der Gefangenen fehlgeschlagen.';
}

if (!empty($_SESSION['booking_error'])) {
    $bookingErrorMessage = htmlspecialchars($_SESSION['booking_error']);
    unset($_SESSION['booking_error']);
}

if (!empty($_SESSION['booking_success'])) {
    $bookingSuccessMessage = htmlspecialchars($_SESSION['booking_success']);
    unset($_SESSION['booking_success']);
} else {
    $bookingSuccessMessage = '';
}
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

        <!-- Zeige mögliche Fehlermeldungen oder Bestätigung -->
        <?php if (!empty($bookingErrorMessage)): ?>
            <div class="error"><?php echo $bookingErrorMessage; ?></div>
        <?php endif; ?>

        <?php if (!empty($bookingSuccessMessage)): ?>
            <div class="success"><?php echo $bookingSuccessMessage; ?></div>
        <?php endif; ?>

        <!-- Einfaches Formular für die Validierung -->
        <h2>Besuch buchen</h2>
        <form action="../controllers/validate_booking.php" method="post">
            <label for="gefangener_id">Gefangener</label>
            <select id="gefangener_id" name="gefangener_id" required>
                <option value="">Bitte Gefangenen wählen</option>
                <?php foreach ($validGefangene as $gefangener): ?>
                    <option value="<?php echo htmlspecialchars($gefangener['GEFANGENER_ID']); ?>">
                        <?php echo htmlspecialchars($gefangener['NACHNAME'] . ', ' . $gefangener['VORNAME']); ?>
                    </option>
                <?php endforeach; ?>
            </select>

            <?php if (empty($validGefangene)): ?>
                <p>Aktuell dürfen Sie keinen Gefangenen besuchen oder die Liste konnte nicht geladen werden.</p>
            <?php endif; ?>

            <label for="gebaeude_id">Gebäude-ID (optional)</label>
            <input type="number" id="gebaeude_id" name="gebaeude_id">

            <label for="besuch_datum">Datum</label>
            <input type="date" id="besuch_datum" name="besuch_datum" required>

            <button type="submit" <?php echo empty($validGefangene) ? 'disabled' : ''; ?>>Validieren</button>
        </form>

        <a href="user_logout.php">Logout</a>
    </div>
</body>
</html>
