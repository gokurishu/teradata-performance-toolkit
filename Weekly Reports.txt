select    UserName,AccountName,SUM_CPU 
from     pdcrinfo.acctg_hst   
where   LogDate='2019-04-16'  
AND LOGHOUR BETWEEN 4 AND 5
order by SUM_CPU desc;

----------------------------------------------------------------

SEL LogDate, LogHour,UserName,AccountName,SUM_CPU,SUM_DSK
FROM PDCRINFO.ACCTG_HST
WHERE LogDate='2019-04-11'
ORDER BY SUM_CPU DESC;

------------------------------------------------------------

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
WHERE a.logdate='2019-04-15'
AND a.SessionID= 1615077
AND a.UserName='SNI47'
ORDER BY TotalCPUTime desc;

-----------------------------------------------------------------------------------------

GRT_30 Mins query :

SELECT l.logdate,l.collecttimestamp, l.queryid, l.queryband,
CASE WHEN queryband  IS NULL  THEN NULL
WHEN  POSITION ( 'wf_' IN queryband)  = 0  THEN queryband
ELSE   SUBSTRING ( SUBSTRING(  queryband FROM POSITION ( 'wf_' IN queryband) ) FROM 1 FOR POSITION ( ';' IN SUBSTRING(  queryband FROM POSITION ( 'wf_' IN queryband) ) ) )
END AS worflowname,
l.procid,sessionid, l.ampcputime, l.maxampcputime , l.totaliocount,  ( l.firstresptime - l.starttime MINUTE(4)) AS RunTIme
,l.NumResultRows,l.SpoolUsage,l.username,
(l.firstresptime - l.firststeptime minute(4)) as resptime

,CASE WHEN AMPCPUTime < 1 OR (AMPCPUTime /  (HASHAMP()+1)) =0 THEN 0
         ELSE MaxAmpCPUTime/(AMPCPUTime /  (HASHAMP()+1))   END (DEC(8,2)) AS CPUSKW
   ,CASE WHEN AMPCPUTime < 1 OR (TotalIOCount /  (HASHAMP()+1)) =0 THEN 0
         ELSE MaxAmpIO/(TotalIOCount /  (HASHAMP()+1))   END (DEC(8,2)) AS IOSKW
   ,CASE WHEN AMPCPUTime < 1 OR TotalIOCount = 0 THEN 0  ELSE (l.AMPCPUTime *1000)/l.TotalIOCount  END  AS PJI
   ,CASE WHEN AMPCPUTime < 1 OR AMPCPUTime = 0 THEN 0  ELSE l.TotalIOCount/(l.AMPCPUTime *1000) END  AS UII
   ,l.MaxAmpCPUTime * (HASHAMP()+1)  /*no. of Amps*/ AS ImpactCPU
   , s.sqltextinfo 
   from pdcrinfo.dbqlogtbl l
join
pdcrinfo.dbqlsqltbl  s
on 
l.procid=s.procid
and l.queryid=s.queryid
and l.logdate=s.logdate
where 
--l.numofactiveamps >  0and
(l.logdate,l.procid, l.queryid)
in
(select distinct a.logdate,
a.procid, a.queryid from(
sel   
logdate,
procid, queryid,
Case when 'AS' = 'AS' then AcctString
       Else 'Unk' end as WrkLd

FROM PDCRINFO.DBQLogTblRpt_hst a
Where 
extract(hour from starttime)  between  00 and 24
and (a.firstresptime - a.starttime minute(4)) >= 31 
and  WrkLd in ('$M00ETLX&S&D&H','$M00ETLX&D&H')
and logdate between  '2020-01-15' and   '2020-01-21'

)a)


--------------------------------------------------

Flow Control :

sel username,count(*) from
pdcrinfo.dbqlogtbl
where logdate = '2018-11-05'
and extract(hour from starttime) between 4 and 5
and NumOfActiveAMPs>0
group by 1
order by 2 desc;




