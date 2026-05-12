DEL FROM PERF_WRK.MVC1;
DEL FROM PERF_WRK.MVC2;
DEL FROM PERF_WRK.MVC3;
DEL FROM PERF_WRK.Monthly_Space_4;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.MVC1
with recursive temp_table(databasename, ownername, depth) as                
	(select root.databasename, root.ownername, 0 as depth                
	from dbc.databases root                
	where root.databasename='datasupport'                
	union all                
	select indirect.databasename, indirect.ownername,                
	seed.depth+1 as depth                
	from temp_table seed, dbc.databases indirect                
	where seed.databasename=indirect.ownername                
	and indirect.ownername<>indirect.databasename                
	and depth<=100                
	)                
select ownername, databasename, depth                
from temp_table;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.MVC2
with recursive temp_table(databasename, ownername, depth) as                
	(select root.databasename, root.ownername, 0 as depth                
	from dbc.databases root                
	where root.databasename='datasupport_fads'                
	union all                
	select indirect.databasename, indirect.ownername,                
	seed.depth+1 as depth                
	from temp_table seed, dbc.databases indirect                
	where seed.databasename=indirect.ownername                
	and indirect.ownername<>indirect.databasename                
	and depth<=100                
	)                
select ownername, databasename, depth                
from temp_table;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.MVC3
with recursive temp_table(databasename, ownername, depth) as                
	(select root.databasename, root.ownername, 0 as depth                
	from dbc.databases root                
	where root.databasename='datasupport_edw'                
	union all                
	select indirect.databasename, indirect.ownername,                
	seed.depth+1 as depth                
	from temp_table seed, dbc.databases indirect                
	where seed.databasename=indirect.ownername                
	and indirect.ownername<>indirect.databasename                
	and depth<=100                
	)                
select ownername, databasename, depth                
from temp_table;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.Monthly_Space_4
select logdate, databasename, SUM(CurrentPerm)/1024/1024/1024/1024 as currentperm,sum(maxperm)/1024/1024/1024/1024 as maxperm,
maxperm *.70 as maxperm_70
from pdcrinfo.databasespace_hst group by 1,2,5;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
b.logdate,
CASE WHEN B.LOGDATE <= '2016-11-04' THEN SYSTEM_MAXSPACE_IN_TB ELSE SYSTEM_MAXSPACE_IN_TB - (39*4) END AS SYSTEM_MAX_IN_TB,
SYSTEM_MAX_IN_TB *.70 as SYSTEM_MAXSPACE_70_IN_TB,
sum(b.IDW_space) as IDW_space_tb,
sum(b.FADS_space) as FADS_space_tb,
sum(b.EDW_space) as EDW_space_tb,
sum(b.spool_space) as spool_space_tb,
sum(b.DBA_space) as DBA_space_tb
from 
(
SELECT
a.logdate, 
case when databasetype='IDW' then
CurrentPerm else 0 end as IDW_space,
case when databasetype='FADS' then
CurrentPerm else 0 end as FADS_space,
case when databasetype='EDW' then
CurrentPerm else 0 end as EDW_space,
CASE when databasetype='spool' then
maxperm else 0 end as spool_space,
case when databasetype='DBA' then 
CurrentPerm else 0 end as DBA_space
FROM PERF_WRK.Monthly_Space_4 a inner join
(
select databasename, cast('IDW' as varchar(30)) as databasetype from PERF_WRK.MVC1
union all
select databasename, 'FADS' as databasetype from PERF_WRK.MVC2
union all
select databasename, 'EDW' as databasetype from PERF_WRK.MVC3
union all
select databasename,'spool'  from dbc.databases where databasename='spoolreserve'
union all 
select databasename, 'DBA' from dbc.databases where databasename not in (
select databasename from PERF_WRK.MVC1
union all
select databasename from PERF_WRK.MVC2
union all
select databasename from PERF_WRK.MVC3))x
on a.databasename=x.databasename)b
inner join (
select logdate,
SUM(MaxPerm)/1024/1024/1024/1024 AS SYSTEM_MAXSPACE_IN_TB
from pdcrinfo.databasespace_hst group by 1)y
on b.logdate=y.logdate
WHERE
B.LOGDATE between (SELECT cast(ADD_MONTHS(date - EXTRACT(DAY FROM date)+1, -1)as date)) and (SELECT cast(date - EXTRACT(DAY FROM date)as date))
group by 1,2,3;
