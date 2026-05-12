--UTILITY HEAT MAP

SELECT
Local_Date,
Local_Hour,
Max(UtilityCountMax)/max(UtilityLimit)*100 Pct
from
(
Select
  FT.Local_Date,
  Case 'H'
   When 'D' Then 0
   Else FT.Local_Hour
  End As Local_Hour,
  Case 'H'
   When 'D' Then 0
   When 'H' Then 0
   Else FT.Local_10Minute
  End As Local_10Minute,
  Case 'H'
   When 'D' Then 0
   When 'H' Then 0
   When 'T' Then 0
   Else FT.Local_Minute
  End As Local_Minute,
  CAL.Year_of_Calendar As Local_Year_of_Calendar,
  CAL.Month_of_Year As Local_Month_of_Year,
  CAL.Day_of_Month As Local_Day_of_Month,
  CAL.Week_of_Year As Local_Week_of_Year,
  CAL.Day_of_Week As Local_Day_of_Week,
  -- TODO CAL.IsBusinessDay As Local_IsBusinessDay,
  (FT.Local_Date - CAL.Day_of_Week + 1) As Local_BOW,
  SH.WorkPeriod,
  SH.Shift,
  SH.Period,
  FT.UtilityType,
  Max(FT.UtilityCount) As UtilityCountMax,
  Avg(FT.UtilityCount) As UtilityCountAvg,
  Avg(FT.UtilityLimit) As UtilityLimit
  
  
 From PDCRINFO.TDWMUtilityStats_Hst_TZ As FT
Inner Join PDCRINFO.Calendar  As CAL
  On FT.Local_Date = CAL.Calendar_Date
Inner Join PDCRINFO.ShiftHour As SH
  On FT.Local_Hour = SH.ShiftHour
Where FT.PPI_Date Between date-30 And date-1
  And FT.Local_Date Between date-30 And date-1
Group By
  FT.Local_Date,
  FT.Local_Hour,
  FT.Local_10Minute,
  FT.Local_Minute,
  Local_Year_of_Calendar,
  Local_Month_of_Year,
  Local_Day_of_Month,
  Local_Week_of_Year,
  Local_Day_of_Week,
  -- TODO Local_IsBusinessDay,
  Local_BOW,
  SH.WorkPeriod,
  SH.Shift,
  SH.Period,
  FT.UtilityType
)abc
where
UtilityLimit='15'
group by 1,2;