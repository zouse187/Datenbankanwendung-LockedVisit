<?php
// Erwartet $conn (Datenbankverbindung) und $g_id (Gefangenen-ID) aus der aufrufenden Datei.

$dropdownOptions = "";
$hatUeberhauptSlots = false;

if ($conn && isset($g_id)) {
    
    // 1. Termine über die neue Stored Procedure holen
    $stmt = oci_parse($conn, "BEGIN GET_GEFANGENEN_TERMINE(:p_g_id, :p_cursor); END;");
    $cursor = oci_new_cursor($conn);
    
    oci_bind_by_name($stmt, ':p_g_id', $g_id);
    oci_bind_by_name($stmt, ':p_cursor', $cursor, -1, OCI_B_CURSOR);
    
    if (oci_execute($stmt)) {
        oci_execute($cursor);
        
        while ($row = oci_fetch_assoc($cursor)) {
            $hatUeberhauptSlots = true;
            
            $terminZeitRaw = $row['TERMIN_ZEIT']; // Format: 'YYYY-MM-DD HH24:MI'
            $istGebucht    = (int)$row['GEBUCHT']; // 1 oder 0
            
            // Datum lesbar für den Besucher formatieren (z. B. "16.07.2026 um 14:00 Uhr")
            $dateObj = new DateTime($terminZeitRaw);
            $anzeigeFormat = $dateObj->format('d.m.Y \u\m H:i') . ' Uhr';
            
            // Value-Format für das Formular (z. B. "2026-07-16T14:00")
            $valueFormat = $dateObj->format('Y-m-d\TH:i');

            // Direkt anhand des DB-Wertes entscheiden, ob belegt oder frei
            if ($istGebucht === 1) {
                // Belegter Termin -> Gesperrt anzeigen
                $dropdownOptions .= "<option disabled>❌ $anzeigeFormat (Bereits belegt)</option>";
            } else {
                // Freier Termin -> Auswählbar
                $dropdownOptions .= "<option value=\"$valueFormat\">✅ $anzeigeFormat</option>";
            }
        }
        oci_free_statement($cursor);
    }
    oci_free_statement($stmt);
}