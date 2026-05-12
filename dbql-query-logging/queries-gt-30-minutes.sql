--Queries running greater than 30 minutes

SELECT    l.logdate , l.collecttimestamp , l.queryid , l.queryband ,
        CASE 
    WHEN queryband IS NULL THEN NULL 
    WHEN POSITION ( 'wf_' IN queryband ) = 0 THEN queryband 
    ELSE SUBSTR ( SUBSTR ( queryband , POSITION ( 'wf_' IN queryband ) ) ,
        1 , POSITION ( ';' IN SUBSTR ( queryband , POSITION ( 'wf_' IN queryband ) ) ) ) 
END    AS worflowname , l.procid , sessionid , l.ampcputime , l.maxampcputime ,
        l.totaliocount , ( l.firstresptime - l.starttime MINUTE( 4 )  ) AS RunTIme ,
        l.NumResultRows , l.SpoolUsage , l.username , ( l.firstresptime - l.firststeptime MINUTE( 4 )  ) AS resptime ,
        CASE 
    WHEN AMPCPUTime < 1 
    OR ( AMPCPUTime / ( HASHAMP ( ) + 1  )  ) = 0 THEN 0 
    ELSE MaxAmpCPUTime / ( AMPCPUTime / ( HASHAMP ( ) + 1  )  ) 
END    ( DEC ( 8 , 2 ) ) AS CPUSKW , 
CASE    
    WHEN AMPCPUTime < 1 
    OR ( TotalIOCount / ( HASHAMP ( ) + 1  )  ) = 0 THEN 0 
    ELSE MaxAmpIO / ( TotalIOCount / ( HASHAMP ( ) + 1  )  ) 
END    ( DEC ( 8 , 2 ) ) AS IOSKW , 
CASE    
    WHEN AMPCPUTime < 1 
    OR TotalIOCount = 0 THEN 0 
    ELSE ( l.AMPCPUTime * 1000  ) / l.TotalIOCount 
END    AS PJI , 
CASE    
    WHEN AMPCPUTime < 1 
    OR AMPCPUTime = 0 THEN 0 
    ELSE l.TotalIOCount / ( l.AMPCPUTime * 1000  ) 
END    AS UII , l.MaxAmpCPUTime * ( HASHAMP ( ) + 1  ) AS ImpactCPU ,
        s.sqltextinfo 
FROM    pdcrinfo.dbqlogtbl l JOIN pdcrinfo.dbqlsqltbl s 
    ON l.procid = s.procid 
    AND l.queryid = s.queryid 
    AND l.logdate = s.logdate 
WHERE    ( l.logdate , l.procid , l.queryid ) IN ( 
SELECT    DISTINCT a.logdate , a.procid , a.queryid 
FROM    ( 
SELECT    logdate , procid , queryid , 
CASE    
    WHEN 'AS' = 'AS' THEN AcctString 
    ELSE 'Unk' 
END    AS WrkLd 
FROM    PDCRINFO.DBQLogTblRpt_hst a 
WHERE    (EXTRACT ( HOUR  FROM starttime )(TITLE 'Hour')) BETWEEN 00 AND 24 
    AND ( a.firstresptime - a.starttime MINUTE( 4 )  ) >= 30 
    AND WrkLd = '$M00ETLX&S&D&H' 
    AND logdate between  DATE-7 and  DATE-1
) a );
