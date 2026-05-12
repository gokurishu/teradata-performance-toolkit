--COLUMN USAGE

SELECT
ObjectDatabaseName
,ObjectTableName
,objectcolumnname
--,FreqofUse
, CASE TypeOfUse
         WHEN  1 THEN  '  1: Reference only'
        WHEN  2 THEN  '  2: Access'
         WHEN  3 THEN  '  3: Reference, access'         
         WHEN  6 THEN  '  6: Access, conditional'
         WHEN  7 THEN  '  7: Reference, access, conditional'
         WHEN 10 THEN  ' 10: Access, inner join'
         WHEN 14 THEN  ' 14: Access, conditional, inner join'
         WHEN 18 THEN  ' 18: Access, outer join'
         WHEN 22 THEN  ' 22: Access, conditional, outer join' 
         WHEN 30 THEN  ' 30: Access, conditional, inner and outer join' 
         WHEN 34 THEN  ' 34: Access, sum'
         WHEN 38 THEN  ' 38: Access, conditional, sum'
         WHEN 46 THEN  ' 46: Access, conditional, sum, inner join'
         WHEN 54 THEN  ' 54: Access, conditional, sum, outer join'
         WHEN 70 THEN  ' 70: Access, conditional, full outer join' 
         WHEN 102 THEN '102: Access, conditional, sum, full outer join'         
         ELSE TypeOfUse  
     END (NAMED TypeOfUse)
,COUNT(*)
FROM PDCRINFO.DBQLOBJTBL
WHERE 
 ObjectDatabaseName = 'SAND_LEGAL'
AND ObjectTableName = 'QC_proto3_mso_Legal_Qualcomm'
and logdate between date - 30 and date
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
