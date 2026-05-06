drop table ARTIKEL cascade constraints;

/*==============================================================*/
/* Table: ARTIKEL                                               */
/*==============================================================*/
create table ARTIKEL (
   ARTIKEL_ID           NUMBER(10)            not null,
   BEZEICHNUNG          VARCHAR2(50)          not null,
   KATEGORIE            VARCHAR2(50),
   EINHEIT              VARCHAR2(50),
   BEMERKUNG            VARCHAR2(255),
   constraint PK_ARTIKEL primary key (ARTIKEL_ID)
);

drop table DELIKT cascade constraints;

/*==============================================================*/
/* Table: DELIKT                                                */
/*==============================================================*/
create table DELIKT (
   DELIKT_ID            NUMBER(10)            not null,
   PARAGRAPH            VARCHAR2(100)         not null,
   BEZEICHNUNG          VARCHAR2(50)          not null,
   BESCHREIBUNG         VARCHAR2(255),
   MAX_STRAFE_MONATE    NUMBER(10),
   constraint PK_DELIKT primary key (DELIKT_ID)
);

drop table LIEFERANT cascade constraints;

/*==============================================================*/
/* Table: LIEFERANT                                             */
/*==============================================================*/
create table LIEFERANT (
   LIEFERANT_ID         NUMBER(10)            not null,
   NAME                 VARCHAR2(50)          not null,
   TYP                  VARCHAR2(50),
   STRASSE              VARCHAR2(50),
   PLZ                  NUMBER(20),
   ORT                  VARCHAR2(50),
   TELEFON              VARCHAR2(50),
   EMAIL                VARCHAR2(50),
   STATUS               VARCHAR2(10),
   constraint PK_LIEFERANT primary key (LIEFERANT_ID)
);

drop table PERSON cascade constraints;

/*==============================================================*/
/* Table: PERSON                                                */
/*==============================================================*/
create table PERSON (
   PERSON_ID            NUMBER(10)            not null,
   VORNAME              VARCHAR2(50)          not null,
   NACHNAME             VARCHAR2(50)          not null,
   GEBURTSDATUM         DATE                  not null,
   GESCHLECHT           VARCHAR2(10),
   TELEFON              VARCHAR2(50),
   EMAIL                VARCHAR2(255),
   constraint PK_PERSON primary key (PERSON_ID),
   constraint AK_UK_PERSON_EMAIL_PERSON unique (EMAIL)
);

drop table RISIKOKATEGORIE cascade constraints;

/*==============================================================*/
/* Table: RISIKOKATEGORIE                                       */
/*==============================================================*/
create table RISIKOKATEGORIE (
   RISIKOKATEGORIE_ID   NUMBER(10)            not null,
   BEZEICHNUNG          VARCHAR2(50)          not null,
   BESCHREIBUNG         VARCHAR2(255),
   constraint PK_RISIKOKATEGORIE primary key (RISIKOKATEGORIE_ID),
   constraint AK_UQ_RISIKOKAT_CODE_RISIKOKA unique (BEZEICHNUNG)
);

drop table STANDORT cascade constraints;

/*==============================================================*/
/* Table: STANDORT                                              */
/*==============================================================*/
create table STANDORT (
   STANDORT_ID          NUMBER(10)            not null,
   NAME                 VARCHAR2(50)          not null,
   STRASSE              VARCHAR2(50)          not null,
   PLZ                  VARCHAR2(10)          not null,
   ORT                  VARCHAR2(50)          not null,
   constraint PK_STANDORT primary key (STANDORT_ID)
);

drop table THERAPIEART cascade constraints;

/*==============================================================*/
/* Table: THERAPIEART                                           */
/*==============================================================*/
create table THERAPIEART (
   THERAPIEART_ID       NUMBER(10)            not null,
   BEZEICHNUNG          VARCHAR2(50)          not null,
   KATEGORIE            VARCHAR2(50),
   STANDARD_DAUER_MIN   NUMBER(3),
   BESCHREIBUNG         VARCHAR2(100),
   constraint PK_THERAPIEART primary key (THERAPIEART_ID)
);

alter table ANGESTELLTER
   drop constraint FK_ANGESTEL_FK_ANGEST_ANGESTEL;

alter table ANGESTELLTER
   drop constraint FK_ANGESTEL_FK_ANGEST_PERSON;

alter table ANGESTELLTER
   drop constraint FK_ANGESTEL_FK_ANGEST_STANDORT;

drop index FK_ANGESTELLTER_STANDORT_FK;

drop index FK_ANGESTELLTER_ANGESTELLTER_F;

