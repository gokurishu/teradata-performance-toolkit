------QUERY TO SHOW TABLE EXPANSION BY DATE,MONTH,LOGDATE-------------


SELECT EXTRACT(YEAR FROM logdate) , EXTRACT(MONTH FROM logdate) , EXTRACT(DAY FROM logdate) , SUM(currentperm) / (1024*1024*1024)
FROM 
PDCRINFO.TableSpace_Hst                
WHERE databasename = 'IDW_TD_CORE_T'             
 AND tablename = 'EVENT_LINE_OF_SERVICE'
GROUP BY 1,2,3


-----------------------------------------------------------------------------------------------------------------------------------------------------------

SEL LOGDATE,SUM(currentperm) / (1024*1024*1024) AS "Sum(Current_Perm)"
FROM 
PDCRINFO.TableSpace_Hst                
WHERE databasename = 'IDW_TD_MKTG_T'             
AND tablename = 'W_DEMOGRAPHIC_PULL_FOR_ALLANT'
GROUP BY 1
ORDER BY 1 ASC

