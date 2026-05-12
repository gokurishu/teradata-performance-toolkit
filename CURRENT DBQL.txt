--Current DBQL

SELECT
a.CollectTimeStamp,
a.procid,
a.queryid,
a.SessionID,
a.UserName,
a.DefaultDatabase AS DatabaseName,
a.StartTime,
a.FirstRespTime,
(a.FirstRespTime - a.StartTime) HOUR TO SECOND(6) AS FirstRespElapsedTime,
CAST (((a.FirstRespTime - a.StartTime) SECOND(4)) AS INTEGER) AS RespElapsTimeInSec,
a.TotalIOCount,
a.AMPCPUTime+ParserCPUTime TotalCPUTime,
a.SpoolUsage AS Spool_GB,
100-(NULLIFZERO(AMPCPUTime/NULLIFZERO(numofactiveamps))/(MaxAMPCPUTime)*100) "SkewFactor",
MaxAMPCPUTime * numofactiveamps AS impactCPU,
a.WDName,
a.NumResultRows,
a.delaytime,
a.ERRORCODE,
a.ErrorText,
b.sqlrowno,                                                  -- check this line
b.sqltextinfo
FROM  DBC.dbqlogtbl a INNER JOIN DBC.dbqlsqltbl b
ON a.procid = b.procid
AND a.queryid = b.queryid
AND a.UserName='KTRIVED1'
ORDER BY a.StartTime ASC;