drop index FK_ANGESTELLTER_PERSON_FK;

drop table ANGESTELLTER cascade constraints;

/*==============================================================*/
/* Table: ANGESTELLTER                                          */
/*==============================================================*/
create table ANGESTELLTER (
   STANDORT_ID          NUMBER(10)            not null,
   ANGESTELLTER_ID      NUMBER(10)            not null,
   ANGESTELLTER_STANDORT_ID NUMBER(10),
   ANGESTELLTER_ANGESTELLTER_ID NUMBER(10),
   PERSON_ID            NUMBER(10)            not null,
   ROLLE                VARCHAR2(50)          not null,
   EINSTELLUNGSDATUM    DATE                  not null,
   STRASSE              VARCHAR2(50)          not null,
   PLZ                  VARCHAR2(50)          not null,
   ORT                  VARCHAR2(50)          not null,
   VORGESETZTEN_ID      NUMBER(10),
   AUSTRITTSDATUM       DATE,
   ABTEILUNG            VARCHAR2(50),
   constraint PK_ANGESTELLTER primary key (STANDORT_ID, ANGESTELLTER_ID),
   constraint AK_UQ_ANGESTELLTER_PE_ANGESTEL unique (PERSON_ID, STANDORT_ID)
);

/*==============================================================*/
/* Index: FK_ANGESTELLTER_PERSON_FK                             */
/*==============================================================*/
create index FK_ANGESTELLTER_PERSON_FK on ANGESTELLTER (
   PERSON_ID ASC
);

/*==============================================================*/
/* Index: FK_ANGESTELLTER_ANGESTELLTER_F                        */
/*==============================================================*/
create index FK_ANGESTELLTER_ANGESTELLTER_F on ANGESTELLTER (
   ANGESTELLTER_STANDORT_ID ASC,
   ANGESTELLTER_ANGESTELLTER_ID ASC
);

/*==============================================================*/
/* Index: FK_ANGESTELLTER_STANDORT_FK                           */
/*==============================================================*/
create index FK_ANGESTELLTER_STANDORT_FK on ANGESTELLTER (
   STANDORT_ID ASC
);

alter table ANGESTELLTER
   add constraint FK_ANGESTEL_FK_ANGEST_ANGESTEL foreign key (ANGESTELLTER_STANDORT_ID, ANGESTELLTER_ANGESTELLTER_ID)
      references ANGESTELLTER (STANDORT_ID, ANGESTELLTER_ID);

alter table ANGESTELLTER
   add constraint FK_ANGESTEL_FK_ANGEST_PERSON foreign key (PERSON_ID)
      references PERSON (PERSON_ID);

alter table ANGESTELLTER
   add constraint FK_ANGESTEL_FK_ANGEST_STANDORT foreign key (STANDORT_ID)
      references STANDORT (STANDORT_ID);


alter table BESUCHER
   drop constraint FK_BESUCHER_FK_BESUCH_PERSON;

drop index JEDER_ANWALT_IST_GENAU_EIN_BES;

drop index FK_BESUCHER_PERSON_FK;

drop table BESUCHER cascade constraints;

/*==============================================================*/
/* Table: BESUCHER                                              */
/*==============================================================*/
create table BESUCHER (
   BESUCHER_ID          NUMBER(10)            not null,
   PERSON_ID            NUMBER(10)            not null,
   REGISTRIERT_AM       DATE                  not null,
   STRASSE              VARCHAR2(50)          not null,
   PLZ                  VARCHAR2(50)          not null,
   ORT                  VARCHAR2(50)          not null,
   BEMERKUNG            VARCHAR2(255),
   constraint PK_BESUCHER primary key (BESUCHER_ID),
   constraint AK_UQ_BESUCHER_PERSON_BESUCHER unique (PERSON_ID)
);

/*==============================================================*/
/* Index: FK_BESUCHER_PERSON_FK                                 */
/*==============================================================*/
create index FK_BESUCHER_PERSON_FK on BESUCHER (
   PERSON_ID ASC
);

/*==============================================================*/
/* Index: JEDER_ANWALT_IST_GENAU_EIN_BES                        */
/*==============================================================*/
create index JEDER_ANWALT_IST_GENAU_EIN_BES on BESUCHER (
   PERSON_ID ASC
);

alter table BESUCHER
   add constraint FK_BESUCHER_FK_BESUCH_PERSON foreign key (PERSON_ID)
      references PERSON (PERSON_ID);


alter table ANWALT
   drop constraint FK_ANWALT_FK_ANWALT_BESUCHER;

drop index EIN_BESUCHER_KANN_0_1_ANWALT_R;

