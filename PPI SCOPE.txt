-- PPI SCOPE QUERY

with dtall as (
-- IDW DATABASES
Select trim(databasename) as db_nm, cast('IDW' as varchar(10)) as databasetype from 
 (
with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename='datasupport'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table
)  DT_IDW
WHERE DATABASENAME NOT IN ('BI_BACKUP_TBL', 'BI_RESTORE', 'BI_ARCHIVE',
-- sprint DB
'SPD_TD_CORE_T',
'SPD_TD_ETL_WRK_T',
'SPD0_STG_T' ,
'SPD0_TD_CORE_T' ,
'SPD0_TD_ETL_WRK_T' ,
'STG_SPD_T'  , 
'STG_SPD_W' ,
'STG_SPRNT_W' ,
'STG_SPRNT_T'                   
)

UNION ALL

-- FADS DATABASES
Select trim(databasename) as db_nm, cast('FADS' as varchar(10)) as databasetype from 
 (
with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename='datasupport_fads'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table
) DT_FADS



UNION ALL

-- EDW DATABASES
Select trim(databasename) as db_nm, cast('EDW' as varchar(10)) as databasetype from 
 (
with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename='datasupport_edw'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table
) DT_EDW



UNION ALL

-- DL DATABASES
Select trim(databasename) as db_nm, cast('DL' as varchar(10)) as databasetype from 
 (

with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename IN ('RESERVATION', 'RESERVATIONS_BI','RESERVATION_LAB')
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table

) DT_DL




UNION ALL

-- PDCR TDIDW DATABASES
Select trim(databasename) as db_nm, cast('PDCR' as varchar(10)) as databasetype from 
 (
with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename='PDCRDATA'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table

) DT_PDCR


UNION ALL

-- PDCR 6750 DATABASES
Select trim(databasename) as db_nm, cast('PDCR' as varchar(10)) as databasetype from 
 (
SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME IN (
'PDCRADM', 'PDCRDATA_TDIDW', 'PDCRINFO'  ,'PDCRINFO_TDIDW'  ,'PDCRSTG'       )

) DT_PDCR_6750


UNION ALL

-- HR DATABASES
Select trim(databasename) as db_nm, cast('HR' as varchar(10)) as databasetype from 
 (
with recursive temp_table(databasename, ownername, depth) as
(select root.databasename, root.ownername, 0 as depth
from dbc.databases root
where root.databasename='DATASUPPORT_HR'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect
where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table

) DT_HR




UNION ALL

-- BACKUP DATABASES
Select trim(databasename) as db_nm, cast('BKP' as varchar(10)) as databasetype from 
 (
SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME = 'BI_BACKUP_TBL'
) DT_BKP

UNION ALL

-- RESTORE DATABASES
Select trim(databasename) as db_nm, cast('RESTORE' as varchar(10)) as databasetype from 
 (
SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME = 'BI_RESTORE'
) DT_RESTORE


UNION ALL

-- RESTORE DATABASES
Select trim(databasename) as db_nm, cast('ARCHIVE' as varchar(10)) as databasetype from 
 (
SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME = 'BI_ARCHIVE'
) DT_ARCHIVE

union all

Select trim(databasename) as db_nm, cast('MBYT' as varchar(10)) as databasetype from 
(
with recursive temp_table(databasename, ownername, depth) as ( select root.databasename, root.ownername, 0 as depth 
from dbc.databases root where root.databasename='DATASUPPORT_MBYT'
union all
select indirect.databasename, indirect.ownername,
seed.depth+1 as depth
from temp_table seed, dbc.databases indirect where seed.databasename=indirect.ownername
and indirect.ownername<>indirect.databasename
and depth<=100
)
select ownername, databasename, depth
from temp_table
)MBY 


UNION ALL

-- RESTORE DATABASES
Select trim(databasename) as db_nm, cast('SPRINT' as varchar(10)) as databasetype from 
 (
SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME IN (

-- sprint DB
'SPD_TD_CORE_T',
'SPD_TD_ETL_WRK_T',
'SPD0_STG_T' ,
'SPD0_TD_CORE_T' ,
'SPD0_TD_ETL_WRK_T' ,
'STG_SPD_T'  , 
'STG_SPD_W' ,
'STG_SPRNT_W' ,
'STG_SPRNT_T'                   
)
) DT_SPRINT
) 

sel databasetype,a.databasename,a.tablename,ColumnName , 
case 
when ConstraintText like '%RANGE_N%' then 'Range base'
else 'Case base'
end as Partition_Type,ConstraintText
from dbc.columnsv a,dbc.PartitioningConstraintsV b, dtall z 
    where 
     PartitioningColumn='Y'
    and a.databasename=b.databasename
    and a.tablename=b.tablename
    and a.databasename=z.db_nm
    and b.databasename=z.db_nm
    
