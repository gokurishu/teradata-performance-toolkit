-- STEP TABLE QUERY

select                                            
logdate,                                           
procid,                                           
queryid,                                           
steplev1num,                                           
steplev2num,                                           
stepname,                                           
StepStartTime,                                           
( CAST(StepStopTime  AS TIMESTAMP) -  CAST(StepStartTime AS TIMESTAMP))  hour(2) TO SECOND  AS "Elapsed Time",                                           
EstCPUCost,                                           
CPUTIME,                                           
IOCOUNT,                                           
EstRowCount,                                           
RowCount                                           
from pdcrinfo.dbqlsteptbl_hst                                           
where                                            
logdate = '2021-09-07'                                           
and queryid = 306786859517445557                                           
order by 4,5;