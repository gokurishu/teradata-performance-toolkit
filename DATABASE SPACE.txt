-- TO FIND SPACE OF DATABASE

SELECT	Databasename (format 'X(15)') ,
SUM(maxperm)/(1024*1024*1024)(FORMAT 'zzzz9.99',
TITLE 'Maxperm-GB') ,SUM(currentperm) /(1024*1024*1024)(FORMAT 'zzzz9.99',
TITLE 'Currentperm-GB') ,
(SUM(maxperm) - SUM(currentperm))/(1024*1024*1024)(FORMAT 'zzzz9.99',TITLE 'Free-GB') ,
((SUM(currentperm * 100))/ NULLIFZERO (SUM(maxperm)) ) (FORMAT 'zz9.99%',
		TITLE 'Percent // Used')
FROM	DBC.DiskSpace
where	databasename = 'PERF_WRK'
group by 1
ORDER BY 4;

--OPS TEAM SPACE QUERY

SELECT	CAST(TRIM(DatabaseName) as CHAR(30)) as Database_Name,
		CAST(SUM(MaxPerm)/1024/1024/1024 as DEC(10,2)) as Assigned_GB,
		CAST(SUM(CurrentPerm)/1024/1024/1024 as DEC(10,2)) as Used_GB,
		CAST(MAX(CurrentPerm)*(hashamp()+1)/1024/1024/1024 as DEC(18,2)) as Used_with_Skew_GB,
		CAST((Used_with_Skew_GB - Used_GB) as DEC(10,2)) as Wasted_GB,
		CAST((100 - (AVG(CurrentPerm)/NULLIFZERO(MAX(CurrentPerm))*100)) as DEC(10,2)) AS SkewFactor,
		cast((Assigned_GB - Used_with_Skew_GB) as DEC(10,2)) as Available_GB,
		CAST((100*Used_with_Skew_GB/NULLIFZERO(Assigned_GB)) as DEC(10,2)) as Pct_Occupied 
FROM	DBC.DiskSpaceV S 
WHERE	S.DataBaseName in ('PERF_WRK' ) 
GROUP BY 1;

------------------------------------------------------------------------------------------------------


--- TO check space of DROPPED DATABASE

Select	       
DATABASENAME,
Logdate as Logdate,
SUM(CURRENTPERM)  / 1024/1024 /1024 / 1024  as CURR_PERM_TB,
SUM(MAXPERM) /1024 / 1024 / 1024/ 1024 AS MAX_PERM_TB,
(CURR_PERM_TB / MAX_PERM_TB ) * 100.00 AS PERM_PCT_USED        
FROM	PDCRINFO.DatabaseSpace_Hst a  
WHERE	 a.LogDate >= date-30 
and databasename ='CDM_DO6'
Group by 1,2;