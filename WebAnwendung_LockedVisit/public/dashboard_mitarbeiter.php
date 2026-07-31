<?php
session_start();

// 1. Pfad zur db.php (Eine Ebene nach oben aus 'public/' heraus in 'config/')
require_once __DIR__ . '/../config/db.php';

// Prüfen, ob der Nutzer eingeloggt ist
if (!isset($_SESSION['db_user']) || !isset($_SESSION['db_pass'])) {
    // Falls user_login.php im selben public-Ordner liegt:
    header('Location: user_login.php');
    exit;
}

// Verbindung zur Oracle-Datenbank aufbauen
$connResult = db_connect($_SESSION['db_user'], $_SESSION['db_pass']);

if (!$connResult['success']) {
    die("<div class='error' style='color:red; text-align:center; padding:20px;'>Datenbankverbindung fehlgeschlagen: " . htmlspecialchars($connResult['error']) . "</div>");
}
$conn = $connResult['conn'];


// =============================================================================
// FORMULARVERARBEITUNG (Stored Procedures)
// =============================================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {

    // PROZESS 1: Besucher-Validierung (Antrag annehmen oder ablehnen)
    if ($_POST['action'] === 'bearbeite_antrag') {
        $besucher_id   = (int)$_POST['besucher_id'];
        $gefangener_id = (int)$_POST['gefangener_id'];
        $entscheidung  = (int)$_POST['entscheidung']; // 1 = Annehmen, 0 = Ablehnen

        $proc_sql = "BEGIN VALIDIERUNGSANTRAG_BEARBEITEN(:p_bes_id, :p_gef_id, :p_entscheidung, :p_ok, :p_meldung); END;";
        $stmt = oci_parse($conn, $proc_sql);

        oci_bind_by_name($stmt, ':p_bes_id', $besucher_id);
        oci_bind_by_name($stmt, ':p_gef_id', $gefangener_id);
        oci_bind_by_name($stmt, ':p_entscheidung', $entscheidung);
        oci_bind_by_name($stmt, ':p_ok', $ok, 10);
        oci_bind_by_name($stmt, ':p_meldung', $meldung, 200);

        oci_execute($stmt);
        oci_free_statement($stmt);

        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }

    // PROZESS 2: Gefangenenstatus verwalten (Besuchbar umschalten)
    if ($_POST['action'] === 'toggle_status') {
        $gefangener_id   = (int)$_POST['gefangener_id'];
        $aktueller_status = (int)$_POST['aktueller_status'];
        
        $neuer_status = ($aktueller_status === 1) ? 0 : 1;

        $proc_sql = "BEGIN UPDATE_BESUCHBAR_STATUS(:p_id, :p_status); END;";
        $stmt = oci_parse($conn, $proc_sql);

        oci_bind_by_name($stmt, ':p_id', $gefangener_id);
        oci_bind_by_name($stmt, ':p_status', $neuer_status);

        oci_execute($stmt);
        oci_free_statement($stmt);

        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }
}


// =============================================================================
// DATEN AUS DER DATENBANK LADEN
// =============================================================================

// Prozess 1: Offene Validierungsanträge
$antraege = [];
$sql_antraege = "SELECT va.BESUCHER_ID, 
                        p_bes.VORNAME AS BESUCHER_VORNAME, 
                        p_bes.NACHNAME AS BESUCHER_NACHNAME,
                        va.GEFANGENER_ID, 
                        p_gef.VORNAME AS GEFANGENER_VORNAME, 
                        p_gef.NACHNAME AS GEFANGENER_NACHNAME
                 FROM VALIDIERUNGSANTRAG va
                 JOIN BESUCHER b ON va.BESUCHER_ID = b.BESUCHER_ID
                 JOIN PERSON p_bes ON b.PERSON_ID = p_bes.PERSON_ID
                 JOIN GEFANGENER g ON va.GEFANGENER_ID = g.GEFANGENER_ID
                 JOIN PERSON p_gef ON g.PERSON_ID = p_gef.PERSON_ID
                 WHERE va.VALIDIERT = 0
                 ORDER BY p_bes.NACHNAME ASC";

$stmt_antraege = oci_parse($conn, $sql_antraege);
if (oci_execute($stmt_antraege)) {
    while ($row = oci_fetch_assoc($stmt_antraege)) {
        $antraege[] = $row;
    }
}
oci_free_statement($stmt_antraege);


// Prozess 2: Liste aller Gefangenen mit Status
$gefangene = [];
$sql_gefangene = "SELECT g.GEFANGENER_ID, p.VORNAME, p.NACHNAME, g.BESUCHBAR 
                  FROM GEFANGENER g 
                  JOIN PERSON p ON g.PERSON_ID = p.PERSON_ID 
                  ORDER BY p.NACHNAME ASC, p.VORNAME ASC";

