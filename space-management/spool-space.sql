--FIND SPOOL SPACE OF USER

SEL CURRENT_TIME, 

     dt.UserName, 

      SUM(ds.MaxPerm)-SUM(ds.CurrentPerm) AS AvailSpool, 

      SUM(ds.CurrentSpool) AS CurrentSpool, 

      MAX(ds.CurrentSpool) AS MaxSpoolUsed, 

      AVG(ds.CurrentSpool) AS AvgSpoolUsed, 

      MIN(ds.CurrentSpool) AS MinSpoolUsed

      FROM  DBC.DiskSpace ds, (

      SELECT          UserName 

      FROM  DBC.SessionInfo 

      WHERE           SessionNo = SESSION) dt

      WHERE DatabaseName <> 'ALL'

      GROUP BY 1,2;