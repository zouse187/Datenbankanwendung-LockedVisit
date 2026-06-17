-- Erstellt oder überschreibt die Prozedur zur Registrierung
CREATE OR REPLACE PROCEDURE REGISTRIERE_PERSON (
    -- Eingangsparameter (IN): Daten, die von PHP an die Datenbank übergeben werden
    p_vorname      IN PERSON.VORNAME%TYPE,
    p_nachname     IN PERSON.NACHNAME%TYPE,
    p_geburtsdatum IN VARCHAR2,
    p_geschlecht   IN PERSON.GESCHLECHT%TYPE,
    p_telefon      IN PERSON.TELEFON%TYPE,
    p_email        IN PERSON.EMAIL%TYPE,
    p_passwort     IN PERSON.PASSWORT%TYPE,
    p_ist_mitarb   IN NUMBER, -- 1 für Mitarbeiter, 0 für Besucher

    -- Optionale Besucherdaten (Standardwert ist NULL, falls nicht ausgefüllt)
    p_bes_strasse  IN BESUCHER.STRASSE%TYPE DEFAULT NULL,
    p_bes_plz      IN BESUCHER.PLZ%TYPE DEFAULT NULL,
    p_bes_ort      IN BESUCHER.ORT%TYPE DEFAULT NULL,

    -- Optionale Mitarbeiterdaten
    p_ang_standort_id  IN ANGESTELLTER.STANDORT_ID%TYPE,
    p_ang_rolle    IN ANGESTELLTER.ROLLE%TYPE DEFAULT NULL,
    p_ang_strasse  IN ANGESTELLTER.STRASSE%TYPE DEFAULT NULL,
    p_ang_plz      IN ANGESTELLTER.PLZ%TYPE DEFAULT NULL,
    p_ang_ort      IN ANGESTELLTER.ORT%TYPE DEFAULT NULL,

    -- Ausgangsparameter (OUT): ID, die von der DB generiert und an PHP zurückgegeben wird
    p_person_id    OUT PERSON.PERSON_ID%TYPE
) AS
BEGIN
    -- Fügt die allgemeinen Basisdaten in die Tabelle PERSON ein
    INSERT INTO PERSON (PERSON_ID, VORNAME, NACHNAME, GEBURTSDATUM,
                        GESCHLECHT, TELEFON, EMAIL, PASSWORT)
    VALUES (
        PERSON_SEQ.nextval, -- Holt die nächste fortlaufende Nummer als ID
        p_vorname,
        p_nachname,
        TO_DATE(p_geburtsdatum, 'YYYY-MM-DD'), -- Wandelt den PHP-Text in ein echtes Datum um
        p_geschlecht,
        p_telefon,
        p_email,
        p_passwort
    )
    RETURNING PERSON_ID INTO p_person_id; -- Speichert die neue ID direkt in der OUT-Variable für PHP

    -- Verzweigung: Je nach Nutzertyp wird ein Eintrag in einer zweiten Tabelle erstellt
    IF p_ist_mitarb = 1 THEN
        -- Wenn Mitarbeiter: Daten in die ANGESTELLTER-Tabelle eintragen
        INSERT INTO ANGESTELLTER (
            ANGESTELLTER_ID, PERSON_ID, STANDORT_ID, ROLLE, EINSTELLUNGSDATUM, STRASSE, PLZ, ORT
        ) VALUES (
            ANGESTELLTER_SEQ.nextval,
            p_person_id, -- Verknüpfung zur gerade erstellten Person
            p_ang_standort_id,
            p_ang_rolle,
            SYSDATE, -- Setzt das aktuelle Server-Datum als Einstellungsdatum
            p_ang_strasse,
            p_ang_plz,
            p_ang_ort
        );
    ELSE
        -- Wenn kein Mitarbeiter: Daten in die BESUCHER-Tabelle eintragen
        INSERT INTO BESUCHER (
            BESUCHER_ID, PERSON_ID, REGISTRIERT_AM, STRASSE, PLZ, ORT
        ) VALUES (
            BESUCHER_SEQ.nextval,
            p_person_id, -- Verknüpfung zur gerade erstellten Person
            SYSDATE, -- Setzt das aktuelle Datum als Registrierungsdatum
            p_bes_strasse,
            p_bes_plz,
            p_bes_ort
        );
    END IF;

EXCEPTION
-- Wenn irgendein Fehler auftritt, brich ab und gib eine Fehlermeldung aus
WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fehler: ' || SQLERRM);
END;
/


-- Erstellt oder überschreibt die Prozedur für den Login-Check
CREATE OR REPLACE PROCEDURE LOGIN_PERSON (
    p_email       IN  PERSON.EMAIL%TYPE,
    p_passwort    IN  PERSON.PASSWORT%TYPE,
    p_person_id   OUT PERSON.PERSON_ID%TYPE,
    p_rolle       OUT VARCHAR2, -- Gibt 'BESUCHER' oder 'ANGESTELLTER' zurück
    p_ok          OUT NUMBER    -- Gibt 1 (Erfolg) oder 0 (Fehlgeschlagen) zurück
) AS
    v_count NUMBER; -- Interne Hilfsvariable zum Zählen
BEGIN
    -- Sucht nach der PERSON_ID, bei der E-Mail und Passwort übereinstimmen
    SELECT PERSON_ID
      INTO p_person_id -- Schreibt die gefundene ID in den Ausgangsparameter
      FROM PERSON
     WHERE EMAIL = p_email
       AND PASSWORT = p_passwort;

    -- Zählt, ob die gefundene ID in der Tabelle ANGESTELLTER existiert
    SELECT COUNT(*) INTO v_count
      FROM ANGESTELLTER
      WHERE PERSON_ID = p_person_id;

    -- Wenn der Zähler größer als 0 ist, ist es ein Angestellter
    IF v_count > 0 THEN
        p_rolle := 'ANGESTELLTER';
    ELSE
        -- Wenn nicht, wird geprüft, ob die ID in der Tabelle BESUCHER existiert
        SELECT COUNT(*) INTO v_count
          FROM BESUCHER
          WHERE PERSON_ID = p_person_id;

        -- Wenn im Besucher-Topf gefunden, kriegt er die Rolle Besucher
        IF v_count > 0 THEN
            p_rolle := 'BESUCHER';
        ELSE
            p_rolle := 'UNBEKANNT';
        END IF;
    END IF;

    -- Wenn der Code bis hierhin kommt, waren Login und Rollenfindung erfolgreich
    p_ok := 1; 

EXCEPTION
    -- Spezialfall: Wenn SELECT INTO keine Zeile findet (E-Mail oder Passwort falsch)
    WHEN NO_DATA_FOUND THEN
        p_ok := 0; -- Setzt Status auf 0 (Fehlgeschlagen)
        p_person_id := NULL; -- Löscht eventuelle ID-Reste
        p_rolle := NULL;     -- Löscht eventuelle Rollen-Reste
END;
/