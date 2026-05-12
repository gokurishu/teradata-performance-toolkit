--CONCURRENCY QUERY | FIND CONCURRENT QUERIES RUN BY USER

SELECT 
logdate,
HHH,
finalwdname,
username,
max(cpu),
max(ConcurrentQueries)
from

(
SELECT    
       logdate
  ,x.HHH
        ,x.MMI    
        ,x.SSE   
                ,finalwdname
                ,username
                ,sum(ampcputime) as cpu
        ,COUNT(*) AS ConcurrentQueries    
    FROM     
        (
        SELECT
a.logdate
,finalwdname
,username
,ampcputime
            ,CAST((EXTRACT(HOUR FROM a.firststeptime)) *3600 
                + (EXTRACT(MINUTE FROM a.firststeptime)) *60 
                + (EXTRACT(SECOND FROM a.firststeptime) ) AS DEC(8,2))  AS Startsecs
            ,CAST(EXTRACT(HOUR FROM a.firstresptime)*3600
                + EXTRACT(MINUTE FROM a.firstresptime)*60 
                + EXTRACT(SECOND FROM a.firstresptime) AS DEC(8,2))  AS Endsecs 
        FROM 
            pdcrinfo.dbqlogtbl_hst a join pdcrinfo.dbqlsqltbl s
            on a.procid=s.procid 
and a.queryid=s.queryid 
and a.logdate=s.logdate 
        WHERE
        s.sqltextinfo like any ('%HRA_V%','%HRA_SEMANTIC_V%')
and ampcputime >0  
 and a.logdate between date-30 and date
            and 
            (
                /* Either minutes are different or query ran for over an hour */
                (
                EXTRACT(MINUTE FROM  a.firststeptime) <> EXTRACT(MINUTE FROM  a.firstresptime)
                OR (a.firstresptime - a.firststeptime) HOUR(4) TO SECOND(6) > '0000:59:00.000000'
                )        
                OR
                /* Or query started or finished exactly on the minute */
                (
                CAST((EXTRACT(SECOND FROM  a.firststeptime)) AS INTEGER) = 0
                OR CAST((EXTRACT(SECOND FROM  a.firstresptime)) AS INTEGER) = 0
                )
            ) 
        GROUP BY 1,2,3,4,5,6
        HAVING (endsecs-startsecs (FLOAT)) > 0.000
        ) m 
            CROSS JOIN
         (
                SELECT
                        SUM(1) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS pos 
                        ,(pos - 1) AS PIT 
                        ,( pit / 3600) AS HHH 
                        ,( pit MOD 3600) / 60 AS MMI 
                        ,( pit mod 60 )  as SSE
                FROM     
                     (select * from sys_calendar.calendar
                      UNION ALL
                      select * from sys_calendar.calendar) as c
                      --POS is the second of the day.  3600 multiplied by desired hour to examine concurrency
                --QUALIFY pos between (1+(3600*10)) and  (3600*14.5)
        ) x 
        WHERE      startsecs <= x.PIT 
            AND Endsecs > x.PIT             
             --   and pos between (1+(3600*10)) and (3600*14.5)
    GROUP BY 1,2,3,4,5,6
)abc
group by 1,2,3,4


-- ============================== EPT Bucket Query =====================================*/

SELECT
EXTRACT (MONTH FROM l.Logdate) AS MMM,
l.username,
WDName
,FinalWDNAME
,
CASE    
    WHEN NumOfActiveAmps = 1 THEN 'One AMP Query' 
    ELSE 'All Amp Query' 
