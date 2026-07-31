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


-- Erstellt oder überschreibt die Prozedur für die Gefangenen, für die der Besucher validiert ist
CREATE OR REPLACE PROCEDURE GET_VALIDIERTE_GEFANGENE (
    p_person_id IN  NUMBER,           -- Die ID des aktuell eingeloggten Besuchers
    p_cursor    OUT SYS_REFCURSOR     -- Ein System-Cursor, der die Ergebnismenge an PHP übergibt
) AS
    -- Eine interne Variable, um die ermittelte BESUCHER_ID kurzzeitig zu speichern
    v_besucher_id NUMBER;
BEGIN
    -- Ermittle die BESUCHER_ID anhand der übergebenen PERSON_ID
    SELECT besucher_id 
    INTO v_besucher_id
    FROM besucher 
    WHERE person_id = p_person_id;

    -- Öffne den Cursor mit der ermittelten v_besucher_id
    OPEN p_cursor FOR
        SELECT 
            g.gefangener_id, 
            p.vorname, 
            p.nachname 
        FROM validierte_besucher vb
        -- Verbindet die Validierungstabelle über die GEFANGENER_ID mit der GEFANGENER-Tabelle
        JOIN gefangener g ON vb.gefangener_id = g.gefangener_id
        -- Verbindet den Gefangenen über seine PERSON_ID mit der PERSON-Tabelle, um Vor- und Nachnamen zu erhalten
        JOIN person p     ON g.person_id = p.person_id
        -- Filtert das Ergebnis so, dass nur Gefangene des aktuell übergebenen Besuchers geladen werden
        WHERE vb.besucher_id = v_besucher_id;

EXCEPTION
    -- Falls für die PERSON_ID kein Eintrag in der BESUCHER-Tabelle existiert
    WHEN NO_DATA_FOUND THEN
        -- Öffnet einen leeren Cursor, damit PHP nicht abstürzt, sondern einfach 0 Zeilen erhält
        OPEN p_cursor FOR 
            SELECT NULL AS gefangener_id, NULL AS vorname, NULL AS nachname FROM dual WHERE 1=0;
END GET_VALIDIERTE_GEFANGENE;
/



