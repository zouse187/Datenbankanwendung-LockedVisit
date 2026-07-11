-- Erstellt oder überschreibt die Prozedur zur Abfrage der Gefangenen für die Validierung
CREATE OR REPLACE PROCEDURE GET_GEFANGENE_FUER_VALIDIERUNG (
    p_person_id IN NUMBER,
    p_cursor    OUT SYS_REFCURSOR
)
AS
BEGIN
    -- Gefangene für das Auswahlmenü des Besuchers laden
    OPEN p_cursor FOR
        SELECT
            g.GEFANGENER_ID,
            p.VORNAME,
            p.NACHNAME
        FROM GEFANGENER g
        JOIN PERSON p
            ON p.PERSON_ID = g.PERSON_ID
        -- Nur Gefangene anzeigen, die grundsätzlich besucht werden dürfen
        WHERE g.BESUCHBAR = 1
          -- Gefangene ausschließen, für die der Besucher bereits validiert ist
          AND NOT EXISTS (
              SELECT 1
              FROM BESUCHER b
              JOIN BESUCHER_VALIDIERUNG bv
                  ON bv.BESUCHER_ID = b.BESUCHER_ID
              WHERE b.PERSON_ID = p_person_id
                AND bv.GEFANGENER_ID = g.GEFANGENER_ID
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
)
AS
    v_besucher_id NUMBER(10);
    v_anzahl      NUMBER;
BEGIN
    p_ok := 0;

    -- Besucher-ID zur übergebenen Person ermitteln
    SELECT BESUCHER_ID
    INTO v_besucher_id
    FROM BESUCHER
    WHERE PERSON_ID = p_person_id;

    -- Prüfen, ob der Gefangene besuchbar ist
    SELECT COUNT(*)
    INTO v_anzahl
    FROM GEFANGENER
    WHERE GEFANGENER_ID = p_gefangener_id
      AND BESUCHBAR = 1;

    IF v_anzahl = 0 THEN
        p_meldung := 'Der Gefangene ist nicht verfügbar.';
        RETURN;
    END IF;

    -- Prüfen, ob bereits ein Validierungsantrag besteht
    SELECT COUNT(*)
    INTO v_anzahl
    FROM BESUCHER_VALIDIERUNG
    WHERE BESUCHER_ID = v_besucher_id
      AND GEFANGENER_ID = p_gefangener_id;

    IF v_anzahl > 0 THEN
        p_meldung := 'Für diesen Gefangenen besteht bereits ein Antrag.';
        RETURN;
    END IF;

    -- Neuen Validierungsantrag speichern
    INSERT INTO BESUCHER_VALIDIERUNG (
        BESUCHER_ID,
        GEFANGENER_ID,
        VALIDIERT
    )
    VALUES (
        v_besucher_id,
        p_gefangener_id,
        0
    );

    COMMIT;

    -- Erfolgsmeldung zurückgeben
    p_ok := 1;
    p_meldung := 'Der Validierungsantrag wurde gestellt.';

EXCEPTION
    -- Fehler behandeln und Änderungen zurücksetzen
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Zu dieser Person wurde kein Besucher gefunden.';

    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Dieser Antrag besteht bereits.';

    WHEN OTHERS THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Der Antrag konnte nicht gespeichert werden.';
END;
/