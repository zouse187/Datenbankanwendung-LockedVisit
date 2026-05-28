/*==============================================================*/
/* Table:  BESUCHSZEITEN                                        */
/*==============================================================*/
create table BESUCHSZEITEN (
    BESUCHSZEITEN_ID    NUMBER(10)                not null,
    PERSON_ID           NUMBER(10)                not null,
    GEFANGENER_ID       NUMBER(10)                not null,
    BESUCHER_ID         NUMBER(10)                not null,
    ANWALT_ID           NUMBER(10)                not null,
    GEFANGENENNAME      VARCHAR(100)              not null,
    DATUM               DATE                      not null
    
);


alter table BESUCHSZEITEN
add (   
    constraint FK_BESUCHSZEITEN_PERSON
        foreign key (PERSON_ID)
        references PERSON (PERSON_ID),
        
    constraint FK_BESUCHSZEITEN_GEFANGENER
        foreign key (GEFANGENER_ID)
        references GEFANGENER (GEFANGENER_ID),
        
    constraint FK_BESUCHSZEITEN_BESUCHER
        foreign key (BESUCHER_ID)
        references BESUCHER (BESUCHER_ID)
);

/*==============================================================*/
/* Index: IDX_BESUCHSZEITEN                                     */
/*==============================================================*/
        
create index IDX_BESUCHSZEITEN_PERSON
    on BESUCHSZEITEN (PERSON_ID);
    
create index IDX_BESUCHSZEITEN_GEFANGENER
    on BESUCHSZEITEN (GEFANGENER_ID);
    
create index IDX_BESUCHSZEITEN_BESUCHER
    on BESUCHSZEITEN (BESUCHER_ID);
    
create index IDX_BESUCHSZEITEN_ANWALT
    on BESUCHSZEITEN (ANWALT_ID);
    
create index IDX_BESUCHSZEITEN_DATUM
    on BESUCHSZEITEN (DATUM);
    
/*==============================================================*/
/* Table: GEFANGENER                                            */
/*==============================================================*/    
alter table GEFANGENER
add BESUCHBAR            NUMBER(1,0) DEFAULT 1 not null
;


alter table GEFANGENER
add constraint CK_GEFANGENER_BESUCHBAR
   check (BESUCHBAR in (0,1))
;
    
/*==============================================================*/
/* View: V_BESUCHSZEITEN_DETAILS                                */
/*==============================================================*/
    
create view V_BESUCHSZEITEN_DETAILS as
    select
        bz.BESUCHSZEITEN_ID,
        bz.DATUM,
        bz.GEFANGENER_ID,
        bz.GEFANGENENNAME,
        bz.BESUCHER_ID,
        bz.ANWALT_ID
from BESUCHSZEITEN bz;
    
/*==============================================================*/
/* View: V_BUCHBARE_GEFANGENEN                                  */
/*==============================================================*/
    
create view V_BUCHBARE_GEFANGENE as
select
    bz.GEFANGENER_ID,
    bz.GEFANGENENNAME,
    g.BESUCHBAR
from BESUCHSZEITEN bz
join GEFANGENER g
    on bz.GEFANGENER_ID = g.GEFANGENER_ID
where g.BESUCHBAR = 1;

/*==============================================================*/
/* View: V_BESUCHSZEITEN_PRO_GEFANGENER                         */
/*==============================================================*/

create view V_BESUCHSZEITEN_PRO_GEFANGENER as
select
    bz.GEFANGENER_ID,
    bz.GEFANGENENNAME,
    bz.BESUCHSZEITEN_ID,
    bz.DATUM,
    bz.BESUCHER_ID,
    bz.ANWALT_ID
from BESUCHSZEITEN bz;
        
/*==============================================================*/
/* Table:  BESUCHER_VALIDIERUNG                                 */
/*==============================================================*/    
create table BESUCHER_VALIDIERUNG (
    BESUCHER_ID     NUMBER(10) NOT NULL,
    GEFANGENER_ID   NUMBER(10) NOT NULL,
    VALIDIERT       NUMBER(1,0) DEFAULT 1 NOT NULL,

    constraint PK_BESUCHER_VALIDIERUNG
        primary key (BESUCHER_ID, GEFANGENER_ID),

    constraint FK_BV_BESUCHER
        foreign key (BESUCHER_ID)
        references BESUCHER (BESUCHER_ID),

    constraint FK_BV_GEFANGENER
        foreign key (GEFANGENER_ID)
        references GEFANGENER (GEFANGENER_ID)
);

alter table BESUCHER_VALIDIERUNG
add constraint CK_BV_VALIDIERT
check (VALIDIERT in (0,1,2))
;

alter table BESUCHER_VALIDIERUNG    
    modify VALIDIERT       NUMBER(1,0) DEFAULT 0 NOT NULL
;

/*==============================================================*/
/* View: V_VALIDIERTE_BESUCHER                                  */
/*==============================================================*/

create view V_VALIDIERTE_BESUCHER as
select
    bv.BESUCHER_ID,
    bv.GEFANGENER_ID,
    bv.VALIDIERT
from BESUCHER_VALIDIERUNG bv
where bv.VALIDIERT = 1;

/*==============================================================*/
/* Function:  IST_BESUCHER_VALIDIERT                            */
/*==============================================================*/
create function IST_BESUCHER_VALIDIERT (
    p_besucher_id   in NUMBER,
    p_gefangener_id in NUMBER
)
return NUMBER
is
    v_count NUMBER;
begin
    select count(*)
    into v_count
    from BESUCHER_VALIDIERUNG
    where BESUCHER_ID = p_besucher_id
      and GEFANGENER_ID = p_gefangener_id
      and VALIDIERT = 1;

    if v_count > 0 then
        return 1;
    else
        return 0;
    end if;
end;
/
