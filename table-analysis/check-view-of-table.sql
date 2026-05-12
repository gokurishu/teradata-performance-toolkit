--Check all views of the table

WITH P (DbName,TblName) AS (
	    SELECT	 'STG_DASH_T','L_ORDERITEMS') 
SELECT	 DatabaseName,
		TVMName,
        TableKind AS "Type" 
FROM	   dbc.TVM T,
        dbc.dbase D,
        P 
WHERE	D.DatabaseId=T.DatabaseId 
    AND CreateText LIKE '%"' || P.DbName || '"."' || P.TblName || '"%' (NOT CS) 
UNION 
SELECT	 DatabaseName,
        TVMName,
        TableKind AS "Type" 
FROM	   dbc.TextTbl X,
        dbc.dbase D,
        dbc.TVM T,
        P 
WHERE	X.TextType='C' 
    AND X.TextString LIKE '%"' || P.DbName || '"."' || P.TblName || '"%' (NOT CS) 
    AND X.DatabaseId=D.DatabaseId 
    AND X.TextId=T.TVMId 
UNION 
SELECT	 ChildDB,
        ChildTable,
        'T' 
FROM	   dbc.RI_Distinct_Children,
        P 
WHERE	ParentDB=P.DbName 
    AND ParentTable=P.TblName 
MINUS 
SELECT	 DatabaseName,
        TVMName,
        TableKind 
FROM	   dbc.TVM T,
        dbc.dbase D,
        P 
WHERE	D.DatabaseId=T.DatabaseId 
    AND DatabaseName=P.DbName 
    AND TVMName=P.TblName 
ORDER BY 1,2