--SYSTEM THROTTLE QUERY
Select
thedate,
thetime,
rulename,
sum(IoThrottleCount),
sum(CpuVpThrottleCount),
sum(CpuVpThrottleTime),
sum(CpuThrottleCount),
sum(CpuThrottleTime),
sum(waitIO)
from
dbc.resusagesps s, tdwm.ruledefs r 
where 
s.wdid = r.ruleid 
and 
thedate = date 
group by 1,2,3;