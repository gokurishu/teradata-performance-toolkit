--DATABASE INSIGHTS QUERIES

-- SPACE STATUS // TELLS TOTAL SPACE AND REMAINING SPACE DATA DB WISE
SELECT 
DB_H.LOGDATE AS THE_DATE, 
COALESCE(DT_ALL.DATABASETYPE,'DBA') AS DB_TYPE,
SUM(DB_H.CURRENTPERM) / 1024/1024/1024/1024 AS CURRPERM_TB,
SUM(DB_H.MAXPERM) /1024/1024/1024/1024 AS MAX_PERM_TB,
SUM(CURRPERM_TB) OVER (PARTITION BY DB_H.LOGDATE)  AS TOTAL_CURRPERM_TB,
SUM(MAX_PERM_TB) OVER (PARTITION BY DB_H.LOGDATE)  AS TOTAL_MAX_PERM_TB,
SUM(MAX_PERM_TB) OVER (PARTITION BY DB_H.LOGDATE) * .7 AS MAX_PERM_TB_70
FROM
DBC.DATABASES DB1
LEFT JOIN
pdcrinfo.databasespace_hst DB_H
ON
DB1.DATABASENAME = DB_H.DATABASENAME
LEFT JOIN

(
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
WHERE DATABASENAME NOT IN ('BI_BACKUP_TBL', 'BI_RESTORE', 'BI_ARCHIVE')



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
Select trim(databasename) as db_nm, cast('New_Prod_Alloc' as varchar(10)) as databasetype from 

 (

SELECT DATABASENAME FROM DBC.DATABASES WHERE DATABASENAME = 'new_prod_alloc'

) DT_allocation

) DT_ALL
ON
DB1.DATABASENAME = DT_ALL.DB_NM
WHERE DB1.DBKIND = 'D'
AND DB_H.LOGDATE =date-1
AND DB1.databasename <> 'SPOOLRESERVE'
GROUP BY 1,2

------------------------------------------------------------------------------------------------------------------------------------------------
--SPACE GROWTH
--Previousday's Space growth >50 GB along with average space growth trend based on 30 days

