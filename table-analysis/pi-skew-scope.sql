-- PI SKEW SCOPE

with para as
(sel * from
(
SELECT    
CAST(TRIM(DatabaseName) as CHAR(30)) as DatabaseName,
CAST(SUM(MaxPerm)/1024/1024/1024 as DEC(10,2)) as Allocated_Space_GB,
CAST(SUM(CurrentPerm)/1024/1024/1024 as DEC(10,2)) as CurrentPerm_GB,
CAST((Total_Used_space_GB - CurrentPerm_GB) as DEC(10,2)) as Wasted_GB,
CAST(MAX(CurrentPerm)*(hashamp()+1)/1024/1024/1024 as DEC(18,2)) as Total_Used_space_GB,
CAST((100*Total_Used_space_GB/NULLIFZERO(Allocated_Space_GB)) as DEC(10,2)) as Space_Pct
FROM    DBC.DiskSpaceV S
where databasename not in ('BI_ARCHIVE')
GROUP BY 1
)abc
where
Space_Pct>=90
)

sel * from
(
SELECT    D.DatabaseName AS DatabaseName, D.TableName AS ObjectName,
        CAST (D.CreateTimeStamp AS DATE) AS Create_Date,
CAST(SUM(a.CurrentPerm)/1024/1024/1024 as DEC(10,2)) as CurrentPerm_GB,
      COUNT(*) * (MAX(CURRENTPERM)  - AVG(CURRENTPERM)) / 1024/1024/1024 AS WASTEDSPACE,
             Cast((100 - ( Avg(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As AvgSkewFactor,
                  'No MVC' as Space_cat

    FROM    dbc.TABLESV D  
    join dbc.tablesizeV a  
    on    d.databasename=a.databasename   
    and d.tablename=a.tablename  
    join para z
    on a.databasename=z.DatabaseName
    
WHERE    (D.databasename NOT IN ('spool_reserve','spoolreserve','$NETVAULT_CATALOG',
         'All','console','Crashdumps','DBC','DBCMANAGER','dbcmngr','dbcmngr12',
        'dbqm','dbqrymgr','Default','HIGA','NETVAULT1','PUBLIC','SQLJ',
      'Sys_Calendar','SYS_MGMT','SYSLIB','SYSSPATIAL','SystemFe',  'SYSUDTLIB',
        'SYSUSR','TD_SYSFNLIB','TMADMIN','viewpoint') 
    and trim(d.databasename) NOT IN ('abcdef')  
    AND (D.databasename NOT LIKE ALL ('%PDCR%','%PMCP%','%QCD%','%tdwm%',
        '%tswiz%','%twm%') 
    and trim(D.databasename) not like all ('abcdef')))  
    AND    (LastAccessTimeStamp IS NOT NULL 
    AND LastAccessTimeStamp(date) < date-90) 
group    by 1,2,3,7
)pqr
union all
Select A.DatabaseName, 
             A.TableName, 
             CAST (b.CreateTimeStamp AS DATE) AS Create_Date,
                        Sum(A.CurrentPerm) /1024/1024/1024 As TotalCurrentPerm,
             COUNT(*) * (MAX(CURRENTPERM)  - AVG(CURRENTPERM)) / 1024/1024/1024 AS WASTEDSPACE,
           Cast((100 - ( Avg(A.CurrentPerm) / NullifZero(Max(A.CurrentPerm)) * 100 )) As Decimal(18,2)) As AvgSkewFactor,
             'Skewed PI' as Space_cat
From DBC.TableSizeV A,
DBC.TABLESV B, para z
where
A.DATABASENAME = B.DATABASENAME AND
A.TABLENAME = B.TABLENAME AND
B.TABLEKIND = 'T' 
and A.DATABASENAME=z.DATABASENAME
and b.DATABASENAME=z.DATABASENAME
Group By 1, 2,3,7
having
WASTEDSPACE >= 50 
and avgSkewFactor >= 30
union all
sel
a.DATABASENAME,
a.TABLENAME,
CAST (z.CreateTimeStamp AS DATE) AS Create_Date,
Sum(a.CurrentPerm) /1024/1024/1024 As TotalCurrentPerm,
   COUNT(*) * (MAX(CURRENTPERM)  - AVG(CURRENTPERM)) / 1024/1024/1024 AS WASTEDSPACE,
    Cast((100 - ( Avg(a.CurrentPerm) / NullifZero(Max(a.CurrentPerm)) * 100 )) As Decimal(18,2)) As AvgSkewFactor,
      'Stale Table' as Space_cat
      
FROM
dbc.tablesizev a,dbc.tablesv z,para q,
(
SELECT
DT_A.DATABASENAME,
DT_A.TABLENAME,
DT_A.CURRENTPERM/1024/1024/1024 AS CURR_PERM_DY1,
DT_B.CURRENTPERM AS CURR_PERM_DY31,
DT_C.CURRENTPERM AS CURR_PERM_DY61,
DT_D.CURRENTPERM/1024/1024/1024 AS CURR_PERM_DY91,
CURR_PERM_DY1 - CURR_PERM_DY91 AS THE_DIFF
FROM
(
SELECT
DATABASENAME, TABLENAME, CURRENTPERM
FROM
PDCRINFO.TABLESPACE_HST
WHERE
LOGDATE = DATE - 1
) DT_A

INNER JOIN

(
SELECT
DATABASENAME, TABLENAME, CURRENTPERM
FROM
PDCRINFO.TABLESPACE_HST
WHERE
LOGDATE = DATE - 31
) DT_B

ON
DT_A.DATABASENAME = DT_B.DATABASENAME
AND
DT_A.TABLENAME = DT_B.TABLENAME


LEFT JOIN


(
SELECT
DATABASENAME, TABLENAME, CURRENTPERM
FROM
PDCRINFO.TABLESPACE_HST
WHERE
LOGDATE = DATE - 61
) DT_C

ON
DT_A.DATABASENAME = DT_C.DATABASENAME
AND
DT_A.TABLENAME = DT_C.TABLENAME



LEFT JOIN


(
SELECT
DATABASENAME, TABLENAME, CURRENTPERM
FROM
PDCRINFO.TABLESPACE_HST
WHERE
LOGDATE = DATE - 91
) DT_D

ON
DT_A.DATABASENAME = DT_D.DATABASENAME
AND
DT_A.TABLENAME = DT_D.TABLENAME


WHERE
THE_DIFF = 0
)b
where
a.databasename=b.databasename
and a.tablename=b.tablename
and a.databasename=z.databasename
and a.tablename=z.tablename
and a.databasename=q.databasename
and z.databasename= q.databasename
group by 1,2,3,7
union all

SELECT    D.DatabaseName AS DatabaseName, D.TableName AS ObjectName,
CAST (D.CreateTimeStamp AS DATE) AS Create_Date,
sum(a.currentperm)/1024/1024/1024 AS ObjectSize,
     max(a.currentperm)/1024/1024/1024 * (HASHAMP()+1) AS SpaceImpact  ,
(100-(Avg(a.Currentperm)/Max(a.Currentperm))*100) as Skew_Factor,
'Unused Table' as Space_cat
         
FROM    dbc.TABLESV D  join dbc.tablesizeV a  
    on    d.databasename=a.databasename   
    and d.tablename=a.tablename  
    join para z
    on      z.databasename=d.databasename
        and z.databasename=a.databasename
WHERE    (D.databasename NOT IN ('spool_reserve','spoolreserve','$NETVAULT_CATALOG',
         'All','console','Crashdumps','DBC','DBCMANAGER','dbcmngr','dbcmngr12',
        'dbqm','dbqrymgr','Default','HIGA','NETVAULT1','PUBLIC','SQLJ',
        'Sys_Calendar','SYS_MGMT','SYSLIB','SYSSPATIAL','SystemFe',  'SYSUDTLIB',
        'SYSUSR','TD_SYSFNLIB','TMADMIN','viewpoint') 
    and trim(d.databasename) NOT IN ('abcdef')  
    AND (D.databasename NOT LIKE ALL ('%PDCR%','%PMCP%','%QCD%','%tdwm%',
        '%tswiz%','%twm%') 
    and trim(D.databasename) not like all ('abcdef')))  
    AND    (LastAccessTimeStamp IS NOT NULL 
    AND LastAccessTimeStamp(date) < date-90)     
group    by 1,2,3

union all

SELECT    D.DatabaseName AS DatabaseName, D.TableName AS ObjectName,
CAST (D.CreateTimeStamp AS DATE) AS Create_Date,
sum(a.currentperm)/1024/1024/1024 AS ObjectSize,
     max(a.currentperm)/1024/1024/1024 * (HASHAMP()+1) AS SpaceImpact  ,
(100-(Avg(a.Currentperm)/Max(a.Currentperm))*100) as Skew_Factor,
'Backup Table' as Space_cat
         
FROM    dbc.TABLESV D  join dbc.tablesizeV  a
on d.databasename=a.databasename
and d.tablename=a.tablename
join para z
on a.databasename=z.databasename
and d.databasename=z.databasename
and d.tablename like any ('%BKP%','%backup%')
group by 1,2,3;

