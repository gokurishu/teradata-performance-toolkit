
-- ========================AWT by workload  =============================
LOCKING ROW FOR ACCESS
SELECT
TheDatePN (FORMAT'yy/mm/dd', TITLE 'Date'),
TheHour (TITLE 'Hour'),
TheMinute (TITLE 'Minute'),
SumPNTbl.dayofweek (TITLE 'Day of Week') ,
rulenamePN (TITLE 'Workload Name'),
ppidPN (FORMAT '9', TITLE 'PP ID')
--agidPN (FORMAT 'ZZ9', TITLE 'AG ID'),
--AVERAGE(RelWgtPN) (FORMAT 'ZZ9', TITLE 'Avg Active Relative Weight')
,AVERAGE(CPUPctPN) (FORMAT 'ZZ9.9', TITLE 'Avg CPU Util  %')
,AVERAGE(PhysicalIOPN) (FORMAT 'ZZ9.9', TITLE 'Avg I/Os per Sec')
,AVERAGE(PhysicalIOMBPN) (FORMAT 'ZZ9.9', TITLE 'Avg I/O Mbytes per Sec')
,AVERAGE(WorkMsgSendDelayCntPN) (FORMAT 'ZZ9.9', TITLE 'Avg # AWT Requests With Send Delay per AMP')
,AVERAGE(WorkMsgReceiveDelayCntPN) (FORMAT 'ZZ9.9', TITLE 'Avg # AWT Requests With Receive Delay per AMP')
,AVERAGE(NumRequestsPN) (FORMAT 'ZZ9.9', TITLE 'Avg # Tasks Assigned AWTs per AMP')
,AVERAGE(AwtReleasesPN) (FORMAT 'ZZ9.9', TITLE 'Avg # AWTs Released per AMP')
--,MAX(QLengthMaxMPN) (FORMAT 'ZZ9.9', TITLE 'Max # Tasks Receive-Side QWaiting for AWT')
,MAX(WorkMsgSendDelayMPN) (FORMAT 'ZZ9.99', TITLE 'Max Send-Side Wait msec')
,MAX(WorkMsgReceiveDelayMPN) (FORMAT 'ZZ9.99', TITLE 'Max Receive-Side Wait msec')
,MAX(QWaitTimeMaxMPN) (FORMAT 'ZZ9.99', TITLE 'Max Receive-Side Total QWait msec')
,AVERAGE(ZEROIFNULL(WorkMsgSendDelayRequestAPN)) (FORMAT 'ZZ9.99', TITLE 'Avg Send-Side Wait msec')
--,AVERAGE(ZEROIFNULL(QLengthAmpAvgAPN)) (FORMAT 'ZZ9.99', TITLE 'Avg Receive-Side # Tasks QLength')
,AVERAGE(ZEROIFNULL(QwaitTimeRequestAPN)) (FORMAT 'ZZ9.99', TITLE 'Avg Receive-Side QWait msec')
,AVERAGE(ZEROIFNULL(WorkMsgReceiveDelayRequestAPN)) (FORMAT 'ZZ9.99', TITLE 'Avg Receive-Side Wait msec')
,MAX(ServiceTimeMPN) (FORMAT 'ZZ9.99', TITLE 'Max Time AWT Held msec')
,AVERAGE(ZEROIFNULL(ServiceTimeAPN)) (FORMAT 'ZZ9.99', TITLE 'Avg Time AWT Held msec')
,MAX(WorkTimeInUseMPN) (FORMAT 'ZZ9.99', TITLE 'Max Time AWT Held or Still Held msec')
/* Pseudo-Max is sum of worktypeinuseXXmax's anytime wiconcurrenthin the interval and can exceed the max of all at any point in time */
--,MAX(WorkTypeInUseMPN) (FORMAT 'ZZ9.9', TITLE 'Pseudo-Max # AWTs In Use per AMP') 
,AVERAGE(AwtUsedAPN) (FORMAT 'ZZ9.9', TITLE 'Avg # AWTs In Use per AMP')
FROM
(
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
NodeId,
rulename AS rulenamePN,
ppid AS ppidPN
--agid AS agidPN
--AVERAGE(RelWgt) AS RelWgtPN
,AVERAGE(CPUPct) AS CPUPctPN
,SUM(PhysicalReadPerm+PhysicalWritePerm+PhysicalReadOther+PhysicalWriteOther)*100 / SUM(CentiSecs) AS PhysicalIOPN
,SUM(PhysicalReadPermKB+PhysicalWritePermKB+PhysicalReadOtherKB+PhysicalWriteOtherKB)*100 / 1024*(SUM(CentiSecs)) AS PhysicalIOMBPN
,SUM(WorkMsgSendDelayCnt) / SUM(NULLIFZERO(AmpCount)) AS WorkMsgSendDelayCntPN
,SUM(NumRequests) / SUM(NULLIFZERO(AmpCount)) AS NumRequestsPN
,SUM(AwtReleases) / SUM(NULLIFZERO(AmpCount)) AS AwtReleasesPN
,SUM(WorkMsgReceiveDelayCnt) / SUM(NULLIFZERO(AmpCount)) AS WorkMsgReceiveDelayCntPN
--,MAX(QLengthMax) AS QLengthMaxMPN
,MAX(WorkMsgSendDelayMax) AS WorkMsgSendDelayMPN
,MAX(WorkMsgReceiveDelayMax) AS WorkMsgReceiveDelayMPN
,MAX(QWaitTimeMax) AS QWaitTimeMaxMPN
,AVERAGE(WorkMsgSendDelayRequestAvg) AS WorkMsgSendDelayRequestAPN
,AVERAGE(WorkMsgReceiveDelayRequestAvg) AS WorkMsgReceiveDelayRequestAPN
--,AVERAGE(QLengthAmpAvg) AS QLengthAmpAvgAPN
,AVERAGE(QWaitTimeRequestAvg) AS QWaitTimeRequestAPN
,AVERAGE(ServiceTimeRequestAvg) AS ServiceTimeAPN
,MAX(ServiceTimeMax) AS ServiceTimeMPN
,MAX(WorkTimeInUseMax) AS WorkTimeInUseMPN
,AVERAGE(AWTUsedAvg) / SUM(NULLIFZERO(AmpCount)) AS AwtUsedAPN
--,MAX(WorkTypeInUseMax) / SUM(NULLIFZERO(AmpCount)) AS WorkTypeInUseMPN
FROM DBC.ResSPSView AS T1
LEFT OUTER JOIN
(SELECT ruleid, rulename
FROM tdwm.RuleDefs AS T2
WHERE T2.RuleType =5 AND T2.RemoveDate=0
GROUP BY 1,2
)AS T2
ON (T1.WDid = T2.RuleId )


INNER JOIN
Sys_Calendar.CALENDAR b
ON calendar_date = thedate
WHERE  /*( ( TheDate =date - 1   AND TheTime >= 000000)
         OR ( TheDate > date -30  ) 
       ) 
       AND
       (    ( TheDate = date - 1 AND TheTime <= 240000   )
         OR ( TheDate < date  ) 
       ) */
       TheDate  BETWEEN date - 30 AND DATE 
      AND Active > 0 
      AND VprType = 'AMP'
GROUP BY 1,2,3,4,5,6,7
) AS SumPNTbl
GROUP BY 1,2,3,4,5 ,6
ORDER BY 1,2,3,4,5,6;


