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