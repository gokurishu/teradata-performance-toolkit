--- DECOMMISON BY DBQL | SZE | TABLE INFO

--90 DAYS DBQL
SELECT 
a.logdate,
a.CollectTimeStamp,
a.procid,
a.queryid,
a.SessionID,
a.UserName,
c.objectdatabasename AS DatabaseName,
c.objecttablename,
SUM(z.CURRENTPERM) /(1024*1024*1024) AS CURRENTPERM,
(MAX(z.CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 AS "Size in GB",
((MAX(z.CURRENTperm)* (HASHAMP()+1))/1024/1024/1024 ) -  (SUM(z.CURRENTPERM) /(1024*1024*1024)) IMPACTED_SPACE,
y.CreatorName,                                                    
y.CreateTimeStamp,               
y.LastAlterName,                 
y.LastAlterTimeStamp,            
y.AccessCount,                   
y.LastAccessTimeStamp,
a.StartTime,
EXTRACT (HOUR FROM a.starttime) AS LogHour,
a.FirstRespTime,
(a.FirstRespTime - a.StartTime) HOUR TO SECOND(6) AS FirstRespElapsedTime,
( a.firstresptime - a.starttime second(4)) as Resptime_secs,
a.TotalIOCount,
a.AMPCPUTime+ParserCPUTime TotalCPUTime,
MaxAMPCPUTime * numofactiveamps AS ImpactCPU,
100-(NULLIFZERO(AMPCPUTime/NULLIFZERO(numofactiveamps))/(MaxAMPCPUTime)*100) "Skew Factor",
a.Statementtype,
a.ERRORCODE,
a.ErrorText,
b.sqlrowno,                                                  -- check this line
a.NumResultRows,
b.sqltextinfo
FROM  PDCRINFO.dbqlogtbl_hst a INNER JOIN PDCRINFO.dbqlsqltbl_hst b
ON a.procid = b.procid
AND a.queryid = b.queryid
AND a.logdate = b.logdate
INNER JOIN (SEL DISTINCT objectdatabasename,ObjectTableName,queryid, procid, logdate FROM PDCRINFO.dbqlobjtbl_hst
WHERE objectdatabasename = 'BI_MINING'
AND objecttablename IN(
'CCL_BACKUP',
'CUST_CALL_JO',
'CUST_CALL_SEGMENT_JO',
'DTS2',
'EDELACR30_MONTHLY_POSTPAIDBANS',
'EDELACR30_NEXIDIA_CRT',
'EDELACR30_TEMP_CFPM_VRFY_MEMOS',
'EDELACR30_TEMP_MESSAGING',
'EDELACR30_TEMP_VRFY_MEMOS',
'EE_MEMO_PAYMENT_WAIVERS',
'JO_CALL_DATA',
'JO_CALL_DATA2',
'JS_CALLS_B4_DEACT',
'JS_TEX_ACTS_V2',
'JS_TWO_MARKET2',
'LAC_SAH_TEMP',
'LC_CEI_MSISDN_SCORE_MONTHLY_TEMP',
'LC_LASTCHANNEL_TEMP_BU',
'LC_SAH_TEMP091819',
'LW_FULLDS_TWEETS',
'LW_FULLDS_VOTER',
'MX_AAL_MODEL_20191031',
'MX_ACCTNUM1',
'MX_ALLCALLS_DAILY_SCORING_SIMULATE',
'MX_ASSIST_BASE_SCORE_FINAL',
'MX_ASSISTED_PAYMENT',
'MX_BANS_FINAL',
'MX_BASE_AAL_SCORE_20191031',
'MX_CL_DATA3',
'MX_CL_DATA4',
'MX_CL_DATA5',
'MX_CR_TEST',
'MX_FREQCALLERS',
'MX_FREQCALLERS_BAN',
'MX_HINT_FINAL',
'MX_HINT_FINAL2',
'MX_HINT_FINAL3',
'MX_NEX_MODEL_VALID',
'MX_NEX_MODEL_VALID2',
'MX_NEX_ZIP_DEC2018',
'MX_PMT_PA_DATA3',
'MX_PMT_PA_DATA4',
'MX_PMT_PA_DATA5',
'MX_PMT_PA_DATA6',
'MX_PMT_PA_DATA7',
'MX_SENTIMENT_SCORE_ATTRS_UPDATE',
'MX_STILL_ON_EIP',
'MX_SUBS_FINAL1',
'MX_SUBS_FINAL2',
'MX_TFB_ACCOUNTBANOPPTY',
'MX_TFB_BASE',
'MX_TFB_SCORE6',
'MX_TFB3_VALID',
'MX_UPLIFT_0120_ATTRS_NEW',
'MX_UPLIFT_0220_ATTRS_NEW',
'MX_UPLIFT_0919_ATTRS_NEW',
'MX_UPLIFT_1019_ATTRS_NEW',
'MX_UPLIFT_1119_ATTRS_NEW',
'MX_UPLIFT_1219_ATTRS_NEW',
'MX_UPLIFT_REFRESH_DEC_1019',
'MX_UPLIFT_REFRESH_DEC_1119',
'MX_UPLIFT_REFRESH13',
'MX_UPLIFT_REFRESH3',
'MX_UPLIFT_REFRESH4',
'MX_UPLIFT_REFRESH6',
'MX_UPLIFT_REFRESH8',
'MX_UPLIFT2020',
'NEX_CHURN',
'NEXIDIA_SAMPLE_PULL',
'NEXIDIA_SAMPLE_PULL_CSATNPS',
'NEXIDIA_TEMP_SUMMARY_TEMP_JC',
'NEXIDIA_TRANSCRIPT_SUMMARY_PROD_BKUP20200512',
'NV_CUST_ATTRB_JAN2019',
'OB_TREATMENT_ALL',
'OB_TREATMENT_FINAL_REPORT_BACKUP',
'PA_3MONTHS',
'PA_DEVICE_CPC_FACT',
'PERM_RETAIL_CALLS_72HR',
'PERM_RETAIL_VISITS_TEX_72HR',
'RETAIL_VISIT_TEST_72HR',
'RH_CALL_ALLOC_TEST',
'RH_CALL_ALLOC_TEST2',
'RH_ROUTING_MODEL_CALLS',
'RH_TEX_BAN_AUG',
'RH_TEX_BAN_JUL',
'RH_TEX_BAN_JUN',
'RH_TEX_BAN_SEP',
'RH_UPMODEL_FEB',
'RH_ZIPCLUST',
'RN_MODEL_SUM_DEC8',
'RN_ZIP_CODE_1',
'RN_ZIP_CODE_1_V2',
'RW_CUST_20160131',
'RW_CUST_20160229',
'RW_CUST_20160331',
'RW_CUST_20160430',
'SJ_ALL_ACTS_MOM_DEACTS',
'SJ_GC_HANDLELOCATION_ALL_2017',
'SJ_RETAIL_DIMBRIDGEDEALERSTORE',
'SNI_CPC_EVENT_BASE_HIST',
'SNI_CPC_EVENT_BASE_HIST_ARC',
'SNI_CPC_EVENT_BASE_HIST_ROLLING',
'SNI_CPC_EVENT_BASE_HIST_ROLLING_2',
'SNI_CREDIT_CLASS_A',
'SNI_OFFER_TEST_REPORTING',
'SNI_PA_BEFORE_CALL',
'SV_CALLS',
'TEX_CALL_STG1_TEMP',
'TEX_CALL_SUM_TENURE_REPCALLCENTER',
'TEX_DOMESTIC_ROAMING_BAN',
'TEX_JJ_VALID_ASSIGNMENTS_20180709',
'TEX_POSTPAID_CALL_ID_TEST',
'TEX_TFB_MBR_2018DEC_TX',
'TMOHIERARCHY'
)
AND logdate BETWEEN DATE-90 AND DATE) AS c
ON a.procid = c.procid
AND a.queryid = c.queryid
AND a.logdate = c.logdate 
INNER JOIN 
DBC.TABLESIZEV as z
on
z.DATABASENAME=c.objectdatabasename
AND z.TABLENAME=c.objecttablename
INNER JOIN
DBC.TABLESV AS y
on
z.DATABASENAME=y.DATABASENAME
and z.TABLENAME=y.TABLENAME

WHERE a.logdate BETWEEN DATE -90 AND DATE
group by 1,2,3,4,5,6,7,8,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
order by 7,8;
------------------------------------------------------------------------------------------------
sel substr(s.sqltextinfo,1,100) as SQLTextPartial,sum( l.ampcputime) as CPUtotal, count(*) 
FROM PDCRINFO.dbqlogtbl l
JOIN PDCRINFO.dbqlsqltbl  s
ON l.procid=s.procid
AND l.queryid=s.queryid
and l.logdate=s.logdate
JOIN (
select 
logdate,
procid,
queryid
from pdcrinfo.dbqlobjtbl
where OBJECTDATABASENAME = 'EDW_D03'
and OBJECTTABLENAME='SUBSCRIPTION_STATUS_HIST'
and logdate between date-10 and date
--and typeofuse >=6
group by 1,2,3    
) O
ON l.queryid = O.queryid
AND  l.procid=o.procid
and l.logdate=o.logdate
Where  L.logdate BETWEEN  date-10 and date
--and l.queryband not like '%wf_PAA_TA_CORE_ADS_ACCT%'
--AND o.logdate BETWEEN  date-30 and date
AND s.logdate BETWEEN  date-10 and date
--AND l.numofactiveamps >  0
and errortext is null
group by 1 
--AND  l.StatementType <>  'Collect Statistics'  
--and O.TYPEOFUSE >=6
order by 2 desc;

----------------------------------------------------------------------------------------------------

select substr(b.sqltextinfo,1,100) as SQLTextPartial,sum( a.ampcputime) as CPUtotal, count(*) 
FROM  pdcrinfo.dbqlogtbl_hst a inner join pdcrinfo.dbqlsqltbl_hst b
on a.procid = b.procid
and a.queryid = b.queryid
and a.logdate = b.logdate
WHERE 
a.logdate='2020-04-16'
AND a.USERNAME='STG_OFSLL_USR'
group by 1
order by 2 desc;


----------------------------------------------------------------------------------------------------
SELECT  
c.objectdatabasename as "DATABASE",
c.objecttablename AS "TABLE",
l.UserName,                     
l.logdate , 
l.collecttimestamp ,
l.queryid , 
l.queryband ,
l.procid , 
sessionid ,
l.ampcputime ,
l.maxampcputime ,
l.totaliocount ,
( l.firstresptime - l.starttime MINUTE( 4 )  ) AS RunTIme ,
100-(NULLIFZERO(AMPCPUTime/NULLIFZERO(numofactiveamps))/(MaxAMPCPUTime)*100) "Skew Factor",

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
END    AS UII ,

l.MaxAmpCPUTime * ( HASHAMP ( ) + 1  ) AS ImpactCPU ,
s.sqltextinfo 

FROM    pdcrinfo.dbqlogtbl l JOIN pdcrinfo.dbqlsqltbl s 
    ON l.procid = s.procid 
    AND l.queryid = s.queryid 
    AND l.logdate = s.logdate 
INNER JOIN (SEL DISTINCT objectdatabasename,ObjectTableName,queryid, procid, logdate FROM PDCRINFO.dbqlobjtbl_hst
/*WHERE objectdatabasename = 'USER_DW'
AND objecttablename=''*/
) AS c
ON l.procid = c.procid
AND l.queryid = c.queryid
AND l.logdate = c.logdate 
WHERE l.logdate='2020-04-07'
AND l.UserName='APPL_ATA_AFV_IDW '

------------------------------------------------------------------------------------------------

-- START DATE AND END DATE OF PREVIOUS MONTH

--START DATE
SELECT cast(ADD_MONTHS(date - EXTRACT(DAY FROM date)+1, -1)as date) 

--END DATE
SELECT cast(date - EXTRACT(DAY FROM date)as date)