drop table ANWALT cascade constraints;

/*==============================================================*/
/* Table: ANWALT                                                */
/*==============================================================*/
create table ANWALT (
   ANWALT_ID            NUMBER(10)            not null,
   BESUCHER_ID          NUMBER(10)            not null,
   KANZLEI_NAME         VARCHAR2(50)          not null,
   FACHGEBIET           VARCHAR2(50),
   KAMMER_NUMMER        NUMBER(20),
   TELEFON_KANZLEI      VARCHAR2(50),
   EMAIL_KANZLEI        VARCHAR2(255),
   constraint PK_ANWALT primary key (ANWALT_ID)
);

/*==============================================================*/
/* Index: EIN_BESUCHER_KANN_0_1_ANWALT_R                        */
/*==============================================================*/
create index EIN_BESUCHER_KANN_0_1_ANWALT_R on ANWALT (
   BESUCHER_ID ASC
);

alter table ANWALT
   add constraint FK_ANWALT_FK_ANWALT_BESUCHER foreign key (BESUCHER_ID)
      references BESUCHER (BESUCHER_ID);


alter table AUSBILDUNG
   drop constraint FK_AUSBILDU_FK_PERSON_PERSON;

drop index FK_PERSON_AUSBILDUNG_FK;

drop table AUSBILDUNG cascade constraints;

/*==============================================================*/
/* Table: AUSBILDUNG                                            */
/*==============================================================*/
create table AUSBILDUNG (
   AUSBILDUNG_ID        NUMBER(10)            not null,
   PERSON_ID            NUMBER(10)            not null,
   BEZEICHNUNG           VARCHAR2(100)         not null,
   BETRIEB_NAME         VARCHAR2(50),
   ORT                  VARCHAR2(50),
   BEGINN_DATUM         DATE,
   ENDE_DATUM           DATE,
   ABSCHLUSSART         VARCHAR2(50),
   BEMERKUNG            VARCHAR2(50),
   constraint PK_AUSBILDUNG primary key (AUSBILDUNG_ID)
);

/*==============================================================*/
/* Index: FK_PERSON_AUSBILDUNG_FK                               */
/*==============================================================*/
create index FK_PERSON_AUSBILDUNG_FK on AUSBILDUNG (
   PERSON_ID ASC
);

alter table AUSBILDUNG
   add constraint FK_AUSBILDU_FK_PERSON_PERSON foreign key (PERSON_ID)
      references PERSON (PERSON_ID);


alter table GEFANGENER
   drop constraint FK_GEFANGEN_FK_GEFANG_PERSON;

drop index FK_GEFANGENER_PERSON_FK;

drop table GEFANGENER cascade constraints;

/*==============================================================*/
/* Table: GEFANGENER                                            */
/*==============================================================*/
create table GEFANGENER (
   GEFANGENER_ID        NUMBER(10)            not null,
   PERSON_ID            NUMBER(10)            not null,
   EINTRITTSDATUM       DATE                  not null,
   ENTLASSUNGSDATUM     DATE,
   SICHERHEITSSTUFE     VARCHAR2(20),
   constraint PK_GEFANGENER primary key (GEFANGENER_ID),
   constraint AK_UQ_GEFANGENER_PERS_GEFANGEN unique (PERSON_ID, EINTRITTSDATUM),
   constraint CK_GEFANGENER_SICHERHEITSSTUFE check (sicherheitsstufe IN ('niedrig', 'mittel', 'hoch'))
);

/*==============================================================*/
/* Index: FK_GEFANGENER_PERSON_FK                               */
/*==============================================================*/
create index FK_GEFANGENER_PERSON_FK on GEFANGENER (
   PERSON_ID ASC
);

alter table GEFANGENER
   add constraint FK_GEFANGEN_FK_GEFANG_PERSON foreign key (PERSON_ID)
      references PERSON (PERSON_ID);


alter table GEBAEUDE
   drop constraint FK_GEBAEUDE_FK_GEBAEU_STANDORT;

drop index FK_GEBAEUDE_STANDORT_FK;

drop table GEBAEUDE cascade constraints;

/*==============================================================*/
/* Table: GEBAEUDE                                              */
/*==============================================================*/
create table GEBAEUDE (
   STANDORT_ID          NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10)            not null,
   BEZEICHNUNG          VARCHAR2(50)          not null,
   STANDORT             VARCHAR2(200)         not null,
   BAUART               VARCHAR2(50),
   constraint PK_GEBAEUDE primary key (STANDORT_ID, GEBAEUDE_ID)
);

