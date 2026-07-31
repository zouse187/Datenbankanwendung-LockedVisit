<?php
// Session starten, um auf die beim Login gespeicherten Zugangsdaten zuzugreifen
session_start();

// 1. Eure Verbindungsfunktion aus config/db.php einbinden
require_once 'config/db.php';

// 2. Zugangsdaten aus der Session auslesen
$db_user = $_SESSION['db_user'] ?? $_SESSION['username'] ?? null;
$db_pass = $_SESSION['db_pass'] ?? $_SESSION['password'] ?? null;

// Falls kein Nutzer eingeloggt ist, zurück zur Login-Seite
if (!$db_user || !$db_pass) {
    header('Location: index.php');
    exit;
}

// Datenbankverbindung aufbauen
$db = db_connect($db_user, $db_pass);

if (!$db['success']) {
    die("<div class='error'>Datenbankfehler: " . htmlspecialchars($db['error']) . "</div>");
}
$conn = $db['conn'];

// -----------------------------------------------------------------------------
// 3. FORMULARVERARBEITUNG (Status-Änderung per Stored Procedure)
// -----------------------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['toggle_status'])) {
    $gefangener_id   = (int)$_POST['gefangener_id'];
    $aktueller_status = (int)$_POST['aktueller_status'];
    
    // Status umkehren: 1 (Besuchbar) wird zu 0, 0 (Nicht besuchbar) wird zu 1
    $neuer_status = ($aktueller_status === 1) ? 0 : 1;

    // Aufruf der Stored Procedure in Oracle PL/SQL
    $proc_sql = "BEGIN UPDATE_BESUCHBAR_STATUS(:p_id, :p_status); END;";
    $proc_stmt = oci_parse($conn, $proc_sql);
    
    // Parameter an die Stored Procedure binden
    oci_bind_by_name($proc_stmt, ':p_id', $gefangener_id);
    oci_bind_by_name($proc_stmt, ':p_status', $neuer_status);
    
    // Stored Procedure ausführen
    $execute_success = oci_execute($proc_stmt);
    
    if (!$execute_success) {
        $e = oci_error($proc_stmt);
        die("<div class='error'>Fehler bei der Statusänderung: " . htmlspecialchars($e['message']) . "</div>");
    }
    
    oci_free_statement($proc_stmt);
    
    // Seite neu laden (verhindert erneutes Senden beim Aktualisieren mit F5)
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// -----------------------------------------------------------------------------
// 4. DATEN ABRUFEN (Gefangene mit Vor- und Nachnamen laden)
// -----------------------------------------------------------------------------
$sql = "SELECT g.GEFANGENER_ID, p.VORNAME, p.NACHNAME, g.BESUCHBAR 
        FROM GEFANGENER g 
        JOIN PERSON p ON g.PERSON_ID = p.PERSON_ID 
        ORDER BY p.NACHNAME ASC, p.VORNAME ASC";

$stmt = oci_parse($conn, $sql);
oci_execute($stmt);
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mitarbeiter - Gefangenenstatus verwalten</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>

<div class="login-container dashboard-container" style="max-width: 750px;">
    <h2>Gefangenenstatus verwalten</h2>
    <div class="info-box">
        Hier können Sie den Besuchbar-Status der Insassen festlegen. Klicken Sie auf den Button, um den Status zu ändern.
    </div>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Vorname</th>
                <th>Nachname</th>
                <th style="text-align: center;">Status / Aktion</th>
            </tr>
        </thead>
        <tbody>
            <?php
            // Zeile für Zeile durchgehen
            while ($row = oci_fetch_assoc($stmt)) {
                $g_id      = $row['GEFANGENER_ID'];
                $vorname   = htmlspecialchars($row['VORNAME']);
                $nachname  = htmlspecialchars($row['NACHNAME']);
                $besuchbar = (int)$row['BESUCHBAR']; // 1 = Besuchbar, 0 = Nicht besuchbar

                // Button-Farbe und Beschriftung anhand eurer style.css festlegen
                if ($besuchbar === 1) {
                    $btn_class = 'btn-green';
                    $btn_text  = 'Besuchbar';
                } else {
                    $btn_class = 'btn-red';
                    $btn_text  = 'Nicht besuchbar';
                }

                echo "<tr>";
                echo "<td>{$g_id}</td>";
                echo "<td>{$vorname}</td>";
                echo "<td>{$nachname}</td>";
                echo "<td style='text-align: center;'>
                        <form method='POST' class='action-form' style='justify-content: center;'>
                            <input type='hidden' name='gefangener_id' value='{$g_id}'>
                            <input type='hidden' name='aktueller_status' value='{$besuchbar}'>
                            <button type='submit' name='toggle_status' class='{$btn_class}'>
                                {$btn_text}
                            </button>
                        </form>
                      </td>";
                echo "</tr>";
            }

            oci_free_statement($stmt);
            oci_close($conn);
            ?>
        </tbody>
    </table>

    <a href="logout.php" class="logout-link">Abmelden / Zurück</a>
</div>

</body>
</html>