-- Erstellt oder überschreibt die Prozedur zur Abfrage der Gefangenen für die Validierung
CREATE OR REPLACE PROCEDURE GET_GEFANGENE_FUER_VALIDIERUNG (
   p_person_id IN NUMBER,
   p_cursor    OUT SYS_REFCURSOR
)
AS
BEGIN
   OPEN p_cursor FOR
       SELECT
           g.GEFANGENER_ID,
           p.VORNAME,
           p.NACHNAME
       FROM GEFANGENER g
       JOIN PERSON p ON p.PERSON_ID = g.PERSON_ID
       WHERE g.BESUCHBAR = 1
         -- Bedingung 1: Es läuft kein offener Antrag in BESUCHER_VALIDIERUNG
         AND NOT EXISTS (
             SELECT 1
             FROM BESUCHER b
             JOIN BESUCHER_VALIDIERUNG bv ON bv.BESUCHER_ID = b.BESUCHER_ID
             WHERE b.PERSON_ID = p_person_id
               AND bv.GEFANGENER_ID = g.GEFANGENER_ID
         )
         -- Bedingung 2: Man ist für diesen Gefangenen nicht schon validiert
         AND NOT EXISTS (
             SELECT 1
             FROM BESUCHER b
             JOIN VALIDIERTE_BESUCHER vb ON vb.BESUCHER_ID = b.BESUCHER_ID
             WHERE b.PERSON_ID = p_person_id
               AND vb.GEFANGENER_ID = g.GEFANGENER_ID
         )
       ORDER BY p.NACHNAME, p.VORNAME;
END;
/



-- Erstellt oder überschreibt die Prozedur zur Abfrage der offenen Validierungsanträge
CREATE OR REPLACE PROCEDURE GET_OFFENE_VALIDIERUNGEN (
    p_person_id IN NUMBER,
    p_cursor    OUT SYS_REFCURSOR
)
AS
BEGIN
    -- Cursor mit allen offenen Validierungsanträgen öffnen
    OPEN p_cursor FOR
        -- Gefangene ermitteln, für die der Besucher noch nicht validiert wurde
        SELECT
            g.GEFANGENER_ID,
            p.VORNAME,
            p.NACHNAME
        FROM BESUCHER b
        JOIN BESUCHER_VALIDIERUNG bv
            ON bv.BESUCHER_ID = b.BESUCHER_ID
        JOIN GEFANGENER g
            ON g.GEFANGENER_ID = bv.GEFANGENER_ID
        JOIN PERSON p
            ON p.PERSON_ID = g.PERSON_ID
        -- Nur noch nicht bestätigte Validierungsanträge anzeigen
        WHERE b.PERSON_ID = p_person_id
          AND bv.VALIDIERT = 0
        ORDER BY p.NACHNAME, p.VORNAME;
END;
/



-- Erstellt oder überschreibt die Prozedur zur Beantragung der Validierung
CREATE OR REPLACE PROCEDURE VALIDIERUNGSANTRAG_STELLEN (
    p_person_id     IN NUMBER,
    p_gefangener_id IN NUMBER,
    p_ok            OUT NUMBER,
    p_meldung       OUT VARCHAR2
) AS
    v_besucher_id NUMBER;
BEGIN
    p_ok := 0;

    -- 1. Zuerst die BESUCHER_ID zur eingeloggten Person finden
    BEGIN
        SELECT BESUCHER_ID INTO v_besucher_id
        FROM BESUCHER
        WHERE PERSON_ID = p_person_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_meldung := 'Fehler: Zu Ihrer Person-ID (' || p_person_id || ') wurde kein Besucher-Profil in der Tabelle BESUCHER gefunden.';
            RETURN;
    END;

    -- 2. Den Antrag in den "Warteraum" eintragen
    INSERT INTO BESUCHER_VALIDIERUNG (BESUCHER_ID, GEFANGENER_ID)
    VALUES (v_besucher_id, p_gefangener_id);

    COMMIT;
    p_ok := 1;
    p_meldung := 'Der Validierungsantrag wurde erfolgreich gesendet!';

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Sie haben für diesen Gefangenen bereits einen Antrag gestellt.';
    WHEN OTHERS THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Datenbankfehler: ' || SQLERRM;
END;
/