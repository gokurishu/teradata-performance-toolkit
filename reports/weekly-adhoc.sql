--TO GET DATA FOR THE WEEK ANALYSIS OF THE CULPRIT USERS
SEL LogDate,LogHour,UserName,AccountName,SUM_CPU,SUM_DSK
FROM PDCRINFO.ACCTG_HST
WHERE LogDate BETWEEN '2020-02-12' AND '2020-02-18'
ORDER BY SUM_CPU DESC;



--TO FIND CULPRIT USERS WHO CONSUME HIGH CPU IN THEIR QUERIES BASED ON SPECIFIC LOG DATE AND LOG HOUR
SEL LogDate,LogHour,UserName,AccountName,SUM_CPU,SUM_DSK
FROM PDCRINFO.ACCTG_HST
WHERE LogDate='2020-02-16'
and LogHour between 7 and 8
ORDER BY SUM_CPU DESC;



--- FIND CLUPRIT USERS IN GROUP BY LOGHOUR AND SUM CPU CONSUMED

SEL LogHour,UserName,SUM_CPU
FROM PDCRINFO.ACCTG_HST
group by 1,2,3
ORDER BY SUM_CPU DESC
WHERE LogDate='2020-02-04'
--and LogHour between 10 and 11


---FIND WHICH STATEMENT CONSUMES HIGHEST CPU

SELECT STATEMENTTYPE,SUM(AMPCPUTIME)
FROM pdcrinfo.dbqlogtbl_hst
GROUP BY 1
ORDER BY 2 DESC
WHERE logdate='2020-02-15'
AND UserName='BI_ETL_USR'
AND
EXTRACT(HOUR FROM starttime)BETWEEN 5 AND 9


-----FIND WHICH STATEMENT IS RUN MOST OF THE TIME

SELECT STATEMENTTYPE,COUNT(STATEMENTTYPE)
FROM pdcrinfo.dbqlogtbl
GROUP BY 1
ORDER BY 2 DESC
WHERE logdate='2020-02-18'
AND
EXTRACT(HOUR FROM STARTTIME)=5


--TO FIND HOW MUCH TIMES A SINGLE QUERY IS RUN

SELECT substr(b.sqltextinfo,1,100),COUNT(*)
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1
ORDER BY 2 DESC
WHERE a.logdate='2020-02-18'
--AND b.sqltextinfo =substr(b.sqltextinfo,100)
AND 
EXTRACT(HOUR FROM STARTTIME)=5
and statementtype='INSERT'

------------------------------------------
--SQL BY CPU WITH OBJECT TABLE
SELECT substr(b.sqltextinfo,1,100),SUM(AMPCPUTIME+ParserCPUTime) as TotalCPUTime
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
INNER JOIN 
(
SEL DISTINCT queryid, procid, logdate FROM PDCRINFO.dbqlobjtbl_hst
WHERE objectdatabasename = 'FADS_T'
AND objecttablename = 'FDR_BLLD'
) AS c
ON a.procid = c.procid
AND a.queryid = c.queryid
AND a.logdate = c.logdate 
and a.logdate='2020-06-27'
Group by 1
order by 2 desc;
--AND b.sqltextinfo =substr(b.sqltextinfo,100)
--AND EXTRACT(HOUR FROM STARTTIME)=5

------------------------------------------

---SQL BY CPU

SELECT substr(b.sqltextinfo,1,100),SUM(AMPCPUTIME+ParserCPUTime) as TotalCPUTime
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1
ORDER BY 2 DESC
--WHERE a.logdate='2020-06-05'
where A.USERNAME='APPH_MINING_ETL'
and a.logdate between date - 9 and date
AND b.logdate BETWEEN DATE - 9 AND DATE
--AND b.sqltextinfo =substr(b.sqltextinfo,100)
--AND EXTRACT(HOUR FROM STARTTIME)=5

---DBQL OF THE USER TO FIND QUERY THAT USER RUNS WHICH CAUSE SPIKE --(WE TAKE QUERIES THAT CONSUME HIGH TOTALCPUTIME

SELECT a.logdate,
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
WHERE a.logdate='2020-02-15'
--AND a.SessionID= 1615077
AND a.UserName='SAS_APP_POST'
AND LogHour BETWEEN 5 AND 9
--AND a.Statementtype='INSERT'
ORDER BY TotalCPUTime desc;

-----------------------------------------
-- WEEKLY POWER BI ANALYSIS

SELECT
a.LogDate,
EXTRACT (HOUR FROM a.starttime) as loghour,
UserName,
substr(b.sqltextinfo,1,100),
SUM(a.AMPCPUTime+ParserCPUTime)as TotalCPUTime,
COUNT(a.queryid) AS "Count"
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1,2,3,4
ORDER BY 5 DESC,6 desc
WHERE a.LogDate BETWEEN DATE-8 AND DATE-2
AND
EXTRACT (HOUR FROM a.starttime) between 6 and 18
and
b.sqlrowno=1;