/*==============================================================*/
/* Index: FK_GEBAEUDE_STANDORT_FK                               */
/*==============================================================*/
create index FK_GEBAEUDE_STANDORT_FK on GEBAEUDE (
   STANDORT_ID ASC
);

alter table GEBAEUDE
   add constraint FK_GEBAEUDE_FK_GEBAEU_STANDORT foreign key (STANDORT_ID)
      references STANDORT (STANDORT_ID);


alter table ZELLE
   drop constraint FK_ZELLE_FK_ZELLE__RAUM;

drop index FK_ZELLE_RAUM_FK;

drop table ZELLE cascade constraints;

/*==============================================================*/
/* Table: ZELLE                                                 */
/*==============================================================*/
create table ZELLE (
   ZELLE_ID             NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10)            not null,
   MAX_BELEGUNG         NUMBER(2)             not null,
   SICHERHEITSSTUFE     VARCHAR2(20),
   constraint PK_ZELLE primary key (ZELLE_ID)
);

/*==============================================================*/
/* Index: FK_ZELLE_RAUM_FK                                      */
/*==============================================================*/
create index FK_ZELLE_RAUM_FK on ZELLE (
   GEBAEUDE_ID ASC
);

alter table ZELLE
   add constraint FK_ZELLE_FK_ZELLE__RAUM foreign key (GEBAEUDE_ID)
      references RAUM (GEBAEUDE_ID);


alter table BELEGUNG
   drop constraint FK_BELEGUNG_FK_BELEGU_GEFANGEN;

alter table BELEGUNG
   drop constraint FK_BELEGUNG_FK_BELEGU_ZELLE;

drop index FK_BELEGUNG_ZELLE_FK;

drop index FK_BELEGUNG_GEFANGENER_FK;

drop table BELEGUNG cascade constraints;

/*==============================================================*/
/* Table: BELEGUNG                                              */
/*==============================================================*/
create table BELEGUNG (
   BELEGUNG_ID          NUMBER(10)            not null,
   ZELLE_ID             NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   VON_DATUM            DATE                  not null,
   BIS_DATUM            DATE,
   constraint PK_BELEGUNG primary key (BELEGUNG_ID)
);

/*==============================================================*/
/* Index: FK_BELEGUNG_GEFANGENER_FK                             */
/*==============================================================*/
create index FK_BELEGUNG_GEFANGENER_FK on BELEGUNG (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_BELEGUNG_ZELLE_FK                                  */
/*==============================================================*/
create index FK_BELEGUNG_ZELLE_FK on BELEGUNG (
   ZELLE_ID ASC
);

alter table BELEGUNG
   add constraint FK_BELEGUNG_FK_BELEGU_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);

alter table BELEGUNG
   add constraint FK_BELEGUNG_FK_BELEGU_ZELLE foreign key (ZELLE_ID)
      references ZELLE (ZELLE_ID);


alter table BESCHAEFTIGUNG
   drop constraint FK_BESCHAEF_FK_BESCHA_RAUM;

drop index FK_BESCHAEFTIGUNG_RAUM_FK;

drop table BESCHAEFTIGUNG cascade constraints;

/*==============================================================*/
/* Table: BESCHAEFTIGUNG                                        */
/*==============================================================*/
create table BESCHAEFTIGUNG (
   BESCHAEFTIGUNG_ID    NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10),
   BEZEICHNUNG          VARCHAR2(50)          not null,
   BESCHREIBUNG         VARCHAR2(255),
   constraint PK_BESCHAEFTIGUNG primary key (BESCHAEFTIGUNG_ID)
);

/*==============================================================*/
/* Index: FK_BESCHAEFTIGUNG_RAUM_FK                             */
/*==============================================================*/
create index FK_BESCHAEFTIGUNG_RAUM_FK on BESCHAEFTIGUNG (
   GEBAEUDE_ID ASC
);

alter table BESCHAEFTIGUNG
   add constraint FK_BESCHAEF_FK_BESCHA_RAUM foreign key (GEBAEUDE_ID)
      references RAUM (GEBAEUDE_ID);


alter table BESUCH
   drop constraint FK_BESUCH_FK_BESUCH_BESUCHER;

alter table BESUCH
   drop constraint FK_BESUCH_FK_BESUCH_GEFANGEN;

alter table BESUCH
   drop constraint FK_BESUCH_FK_BESUCH_RAUM;

drop index FK_BESUCH_RAUM_FK;

drop index FK_BESUCH_BESUCHER_FK;

drop index FK_BESUCH_GEFANGENER_FK;

drop table BESUCH cascade constraints;

