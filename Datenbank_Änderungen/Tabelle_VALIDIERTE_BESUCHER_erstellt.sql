/*==============================================================*/
/* Table:  VALIDIERTE_BESUCHER                                        */
/*==============================================================*/
CREATE TABLE VALIDIERTE_BESUCHER (
    BESUCHER_ID NUMBER(10)  not null,
    GEFANGENER_ID NUMBER(10) not null,

    -- Definition der Fremdschlüssel
    CONSTRAINT fk_besucher 
        FOREIGN KEY (BESUCHER_ID) 
        REFERENCES BESUCHER(BESUCHER_ID),

    CONSTRAINT fk_gefangener 
        FOREIGN KEY (GEFANGENER_ID) 
        REFERENCES GEFANGENER(GEFANGENER_ID),

    -- Zusammengesetzter Primärschlüssel, damit eine Kombination nur einmal existiert
    PRIMARY KEY (BESUCHER_ID, GEFANGENER_ID)
);
