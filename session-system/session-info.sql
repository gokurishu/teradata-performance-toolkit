---FIND SESSION INFO FROM SESSION ID AND DATE---------


SELECT 
a.logdate,
a.CollectTimeStamp,
a.SessionID,
a.QueryId,
a.UserName,
a.DefaultDatabase as DatabaseName,
a.StartTime,
a.FirstRespTime,
--(a.firstresptime - a.StartTime) HOUR to MINUTE as FIRSTRESPELAPSEDTIME,
--FIRSTRESPELAPSEDTIME MINUTE to SECOND as ELAPSEDTIME_SEC,
(a.FirstRespTime - a.StartTime) hour(2) to second(6) as FirstRespElapsedTime,
EXTRACT (HOUR FROM a.starttime) AS LogHour,
a.TotalIOCount,
a.AMPCPUTime+ParserCPUTime TotalCPUTime,
--a.SpoolUsage as Spool_GB,
100-(nullifzero(AMPCPUTime/HASHAMP())/(MaxAMPCPUTime)*100) "SkewFactor",
MaxAMPCPUTime * (HASHAMP()+1) AS ImpactCPU,
a.Queryband,
--a.delaytime,
a.Statementtype,
--a.errorcode,
a.ErrorText,
b.sqlrowno,                                              -- check this line
a.NumResultRows,                
b.sqltextinfo
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
WHERE a.logdate='2021-04-01'
AND a.SessionID= 29921301
ORDER BY a.StartTime