-- CSR STATUS

SEL 
cast(cast(min(startdate) as char(20)) as timestamp(0)) as Start_Date, 
cast(cast(max(enddate) as char(20)) as timestamp(0)) as End_Date, 
(End_Date - Start_Date) DAY(4) to SECOND(4) as Total_Time,
count(*) as Current_Step
FROM 
(
SEL startdate, enddate FROM FADS_SAA_INTG_V.RL_VW_VAUDITRTPROCESS WHERE
STATUSNAME<>'DISABLED' AND STARTDATE =  DATE
) CSR_DATA;


---------------------------------------------------------------------------------------
--CSR STEPS

Select  ROW_NUMBER() OVER ( ORDER BY MessageKey Desc ), x.* 
from FADS_SAA_INTG_V.RL_vw_vAuditRTProcessMessage x

where dateProcess = DATE '2020-12-15'
order by Messagekey asc;


----------------------------------------------------------------------------------------

--CSR CONSUMPTION

SELECT * FROM (   sel LogDate, avg(CPUUtilPct) as avg_CPU, Max(CPUUtilPct) as max_CPU
   
   FROM
   (
   SELECT    a.LogDate, a.Loghour, SUM(TotalCPUServSec + TotalCPUExecSec) AS CPUBusy,
   
           SUM(TotalCPUServSec + TotalCPUExecSec + TotalCPUWaitIOSec + TotalCPUIdleSec) AS CPUTotal  ,
           
           (CPUBUSY / NULLIFZERO(CPUTotal)) * 100(DECIMAL(3, 0)) AS CPUUtilPct  
           
   FROM    PDCRINFO.ResUsageSumHr_hst a  ,
   
   (SELECT
   a.logdate,extract (hour from starttime) as start_Hour
   FROM   pdcrinfo.dbqlogtbl_hst a INNER JOIN pdcrinfo.dbqlsqltbl_hst b
                   ON         a.procid = b.procid
                   AND       a.queryid = b.queryid
                   and a.logdate=b.logdate
   WHERE  username='FADS_SAA_INTG_USR'
     and  b.logdate BETWEEN  DATE-16 AND DATE-1
        and a.logdate BETWEEN  DATE-16 AND DATE-1
                 and sqltextinfo like '%call%'
   group by 1,2
   
   union all 
   
   SELECT
   cast (starttime as date) as logdate, extract (hour from starttime) as start_Hour
   FROM   dbc.dbqlogtbl a INNER JOIN dbc.dbqlsqltbl b
                   ON         a.procid = b.procid
                   AND       a.queryid = b.queryid
   WHERE  username='FADS_SAA_INTG_USR'
                 and sqltextinfo like '%call%'
   group by 1,2)abc
   WHERE     a.LogDate =abc.logdate
   and a.Loghour=abc.start_Hour
   GROUP BY 1, 2)a
   
   RIGHT OUTER JOIN PDCRINFO.CALENDAR c  
       ON a.logdate = c.calendar_date 
   WHERE    c.calendar_date BETWEEN  DATE-16 AND DATE
   group by 1 ) "custom sql query1" WHERE (0 = 1)


-----------------------------------------------------------------------------------

-- CSR AMOL

SELECT STARTDATE(DATE) AS RUN_DATE, PROCESSNAME,
CASE
WHEN STATUSNAME='Successful' AND ENDDATE IS NOT NULL THEN 'Done'
WHEN STATUSNAME<>'Successful' AND ENDDATE IS NULL THEN 'In Progress'
END AS STATUS,
STARTDATE START_TIME,
ENDDATE END_TIME,
CASE
WHEN STATUS='Done' AND END_TIME IS NOT NULL THEN (ENDDATE - STARTDATE HOUR(4) TO MINUTE)
ELSE NULL
END AS TOTAL_RUN_TIME_WHEN_ENDED,
CASE
WHEN END_TIME IS NOT NULL AND ELAPSEDSECONDS=1 THEN ELAPSEDSECONDS||' '||'Second'
WHEN END_TIME IS NOT NULL AND (ELAPSEDSECONDS/60)<1 THEN ELAPSEDSECONDS||' '||'Seconds'
WHEN END_TIME IS NOT NULL AND (ELAPSEDSECONDS/60)=1 THEN (ELAPSEDSECONDS/60)||' '||'Minute'
WHEN END_TIME IS NOT NULL AND (ELAPSEDSECONDS/60)>1 THEN (ELAPSEDSECONDS/60)||' '||'Minutes'
WHEN STATUS='In Progress' AND CAST((CAST(CURRENT_TIMESTAMP AS TIMESTAMP(6))-CAST(STARTDATE AS TIMESTAMP(6)) SECOND(4)) AS DECIMAL(6,2))>59
THEN (CAST((CAST(CURRENT_TIMESTAMP AS TIMESTAMP(6))-CAST(STARTDATE AS TIMESTAMP(6)) SECOND(4)) AS DECIMAL(6,2)))/60||' '||'Minute'
WHEN STATUS='In Progress' AND CAST((CAST(CURRENT_TIMESTAMP AS TIMESTAMP(6))-CAST(STARTDATE AS TIMESTAMP(6)) SECOND(4)) AS DECIMAL(6,2))<=59
THEN CAST((CAST(CURRENT_TIMESTAMP AS TIMESTAMP(6))-CAST(STARTDATE AS TIMESTAMP(6)) SECOND(4)) AS DECIMAL(6,2))||' '||'Second'
ELSE NULL
END AS TIME_TAKEN
FROM FADS_SAA_INTG_V.RL_VW_VAUDITRTPROCESS
WHERE STATUSNAME <> 'DISABLED'
AND STARTDATE = DATE
GROUP BY 1,2,3,4,5,6,7
ORDER BY START_TIME
;

