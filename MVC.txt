

----CHECK IN THE PDCR LOG TABLE WHETHER THE QUERY IS USED IN THE PAST 30 DAYS IF NOT USED IN THE LAST 30 DAYS THEN CHECK FOR 90 DAYS---



SHOW TABLE STG_OER_T.L_ZEVM_HDR   -- SEE TABLE STRUCTURE AND COPY IT ON NEW EDITOR

-------DETAILS ABOUT THE TABLES ----------
SEL * FROM DBC.TABLESV
WHERE TABLENAME LIKE'%F_WHSL_SUB_LAST_USAGE_REFILL%'


SEL CAST(Count(*) AS BIGINT) from STG_OER_T.L_ZEVM_HDR  --COUNT THE NO OF ROWS IN THE TABLE


----- TOO SEE FREQUENT ITEM FOR NUMERIC DATA TYPE -----

SEL LOAD_DTTM  , count(*) (float) cn
,(cn/1875901127)*100 Prcnt 
from STG_OER_T.L_ZEVM_HDR
--having cn > 29902966.51
group by 1 order by 2 desc


----- TOO SEE FREQUENT ITEM FOR CHAR DATA TYPE -----

sel  ''''||CLIENT|| ''''||','  , count(*) (float) cn
,(cn/1875901127)*100 Prcnt 
from STG_OER_T.L_ZEVM_HDR
--having cn > 29902966.51
group by 1 order by 2 desc

----- TO CHECK THE SIZE OF THE ORIGINAL TABLE WRT TO THE COMPRESSED TABLE ----------------- 
SEL
Databasename,Tablename,
SUM(CURRENTPERM)/1024/1024/1024 AS Current_PERM_GB           
FROM DBC.TablesizeV
WHERE 
Tablename IN ('L_ZEVM_HDR') 
--AND Databasename='teracopy_stage'
GROUP BY 1,2




HELP TABLE DBC.TablesizeV



COMPRESS (TIMESTAMP '2018-12-31 00:00:00.000000')

PARTITION BY ( RANGE_N(CAST((EFF_START_DTTM ) AS DATE AT TIME ZONE 'America Pacific') BETWEEN '2014-11-28' AND '2025-12-31' EACH INTERVAL '1' DAY ,
NO RANGE, UNKNOWN),CASE_N(
CURR_IND =  'Y',
CURR_IND =  'N') )

------------------------------------------------------------------------------------------------------------------------------------------------------------------------


 -- FIND LIST OF TABLES ELGIBLE FOR MVC
 
 SELECT dbt.DATABASENAME, dbt.TABLENAME, 
            MAX(CASE WHEN (compressvaluelist IS NOT NULL) 
                     THEN (CASE WHEN INDEX(compressvaluelist,',') > 0
                                THEN '3. MVC '
                                ELSE '2. SVC '
                                END)
                     ELSE '1. NONE'
                     END) AS Compress_Type,
            MIN(pds.Current_Perm/(1024*1024*1024)) AS Current_Perm
     FROM DBC.columns AS dbt, (SELECT t.DATABASENAME, t.TABLENAME, 
                                     SUM(ts.CurrentPerm) AS Current_Perm
                               FROM DBC.Tables AS t, DBC.TableSize AS ts
                               WHERE t.DATABASENAME = ts.DATABASENAME
                               AND   t.TABLENAME = ts.TABLENAME
                               AND   ts.TABLENAME <> 'ALL'
                               HAVING Current_Perm > 1000000000
                               GROUP BY 1,2) AS pds
     WHERE dbt.DATABASENAME IN ('FADS_T')
     AND   dbt.DATABASENAME = pds.DATABASENAME
     AND   dbt.TABLENAME = pds.TABLENAME
     -- HAVING Compress_Type = '1. NONE'
     GROUP BY 1,2
     ORDER BY 1,3,4 DESC, 2;
	 
----------------------------------------------------------------------------------------------------------

-- FIND LIST OF COMPRESEBLE COLUMN OUT OF TOTAL COLUMN FOR MVC

SEL     a.Databasename AS DatabaseName, a.tablename AS TableName, cols.Totcolumns AS TotalColumns, a.NotCompressed AS CompressibleColumns,cast(b.TableSize AS Decimal(30,0)) AS TableSize, cast ((b.tablesize/
(1024*1024*1024)) as decimal(8,2)) as TableSize_GBs
FROM               
                        
