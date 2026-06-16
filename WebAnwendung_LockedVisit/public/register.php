<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Registrierung</title>
    <link rel="stylesheet" href="../assets/style.css">
    
    <script>
        // Blendet je nach Checkbox die passenden Felder ein oder aus
        function toggleRoleFields() {
            // Prüft, ob das Häkchen bei "Ich bin Mitarbeiter" gesetzt ist (true oder false)
            const isMitarb = document.getElementById('ist_mitarbeiter').checked;
            
            // Wenn angehakt: Zeige Mitarbeiter-Felder, verstecke Besucher-Felder (und umgekehrt)
            document.getElementById('mitarbeiter_fields').style.display = isMitarb ? 'block' : 'none';
            document.getElementById('besucher_fields').style.display = isMitarb ? 'none' : 'block';
        }
    </script>
</head>
<body onload="toggleRoleFields()">
<div class="login-container">
    <h1>Registrierung</h1>

    <?php if (!empty($_GET['error'])): ?>
        <div class="error">
            <?= htmlspecialchars($_GET['error']) ?>
        </div>
    <?php endif; ?>

    <form action="../controllers/register_check.php" method="post">
        
        <label>Vorname</label>
        <input type="text" name="vorname" required>

        <label>Nachname</label>
        <input type="text" name="nachname" required>

        <label>Geburtsdatum</label>
        <input type="date" name="geburtsdatum" required>

        <label>Geschlecht</label>
        <input type="text" name="geschlecht">

        <label>Telefon</label>
        <input type="text" name="telefon">

        <label>E-Mail</label>
        <input type="email" name="email" required>

        <label>Passwort</label>
        <input type="password" name="passwort" required>

        <label class="checkbox-row">
            <input type="checkbox" id="ist_mitarbeiter" name="ist_mitarbeiter" value="1" onchange="toggleRoleFields()">
            <span>Ich bin Mitarbeiter</span>
        </label>

        <div id="mitarbeiter_fields">
            <h3>Mitarbeiterdaten</h3>
            <label for="standort">Standort</label>
            <select name="ang_standort_id" id="standort">
                <option value="1">JVA Berlin</option>
                <option value="2">JVA Minden</option>
            </select>

            <label>Rolle</label>
            <input type="text" name="ang_rolle">

            <label>Straße</label>
            <input type="text" name="ang_strasse">

            <label>PLZ</label>
            <input type="text" name="ang_plz">

            <label>Ort</label>
            <input type="text" name="ang_ort">
        </div>

        <div id="besucher_fields">
            <h3>Besucherdaten</h3>
            <label>Straße</label>
            <input type="text" name="bes_strasse">

            <label>PLZ</label>
            <input type="text" name="bes_plz">

            <label>Ort</label>
            <input type="text" name="bes_ort">
        </div>

        <button type="submit">Registrieren</button>
    </form>

    <p><a href="user_login.php">Zurück zur Anmeldung</a></p>
</div>
</body>
</html>