/* ==========================Flow control Query ================================*/

LOCKING ROW FOR ACCESS
SELECT                  
TheDate AS LogDate                       
,EXTRACT (HOUR FROM TheTime) AS TheHour                   
,EXTRACT (MINUTE FROM thetime) AS TheMinute
,CASE WHEN TheHour BETWEEN 4 AND 6 THEN 'PE-MSTR-Load'
                                                WHEN TheHour BETWEEN 7 AND 20 THEN 'PE-Online'
                                                ELSE 'PE-Batch' END AS "Planned Environment"
,CASE WHEN day_of_week = 1 THEN 'Sunday'
WHEN day_of_week = 2 THEN 'Monday'
WHEN day_of_week = 3 THEN 'Tuesday'
WHEN day_of_week = 4 THEN 'Wednesday'
WHEN day_of_week = 5 THEN 'Thursday'
WHEN day_of_week = 6 THEN 'Friday'
WHEN day_of_week = 7 THEN 'Saturday'
END AS DayOfWeek
,SUM(FlowCtlCnt) AS FlowCtlCnt              
,SUM(CASE WHEN flowctlcnt > 0 THEN 1 ELSE 0 END) AS AMPS_In_FlwCntrl         
,SUM(CASE WHEN Available = 0 THEN 1 ELSE 0 END) AS "0_EofI_AWT_Count"
,SUM (CASE WHEN AvailableMin = 0 THEN 1 ELSE 0 END ) AS "0_AWT_Count"                  
,SUM (CASE WHEN AvailableMin BETWEEN 1 AND 5 THEN 1 ELSE 0 END ) AS "1To5_AWT_Count"                  
,SUM (CASE WHEN AvailableMin BETWEEN 5 AND 10 THEN 1 ELSE 0 END ) AS "5To10_AWT_Count"                  
,SUM (CASE WHEN AvailableMin > 10 THEN 1 ELSE 0 END ) AS "GT10_AWT_Count"                  
,MAX(FlowCtlTime/1000) AS Max_FlowCtlTime_Secs
,SUM(FlowCtlTime/1000) AS Sum_FlowCtlTime_Secs                   
FROM   DBC.ResUsageSawt a
INNER JOIN sys_calendar.CALENDAR b
ON calendar_date = LogDate
WHERE TheDate BETWEEN '2015-09-01' AND '2015-09-30'
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5;

