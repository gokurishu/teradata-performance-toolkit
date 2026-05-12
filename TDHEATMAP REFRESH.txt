/*Partitioned:
PERF_WRK.L_S_CONTACT
STG_XMN_T.T_XMINE_USAGE_DATES
FADS_T.F_SPRNT_NETWORK_USAGE

No paritioned:
STG_SAM_T.T_EIP_ACTIVITY
STG_PCD_T.T_ORDER_CONDITIONS

CASE PARITIONED:
FADS_T.D_ACCOUNT
FADS_T.M_EIP_EQUIPMENT

DUAL PARTITIONE CASE AND RANGE:
FADS_T.F_POSTPAID_INVOICE
FADS_T.F_CREDIT_HISTORY*/

-------------------------------------------------------------------------------------------------------------------------------------------------------------

--PERF_WRK.L_S_CONTACT
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

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--STG_XMN_T.T_XMINE_USAGE_DATES
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
databasename = 'STG_XMN_T'
and
tablename = 'T_XMINE_USAGE_DATES';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--FADS_T.F_SPRNT_NETWORK_USAGE
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
databasename = 'FADS_T'
and
tablename = 'F_SPRNT_NETWORK_USAGE';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--STG_SAM_T.T_EIP_ACTIVITY
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
databasename = 'STG_SAM_T'
and
tablename = 'T_EIP_ACTIVITY';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--STG_PCD_T.T_ORDER_CONDITIONS
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
databasename = 'STG_PCD_T'
and
tablename = 'T_ORDER_CONDITIONS';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--FADS_T.D_ACCOUNT
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
databasename = 'FADS_T'
and
tablename = 'D_ACCOUNT';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--FADS_T.M_EIP_EQUIPMENT
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
databasename = 'FADS_T'
and
tablename = 'M_EIP_EQUIPMENT';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--FADS_T.F_POSTPAID_INVOICE
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
databasename = 'FADS_T'
and
tablename = 'F_POSTPAID_INVOICE';

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--FADS_T.F_CREDIT_HISTORY
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
databasename = 'FADS_T'
and
tablename = 'F_CREDIT_HISTORY';
