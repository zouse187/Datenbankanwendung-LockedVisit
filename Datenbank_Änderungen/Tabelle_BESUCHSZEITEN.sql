/*==============================================================*/
/* Table:  BESUCHSZEITEN                                        */
/*==============================================================*/
create table BESUCHSZEITEN (
    BESUCHSZEITEN_ID    NUMBER(10)                not null,
    PERSON_ID           NUMBER(10)                not null,
    GEFANGENER_ID       NUMBER(10)                not null,
    DATUM               DATE                      not null
);


alter table BESUCHSZEITEN
add (   
    constraint FK_BESUCHSZEITEN_PERSON
        foreign key (PERSON_ID)
        references PERSON (PERSON_ID),
        
    constraint FK_BESUCHSZEITEN_GEFANGENER
        foreign key (GEFANGENER_ID)
        references GEFANGENER (GEFANGENER_ID)
);

/*==============================================================*/
/* Index: IDX_BESUCHSZEITEN                                     */
/*==============================================================*/
        
create index IDX_BESUCHSZEITEN_PERSON
    on BESUCHSZEITEN (PERSON_ID);
    
create index IDX_BESUCHSZEITEN_GEFANGENER
    on BESUCHSZEITEN (GEFANGENER_ID);
    
create index IDX_BESUCHSZEITEN_DATUM
    on BESUCHSZEITEN (DATUM);