Select A.Databasename,A.Tablename,COALESCE(A.Statsname,A.Columnname)as Statname,B.LastAccessTimeStamp,B.AccessCount
from dbc.statsv A LEFT JOIN
(SELECT DatabaseName,
       TVMName AS TableName,statsid,
       COALESCE(DBC.StatsTbl.StatsName, DBC.StatsTbl.ExpressionList) AS StatName,
       OU.LastAccessTimeStamp,
       OU.UserAccessCnt AS AccessCount
FROM ObjectUsage OU
JOIN DBC.Dbase ON DBC.Dbase.DatabaseId = OU.DatabaseId
JOIN DBC.TVM ON DBC.TVM.TVMId = OU.ObjectId
JOIN DBC.StatsTbl ON DBC.StatsTbl.DatabaseId = OU.DatabaseId
                 AND DBC.StatsTbl.ObjectId = OU.ObjectId
                 AND DBC.StatsTbl.StatsId = OU.FieldId
                 WHERE  OU.usagetype='STA'
                 and databasename='FADS_T'
                 and tablename='D_BSCS_PRODUCT_SUBSCRIPTION'
                 and statname is not null)B
                                                          ON A.DATABASENAME=B.DATABASENAME
                                                          AND A.TABLENAME=B.TABLENAME
                                                          AND COALESCE(A.Statsname,A.Columnname)=B.StatName
                                                          Where A.databasename='FADS_T'
                                                          and A.tablename='D_BSCS_PRODUCT_SUBSCRIPTION'
 
 
 
 