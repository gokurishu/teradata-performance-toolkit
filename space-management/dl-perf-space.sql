--FIND SPACE OCCUPIED BY TABLES SORTED BY CREATOR IN DL_PERF


SELECT a.databasename,a.tablename,b.createtimestamp,b.creatorname,
SUM(currentperm) /(1024*1024*1024) AS currentperm_gb,
(100 - (AVG(currentperm)/MAX(currentperm)*100)) AS skewfactor
FROM
dbc.tablesizeV a, dbc.tablesV b
WHERE a.databasename = b.databasename
AND a.tablename = b.tablename
AND a.databasename= 'PERF_WRK'
--and a.tablename = 'W_SAA_CFGB2BRMDLRCDEOVRLAY'
GROUP BY 1,2,3,4
order BY 5 DESC;
 