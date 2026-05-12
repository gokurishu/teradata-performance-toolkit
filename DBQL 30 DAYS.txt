----DBQL 30 DAYS DBQL LOG---------

SELECT a.logdate,
a.CollectTimeStamp,
a.SessionID,
a.QueryId,
a.UserName,
a.DefaultDatabase as DatabaseName,
a.Queryband,
a.StartTime,
a.FirstRespTime,
--(a.firstresptime - a.StartTime) HOUR to MINUTE as FIRSTRESPELAPSEDTIME,
--FIRSTRESPELAPSEDTIME MINUTE to SECOND as ELAPSEDTIME_SEC,
(a.FirstRespTime - a.StartTime) hour(2) to second(6) as FirstRespElapsedTime,
( a.firstresptime - a.starttime second(4)) as resptime,
EXTRACT (HOUR FROM a.starttime) AS LogHour,
a.TotalIOCount,
a.AMPCPUTime+ParserCPUTime TotalCPUTime,
a.WDName,
100-(nullifzero(AMPCPUTime/HASHAMP())/(MaxAMPCPUTime)*100) "SkewFactor",
MaxAMPCPUTime * (HASHAMP()+1) AS ImpactCPU,
a.ClientID,
a.delaytime,
a.Statementtype,
a.errorcode,
a.ErrorText,
b.sqlrowno,                                              -- check this line
a.NumResultRows,                 
b.sqltextinfo
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
--where ampcputime > 10000
--AND A.USERNAME='APPL_SSI_AZURE'
AND sqltextinfo LIKE '%Sim_Card_Handset_Hist_VT%'
--AND a.Statementtype='INSERT'
and a.logdate between date - 30 and date
AND b.logdate BETWEEN DATE - 30 AND DATE
ORDER BY TotalCPUTime DESC;