-- =================================== Orig-Final WD =========================================
LOCKING ROW FOR ACCESS
SEL Logdate, Day_of_week, TheHour, Username, WDname, b.RuleName AS FinalWDName,
WINDOW
,QryCNT
,SumCPU
,AvgCPU
,MaxCPU
,SumTDWMDelayTime 
,AvgTDWMDelayTime 
,MaxTDWMDelayTime 
FROM (
SELECT  
a.LogDate
,b.day_of_week
,EXTRACT(HOUR FROM starttime) AS TheHour
,username
,Rulename AS WDName
,FinalWDID
,CASE WHEN (TheHour BETWEEN 0 AND 3) THEN 'Batch_Window'
                WHEN (TheHour BETWEEN 4 AND 23) AND (day_of_week = 1) THEN 'MSTRLoad_Window'
                WHEN (TheHour BETWEEN 4 AND 6) THEN 'MSTRLoad_Window'
                WHEN (TheHour BETWEEN 7 AND 18) THEN 'Online'
                WHEN (TheHour BETWEEN 19 AND 23) THEN 'Batch_Window'
END AS WINDOW
,COUNT (*) AS QryCNT
,SUM(a.AmpCpuTIME+ a.ParserCPUTime) AS SumCPU
,AVG(a.AmpCpuTIME+ a.ParserCPUTime) AS AvgCPU
,MAX(a.AmpCpuTIME+ a.ParserCPUTime) AS MaxCPU
,SUM(DelayTime) AS SumTDWMDelayTime 
,AVG(DelayTime) AS AvgTDWMDelayTime 
,MAX(DelayTime) AS MaxTDWMDelayTime 
,ZEROIFNULL(CAST(AVG ( CAST(EXTRACT(HOUR
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) * 3600 + EXTRACT(MINUTE
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) * 60 + EXTRACT(SECOND
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) AS DECIMAL(10,
                                2)) ) AS DECIMAL(10,2))) AS AvgDurationSecs
,ZEROIFNULL(CAST(MAX ( CAST(EXTRACT(HOUR
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) * 3600 + EXTRACT(MINUTE
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) * 60 + EXTRACT(SECOND
FROM   ((a.FirstRespTime - a.StartTime) HOUR(2) TO SECOND(2) ) ) AS DECIMAL(10,
                                2)) ) AS DECIMAL(10,2))) AS MaxDurationSecs
FROM   
DBA_VM.dbqlogtbl_hst a INNER JOIN Sys_Calendar.CALENDAR b
ON a.logdate = b.Calendar_date
INNER JOIN tdwm.ruledefs c
ON WDID = ruleid
WHERE 
logdate BETWEEN '2015-10-01' AND '2015-11-17'
GROUP BY 1,2,3,4,5,6,7) a, tdwm.ruledefs b
WHERE FinalWDID = RuleID;

--- Max AWT 

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
WHERE TheDate = DATE - 7
AND Calendar_date = DATE   - 7
--AND day_of_week IN (1,7
AND TheHour IN (1,2,3,4,5)
GROUP BY 1,2,3,4
ORDER BY 1,2,3;