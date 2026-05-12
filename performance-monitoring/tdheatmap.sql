DBC.PartitioningConstraintsV

--Heatmap History Table
PERF_WRK.heatmap_history

----------------------------------------------------------------
--Partitioned
PERF_WRK.L_S_CONTACT
STG_XMN_T.T_XMINE_USAGE_DATES
FADS_T.F_SPRNT_NETWORK_USAGE

--No paritioned
STG_SAM_T.T_EIP_ACTIVITY
STG_PCD_T.T_ORDER_CONDITIONS

--CASE PARITIONED
FADS_T.D_ACCOUNT
FADS_T.M_EIP_EQUIPMENT



--Multilevel PARTITIONE CASE AND RANGE
FADS_T.F_POSTPAID_INVOICE
FADS_T.F_CREDIT_HISTORY

---------------------------------------------------------------------------------------------------------------------------------
-- INSERT SELECT
--HISTORY TABLE FROM SELECT
INSERT INTO PERF_WRK.heatmap_history
SELECT  
		date TheDate
      , time TheTime
      , t1.ampnumber
      , dbase.databasenamei  DatabaseName
      , tvm.tvmnamei  TableName
      , t1.starttableid
      , t1.starttableiduniq
      , t1.starttableidtypeandindex
      , t1.startpartition
      , t1.startrowid
      , t1.endtableid
      , t1.endtableiduniq
      , t1.endtableidtypeandindex
      , t1.endpartition
      , t1.endrowhash
      , to_byte(t1.cylinderidmsw) || to_byte(t1.cylinderidlsw) CylinderId
      , t1.cylinderidmsw
      , t1.cylinderidlsw
      , t1.temperature
      , t1.normalizedtempinfo
      , t1.requestedtempinfo
      , t1.veryhotcandidate
      , t1.veryhotcache
      , t1.tempwarmceiling
      , t1.tempwarmfloor
      , t1.tempveryhotfloor
      , t1.percentfull
      , t1.temppercentile
      , t1.grade
      , t1.mediatype
      , t1.storageclass from table (syslib.tdheatmap (1))
   as t1 (
            AmpNumber,
            StartTableId,
            StartTableIdUniq,
            StartTableIdTypeAndIndex,
            StartPartition,
            StartRowId,
            EndTableId,
            EndTableIdUniq,
            EndTableIdTypeAndIndex,
            EndPartition,
            EndRowHash,
            CylinderIdMsw,
            CylinderIdLsw,
            Temperature,
            NormalizedTempInfo,
            RequestedTempInfo,
            VeryHotCandidate,
            VeryHotCache,
            TempWarmCeiling,
            TempWarmFloor,
            TempVeryHotFloor,
            PercentFull,
            TempPercentile,
            Grade,
            MediaType,
            StorageClass),
dbc.tvm tvm,
dbc.dbase dbase
where t1.starttableiduniq = tvm.tvmid
    and tvm.databaseid = dbase.databaseid
    and
databasename = 'PERF_WRK'
and
tablename = 'L_S_CONTACT';
-----------------------------------------------------------------------------------------------------------------------------------
--  QUERY
SELECT
DISTINCT 
a.TheDate AS "CAPTURE DATE",
a.TheTime AS "CAPTURE TIME",
a.DatabaseName,
a.TableName,
LATEST_DATETIME,
a.CylinderId,
a.Temperature,
a.NormalizedTempInfo,
a.PercentFull,
a.TempWarmCeiling,
a.Grade,
a.TempPercentile,
a.TempWarmFloor,
a.TempVeryHotFloor,
a.MediaType,
a.StorageClass
FROM
( SEL * FROM PERF_WRK.heatmap_history 
WHERE DATABASENAME='STG_XMN_T' AND TABLENAME='T_XMINE_USAGE_DATES') AS a
inner join
STG_XMN_T.T_XMINE_USAGE_DATES AS b
on 
a.StartPartition=b.partition
--GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
--ORDER BY 1,2;
-------------------------------------------------------------------------------------------------------------------------------------

--PPI
SELECT *
FROM DBC.PartitioningConstraintsV
where 
databasename = 'FADS_T'
and
tablename = 'F_SPRNT_NETWORK_USAGE';

--------------------------------------------------------------------
--Get partition Column with cast on it 
SELECT 
SUBSTR
(ConstraintText,23, (POSITION(' )' IN ConstraintText) - 23 + Length(')'))) as "Partition Column"
FROM DBC.PartitioningConstraintsV
where 
databasename = 'STG_XMN_T'
and
tablename = 'T_XMINE_USAGE_DATES';

--------------------------------------------------------------------
SELECT INSTR(ConstraintText,'(',-1,1)
FROM DBC.PartitioningConstraintsV
where 
databasename = 'FADS_T'
and
tablename = 'F_SPRNT_NETWORK_USAGE';


---------------------------------------------------------------------

SELECT
DISTINCT 
a.TheDate AS "CAPTURE DATE",
a.TheTime AS "CAPTURE TIME",
a.DatabaseName,
a.TableName,
--LATEST_DATETIME,
a.CylinderId,
a.Temperature,
a.NormalizedTempInfo,
a.PercentFull,
a.TempWarmCeiling,
a.Grade,
a.TempPercentile,
a.TempWarmFloor,
a.TempVeryHotFloor,
a.MediaType,
a.StorageClass
FROM
 PERF_WRK.heatmap_history a where a.StartPartition in 
 ( sel b.partition
 from 
 STG_XMN_T.T_XMINE_USAGE_DATES b
 )
 and a.DATABASENAME='STG_XMN_T' AND a.TABLENAME='T_XMINE_USAGE_DATES'
--GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
--ORDER BY 1,2;