sel * from
 (
  sel
  abc.DatabaseName,
  avgs.databasetype,
     Past_avg_growth,
   CURRENTPERM-avg_curr as growth,
  MAXPERM,
  CURRENTPERM,
  PERMPCTUSED
  from
  (
  Select
    year_of_calendar
   ,Month_of_Year
   ,Week_of_year
   ,DatabaseName
   ,AccountName
   ,Logdate   as Logdate
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =date-1
  AND  c.Calendar_date =date-1
 Group by 1,2,3,4,5,6
)abc, (-- IDW DATABASES
Select trim(databasename) as databasename, cast('IDW' as varchar(10)) as databasetype from 
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
WHERE DATABASENAME NOT IN ('BI_BACKUP_TBL', 'BI_RESTORE', 'BI_ARCHIVE')



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
) DT_ARCHIVE) b,(  sel
  abc.DatabaseName,
  databasetype,
 avg( CURRENTPERM) as avg_curr

  from
  (
  Select
    year_of_calendar
   ,Month_of_Year
   ,Week_of_year
   ,DatabaseName
   ,AccountName
   ,Logdate   as Logdate
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  = date-2
  AND  c.Calendar_date = date-2
 Group by 1,2,3,4,5,6
)abc, (-- IDW DATABASES
Select trim(databasename) as databasename, cast('IDW' as varchar(10)) as databasetype from 
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
WHERE DATABASENAME NOT IN ('BI_BACKUP_TBL', 'BI_RESTORE', 'BI_ARCHIVE')



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
) DT_ARCHIVE) b
where 
abc.DATABASENAME=b.DATABASENAME
group by 1,2)avgs, (sel databasename,avg(growth) as Past_avg_growth
 from
 (
 sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-2
  AND  c.Calendar_date =date-2
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-3
  AND  c.Calendar_date =date-3
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
Union all 
 sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-3
  AND  c.Calendar_date =date-3
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-4
  AND  c.Calendar_date =date-4
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-4
  AND  c.Calendar_date =date-4
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-5
  AND  c.Calendar_date =date-5
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-5
  AND  c.Calendar_date =date-5
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-6
  AND  c.Calendar_date =date-6
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-6
  AND  c.Calendar_date =date-6
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-7
  AND  c.Calendar_date =date-7
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-7
  AND  c.Calendar_date =date-7
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-8
  AND  c.Calendar_date =date-8
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-8
  AND  c.Calendar_date =date-8
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-9
  AND  c.Calendar_date =date-9
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
  sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-9
  AND  c.Calendar_date =date-9
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-10
  AND  c.Calendar_date =date-10
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
   sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-10
  AND  c.Calendar_date =date-10
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-11
  AND  c.Calendar_date =date-11
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
   sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-11
  AND  c.Calendar_date =date-11
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-12
  AND  c.Calendar_date =date-12
  
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all
   sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-12
  AND  c.Calendar_date =date-12
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-13
  AND  c.Calendar_date =date-13
 
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all

   sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-13
  AND  c.Calendar_date =date-13
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-14
  AND  c.Calendar_date =date-14 
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 union all

   sel abc.databasename,abc.logdate,abc.CURRENTPERM- pqr.CURRENTPERM as growth
 from
 (
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-14
  AND  c.Calendar_date =date-14
  
 Group by 1,2
 )abc,(
 Select
Logdate   as Logdate,
databasename
   ,MAX(CURRENTPERM/1024/1024/1024)     as CURRENTPERM
   ,MAX(PEAKPERM/1024/1024/1024)        as PEAKPERM
   ,MAX(MAXPERM/1024/1024/1024)         as MAXPERM
   ,MAX(CURRENTPERMSKEW) as CURRENTPERMSKEW
   ,MAX(PERMPCTUSED)     as PERMPCTUSED
 FROM PDCRINFO.DatabaseSpace_Hst a
 INNER JOIN PDCRINFO.Calendar c
 ON a.Logdate = c.Calendar_date
 WHERE  a.LogDate  =  date-15
  AND  c.Calendar_date =date-15
 
 Group by 1,2)pqr
 where
 abc.databasename=pqr.databasename
 )xyz
 where growth>=0
 group by 1)ghv
 
where 
abc.DATABASENAME=b.DATABASENAME
and avgs.DATABASENAME=b.DATABASENAME
and abc.DATABASENAME=avgs.DATABASENAME
and ghv.DATABASENAME=b.DATABASENAME
and abc.DATABASENAME=ghv.DATABASENAME
)abc
where growth>10
and databasetype not in ('DL','DBA')

---------------------------------------------------------------------------------------------------------------------------

-- USEFUL - -GET TOP DATABASE UNDER EACH SCHEMA
--DATABASE ALERT
--Database Usage >=90%

sel databasetype,
abc.DatabaseName,
CurrentPerm_GB,
Wasted_GB,
Allocated_Space_GB,
Total_Used_space_GB,
Space_Pct,
Past_avg_growth
from
(
SELECT     CAST(TRIM(DatabaseName) as CHAR(30)) as DatabaseName,
                CAST(SUM(MaxPerm)/1024/1024/1024 as DEC(10,2)) as Allocated_Space_GB,
                CAST(SUM(CurrentPerm)/1024/1024/1024 as DEC(10,2)) as CurrentPerm_GB,
                CAST((Total_Used_space_GB - CurrentPerm_GB) as DEC(10,2)) as Wasted_GB,
                CAST(MAX(CurrentPerm)*(hashamp()+1)/1024/1024/1024 as DEC(18,2)) as Total_Used_space_GB,
                CAST((100*Total_Used_space_GB/NULLIFZERO(Allocated_Space_GB)) as DEC(10,2)) as Space_Pct
FROM    