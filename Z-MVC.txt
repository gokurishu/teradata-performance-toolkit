DEL FROM PERF_WRK.MVC1;
DEL FROM PERF_WRK.MVC2;
DEL FROM PERF_WRK.MVC3;
DEL FROM PERF_WRK.MVC4;
DEL FROM PERF_WRK.MVC_Tables;

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
INSERT INTO PERF_WRK.MVC4 
 		select databasename, cast('IDW' as varchar(30)) as databasetype from PERF_WRK.MVC1                
		union all                
		select databasename, 'FADS' as databasetype from PERF_WRK.MVC2                
		union all                
		select databasename, 'EDW' as databasetype from PERF_WRK.MVC3                
		union all                
		select databasename,'spool'  from dbc.databases where databasename='spoolreserve'                
		union all                 
		select databasename, 'DBA' from dbc.databases where databasename not in
			(                
			select databasename from PERF_WRK.MVC1                 
			union all                
			select databasename from PERF_WRK.MVC2                 
			union all                
			select databasename from PERF_WRK.MVC3 
			);                
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.MVC_Tables
Select a.Databasename,                
                a.DatabaseType,                
                a.Tablename,
                TotColumnsperTable,                 
                ZeroIfNull(MVCUsed) As MVCUsedTbl,                 
                MVCNotUsed as MVCNotUsedTbl,                 
                ZeroIfNull(MVCUsed / (TotColumnsperTable *1.00)) as Perc_MVC_per_Tbl,                
                 Sum(CurrentPerm) As TblSize,                
                 case when MVCUsedTbl > 0 then 1 else 0 end as Tables_With_MVC,                
                 case when MVCUsedTbl = 0 then 1 else 0 end as Tables_WithNo_MVC                
                                
From

(Select c1.DatabaseName,   v.databasetype, c1.tablename, Count(*) As TotColumnsperTable From DBC.Columns c1,                
PERF_WRK.MVC4 v                
where c1.databasename = v.databasename and                
v.databasetype in ('IDW','EDW','FADS')                
AND C1.DatabaseName Not In ('pmcpdata', 'pdcrdata', 'dbc', 'crashdumps', 'pmcptpcd', 'pdcrtpcd', 'dbcmngr', 'qcd', 'tdwm', 'systemfe', 'dbcmanager', 'sys_calendar', 'syslib','BI_BACKUP_TBL'                
              ,'sysadmin','locklogshredder' )                
              and C1.tablename not like 'Z_%'                
              Group By 1,2,3) a                
Left Outer Join                
             (Select DatabaseName, Tablename, Count(*) As MVCUsed From DBC.Columns                 
              Where CompressValueList Like '%(%)%'                 
                            and tablename not like 'Z_%'                
              Group By 1,2) b                
On a.DatabaseName = b.DatabaseName and                
a.tablename = b.tablename                
Left Outer Join                
            (Select DatabaseName, Tablename, Count(*) As MVCNotUsed From DBC.Columns                
             Where (CompressValueList Not Like '%(%)%' Or CompressValueList Is Null)                 
                          and tablename not like 'Z_%'                
             Group By 1,2) c                
On a.DatabaseName = c.DatabaseName and                
a.tablename  = c.tablename                
Inner Join                
           DBC.TableSize x                
On a.DatabaseName = x.DatabaseName 
and                
a.Tablename = x.Tablename
Group By 1, 2, 3, 4, 5,6,7,9,10;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO PERF_WRK.MVC_HISTORY

SELECT	CURRENT_DATE AS theDate, COUNT(*) AS Total_Tables
, SUM(TABLES_WITH_MVC) AS TblsWithMVC
,
		SUM (TABLES_WITHNO_MVC) AS TblsWithNoMVC
FROM
PERF_WRK.MVC_TABLES
WHERE
TblSize / 1024/1024/1024 >= 10                
group by 1;