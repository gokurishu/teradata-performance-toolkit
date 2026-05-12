create volatile table vt1
as
(
sel * from
(
SELECT 
OBJECTDATABASENAME,
objecttablename,
currentperm_gb,
count(distinct l.StatementType ) as ctr
FROM PDCRINFO.dbqlogtbl l
JOIN PDCRINFO.dbqlsqltbl  s
ON l.procid=s.procid
AND l.queryid=s.queryid
and l.logdate=s.logdate
JOIN (
select 
logdate,
procid,
queryid,
OBJECTDATABASENAME,
objecttablename,
currentperm_gb
from pdcrinfo.dbqlobjtbl abc, (
sel databasename,tablename,currentperm_gb
from
(
SELECT a.databasename,a.tablename,b.createtimestamp,b.creatorname,
SUM(currentperm) /(1024*1024*1024) AS currentperm_gb,
(100 - (AVG(currentperm)/MAX(currentperm)*100)) AS skewfactor
FROM
dbc.tablesizev a, dbc.tablesv b
WHERE a.databasename = b.databasename
AND a.tablename = b.tablename
AND a.databasename= 'BI_MINING'
GROUP BY 1,2,3,4
)abc
where currentperm_gb>=1
)a
where OBJECTDATABASENAME = 'BI_MINING'
and logdate between date-90 and date
and a.databasename=abc.OBJECTDATABASENAME
and a.tablename=abc.objecttablename
group by 1,2,3,4,5,6    
) O
ON l.queryid = O.queryid
AND  l.procid=o.procid
and l.logdate=o.logdate
Where  L.logdate BETWEEN  date-90 and date
--and l.queryband not like '%wf_PAA_TA_CORE_ADS_ACCT%'
--AND o.logdate BETWEEN  date-30 and date
AND s.logdate BETWEEN  date-90 and date
--AND l.numofactiveamps >  0
and errortext is null
group by 1,2,3
)abc
where ctr<=2
)
with data 
no primary index
on commit preserve rows ;

--------------------------------------------------------------------

SELECT 
l.logdate,OBJECTDATABASENAME,OBJECTTABLENAME,currentperm_gb
   ,s.sqltextinfo AS  sqltextinfo, l.StatementType
   
FROM PDCRINFO.dbqlogtbl l
JOIN PDCRINFO.dbqlsqltbl  s
ON l.procid=s.procid
AND l.queryid=s.queryid
and l.logdate=s.logdate
JOIN (
select 
a.logdate,
procid,
queryid,
a.OBJECTDATABASENAME,
currentperm_gb,
a.OBJECTTABLENAME
from pdcrinfo.dbqlobjtbl a, vt1 b
where a.OBJECTDATABASENAME = b.OBJECTDATABASENAME
and a.OBJECTTABLENAME= b.OBJECTTABLENAME
and a.logdate between date-90 and date
--and typeofuse >=6
group by 1,2,3,4,5,6    
) O
ON l.queryid = O.queryid
AND  l.procid=o.procid
and l.logdate=o.logdate
Where  L.logdate BETWEEN  date-90 and date
--and l.queryband not like '%wf_PAA_TA_CORE_ADS_ACCT%'
--AND o.logdate BETWEEN  date-30 and date
AND s.logdate BETWEEN  date-90 and date
--AND l.numofactiveamps >  0
and errortext is null
--AND  l.StatementType <>  'Collect Statistics'  
--and O.TYPEOFUSE >=6
order by 2 desc
;
