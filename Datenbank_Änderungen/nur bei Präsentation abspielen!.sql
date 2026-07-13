-- 1. Alle offenen Anträge in die Tabelle der dauerhaft berechtigten Besucher kopieren
INSERT INTO VALIDIERTE_BESUCHER (BESUCHER_ID, GEFANGENER_ID)
SELECT BESUCHER_ID, GEFANGENER_ID 
FROM BESUCHER_VALIDIERUNG;

-- 2. Den Warteraum leeren (da jetzt alle genehmigt sind)
DELETE FROM BESUCHER_VALIDIERUNG;

-- 3. Speichern, damit PHP die Änderungen sieht!
COMMIT;