/*==============================================================*/
/* Table: BESUCH                                                */
/*==============================================================*/
create table BESUCH (
   BESUCH_ID            NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10)            not null,
   BESUCHER_ID          NUMBER(10)            not null,
   BESUCHSDATUM         DATE                  not null,
   BEMERKUNG            VARCHAR2(255),
   constraint PK_BESUCH primary key (BESUCH_ID)
);

/*==============================================================*/
/* Index: FK_BESUCH_GEFANGENER_FK                               */
/*==============================================================*/
create index FK_BESUCH_GEFANGENER_FK on BESUCH (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_BESUCH_BESUCHER_FK                                 */
/*==============================================================*/
create index FK_BESUCH_BESUCHER_FK on BESUCH (
   BESUCHER_ID ASC
);

/*==============================================================*/
/* Index: FK_BESUCH_RAUM_FK                                     */
/*==============================================================*/
create index FK_BESUCH_RAUM_FK on BESUCH (
   GEBAEUDE_ID ASC
);

alter table BESUCH
   add constraint FK_BESUCH_FK_BESUCH_BESUCHER foreign key (BESUCHER_ID)
      references BESUCHER (BESUCHER_ID);

alter table BESUCH
   add constraint FK_BESUCH_FK_BESUCH_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);

alter table BESUCH
   add constraint FK_BESUCH_FK_BESUCH_RAUM foreign key (GEBAEUDE_ID)
      references RAUM (GEBAEUDE_ID);


alter table GEFANGENER_ANWALT
   drop constraint FK_GEFANGEN_FK_ANWALT_ANWALT;

alter table GEFANGENER_ANWALT
   drop constraint FK_GEFANGEN_FK_GEFANG_GEFANGEN;

drop index FK_ANWALT_GA_FK;

drop index FK_GEFANGENER_GA_FK;

drop table GEFANGENER_ANWALT cascade constraints;

/*==============================================================*/
/* Table: GEFANGENER_ANWALT                                     */
/*==============================================================*/
create table GEFANGENER_ANWALT (
   GEFANGENER_ANWALT_ID NUMBER(10)            not null,
   ANWALT_ID            NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   MANDAT_AB            DATE                  not null,
   MANDAT_BIS           DATE,
   TYP                  VARCHAR2(100),
   BEMERKUNG            VARCHAR2(100),
   constraint PK_GEFANGENER_ANWALT primary key (GEFANGENER_ANWALT_ID)
);

/*==============================================================*/
/* Index: FK_GEFANGENER_GA_FK                                   */
/*==============================================================*/
create index FK_GEFANGENER_GA_FK on GEFANGENER_ANWALT (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_ANWALT_GA_FK                                       */
/*==============================================================*/
create index FK_ANWALT_GA_FK on GEFANGENER_ANWALT (
   ANWALT_ID ASC
);

alter table GEFANGENER_ANWALT
   add constraint FK_GEFANGEN_FK_ANWALT_ANWALT foreign key (ANWALT_ID)
      references ANWALT (ANWALT_ID);

alter table GEFANGENER_ANWALT
   add constraint FK_GEFANGEN_FK_GEFANG_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);


alter table GEFANGENER_BESCHAEFTIGUNG
   drop constraint FK_GEFANGEN_FK_GB_BES_BESCHAEF;

alter table GEFANGENER_BESCHAEFTIGUNG
   drop constraint FK_GEFANGEN_FK_GB_GEF_GEFANGEN;

drop index FK_GB_BESCHAEFTIGUNG_FK;

drop index FK_GB_GEFANGENER_FK;

drop table GEFANGENER_BESCHAEFTIGUNG cascade constraints;

/*==============================================================*/
/* Table: GEFANGENER_BESCHAEFTIGUNG                             */
/*==============================================================*/
create table GEFANGENER_BESCHAEFTIGUNG (
   GEFANGENER_BESCHAEFTIGUNG_ID NUMBER(10)            not null,
   BESCHAEFTIGUNG_ID    NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   VON_DATUM            DATE                  not null,
   BIS_DATUM            DATE,
   constraint PK_GEFANGENER_BESCHAEFTIGUNG primary key (GEFANGENER_BESCHAEFTIGUNG_ID)
);