(                       
SELECT      
a.DatabaseName
,a.TableName
/* To identify which columns are compressed and which are not */
,SUM(             
CASE   WHEN   a.Compressible = 'C' THEN 1         
ELSE    0          
END     ) AS Compressed
,SUM(         
CASE   WHEN   a.Compressible='N' THEN 1           
ELSE    0          
END)  AS NotCompressed
FROM dbc.COLUMNS a INNER JOIN dbc.tables c           
ON a.DatabaseName =c.DatabaseName                   
AND     a.tablename =c.tablename 
/* Condition included to find only the base tables & exclude the views, macros,..) */
WHERE c.TableKind  ='T'
/* Condition included to exclude the data types which can not be compressed like clob, blob, period, UDT..) */
AND columntype NOT IN ('BO', 'CO', 'PD', 'PM', 'PS', 'PT', 'PZ', 'UT')
/* Subquery added to eclude the PI & PPI columns which can not be compressed */
AND (a.databasename, a.tablename, a.columnname) NOT IN 
(SELECT databasename, tablename, columnname 
FROM dbc.indices
WHERE indextype IN ('P', 'Q')
) 
AND (A.databasename) NOT IN
('spool_reserve','spoolreserve','$NETVAULT_CATALOG',
'All','console','Crashdumps','DBC','DBCMANAGER','dbcmngr','dbcmngr12',
'dbqm','dbqrymgr','Default','HIGA','NETVAULT1','PUBLIC',
'SQLJ','Sys_Calendar','SYS_MGMT','SYSLIB','SYSSPATIAL',
'SystemFe','SYSUDTLIB','SYSUSR','TD_SYSFNLIB','TMADMIN',
'viewpoint')  
AND (A.databasename) NOT LIKE ALL  ('%QCD%',
'%tdwm%','%tswiz%','%twm%')     
GROUP BY 1, 2
HAVING Compressed = 0
) a INNER JOIN   /* Join with tablesize for find the size of the tables */
(SEL     databasename, tablename, SUM(currentperm) AS TableSize
FROM               
dbc.tablesize                       
GROUP BY 1, 2) b            
 ON       a.Databasename =b.databasename
AND a.tablename = b.tablename  
INNER JOIN  /* Joiining with dbc.columns again to identify the total numbers of columns in the table */
(SELECT databasename, tablename, COUNT(columnname) AS TotColumns
FROM dbc.COLUMNS
GROUP BY 1, 2
) cols
ON a.databasename = cols.databasename
AND a.tablename = cols.tablename 
where a.databasename='FADS_T'
ORDER  BY 5 DESC;

----------------------------------------------------------------------------------------------------------------------------------------


-- MORE SCOPE MVC QUERY 

SELECT    
a.Databasename AS DatabaseName,
a.tablename AS TableName, 
cols.Totcolumns AS TotalColumns,
a.Compressed AS CompressedColumns, 
a.NotCompressed AS CompressibleColumns,
cast(b.TableSize AS Decimal(30,0)) AS TableSize, 
cast ((b.tablesize/(1024*1024*1024)) as decimal(8,2)) as TableSize_GBs
FROM                                   
(                       
SELECT      
a.DatabaseName
,a.tablename
/* To identify which columns are compressed and which are not */
,SUM(             
CASE   WHEN   a.Compressible = 'C' THEN 1         
ELSE    0          
END     ) AS Compressed
,SUM(         
CASE   WHEN   a.Compressible='N' THEN 1           
ELSE    0          
END)  AS NotCompressed
FROM dbc.COLUMNS a INNER JOIN dbc.tables c           
ON a.DatabaseName =c.DatabaseName                   
AND     a.tablename =c.tablename 
/* Condition included to find only the base tables & exclude the views, macros,..) */
WHERE c.TableKind  ='T'
/* Condition included to exclude the data types which can not be compressed like clob, blob, period, UDT..) */
AND columntype NOT IN ('BO', 'CO', 'PD', 'PM', 'PS', 'PT', 'PZ', 'UT')
/* Subquery added to eclude the PI & PPI columns which can not be compressed */
AND (a.databasename, a.tablename, a.columnname) NOT IN 
(SELECT databasename, tablename, columnname 
FROM dbc.indices
WHERE indextype IN ('P', 'Q')
) 
AND (A.databasename) NOT IN
('spool_reserve','spoolreserve','$NETVAULT_CATALOG',
'All','console','Crashdumps','DBC','DBCMANAGER','dbcmngr','dbcmngr12',
'dbqm','dbqrymgr','Default','HIGA','NETVAULT1','PUBLIC',
'SQLJ','Sys_Calendar','SYS_MGMT','SYSLIB','SYSSPATIAL',
'SystemFe','SYSUDTLIB','SYSUSR','TD_SYSFNLIB','TMADMIN',
'viewpoint')  
AND  (A.databasename) NOT LIKE ALL  ('%QCD%',
'%tdwm%','%tswiz%','%twm%')   
GROUP BY 1, 2
HAVING Compressed > 0
AND NotCompressed > 0
) a INNER JOIN   /* Join with tablesize for find the size of the tables */
(SEL     databasename, tablename, SUM(currentperm) AS TableSize
FROM               
dbc.tablesize                       
GROUP BY 1, 2) b            
 ON       a.Databasename =b.databasename
AND a.tablename = b.tablename  
INNER JOIN  /* Joiining with dbc.columns again to identify the total numbers of columns in the table */
(SELECT databasename, tablename, COUNT(columnname) AS TotColumns
FROM dbc.COLUMNS
GROUP BY 1, 2
) cols
ON a.databasename = cols.databasename
AND a.tablename = cols.tablename 
where
a.databasename='FADS_CSR_HIST_T'
ORDER  BY 6 DESC;