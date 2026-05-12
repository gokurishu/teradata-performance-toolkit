--AWT

sel
LogDate,
LogHour,
avg(max_awt)
from
(
sel
LogDate,
LogHour,
Log10Minute,
maxAWT/120*100 as max_awt

from
(
SELECT
  c.year_of_calendar        AS Year_of_Calendar
,c.Month_of_Year           AS Month_of_Year   
 ,c.Week_of_Year            AS Week_of_Year    
 ,(LogDate - ((LogDate - DATE '0001-01-07') MOD 7)) as BOW    
 ,c.Day_of_Month            AS Day_of_Month                                            
 ,c.Day_of_week             AS Day_of_Week
,LogDate                   AS LogDate
,WorkPeriod                AS WorkPeriod
,Period                    AS Period
,LogHour                   AS LogHour
,Log10Minute               AS Log10Minute
,NodeType                  AS NodeType
,MAX(MaxAWT)               AS MaxAWT
,AVG(AvgAWT)               AS AvgAWT
,MIN(MinAWT)               AS MinAWT
,MAX(MaxAWTUtil)           AS MaxAWTUtil
,AVG(AvgAWTUtil)           AS AvgAWTUtil
,MIN(MinAWTUtil)           AS MinAWTUtil
,MAX(MSGWORKNEW)           AS MSGWORKNEW
,MAX(MSGWORKONE)           AS MSGWORKONE
,MAX(MSGWORKTWO)           AS MSGWORKTWO 
 ,MAX(MSGWORKTHREE)         AS MSGWORKTHREE  
 ,MAX(WorkTypeInuse04)      AS WorkTypeInuse04
,MAX(WorkTypeInuse05)      AS WorkTypeInuse05
,MAX(WorkTypeInuse06)      AS WorkTypeInuse06
,MAX(WorkTypeInuse07)      AS WorkTypeInuse07
,MAX(MSGWORKEXPNEW)        AS MSGWORKEXPNEW
,MAX(MSGWORKEXPONE)        AS MSGWORKEXPONE
,MAX(WorkTypeInuse10)      AS WorkTypeInuse10 
 ,MAX(WorkTypeInuse11)      AS WorkTypeInuse11 
 ,MAX(MSGWORKSPAWN)         AS MSGWORKSPAWN  
 ,MAX(MSGWORKNORM)          AS MSGWORKNORM   
 ,MAX(MSGWORKABORT)         AS MSGWORKABORT  
 ,MAX(MSGWORKCONTROL)       AS MSGWORKCONTROL
,SUM(dt1.AWT_0Pct   )      AS AWT_0Pct
,SUM(dt1.AWT1_15Pct )      AS AWT1_15Pct
,SUM(dt1.AWT16_35Pct)      AS AWT16_35Pct
,SUM(dt1.AWT36_50Pct)      AS AWT36_50Pct
,SUM(dt1.AWT51_65Pct)      AS AWT51_65Pct
,SUM(dt1.AWT66_85Pct)      AS AWT66_85Pct
,SUM(dt1.AWT86_99Pct)      AS AWT86_99Pct
,SUM(dt1.AWT_100Pct )      AS AWT_100Pct
,SUM(dt1.AWT_Allocation)   AS AWT_Allocation
,MAX(AWTLIMIT)             AS AWTLIMIT
,MAX(MsgQueDepth)          AS MsgQueDepth
,SUM(InFlowControl)        AS InFlowControl    
 ,SUM(FlowCtlCnt)           AS FlowCtlCnt
,SUM(FlowCtlTime)          AS FlowCtlTime  
 ,MAX(MaxFlowCtlTimePct)    AS MaxFlowCtlTimePct
,MAX(AvgFlowCtlTimePct)    AS AvgFlowCtlTimePct    
 ,MAX(MaxInuseMax)          AS InuseMax         
 ,MAX(MaxInuseMax)          AS MaxInuseMax      
 ,AVG(AvgInuseMax)          AS AvgInuseMax      
 ,MAX(AWTINUSE)             AS AWTINUSE         
 ,MIN(Available)            AS Available        
 ,MIN(AvailableMin)         AS AvailableMin  
 ,SUM(dt1.AVAIL_0Pct   )    AS AVAIL_0Pct        
 ,SUM(dt1.AVAIL1_15Pct )    AS AVAIL1_15Pct      
 ,SUM(dt1.AVAIL16_35Pct)    AS AVAIL16_35Pct     
 ,SUM(dt1.AVAIL36_50Pct)    AS AVAIL36_50Pct     
 ,SUM(dt1.AVAIL51_65Pct)    AS AVAIL51_65Pct     
 ,SUM(dt1.AVAIL66_85Pct)    AS AVAIL66_85Pct     
 ,SUM(dt1.AVAIL86_99Pct)    AS AVAIL86_99Pct     
 ,SUM(dt1.AVAIL_100Pct )    AS AVAIL_100Pct      
FROM
(SELECT
   LogDate
  ,WorkPeriod
  ,Period
  ,LogHour
  ,Log10Minute
  ,NodeType
  ,MaxAWT
  ,AvgAWT
  ,MinAWT
  ,MaxAWTUtil
  ,AvgAWTUtil
  ,MinAWTUtil
  ,MSGWORKNEW           AS MSGWORKNEW
  ,MSGWORKONE           AS MSGWORKONE
  ,MSGWORKTWO           AS MSGWORKTWO
  ,MSGWORKTHREE         AS MSGWORKTHREE
  ,WorkTypeInuse04      AS WorkTypeInuse04    
  ,WorkTypeInuse05      AS WorkTypeInuse05    
  ,WorkTypeInuse06      AS WorkTypeInuse06    
  ,WorkTypeInuse07      AS WorkTypeInuse07    
  ,MSGWORKEXPNEW        AS MSGWORKEXPNEW      
  ,MSGWORKEXPONE        AS MSGWORKEXPONE      
  ,WorkTypeInuse10      AS WorkTypeInuse10    
  ,WorkTypeInuse11      AS WorkTypeInuse11    
  ,MSGWORKABORT         AS MSGWORKABORT
  ,MSGWORKSPAWN         AS MSGWORKSPAWN
  ,MSGWORKNORM          AS MSGWORKNORM
  ,MSGWORKCONTROL       AS MSGWORKCONTROL          
  ,AWT_0Pct
  ,AWT1_15Pct
  ,AWT16_35Pct
  ,AWT36_50Pct
  ,AWT51_65Pct
  ,AWT66_85Pct
  ,AWT86_99Pct
  ,AWT_100Pct
  ,AWT_Allocation     -- includes MessageType 00 & 01 only
  ,AWTLimit
  ,MsgQueDepth
  ,InFlowControl      
  ,FlowCtlCnt
  ,FlowCtlTime        
  ,MaxFlowCtlTimePct  
  ,AvgFlowCtlTimePct  
  ,MaxInuseMax
  ,AvgInuseMax
  ,AWTINUSE
  ,Available          
  ,AvailableMin       
  ,AVAIL_0Pct    
  ,AVAIL1_15Pct  
  ,AVAIL16_35Pct 
  ,AVAIL36_50Pct 
  ,AVAIL51_65Pct 
  ,AVAIL66_85Pct 
  ,AVAIL86_99Pct 
  ,AVAIL_100Pct 
FROM PDCRINFO.AWTRpt_Hst  a
WHERE LogDate BETWEEN  date-30 AND date-1
AND  LogHour BETWEEN 0 AND 23 ) dt1

INNER JOIN PDCRINFO.Calendar c
ON dt1.logdate = c.calendar_date
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12  )abc
)pqr
group by 1,2