$stmt_gefangene = oci_parse($conn, $sql_gefangene);
if (oci_execute($stmt_gefangene)) {
    while ($row = oci_fetch_assoc($stmt_gefangene)) {
        $gefangene[] = $row;
    }
}
oci_free_statement($stmt_gefangene);

oci_close($conn);
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mitarbeiter - Dashboard</title>
    <link rel="stylesheet" href="../assets/style.css">
    <style>
        .section-box {
            background: #2A2A2A;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 30px;
        }
        .section-title {
            color: #FE731F;
            margin-top: 0;
            border-bottom: 2px solid #FE731F;
            padding-bottom: 8px;
        }
        .action-btns {
            display: flex;
            gap: 8px;
            justify-content: center;
        }
    </style>
</head>
<body>

<div class="login-container dashboard-container" style="max-width: 850px; margin-top: 40px;">
    <h2>Mitarbeiter-Dashboard</h2>
    <div class="info-box" style="margin-bottom: 25px;">
        Willkommen im Mitarbeiterbereich. Hier können Sie Besucheranträge prüfen sowie den Besuchbar-Status der Insassen verwalten.
    </div>

    <div class="section-box">
        <h3 class="section-title">1. Offene Besucher-Validierungsanträge</h3>
        
        <?php if (empty($antraege)): ?>
            <p style="color: #bbb; font-style: italic;">Aktuell liegen keine offenen Validierungsanträge vor.</p>
        <?php else: ?>
            <table>
                <thead>
                    <tr>
                        <th>Besucher</th>
                        <th>Möchte besuchen</th>
                        <th style="text-align: center;">Aktion</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($antraege as $a): ?>
                        <tr>
                            <td><?= htmlspecialchars($a['BESUCHER_VORNAME'] . ' ' . $a['BESUCHER_NACHNAME']) ?> (ID: <?= $a['BESUCHER_ID'] ?>)</td>
                            <td><?= htmlspecialchars($a['GEFANGENER_VORNAME'] . ' ' . $a['GEFANGENER_NACHNAME']) ?> (ID: <?= $a['GEFANGENER_ID'] ?>)</td>
                            <td>
                                <div class="action-btns">
                                    <form method="POST">
                                        <input type="hidden" name="action" value="bearbeite_antrag">
                                        <input type="hidden" name="besucher_id" value="<?= $a['BESUCHER_ID'] ?>">
                                        <input type="hidden" name="gefangener_id" value="<?= $a['GEFANGENER_ID'] ?>">
                                        <input type="hidden" name="entscheidung" value="1">
                                        <button type="submit" class="btn-green" style="padding: 6px 12px; width: auto;">Annehmen</button>
                                    </form>
                                    <form method="POST">
                                        <input type="hidden" name="action" value="bearbeite_antrag">
                                        <input type="hidden" name="besucher_id" value="<?= $a['BESUCHER_ID'] ?>">
                                        <input type="hidden" name="gefangener_id" value="<?= $a['GEFANGENER_ID'] ?>">
                                        <input type="hidden" name="entscheidung" value="0">
                                        <button type="submit" class="btn-red" style="padding: 6px 12px; width: auto;">Ablehnen</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>

    <div class="section-box">
        <h3 class="section-title">2. Gefangenenstatus verwalten (Besuchbar)</h3>
        
        <?php if (empty($gefangene)): ?>
            <p style="color: #bbb; font-style: italic;">Keine Gefangenen in der Datenbank gefunden.</p>
        <?php else: ?>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Vorname</th>
                        <th>Nachname</th>
                        <th style="text-align: center;">Status (Klicken zum Ändern)</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($gefangene as $g): 
                        $besuchbar = (int)$g['BESUCHBAR'];
                        $btn_class = ($besuchbar === 1) ? 'btn-green' : 'btn-red';
                        $btn_text  = ($besuchbar === 1) ? 'Besuchbar' : 'Nicht besuchbar';
                    ?>
                        <tr>
                            <td><?= $g['GEFANGENER_ID'] ?></td>
                            <td><?= htmlspecialchars($g['VORNAME']) ?></td>
                            <td><?= htmlspecialchars($g['NACHNAME']) ?></td>
                            <td style="text-align: center;">
                                <form method="POST">
                                    <input type="hidden" name="action" value="toggle_status">
                                    <input type="hidden" name="gefangener_id" value="<?= $g['GEFANGENER_ID'] ?>">
                                    <input type="hidden" name="aktueller_status" value="<?= $besuchbar ?>">
                                    <button type="submit" class="<?= $btn_class ?>" style="padding: 6px 14px; width: auto;">
                                        <?= $btn_text ?>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>

    <a href="logout.php" class="logout-link">Abmelden</a>
</div>

</body>
</html>