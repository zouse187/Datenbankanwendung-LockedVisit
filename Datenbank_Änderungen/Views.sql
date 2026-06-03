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
/* View: V_VALIDIERTE_BESUCHER                                  */
/*==============================================================*/

create view V_VALIDIERTE_BESUCHER as
select
    bv.BESUCHER_ID,
    bv.GEFANGENER_ID,
    bv.VALIDIERT
from BESUCHER_VALIDIERUNG bv
where bv.VALIDIERT = 1;
