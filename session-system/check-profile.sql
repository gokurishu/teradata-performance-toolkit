--STEP 1 GET PROFILE NAME
SEL Profilename FROM dbc.dbase where DatabaseNameI='KTRIVED1'   


--STEP 2 GET DETAILS FROM PROFILE

SEL SpoolSpace FROM DBC.PROFILES
WHERE PROFILENAME='prof_SYSPERF4B_DBA'


--SPOOL OF KANISHK - 8947848532800  (8TB)




-------

--Check version of Teradata

SELECT  InfoData AS Version
FROM    DBC.DBCInfoV
WHERE   InfoKey = 'VERSION';



--  CHECK IF ACCOUNT IS LOCKED OR NOT

SELECT
CAST(CAST(logdate AS FORMAT 'YYYY-MM-DD') AS VARCHAR(100))
,CAST(logtime AS VARCHAR(100))
,sessionno
,USERNAME
,CAST(CAST(logondate AS FORMAT 'YYYY-MM-DD') AS VARCHAR(100))
,CAST(logontime AS VARCHAR(100))
,event
FROM dbc.logonoff
WHERE logdate = DATE
ORDER BY 1,2


----
Check for Phantom Spool and Peak spool :

SEL * FROM dbc.diskspacev where DatabaseName='APPL_TM1_TDFADS'   

----
Find NTID of user :

sel * from dbc.dbase where commentstring like '%Michael%finney%'