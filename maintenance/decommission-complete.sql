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
WHERE DATABASENAME in('IDW_TD_CORE_T')
AND
TABLENAME ='PAYMENT'
GROUP BY 1,2;   


--------------------------------------------------------------------------------------------------------------------------------------------------
--Table Info

SELECT
DataBaseName,            
TableName,                 
Version,                       
TableKind,                    
RequestText,           
CreatorName,                                                    
CreateTimeStamp,               
LastAlterName,                 
LastAlterTimeStamp,            
AccessCount,                   
LastAccessTimeStamp           

FROM DBC.TABLESV

WHERE DATABASENAME=''
AND
TABLENAME='';


--------------------------------------------------------------------------------------------------------------------------------------------------
--Database Info

SEL * FROM DBC.DATABASES
WHERE
DATABASENAME='IDW_TD_CORE_T';

--------------------------------------------------------------------------------------------------------------------------------------------------
--Table Growth

SEL LOGDATE,SUM(currentperm) / (1024*1024*1024) AS "Sum(Current_Perm)"
FROM 
PDCRINFO.TableSpace_Hst                
WHERE databasename = 'IDW_TD_CORE_T'             
AND tablename = 'PAYMENT'
GROUP BY 1
ORDER BY 1 ASC;

--------------------------------------------------------------------------------------------------------------------------------------------------
--Table Usage

SEL * FROM IDW_STATS_V.IDW_TABLE_USAGE_DETAILS
WHERE DATABASENAME='IDW_TD_CORE_T'
AND TABLENAME='PAYMENT';

--------------------------------------------------------------------------------------------------------------------------------------------------


--LOAD_DT
SELECT MIN(LOAD_DTTM),MAX(LOAD_DTTM)
FROM 
IDW_TD_CORE_T.PAYMENT;

--------------------------------------------------------------------------------------------------------------------------------------------------