END    AS Type_of_Query
,
CASE    
    WHEN TDWMEstTotalTime < 1000                           THEN '01) Less Than 1 Second'
      WHEN TDWMEstTotalTime BETWEEN 1000.00001   
    AND 10000   THEN '02a) Between 1 & 10 Seconds'
      WHEN TDWMEstTotalTime BETWEEN 10000.00001   
    AND 20000   THEN '02a) Between 10 & 20 Seconds'
      WHEN TDWMEstTotalTime BETWEEN 20000.00001   
    AND 30000   THEN '02a) Between 20 & 30 Seconds'
            WHEN TDWMEstTotalTime BETWEEN 30000.00001   
    AND 40000   THEN '02a) Between 30 & 40 Seconds'
      WHEN TDWMEstTotalTime BETWEEN 40000.00001   
    AND 50000   THEN '02a) Between 40 & 50 Seconds'
      WHEN TDWMEstTotalTime BETWEEN 50000.00001   
    AND 60000   THEN '02a) Between 50 & 60 Seconds'
      WHEN TDWMEstTotalTime > 60000                        THEN '65) Greater Than 60 seconds'
    ELSE ' Unknown' 
END     AS EstProcessTime
,COUNT(*)     AS querycount
,SUM(
CASE    
    WHEN WDName <> FinalWDName THEN 1 
    ELSE 0 
END) AS ExcpCnt ,
CASE    
    WHEN querycount = 0 THEN 0 
    ELSE 100*ExcpCnt/querycount 
END    ExcpPct ,SUM(
CASE    
    WHEN DelayTime > 0 THEN 1 
    ELSE 0 
END) AS DelayCnt ,MAX(ParserCPUTime + AmpCPUTime) AS Max_Query_CPU ,
        SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) <=1 THEN 1 
    ELSE 0 
END    ) AS LessThanCPUQuery
-- By 5 out to 100
,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 1 
    AND (ParserCPUTime + AmpCPUTime) <= 100 THEN 1 
    ELSE 0 
END    ) AS CPU_1to100 ,

SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 100 
    AND (ParserCPUTime + AmpCPUTime) <= 200 THEN 1 
    ELSE 0 
END    ) AS CPU_100to200 ,

SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 200
    AND (ParserCPUTime + AmpCPUTime) <= 300 THEN 1 
    ELSE 0 
END    ) AS CPU_200to300 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 300
    AND (ParserCPUTime + AmpCPUTime) <= 400 THEN 1 
    ELSE 0 
END    ) AS CPU_300to400 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 400 
    AND (ParserCPUTime + AmpCPUTime) <= 500 THEN 1 
    ELSE 0 
END    ) AS CPU_400to500 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 500
    AND (ParserCPUTime + AmpCPUTime) <= 1000 THEN 1 
    ELSE 0 
END    ) AS CPU_500to1000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 1000 
    AND (ParserCPUTime + AmpCPUTime) <= 2000 THEN 1 
    ELSE 0 
END    ) AS CPU_1000to2000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 2000 
    AND (ParserCPUTime + AmpCPUTime) <= 3000 THEN 1 
    ELSE 0 
END    ) AS CPU_2000to3000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 3000
    AND (ParserCPUTime + AmpCPUTime) <= 4000 THEN 1 
    ELSE 0 
END    ) AS CPU_3000to4000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 4000 
    AND (ParserCPUTime + AmpCPUTime) <= 5000 THEN 1 
    ELSE 0 
END    ) AS CPU_4000to5000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 5000
    AND (ParserCPUTime + AmpCPUTime) <= 6000 THEN 1 
    ELSE 0 
END    ) AS CPU_5000to6000 ,SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 6000 
    AND (ParserCPUTime + AmpCPUTime) <= 7000 THEN 1 
    ELSE 0 
END    ) AS CPU_6000to7000 ,
SUM (
CASE    
    WHEN (ParserCPUTime + AmpCPUTime) > 7000 THEN 1 
    ELSE 0 
END    ) AS CPU_GT_7000

FROM pdcrinfo.dbqlogtbl_hst l inner join pdcrinfo.dbqlsqltbl  s 
    on 
l.procid=s.procid 
    and l.queryid=s.queryid 
    and l.logdate=s.logdate 

WHERE l. logdate  BETWEEN date-30 
    AND DATE  
--AND WDName LIKE 'EPNR%'
    and s.sqltextinfo like any ('%HRA_V%','%HRA_SEMANTIC_V%')
GROUP BY 1,2,3,4,5,6
ORDER BY 1,2,3,4,5;
