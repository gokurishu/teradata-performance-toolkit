SELECT
           count(DT.tablename) over (PARTITION BY DT.DATABASETYPE) as total_skewed_cnt,
           DT3.TOTAL_CNT,
            DT.DatabaseType,
            DT.DatabaseName,
            DT.TableName,
            DT.TotalCurrentPerm,
            DT.IMPACTED_SPACE,
            DT.MinCurrentPerm,
             DT.AvgCurrentPerm,
             DT.MaxCurrentPerm,
             DT.AvgSkewFactor,
             DT.MinSkewFactor,
             cast(99 as byteint) AS GOAL
            From
            (
        Select 
            CASE WHEN  PERF_WRK.MVC4.DATABASETYPE = 'DBA' AND a.DATABASENAME LIKE 'DL_%' THEN 'DL' ELSE PERF_WRK.MVC4.DATABASETYPE END AS DatabaseType,
             A.DatabaseName, 
             A.TableName, 
             Sum(A.CurrentPerm) As TotalCurrentPerm,
             Min(A.CurrentPerm) As MinCurrentPerm,
             Avg(A.CurrentPerm) As AvgCurrentPerm,
             Max(A.CurrentPerm) As MaxCurrentPerm,
             ((MAX(currentperm)*(HASHAMP()+1) ) )  AS ACTUAL_SPACE_USED,
             ACTUAL_SPACE_USED - TOTALCURRENTPERM  AS IMPACTED_SPACE,
             Cast((100 - ( Avg(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As AvgSkewFactor,
             Cast((100 - ( Min(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As MinSkewFactor
From DBC.TableSize A,
PERF_WRK.MVC4
WHERE
A.DATABASENAME = PERF_WRK.MVC4.DATABASENAME
Group By  1,2,3
Having TotalCurrentPerm >= 500000000
       And (AvgSkewFactor >= 10 )
          
       ) dt,
       
       (
select
database_type,
total_cnt
from
(
select t.databasename, t.tablename,CASE WHEN  PERF_WRK.MVC4.DATABASETYPE = 'DBA' AND PERF_WRK.MVC4.DATABASENAME LIKE 'DL_%' THEN 'DL' ELSE PERF_WRK.MVC4.DATABASETYPE END AS Database_Type,
count(t.tablename) over (partition by database_type) as total_cnt
from
dbc.tables t,
PERF_WRK.MVC4
where
t.databasename = PERF_WRK.MVC4.databasename
and 
Database_Type in ('FADS','EDW','IDW', 'DL')
) DT2
group by 1,2)  DT3
WHERE
DT.DatabaseType = DT3.DATABASE_tYPE
  
Order By 10 Desc, 11 Desc, 5 Desc;
----------------------------------------------------------------------------------------------------------------------------------------

SELECT
           count(DT.tablename) over (PARTITION BY DT.DATABASETYPE) as total_skewed_cnt,
           DT3.TOTAL_CNT,
            DT.DatabaseType,
            DT.DatabaseName,
            DT.TableName,
            DT.TotalCurrentPerm,
            DT.IMPACTED_SPACE,
            DT.MinCurrentPerm,
             DT.AvgCurrentPerm,
             DT.MaxCurrentPerm,
             DT.AvgSkewFactor,
             DT.MinSkewFactor,
             cast(99 as byteint) AS GOAL
            From
            (
        Select 
            CASE WHEN  PERF_WRK.MVC4.DATABASETYPE = 'DBA' AND a.DATABASENAME LIKE 'DL_%' THEN 'DL' ELSE PERF_WRK.MVC4.DATABASETYPE END AS DatabaseType,
             A.DatabaseName, 
             A.TableName, 
             Sum(A.CurrentPerm) As TotalCurrentPerm,
             Min(A.CurrentPerm) As MinCurrentPerm,
             Avg(A.CurrentPerm) As AvgCurrentPerm,
             Max(A.CurrentPerm) As MaxCurrentPerm,
             ((MAX(currentperm)*(HASHAMP()+1) ) )  AS ACTUAL_SPACE_USED,
             ACTUAL_SPACE_USED - TOTALCURRENTPERM  AS IMPACTED_SPACE,
             Cast((100 - ( Avg(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As AvgSkewFactor,
             Cast((100 - ( Min(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As MinSkewFactor
From DBC.TableSize A,
PERF_WRK.MVC4
WHERE
A.DATABASENAME = PERF_WRK.MVC4.DATABASENAME
Group By  1,2,3
Having TotalCurrentPerm >= 500000000
       And (AvgSkewFactor >= 10 )
          
       ) dt,
       
       (
select
database_type,
total_cnt
from
(
select t.databasename, t.tablename,CASE WHEN  PERF_WRK.MVC4.DATABASETYPE = 'DBA' AND PERF_WRK.MVC4.DATABASENAME LIKE 'DL_%' THEN 'DL' ELSE PERF_WRK.MVC4.DATABASETYPE END AS Database_Type,
count(t.tablename) over (partition by database_type) as total_cnt
from
dbc.tables t,
PERF_WRK.MVC4
where
t.databasename = PERF_WRK.MVC4.databasename
and 
Database_Type in ('FADS','EDW','IDW', 'DL')
) DT2
group by 1,2)  DT3
WHERE
DT.DatabaseType = DT3.DATABASE_tYPE
  
Order By 10 Desc, 11 Desc, 5 Desc;