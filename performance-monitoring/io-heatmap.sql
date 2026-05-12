--IO HEATMAP

select
        TheDate
        ,extract (hour from TheTime)
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
            and thedate between date-10 and  current_date 
                ) as AA
                QUALIFY QUANTILE (5,DiskPct)=4
                Group by 1,2,3
        ) as BB
            Group by 1,2,3;