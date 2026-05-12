------------- SYSTEM DETIALS (TELLS ABOUT EACH BOX WE HAVE) -----------------


SELECT	   LogDate, NodeType, NodeCPUs, Nodes, (Nodes * NodeCPUs * 3600) AS CPUSec_Hr,
		CPUSec_Hr*24 AS SystemCPU, 
		CASE    
			WHEN NodeType LIKE '%No_AMP%' THEN 0  
			ELSE SystemCPU * .8 
		END   AS UserCPU, AMPs, PEs  
FROM(
	SELECT	   LogDate, NodeType, NCPU AS NodeCPUs, COUNT(DISTINCT(dt.NodeID)) AS Nodes,
			MAX(dt.AMPs) * Nodes  AS AMPs, MAX(dt.PEs) * Nodes AS PEs,  MAX(dt.GTW) * Nodes AS Gateways,
			MAX(MemSize) / 1024  AS MemSize_GBs, MAX(AMPSize) / 1073741824  AS AMPSPACE_GBs,
			MAX(dt.AMPs) AS NodeAMPs, MAX(dt.PEs)  AS NodePEs  
	FROM(
		SELECT	   PMA.LogDate, NodeID, 
				CASE    
					WHEN AMPS > 0 THEN Model  
					ELSE Model || 'No_AMP'  
				END    AS NodeType, NCPU, AMPs, PEs, GTW, MemSize,  
				CASE    
					WHEN AMPS > 0 THEN MaxPerm_  
					ELSE 0  
				END     AS AMPSize    
		FROM(
			SELECT	    DISTINCT(NodeID) AS NodeId, Nodetype         AS Model,
					 NCPUs            AS NCPU, VPROC1           AS AMPs, VPROC2           AS PEs,
					VPROC3           AS GTW, MemSize          AS MemSize, thedate          AS Logdate  
			FROM	   DBC.ResUsageSPMA  
			WHERE	  Logdate = DATE) PMA     
		INNER JOIN(
			SELECT	   DATE AS Logdate, VPROC, SUM(CURRENTPERM) AS CurrentPerm,
					SUM(PEAKPERM)    AS PeakPerm, SUM(MAXPERM)     AS MaxPerm_,  (AVG(a.CURRENTPERM) / NULLIFZERO(MAX(a.CURRENTPERM))) * 100  AS CurrentPermSkew,
					(SUM(CURRENTPERM) / NULLIFZERO(SUM(MAXPERM))) * 100           AS PermPctUsed  
			FROM	   DBC.DISKSPACE  a  
			WHERE	  a.maxPERM > 0    
			GROUP BY 1, 2) DS 
			ON PMA.Logdate = DS.Logdate  
		GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9) dt  
	GROUP BY 1, 2, 3) dt1      ;