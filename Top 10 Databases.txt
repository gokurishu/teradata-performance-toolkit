SELECT  
OBJECTDATABASENAME,
OBJECTTABLENAME,
ampcputimes,
ImpactCPU,
query_cnt,
total_users
,SUM(PJI_GT_3) "PJI > 3"
,SUM(UII_GT_3) "UII > 3"
,SUM(CPUSkew_GT_50PCT) "CPU_Skew > 50%"
FROM(
SELECT 
sq.OBJECTDATABASENAME,sq.OBJECTTABLENAME,sq.ampcputimes,sq.ImpactCPU,sq.query_cnt,sq.total_users
     ,CASE WHEN     (MaxAmpCPUTime * (HASHAMP()+1)) <100 THEN '1) LT 100'
         WHEN     (MaxAmpCPUTime * (HASHAMP()+1))>= 100 AND     (MaxAmpCPUTime * (HASHAMP()+1))  < 1000 THEN '2) 100-1K'
        WHEN     (MaxAmpCPUTime * (HASHAMP()+1))>= 1000 AND     (MaxAmpCPUTime * (HASHAMP()+1))  < 10000 THEN '3) 1-10K'
        WHEN     (MaxAmpCPUTime * (HASHAMP()+1))>= 10000 AND     (MaxAmpCPUTime * (HASHAMP()+1))  < 25000 THEN '4) 10-25K'
         WHEN     (MaxAmpCPUTime * (HASHAMP()+1))>= 25000 AND     (MaxAmpCPUTime * (HASHAMP()+1))  < 125000 THEN '5) 25K - 125 K'
        WHEN     (MaxAmpCPUTime * (HASHAMP()+1)) BETWEEN 125000 AND 250000 THEN '6) 125K - 250 K' 
        WHEN     (MaxAmpCPUTime * (HASHAMP()+1)) > 250000 THEN '7) GT 250K' END as Thresholds
    
    , SUM(CASE WHEN (((AMPCPUTime+Parsercputime) * 1000)/NULLIFZERO(TotalIOCount)) >4 THEN 1 ELSE 0 end) PJI_GT_3 
    , SUM(CASE WHEN (TotalIOCount/((AMPCPUTime + ParserCPUTime) * 1000)) >4 THEN 1 ELSE 0 end) UII_GT_3
    , SUM(CASE WHEN (100-(NULLIFZERO(AMPCPUTime/NULLIFZERO(NumOfActiveAMPs))/NULLIFZERO(MaxAMPCPUTime)*100)) > 50 THEN 1 ELSE 0 end) CPUSkew_GT_50PCT
    , SUM(CASE WHEN (100- (NULLIFZERO(TotalIOCount /NULLIFZERO(NumOfActiveAMPs)) /NULLIFZERO(maxampio)) * 100) >50  THEN 1 ELSE 0 end)   AS IOSkew_GT_50PCT
    
    FROM pdcrinfo.DBQLogTbl_hst lg, (
select 
logdate,
procid,
queryid,
a.OBJECTDATABASENAME,a.OBJECTTABLENAME,ampcputimes,ImpactCPU,query_cnt,total_users
from pdcrinfo.dbqlobjtbl a, (
sel OBJECTDATABASENAME,OBJECTTABLENAME,ampcputimes,ImpactCPU,query_cnt,total_users
from
(
SELECT 
OBJECTDATABASENAME,
OBJECTTABLENAME,
sum(l.ampcputime) as ampcputimes
,sum(l.MaxAmpCPUTime * (HASHAMP()+1))  AS ImpactCPU,
count(l.queryid) query_cnt,
count(distinct username) total_users
FROM PDCRINFO.dbqlogtbl l
JOIN (
select 
logdate,
procid,
queryid,
OBJECTDATABASENAME,
OBJECTTABLENAME
from pdcrinfo.dbqlobjtbl
where  logdate =date-1
and OBJECTTABLENAME is not null
and OBJECTDATABASENAME<>'TD_SYSFNLIB'
and objecttype IN ( 'Tab' , 'JIx', 'Idx' )
group by 1,2,3,4,5    
) O
ON l.queryid = O.queryid
AND  l.procid=o.procid
and l.logdate=o.logdate
Where  L.logdate =date-1
and errortext is null
group by OBJECTDATABASENAME,
OBJECTTABLENAME) abc
QUALIFY ROW_NUMBER() OVER (ORDER BY ampcputimes DESC) BETWEEN 1 AND 10
)b
where a.OBJECTDATABASENAME = b.OBJECTDATABASENAME
and a.OBJECTTABLENAME=b.OBJECTTABLENAME
and logdate =date-1
--and typeofuse >=6
group by 1,2,3,4,5,6,7,8,9  
) sq
    WHERE  lg.procid = sq.procid
     AND  lg.queryid = sq.queryid
     AND lg.logdate = sq.logdate
     AND lg.LogDate =date-1
     AND lg.numsteps>0
     AND lg.ampcputime>0
     and extract (hour from starttime) BETWEEN 0 and 16

    GROUP BY 1,2,3,4,5,6,7
    )a
    where
    Thresholds in ('5) 25K - 125 K','6) 125K - 250 K','7) GT 250K' )
GROUP BY 1,2,3,4,5,6

