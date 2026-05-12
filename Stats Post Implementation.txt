--90 DAYS STATS POST IMPLEMENTATION

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
WHERE objectdatabasename IN('EDW_D02','EDW_D01','IDW_TD_MKTG_T')
AND objecttablename IN(
'FINANCIAL_ACCRUAL_ACTIVITY',
'FINANCIAL_ACCRUAL_ACTIVITY',
'TD_SERVICE_AGREEMENT',
'TD_BILLING_ACCOUNT',
'T_AUTHORIZE',
'B2C_DEMOGRAPHIC'
)
--AND objectcolumnname LIKE 'CALENDAR_DATE%'
AND logdate BETWEEN DATE-90 AND DATE) AS c
ON a.procid = c.procid
AND a.queryid = c.queryid
AND a.logdate = c.logdate 
WHERE a.logdate BETWEEN DATE -90 AND DATE
AND a.StatementType='COLLECT STATISTICS'
order by a.logdate,objecttablename asc;