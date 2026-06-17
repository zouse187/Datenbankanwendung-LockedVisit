-- PASSWORT zu PERSON hinzufügen
ALTER TABLE PERSON
  ADD (PASSWORT VARCHAR2(255));

-- Erst wenn alle existierende Personen ein Passwort haben darf man PASSWORT auf not null setzen
UPDATE PERSON
SET PASSWORT = PERSON_ID
WHERE PASSWORT IS NULL;

-- PERSON wird auf not null gesetzt
ALTER TABLE PERSON
  MODIFY (PASSWORT VARCHAR2(255) NOT NULL);

-- Erst wenn alle existierende Personen eine Mail haben darf man EMAIL auf not null setzen
UPDATE PERSON
SET EMAIL = 'placeholder_' || PERSON_ID || '@example.com'
WHERE EMAIL IS NULL;

-- EMAIL wird auf not null gesetzt
ALTER TABLE PERSON
  MODIFY (EMAIL VARCHAR2(255) NOT NULL);
