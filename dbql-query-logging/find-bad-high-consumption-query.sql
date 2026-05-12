-- THIS WILL FIND SUSPECTED QUERY WITH CPU_IMPACT AND AMPCPUTIME GROUPED BY LOGDATE,USERNAME,QUERY_THEY EXECUTE  (ALSO CONTAINS NO OF TIME QUERY IS RUN)  ---
-- AMPCPUT TIME GREATE THAN (200)000 --> TUNE IT  --
-- RATIO BETWEEN AMPCPU_TIME AND CPU_IMPACT HIGHT -> TUNE IT -- 




Select logdate,
username,
TotalCPUTime,
impactCPU,
query_text,
ctf
from 
(
SELECT
a.logdate,
a.UserName,
sum(a.AMPCPUTime+ParserCPUTime) TotalCPUTime,
sum(MaxAMPCPUTime * numofactiveamps) AS impactCPU,
substr (b.sqltextinfo,1,100) as query_text,
count(*) as ctf
FROM   pdcrinfo.dbqlogtbl_hst a INNER JOIN pdcrinfo.dbqlsqltbl_hst b
                ON         a.procid = b.procid
                AND       a.queryid = b.queryid
                AND       a.logdate = b.logdate
WHERE a.logdate BETWEEN DATE -10 AND           DATE
                AND       b.logdate BETWEEN  DATE-10 AND DATE
               and b.sqlrowno=1
               group by 1,2,5
               )abc
               where
                impactCPU>=100000