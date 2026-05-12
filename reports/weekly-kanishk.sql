'2020-05-06' AND '2020-05-12'	|	'2020-04-08' AND '2020-04-14'
'2020-05-13' AND '2020-05-19'	|	'2020-04-15' AND '2020-04-21'
'2020-05-20' AND '2020-05-26'	|	'2020-04-22' AND '2020-04-28'
'2020-05-27' AND '2020-06-02'	|	'2020-04-29' AND '2020-05-05'



-- CPU BY USER (WEEK WISE)
SEL LogDate,LogHour,UserName,SUM_CPU
FROM PDCRINFO.ACCTG_HST
WHERE LogDate BETWEEN DATE-7 AND DATE-1
ORDER BY SUM_CPU DESC;

----------------------------------------------------------------
--COUNT OF QUERY 
SELECT
UserName,LOGDATE,EXTRACT(HOUR FROM starttime) AS LogHour,
COUNT(QueryID) AS "COUNT"
FROM pdcrinfo.dbqlogtbl
GROUP BY 1,2,3
ORDER BY 4 DESC
WHERE LogDate BETWEEN DATE-7 AND DATE-1;

---------------------------------------------------------------


---FIND WHICH STATEMENT CONSUMES HIGHEST CPU

SELECT UserName,STATEMENTTYPE,EXTRACT(HOUR FROM starttime) AS LogHour,SUM(AMPCPUTIME+ParserCPUTime) as TotalCPUTime
FROM pdcrinfo.dbqlogtbl
GROUP BY 1,2,3
ORDER BY 4 DESC
WHERE LogDate BETWEEN  '2020-05-27' AND '2020-06-02'

----------------------------------------------------------------

-----FIND WHICH STATEMENT IS RUN MOST OF THE TIME

SELECT UserName,STATEMENTTYPE,EXTRACT(HOUR FROM starttime) AS LogHour,COUNT(STATEMENTTYPE) as "Count"
FROM pdcrinfo.dbqlogtbl
GROUP BY 1,2,3
ORDER BY 4 DESC
WHERE LogDate BETWEEN  '2020-05-27' AND '2020-06-02'

----------------------------------------------------------------

--TO FIND HOW MUCH TIMES A SINGLE QUERY IS RUN

SELECT top UserName,substr(b.sqltextinfo,1,100),COUNT(*)
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1,2
ORDER BY 3 DESC
WHERE a.LogDate BETWEEN '2020-06-01' AND '2020-06-02';

----------------------------------------------------------------
--TO FIND HOW MUCH CPU A SINGLE QUERY CONSUMES.

SELECT top 2000 UserName,substr(b.sqltextinfo,1,100),SUM(a.AMPCPUTime+ParserCPUTime) as TotalCPUTime
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1,2
ORDER BY 3 DESC
WHERE a.LogDate BETWEEN '2020-06-01' AND '2020-06-02';

----------------------------------------------------------------

SELECT top 2000 UserName,substr(b.sqltextinfo,1,100),SUM(a.AMPCPUTime+ParserCPUTime)as TotalCPUTime,COUNT(*) AS "Count"
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
GROUP BY 1,2
ORDER BY 3 DESC,4 desc
WHERE a.LogDate BETWEEN DATE-7 AND DATE-1;


-------------------------------------------------------------------

---CURRENT WEEK ( 6 AM TO 6 PM ) | (WEEKDAYS ONLY)
SEL LogDate,LogHour,UserName,SUM_CPU "CURRENT WEEK CPU"
FROM PDCRINFO.ACCTG_HST 
WHERE LogDate BETWEEN DATE-7 AND DATE-1
AND td_day_of_week(LogDate)<>1
AND td_day_of_week(LogDate)<>7
AND LogHour BETWEEN 6 AND 18


---PREVIOUS WEEK ( 6 AM TO 6 PM ) | (WEEKDAYS ONLY)
SEL LogDate,LogHour,UserName,SUM_CPU "PAST WEEK CPU"
FROM PDCRINFO.ACCTG_HST 
WHERE LogDate BETWEEN DATE-14 AND DATE-7
AND td_day_of_week(LogDate)<>1
AND td_day_of_week(LogDate)<>7
AND LogHour BETWEEN 6 AND 18;


 
