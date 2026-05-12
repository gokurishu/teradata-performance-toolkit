--90 DAYS DBQL
SELECT 
a.logdate,
a.CollectTimeStamp,
a.procid,
a.queryid,
a.SessionID,
a.UserName,
c.objectdatabasename AS DatabaseName,
c.objecttablename,          
a.StartTime,
EXTRACT (HOUR FROM a.starttime) AS LogHour,
a.FirstRespTime,
(a.FirstRespTime - a.StartTime) HOUR TO SECOND(6) AS FirstRespElapsedTime,
( a.firstresptime - a.starttime second(4)) as Resptime_secs,
--CAST (((a.FirstRespTime - a.StartTime) SECOND(4)) AS INTEGER) AS RespElapsTimeInSec,
a.TotalIOCount,
a.AMPCPUTime+ParserCPUTime TotalCPUTime,
--a.SpoolUsage AS Spool_Usage,
MaxAMPCPUTime * numofactiveamps AS ImpactCPU,
100-(NULLIFZERO(AMPCPUTime/NULLIFZERO(numofactiveamps))/(MaxAMPCPUTime)*100) "Skew Factor",
a.Statementtype,
--a.delaytime,
a.ERRORCODE,
a.ErrorText,
b.sqlrowno,                                                  -- check this line
a.NumResultRows,
b.sqltextinfo
FROM  PDCRINFO.dbqlogtbl_hst a INNER JOIN PDCRINFO.dbqlsqltbl_hst b
ON a.procid = b.procid
AND a.queryid = b.queryid
AND a.logdate = b.logdate INNER JOIN (SEL DISTINCT objectdatabasename,ObjectTableName,queryid, procid, logdate FROM PDCRINFO.dbqlobjtbl_hst
WHERE objectdatabasename = 'USER_DW'
AND objecttablename IN(
'AA_EIP_PLAN_NEWBAN',
'AA_EIP_PLAN_3YRSPLUS',
'AA_EIP_PLAN_LT1YR',
'AA_EIP_PLAN_1_3YRS'
)
--AND objectcolumnname LIKE 'CALENDAR_DATE%'
AND logdate BETWEEN DATE-90 AND DATE) AS c
ON a.procid = c.procid
AND a.queryid = c.queryid
AND a.logdate = c.logdate 
WHERE a.logdate BETWEEN DATE -90 AND DATE


---------------------------------------------------------------------------------------------------------------------------------------------
--TABLE SIZE
SELECT
databasename as "Database Name",
TABLENAME as "Table Name",
(MAX(CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 AS "Size in GB",
SUM(CURRENTPERM) /(1024*1024*1024) AS CURRENTPERM,
((MAX(CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 ) -  (SUM(CURRENTPERM) /(1024*1024*1024)) IMPACTED_SPACE,
(100 - (AVG(CURRENTPERM)/MAX(CURRENTPERM)*100)) AS SKEWFACTOR
FROM
DBC.TABLESIZEV
WHERE DATABASENAME in('USER_DW')
AND
TABLENAME IN (
'AA_EIP_PLAN_NEWBAN',
'AA_EIP_PLAN_3YRSPLUS',
'AA_EIP_PLAN_LT1YR',
'AA_EIP_PLAN_1_3YRS'
)
GROUP BY 1,2;   
--------------------------------------------------------------------------------------------------------------------------------------------------
--TABLE DETAILS
SEL
DataBaseName,            
TableName,                 
Version,                       
TableKind,                    
ProtectionType,                
JournalFlag,                   
CreatorName,                                                    
CreateTimeStamp,               
LastAlterName,                 
LastAlterTimeStamp,            
AccessCount,                   
LastAccessTimeStamp           
FROM DBC.TABLESV
WHERE DATABASENAME='STG_BSCS_GG_W'
AND
TABLENAME IN
(

)
;
-----------------------------------------------------------------------------------------------------------------------------------------------------
--- Format Jayson likes ( Combination of TablesV and TableSize )
SELECT 
Trim(t.databasename) AS Database_Name,
Trim(t.TableName) AS Table_Name, 
Trim(t.creatorname) AS CREATOR_NAME,
Cast(t.createtimestamp AS DATE) AS CREATED_DATE,
LastAlterName,
(MAX(CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 AS "Size in GB",
Cast(t.lastaccesstimestamp AS DATE) AS LAST_ACCESS_DATE
FROM        dbc.tables t
LEFT JOIN   dbc.tablesize ts
ON t.databasename = ts.databasename
AND         t.TableName = ts.TableName
WHERE       t.databasename = 'user_dw'
AND         t.TableName 
IN
('')
GROUP BY    1,2,3,4,5,7
ORDER BY    6 DESC;