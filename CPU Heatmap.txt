--CPU HEATMAP
select
A.TheDate,
A.TheTime,
extract(hour from A.TheTime) as HR,
extract(minute from A.TheTime) As Mn
,A.NodeType
,A.AvgCPUPct
,A.MaxCPUPct
,"80th Percentile Disk"
,"Max Disk"
from
(
    Select
    thedate
    ,TheTime
    ,nodeid as NodeType
    ,avg(((CPUUServ + CPUUExec)/NULLIFZERO(NCPUs))/Secs) as AvgCPUPct
    ,max(((CPUUServ + CPUUExec)/NULLIFZERO(NCPUs))/Secs) as MaxCPUPct
    from dbc.ResUsageSpma
    ---pdcrinfo.ResUsageSpma_hst
    where  thedate between DATE - 30 AND DATE
    group by 1,2,3
)  A
,
(
    select
    TheDate
    ,TheTime
    ,"80th Percentile Disk"
    ,"Max Disk"
    ,NodeType as NodeTypeB
    from
    (
        select
        TheDate
        ,TheTime
        ,NodeType
        ,min(DiskPct) as "80th Percentile Disk"
        ,max(DiskPct) as "Max Disk"
        from
        (
                select
                *
                FROM
                (
                    select
                    ---cast((thedate(format'YYYY-MM-DD'))||' '||cast(thetime as char(2))||':'||cast(((extract(minute from TheTime))(format'99')) as char(2))||':00' as timestamp(0)) as SysTime
                    TheDate
                    ,TheTime
                    ,nodeid as NodeType
                    ,cast(ldvOutReqTime as decimal(9,2))/secs as DiskPct
                    from dbc.ResUsageSldv
                    ---pdcrinfo.ResUsageSldv_hst
                    where ldvreads > 0
                    and LdvType='DISK'
            and     thedate between DATE - 30 AND DATE
                ) as AA
                QUALIFY QUANTILE (5,DiskPct)=4
                Group by 1,2,3
        ) as BB
            Group by 1,2,3
    ) sldv
) B
where A.TheDate = B.TheDate
    and A.TheTime = B.TheTime
    and A.NodeType = B.NodeTypeB