/*==============================================================*/
/* Index: FK_GB_GEFANGENER_FK                                   */
/*==============================================================*/
create index FK_GB_GEFANGENER_FK on GEFANGENER_BESCHAEFTIGUNG (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_GB_BESCHAEFTIGUNG_FK                               */
/*==============================================================*/
create index FK_GB_BESCHAEFTIGUNG_FK on GEFANGENER_BESCHAEFTIGUNG (
   BESCHAEFTIGUNG_ID ASC
);

alter table GEFANGENER_BESCHAEFTIGUNG
   add constraint FK_GEFANGEN_FK_GB_BES_BESCHAEF foreign key (BESCHAEFTIGUNG_ID)
      references BESCHAEFTIGUNG (BESCHAEFTIGUNG_ID);

alter table GEFANGENER_BESCHAEFTIGUNG
   add constraint FK_GEFANGEN_FK_GB_GEF_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);


alter table GEFANGENER_RISIKO
   drop constraint FK_GEFANGEN_FK_GR_GEF_GEFANGEN;

alter table GEFANGENER_RISIKO
   drop constraint FK_GEFANGEN_FK_GR_RIS_RISIKOKA;

drop index FK_GR_RISIKOKATEGORIE_FK;

drop index FK_GR_GEFANGENER_FK;

drop table GEFANGENER_RISIKO cascade constraints;

/*==============================================================*/
/* Table: GEFANGENER_RISIKO                                     */
/*==============================================================*/
create table GEFANGENER_RISIKO (
   GEFANGENER_RISIKO_ID NUMBER(10)            not null,
   RISIKOKATEGORIE_ID   NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   GUELTIG_AB           DATE                  not null,
   GUELTIG_BIS          DATE,
   constraint PK_GEFANGENER_RISIKO primary key (GEFANGENER_RISIKO_ID)
);

/*==============================================================*/
/* Index: FK_GR_GEFANGENER_FK                                   */
/*==============================================================*/
create index FK_GR_GEFANGENER_FK on GEFANGENER_RISIKO (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_GR_RISIKOKATEGORIE_FK                              */
/*==============================================================*/
create index FK_GR_RISIKOKATEGORIE_FK on GEFANGENER_RISIKO (
   RISIKOKATEGORIE_ID ASC
);

alter table GEFANGENER_RISIKO
   add constraint FK_GEFANGEN_FK_GR_GEF_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);

alter table GEFANGENER_RISIKO
   add constraint FK_GEFANGEN_FK_GR_RIS_RISIKOKA foreign key (RISIKOKATEGORIE_ID)
      references RISIKOKATEGORIE (RISIKOKATEGORIE_ID);


alter table LIEFERPOSITION
   drop constraint FK_LIEFERPO_FK_LIEFER_ARTIKEL;

alter table LIEFERPOSITION
   drop constraint FK_LIEFERPO_FK_LIEFER_LIEFERUN;

drop index FK_LIEFERPOSITION_ARTIKEL_FK;

drop index FK_LIEFERPOSITION_LIEFERUNG_FK;

drop table LIEFERPOSITION cascade constraints;

/*==============================================================*/
/* Table: LIEFERPOSITION                                        */
/*==============================================================*/
create table LIEFERPOSITION (
   STANDORT_STANDORT_ID NUMBER(10),
   LIEFERANT_LIEFERANT_ID NUMBER(10),
   LIEFERUNG_LIEFERUNG_ID NUMBER(10),
   ARTIKEL_ARTIKEL_ID   NUMBER(10),
   LIEFERPOSITION_ID    NUMBER(10)            not null,
   LIEFERUNG_ID         NUMBER(10)            not null,
   ARTIKEL_ID           NUMBER(10)            not null,
   MENGE                NUMBER(10)            not null,
   EINZELPREIS          NUMBER(8, 2),
   BEMERKUNG            VARCHAR2(255),
   constraint PK_LIEFERPOSITION primary key (LIEFERPOSITION_ID, LIEFERUNG_ID)
);

/*==============================================================*/
/* Index: FK_LIEFERPOSITION_LIEFERUNG_FK                        */
/*==============================================================*/
create index FK_LIEFERPOSITION_LIEFERUNG_FK on LIEFERPOSITION (
   STANDORT_STANDORT_ID ASC,
   LIEFERANT_LIEFERANT_ID ASC,
   LIEFERUNG_LIEFERUNG_ID ASC
);

/*==============================================================*/
/* Index: FK_LIEFERPOSITION_ARTIKEL_FK                          */
/*==============================================================*/
create index FK_LIEFERPOSITION_ARTIKEL_FK on LIEFERPOSITION (
   ARTIKEL_ARTIKEL_ID ASC
);

alter table LIEFERPOSITION
   add constraint FK_LIEFERPO_FK_LIEFER_ARTIKEL foreign key (ARTIKEL_ARTIKEL_ID)
      references ARTIKEL (ARTIKEL_ID);