TO get query of culprit users :

 select     l.logdate,l.username, substr(s.sqltextinfo,1,100) as SQLT,
            EXTRACT (HOUR FROM starttime) AS LogHour,
    sum(l.MaxAmpCPUTime * (HASHAMP()+1)) as ImpactCPU,
            sum( l.ampcputime) as CPU,
            count(1)
    from    pdcrinfo.dbqlogtbl l join pdcrinfo.dbqlsqltbl s
        on l.procid=s.procid
        and l.queryid=s.queryid
        and l.logdate=s.logdate
    where    l.logdate='2020-01-31'
    and username='BI_ETL_USR'
    and LogHour between 13 and 14
    --and s.sqltextinfo like '%INSERT INTO MPCS_DNC_MSISDN%'
    group by 1,2,3,4
    order by 7 desc;

-------------------------------------------------------

SELECT 
a.UserName,
a.logdate,
extract (hour from a.StartTime),
a.queryband,
substr(b.sqltextinfo,1,100)
  ,MaxAWT
  ,AvgAWT
  ,MinAWT
  ,FlowCtlCnt
  ,FlowCtlTime       
,  SUM(a.AMPCPUTime+ParserCPUTime) TotalCPUTime,
SUM(MaxAMPCPUTime * numofactiveamps) AS impactCPU
,count(b.sqltextinfo)

FROM  pdcrinfo.dbqlogtbl_hst a INNER JOIN pdcrinfo.dbqlsqltbl_hst b
ON a.procid = b.procid
AND a.queryid = b.queryid
AND a.logdate = b.logdate
join pdcrinfo.awtrpt_hst awt on
awt.logdate=a.logdate
and awt.loghour=extract(hour from starttime)
WHERE a.logdate BETWEEN DATE -17 AND           DATE
                AND       b.logdate BETWEEN  DATE-17 AND DATE
--and extract(hour from starttime) between 13 and 14
and NumOfActiveAMPs>0
AND b.sqlrowno=1
and a.username='TEMP_FADS_USR'  
and b.sqltextinfo like '%INSERT INTO I_AUTO_PORT_SUB_STATUS%'
GROUP BY 1,2,3,4,5,6,7,8,9,10;

------------------------------------------------------------------------------------------------------------------------------

SELECT
TheDate AS TheDatePN
,EXTRACT(HOUR FROM thetime) TheHour
,EXTRACT(MINUTE FROM thetime) TheMinute
,CASE WHEN day_of_week = 1 THEN 'Sunday'
WHEN day_of_week = 2 THEN 'Monday'
WHEN day_of_week = 3 THEN 'Tuesday'
WHEN day_of_week = 4 THEN 'Wednesday'
WHEN day_of_week = 5 THEN 'Thursday'
WHEN day_of_week = 6 THEN 'Friday'
WHEN day_of_week = 7 THEN 'Saturday'
END AS dayofweek,
MAX(InuseMax),
MAX(FlowCtlCnt),
MAX(FlowCtlTime)/1000/60,
SUM(FlowCtlTime)/1000/60
FROM dbc.resusagesawt INNER JOIN sys_calendar.CALENDAR
ON TheDate = calendar_date
WHERE TheDate between date '2019-04-23' and date '2019-05-07'
AND Calendar_date between date '2019-04-23' and date '2019-05-07'
--AND day_of_week IN (1,7
--AND TheHour IN (17,18,19,20)
GROUP BY 1,2,3,4
ORDER BY 1,2,3





------------------------------------------------------------------------------------------------------------------------------------
--Weekly Spike Report -- UTILITY HEATMAP -- Hour Wise Utility Jobs Running 
select
LogDate,
EXTRACT (HOUR FROM STARTTIME) as Loghour,
USERNAME,
COUNT(DISTINCT LSN)
from
pdcrinfo.DBQLOGTBL_HST
where
logdate='2020-02-02'
and loghour between 4 and 5
AND LSN IS NOT NULL
GROUP BY 1,2,3

------------------------------------------------------------------------------------------------------------------------------------

Chart Refresh :

Flow control – 11 days
TDIDW Flow Control Chart : 36 Days
Concurrent users :  11 days
Concurrent Query : 11 Days
CPU Backlog Report : 36 Days
Query and User Count : 14 Days
Space Usage : 11 Days

Analysis :

Below views referred :

Concurrent user :   logonoff_hst
Cpu backlog : acctg_hst
Heat map : acctg_hst  (top consuming session ids)
Flow control : dbqlogtbl
