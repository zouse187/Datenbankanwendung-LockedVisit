CREATE OR REPLACE PROCEDURE TERMIN_BUCHEN (
    p_person_id     IN NUMBER,
    p_gefangener_id IN NUMBER,
    p_datum_str     IN VARCHAR2, 
    p_ok            OUT NUMBER,  
    p_meldung       OUT VARCHAR2 
)
AS
    v_anzahl        NUMBER;
    v_besucht_count NUMBER;
    v_slot_erlaubt  NUMBER;
    v_neu_id        NUMBER;
    v_datum         DATE;
    v_uhrzeit_str   VARCHAR2(5);
    v_wochentag     NUMBER;
BEGIN
    p_ok := 0;

    -- String in Oracle-DATE konvertieren
    v_datum := TO_DATE(p_datum_str, 'YYYY-MM-DD HH24:MI:SS');

    -- Wochentag (1=Mo, 5=Fr) und Uhrzeit ('HH24:MI') ermitteln
    v_wochentag := TRUNC(v_datum) - TRUNC(v_datum, 'IW') + 1;
    v_uhrzeit_str := TO_CHAR(v_datum, 'HH24:MI');

    /* 1) Prüfen, ob für diesen Gefangenen genau dieses Besuchsfenster existiert */
    SELECT COUNT(*)
    INTO v_slot_erlaubt
    FROM GEFANGENEN_SLOTS
    WHERE GEFANGENER_ID = p_gefangener_id
      AND WOCHENTAG = v_wochentag
      AND UHRZEIT = v_uhrzeit_str;

    IF v_slot_erlaubt = 0 THEN
        p_meldung := 'Dieser Gefangene hat zu dieser Zeit kein reguläres Besuchsfenster.';
        RETURN;
    END IF;

    /* 2) Schritt 8: Prüfen, ob der Gefangene generell besuchbar ist */
    SELECT COUNT(*)
    INTO v_anzahl
    FROM GEFANGENER
    WHERE GEFANGENER_ID = p_gefangener_id
      AND BESUCHBAR = 1;

    IF v_anzahl = 0 THEN
        p_meldung := 'Der Gefangene darf aktuell keinen Besuch empfangen.';
        RETURN;
    END IF;

    /* 3) Schritt 9: Prüfen, ob der Slot bereits durch eine andere Buchung belegt ist */
    SELECT COUNT(*)
    INTO v_besucht_count
    FROM BESUCHSZEITEN
    WHERE GEFANGENER_ID = p_gefangener_id
      AND DATUM = v_datum;

    IF v_besucht_count > 0 THEN
        p_meldung := 'Dieser Terminslot ist für den Gefangenen bereits vergeben.';
        RETURN;
    END IF;

    /* 4) Schritt 10: Termin buchen */
    SELECT NVL(MAX(BESUCHSZEITEN_ID), 0) + 1
    INTO v_neu_id
    FROM BESUCHSZEITEN;

    INSERT INTO BESUCHSZEITEN (BESUCHSZEITEN_ID, PERSON_ID, GEFANGENER_ID, DATUM)
    VALUES (v_neu_id, p_person_id, p_gefangener_id, v_datum);

    COMMIT;

    p_ok := 1;
    p_meldung := 'Termin wurde erfolgreich gebucht!';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Der Termin konnte nicht gespeichert werden: ' || SQLERRM;
END;
/