alter table LIEFERPOSITION
   add constraint FK_LIEFERPO_FK_LIEFER_LIEFERUN foreign key (STANDORT_STANDORT_ID, LIEFERANT_LIEFERANT_ID, LIEFERUNG_LIEFERUNG_ID)
      references LIEFERUNG (STANDORT_STANDORT_ID, LIEFERANT_LIEFERANT_ID, LIEFERUNG_ID);


alter table LIEFERUNG
   drop constraint FK_LIEFERUN_FK_LIEFER_LIEFERAN;

alter table LIEFERUNG
   drop constraint FK_LIEFERUN_FK_LIEFER_STANDORT;

drop index FK_LIEFERUNG_LIEFERANT_FK;

drop index FK_LIEFERUNG_STANDORT_FK;

drop table LIEFERUNG cascade constraints;

/*==============================================================*/
/* Table: LIEFERUNG                                             */
/*==============================================================*/
create table LIEFERUNG (
   STANDORT_STANDORT_ID NUMBER(10),
   LIEFERANT_LIEFERANT_ID NUMBER(10),
   LIEFERUNG_ID         NUMBER(10)            not null,
   LIEFERANT_ID         NUMBER(10)            not null,
   STANDORT_ID          NUMBER(10)            not null,
   LIEFERDATUM          DATE                  not null,
   STATUS               VARCHAR2(50),
   BEMERKUNG            VARCHAR2(255),
   constraint PK_LIEFERUNG primary key (LIEFERUNG_ID)
);

/*==============================================================*/
/* Index: FK_LIEFERUNG_STANDORT_FK                              */
/*==============================================================*/
create index FK_LIEFERUNG_STANDORT_FK on LIEFERUNG (
   STANDORT_STANDORT_ID ASC
);

/*==============================================================*/
/* Index: FK_LIEFERUNG_LIEFERANT_FK                             */
/*==============================================================*/
create index FK_LIEFERUNG_LIEFERANT_FK on LIEFERUNG (
   LIEFERANT_LIEFERANT_ID ASC
);

alter table LIEFERUNG
   add constraint FK_LIEFERUN_FK_LIEFER_LIEFERAN foreign key (LIEFERANT_LIEFERANT_ID)
      references LIEFERANT (LIEFERANT_ID);

alter table LIEFERUNG
   add constraint FK_LIEFERUN_FK_LIEFER_STANDORT foreign key (STANDORT_STANDORT_ID)
      references STANDORT (STANDORT_ID);


alter table RAUM
   drop constraint FK_RAUM_FK_RAUM_G_GEBAEUDE;

drop index FK_RAUM_GEBAEUDE_FK;

drop table RAUM cascade constraints;

/*==============================================================*/
/* Table: RAUM                                                  */
/*==============================================================*/
create table RAUM (
   RAUM_ID              NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10)            not null,
   STANDORT_ID          NUMBER(10)            not null,
   GEBAEUDE_GEBAEUDE_ID NUMBER(10),
   RAUMNR               VARCHAR2(20)          not null,
   TYP                  VARCHAR2(30)          not null,
   constraint PK_RAUM primary key (RAUM_ID)
);

/*==============================================================*/
/* Index: FK_RAUM_GEBAEUDE_FK                                   */
/*==============================================================*/
create index FK_RAUM_GEBAEUDE_FK on RAUM (
   STANDORT_ID ASC,
   GEBAEUDE_GEBAEUDE_ID ASC
);

alter table RAUM
   add constraint FK_RAUM_FK_RAUM_G_GEBAEUDE foreign key (STANDORT_ID, GEBAEUDE_GEBAEUDE_ID)
      references GEBAEUDE (STANDORT_ID, GEBAEUDE_ID);


alter table SCHULBILDUNG
   drop constraint FK_SCHULBIL_FK_PERSON_PERSON;

drop index FK_PERSON_SCHULBILDUNG_FK;

drop table SCHULBILDUNG cascade constraints;

/*==============================================================*/
/* Table: SCHULBILDUNG                                          */
/*==============================================================*/
create table SCHULBILDUNG (
   SCHULBILDUNG_ID      NUMBER(10)            not null,
   PERSON_ID            NUMBER(10)            not null,
   ABSCHLUSSART         VARCHAR2(50)          not null,
   SCHULNAME            VARCHAR2(50),
   ORT                  VARCHAR2(50),
   ABSCHLUSS_JAHR       DATE,
   BEMERKUNG            VARCHAR2(50),
   constraint PK_SCHULBILDUNG primary key (SCHULBILDUNG_ID)
);

