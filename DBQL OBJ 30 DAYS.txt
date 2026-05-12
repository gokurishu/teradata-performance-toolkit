--DBQL OBJ 30 DAYS 

SELECT 
a.logdate,
a.CollectTimeStamp,
a.procid,
a.SessionID,
a.UserName,
a.DefaultDatabase AS DatabaseName,
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
AND a.logdate = b.logdate INNER JOIN (SEL DISTINCT queryid, procid, logdate FROM PDCRINFO.dbqlobjtbl_hst
WHERE objectdatabasename = 'STG_OER_T'
AND objecttablename = 'L_ZEVM_HDR'
--AND objectcolumnname LIKE 'CALENDAR_DATE%'
AND logdate BETWEEN DATE-30 AND DATE) AS c
ON a.procid = c.procid
AND a.queryid = c.queryid
AND a.logdate = c.logdate 
WHERE a.logdate BETWEEN DATE -30 AND DATE
--AND b.logdate BETWEEN  DATE-30 AND DATE
--AND a.username ='INVMGMTUSWM10001'
--AND ampcputime >10000
--AND a.StatementType='COLLECT STATISTICS';