-- Erstellt oder überschreibt die Prozedur zur Abfrage der Gefangenen für die Validierung
CREATE OR REPLACE PROCEDURE GET_NICHT_VALIDIERTE_GEFANGENE (
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
         -- Bedingung 1: Es läuft kein offener Antrag in VALIDIERUNGSANTRAG
         AND NOT EXISTS (
             SELECT 1
             FROM BESUCHER b
             JOIN VALIDIERUNGSANTRAG bv ON bv.BESUCHER_ID = b.BESUCHER_ID
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
CREATE OR REPLACE PROCEDURE GET_OFFENE_VALIDIERUNGSANTRAEGE (
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
        JOIN VALIDIERUNGSANTRAG bv
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
    INSERT INTO VALIDIERUNGSANTRAG (BESUCHER_ID, GEFANGENER_ID)
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


-- Erstellt oder überschreibt die Prozedur zum Anzeigen der freien und gebuchten Termine
CREATE OR REPLACE PROCEDURE GET_GEFANGENEN_TERMINE (
    p_gefangener_id IN  NUMBER,
    p_cursor        OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT TO_CHAR(gt.DATUM, 'YYYY-MM-DD HH24:MI') AS TERMIN_ZEIT,
               gt.GEBUCHT
          FROM GEFANGENEN_TERMINE gt
          -- JOIN mit der Gefangenen-Tabelle, um den Besuchsstatus zu prüfen
          JOIN GEFANGENER g ON gt.GEFANGENER_ID = g.GEFANGENER_ID
         WHERE gt.GEFANGENER_ID = p_gefangener_id
           AND g.BESUCHBAR = 1          -- Nur wenn der Gefangene besuchbar ist (1)
           AND gt.DATUM >= SYSDATE      -- Nur Termine, die nicht in der Vergangenheit liegen
         ORDER BY gt.DATUM ASC;
END;
/



-- Erstellt oder überschreibt die Prozedur zur Terminbuchung
CREATE OR REPLACE PROCEDURE TERMIN_BUCHEN (
    p_person_id     IN  NUMBER, -- PERSON_ID aus $_SESSION['person_id']
    p_gefangener_id IN  NUMBER,
    p_datum_str     IN  VARCHAR2, 
    p_ok            OUT NUMBER,  
    p_meldung       OUT VARCHAR2 
)
AS
    v_datum         DATE;
    v_besucher_id   NUMBER;
BEGIN
    p_ok := 0;

    -- 1. String in Oracle-DATE konvertieren (Format: YYYY-MM-DD HH24:MI:SS)
    v_datum := TO_DATE(p_datum_str, 'YYYY-MM-DD HH24:MI:SS');

    -- 2. BESUCHER_ID anhand der PERSON_ID (p_person_id) ermitteln
    SELECT BESUCHER_ID
    INTO v_besucher_id
    FROM BESUCHER
    WHERE PERSON_ID = p_person_id;

    -- 3. Termin direkt buchen (UPDATE auf GEFANGENEN_TERMINE)
    UPDATE GEFANGENEN_TERMINE
       SET GEBUCHT = 1,
           BESUCHER_ID = v_besucher_id
     WHERE GEFANGENER_ID = p_gefangener_id
       AND DATUM = v_datum;

    -- Änderungen festschreiben
    COMMIT;

    p_ok := 1;
    p_meldung := 'Termin wurde erfolgreich gebucht!';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Fehler bei der Buchung: ' || SQLERRM;
END;
/


-- Erstellt oder überschreibt die Prozedur zur Anzeigen der Anträge
CREATE OR REPLACE PROCEDURE GET_OFFENE_ANTRAEGE (
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT va.BESUCHER_ID,
               va.GEFANGENER_ID,
               -- Besucher-Name aus PERSON holen
               p_bes.VORNAME || ' ' || p_bes.NACHNAME AS BESUCHER_NAME,
               -- Gefangenen-Name ebenfalls aus PERSON holen (über GEFANGENER)
               p_gef.VORNAME || ' ' || p_gef.NACHNAME AS GEFANGENER_NAME
          FROM VALIDIERUNGSANTRAG va
          JOIN BESUCHER b   ON va.BESUCHER_ID = b.BESUCHER_ID
          JOIN PERSON p_bes ON b.PERSON_ID = p_bes.PERSON_ID
          JOIN GEFANGENER g ON va.GEFANGENER_ID = g.GEFANGENER_ID
          JOIN PERSON p_gef ON g.PERSON_ID = p_gef.PERSON_ID
         WHERE va.VALIDIERT = 0
         ORDER BY p_bes.NACHNAME ASC;
END;
/

-- Erstellt oder überschreibt die Prozedur zur Bearbeitung der Anträge
CREATE OR REPLACE PROCEDURE VALIDIERUNGSANTRAG_BEARBEITEN (
    p_besucher_id   IN  NUMBER,
    p_gefangener_id IN  NUMBER,
    p_entscheidung  IN  NUMBER, -- 1 = Annehmen, 0 = Ablehnen
    p_ok            OUT NUMBER,
    p_meldung       OUT VARCHAR2
) AS
BEGIN
    p_ok := 0;

    IF p_entscheidung = 1 THEN
        -- FALL A: ANNEHMEN
        INSERT INTO VALIDIERTE_BESUCHER (BESUCHER_ID, GEFANGENER_ID)
        VALUES (p_besucher_id, p_gefangener_id);
        
        UPDATE VALIDIERUNGSANTRAG
           SET VALIDIERT = 1
         WHERE BESUCHER_ID = p_besucher_id
           AND GEFANGENER_ID = p_gefangener_id;
           
        p_meldung := 'Der Antrag wurde erfolgreich angenommen und validiert.';
        
    ELSIF p_entscheidung = 0 THEN
        -- FALL B: ABLEHNEN
        DELETE FROM VALIDIERUNGSANTRAG
         WHERE BESUCHER_ID = p_besucher_id
           AND GEFANGENER_ID = p_gefangener_id;
           
        p_meldung := 'Der Antrag wurde abgelehnt und gelöscht.';
    ELSE
        p_meldung := 'Ungültige Entscheidung übergeben.';
        RETURN;
    END IF;

    COMMIT;
    p_ok := 1;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_ok := 0;
        p_meldung := 'Fehler bei der Bearbeitung: ' || SQLERRM;
END;
/

-- Erstellt oder überschreibt die Prozedur zum Ändern des Besuchbar-Status
CREATE OR REPLACE PROCEDURE UPDATE_BESUCHBAR_STATUS (
    p_gefangener_id IN NUMBER,
    p_neuer_status  IN NUMBER  -- Nimmt 1 (Besuchbar) oder 0 (Nicht besuchbar) entgegen
) AS
BEGIN
    -- Aktualisiert die Spalte BESUCHBAR in der Tabelle GEFANGENER
    UPDATE GEFANGENER
    SET BESUCHBAR = p_neuer_status
    WHERE GEFANGENER_ID = p_gefangener_id;

    -- Änderungen in Oracle dauerhaft speichern
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Fehler beim Aktualisieren des Status: ' || SQLERRM);
END UPDATE_BESUCHBAR_STATUS;
/