/*==============================================================*/
/* Index: FK_PERSON_SCHULBILDUNG_FK                             */
/*==============================================================*/
create index FK_PERSON_SCHULBILDUNG_FK on SCHULBILDUNG (
   PERSON_ID ASC
);

alter table SCHULBILDUNG
   add constraint FK_SCHULBIL_FK_PERSON_PERSON foreign key (PERSON_ID)
      references PERSON (PERSON_ID);


alter table THERAPIE
   drop constraint FK_THERAPIE_FK_GEFANG_GEFANGEN;

alter table THERAPIE
   drop constraint FK_THERAPIE_FK_RAUM_T_RAUM;

alter table THERAPIE
   drop constraint FK_THERAPIE_FK_THERAP_THERAPIE;

drop index FK_RAUM_THERAPIE_FK;

drop index FK_THERAPIEART_THERAPIE_FK;

drop index FK_GEFANGENER_THERAPIE_FK;

drop table THERAPIE cascade constraints;

/*==============================================================*/
/* Table: THERAPIE                                              */
/*==============================================================*/
create table THERAPIE (
   THERAPIE_ID          NUMBER(10)            not null,
   GEBAEUDE_ID          NUMBER(10),
   THERAPIEART_ID       NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   DATUM                DATE                  not null,
   DAUER_MIN            NUMBER(3),
   STATUS               VARCHAR2(50),
   BEMERKUNG            VARCHAR2(50),
   constraint PK_THERAPIE primary key (THERAPIE_ID)
);

/*==============================================================*/
/* Index: FK_GEFANGENER_THERAPIE_FK                             */
/*==============================================================*/
create index FK_GEFANGENER_THERAPIE_FK on THERAPIE (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_THERAPIEART_THERAPIE_FK                            */
/*==============================================================*/
create index FK_THERAPIEART_THERAPIE_FK on THERAPIE (
   THERAPIEART_ID ASC
);

/*==============================================================*/
/* Index: FK_RAUM_THERAPIE_FK                                   */
/*==============================================================*/
create index FK_RAUM_THERAPIE_FK on THERAPIE (
   GEBAEUDE_ID ASC
);

alter table THERAPIE
   add constraint FK_THERAPIE_FK_GEFANG_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);

alter table THERAPIE
   add constraint FK_THERAPIE_FK_RAUM_T_RAUM foreign key (GEBAEUDE_ID)
      references RAUM (GEBAEUDE_ID);

alter table THERAPIE
   add constraint FK_THERAPIE_FK_THERAP_THERAPIE foreign key (THERAPIEART_ID)
      references THERAPIEART (THERAPIEART_ID);


alter table VERURTEILUNG
   drop constraint FK_VERURTEI_FK_DELIKT_DELIKT;

alter table VERURTEILUNG
   drop constraint FK_VERURTEI_FK_GEFANG_GEFANGEN;

drop index FK_DELIKT_VERURTEILUNG_FK;

drop index FK_GEFANGENER_VERURTEILUNG_FK;

drop table VERURTEILUNG cascade constraints;

/*==============================================================*/
/* Table: VERURTEILUNG                                          */
/*==============================================================*/
create table VERURTEILUNG (
   VERURTEILUNG_ID      NUMBER(10)            not null,
   GEFANGENER_ID        NUMBER(10)            not null,
   DELIKT_ID            NUMBER(10)            not null,
   URTEIL_DATUM         DATE                  not null,
   STRAFDAUER_MONATE    NUMBER(10)            not null,
   STRAFENDE_DATUM      DATE,
   BEWAEHRUNG           SMALLINT,
   GERICHT              VARCHAR2(200),
   AKTENZEICHEN         VARCHAR2(300),
   constraint PK_VERURTEILUNG primary key (VERURTEILUNG_ID)
);

/*==============================================================*/
/* Index: FK_GEFANGENER_VERURTEILUNG_FK                         */
/*==============================================================*/
create index FK_GEFANGENER_VERURTEILUNG_FK on VERURTEILUNG (
   GEFANGENER_ID ASC
);

/*==============================================================*/
/* Index: FK_DELIKT_VERURTEILUNG_FK                             */
/*==============================================================*/
create index FK_DELIKT_VERURTEILUNG_FK on VERURTEILUNG (
   DELIKT_ID ASC
);

alter table VERURTEILUNG
   add constraint FK_VERURTEI_FK_DELIKT_DELIKT foreign key (DELIKT_ID)
      references DELIKT (DELIKT_ID);

alter table VERURTEILUNG
   add constraint FK_VERURTEI_FK_GEFANG_GEFANGEN foreign key (GEFANGENER_ID)
      references GEFANGENER (GEFANGENER_ID);