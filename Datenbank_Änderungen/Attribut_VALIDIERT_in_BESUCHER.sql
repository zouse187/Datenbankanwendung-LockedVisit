/*==============================================================*/
/* Table: BESUCHER                                            */
/*==============================================================*/    
alter table BESUCHER
add VALIDIERT            NUMBER(1,0) DEFAULT 0 not null
;

alter table BESUCHER
add constraint CK_BESUCHER_VALIDIERT
   check (VALIDIERT in (0,1))
;