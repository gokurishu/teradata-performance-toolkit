--SKEW OF PI (SKEW OF THE TABLE) IMPACT SPACE SAVINGS

SELECT 
databasename as "Database Name", 
TABLENAME as "Table Name", 
(MAX(CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 AS "Size in GB", 
SUM(CURRENTPERM) /(1024*1024*1024) AS CurrentPerm, 
((MAX(CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 ) -  (SUM(CURRENTPERM) /(1024*1024*1024)) ImpactedSpace,
(100 - (AVG(CURRENTPERM)/MAX(CURRENTPERM)*100)) AS SkewFactor 
FROM 
DBC.TABLESIZEV 
--WHERE DATABASENAME in( 'dl_perf','stg_sam_t') 
 WHERE TABLENAME ='L_UDR_PRE_ZERO' 
GROUP BY 1,2;  



------------------

--TO FIND SKEW OF NEW COLUMN (COLUMN LEVEL SKEW)


SELECT
SUM(SKEWCALC.NumberOfRows) as TotalRows
,MIN(SKEWCALC.NumberOfRows) as MinRowsOnAmp
,MAX(SKEWCALC.NumberOfRows) as MaxRowsOnAmp
,AVG(SKEWCALC.NumberOfRows) as AVGRowsOnAmp
,100 - ( AVG(SKEWCALC.NumberOfRows)
/ MAX(SKEWCALC.NumberofRows) * 100 ) as SkewFactor
FROM ( /* Derived Table */
SELECT
Hashamp (Hashbucket (Hashrow(
/* Candidate Primary Index Column(s) go below here */
STATUS_RSN_CODE2
))) as AMPNumber
,Count(*) AS NumberOfRows
From /* Candidate Table goes below here */
SAND_LEGAL.cpsms_write_off_detail2
GROUP BY 1) as SKEWCALC( AmpNumber, NumberOfRows);
