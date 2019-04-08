# Configure MaxDOP
[Configure the max degree of parallelism Server Configuration Option](<https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option?view=sql-server-2017>)

## Info of NUMA nodes / Logical CPUs 
```
-- 4 NUMA nodes (Node 000 to Node 003)
select *
from sys.dm_os_performance_counters
where object_name = 'SQLServer:Buffer Node'
and counter_name = 'Page life expectancy'
order by instance_name

-- 24 CPU per Node
-- CPU 00 - CPU 23 (Node 0)
-- CPU 00 - CPU 23 (Node 1)
-- CPU 00 - CPU 23 (Node 2)
-- CPU 00 - CPU 23 (Node 3)

SELECT
   (cpu_count / hyperthread_ratio) AS Number_of_PhysicalCPUs,
   CPU_Count AS Number_of_LogicalCPUs
FROM sys.dm_os_sys_info
```

## Script for MaxDOP recommendation
```
declare @hyperthreadingRatio bit
declare @logicalCPUs int
declare @HTEnabled int
declare @physicalCPU int
declare @SOCKET int
declare @logicalCPUPerNuma int
declare @NoOfNUMA int

select @logicalCPUs = cpu_count -- [Logical CPU Count]
    ,@hyperthreadingRatio = hyperthread_ratio --  [Hyperthread Ratio]
    ,@physicalCPU = cpu_count / hyperthread_ratio -- [Physical CPU Count]
    ,@HTEnabled = case 
        when cpu_count > hyperthread_ratio
            then 1
        else 0
        end -- HTEnabled
from sys.dm_os_sys_info
option (recompile);

select @logicalCPUPerNuma = COUNT(parent_node_id) -- [NumberOfLogicalProcessorsPerNuma]
from sys.dm_os_schedulers
where [status] = 'VISIBLE ONLINE'
    and parent_node_id < 64
group by parent_node_id
option (recompile);

select @NoOfNUMA = count(distinct parent_node_id)
from sys.dm_os_schedulers -- find NO OF NUMA Nodes 
where [status] = 'VISIBLE ONLINE'
    and parent_node_id < 64

select '@logicalCPUs = ' + CAST(@logicalCPUs as varchar(3)) as logicalCPUs,
'@logicalCPUPerNuma= ' + CAST(@logicalCPUPerNuma  as varchar(3)) as logicalCPUPerNuma,
'@physicalCPU = ' + CAST(@physicalCPU as varchar(3)) as physicalCPU

-- Report the recommendations ....
select
    --- 8 or less processors and NO HT enabled
    case 
        when @logicalCPUs < 8
            and @HTEnabled = 0
            then 'MAXDOP setting should be : ' + CAST(@logicalCPUs as varchar(3))
                --- 8 or more processors and NO HT enabled
        when @logicalCPUs >= 8
            and @HTEnabled = 0
            then 'MAXDOP setting should be : 8'
                --- 8 or more processors and HT enabled and NO NUMA
        when @logicalCPUs >= 8
            and @HTEnabled = 1
            and @NoofNUMA = 1
            then 'MaxDop setting should be : ' + CAST(@logicalCPUPerNuma / @physicalCPU as varchar(3))
                --- 8 or more processors and HT enabled and NUMA
        when @logicalCPUs >= 8
            and @HTEnabled = 1
            and @NoofNUMA > 1
            then 'MaxDop setting should be : ' + CAST(@logicalCPUPerNuma / @physicalCPU as varchar(3))
        else ''
        end as Recommendations
go
```
## [Microsoft Recommendation/Guideline](<https://support.microsoft.com/en-ca/help/2806535/recommendations-and-guidelines-for-the-max-degree-of-parallelism-confi>)
```
-- For SQL Server 2005 and later versions
1) Server with single NUMA node  Less than 8 logical processors  Keep MAXDOP at or below # of logical processors
2) Server with single NUMA node  Greater than 8 logical processors  Keep MAXDOP at 8
3) Server with multiple NUMA nodes  Less than 8 logical processors per NUMA node  Keep MAXDOP at or below # of logical processors per NUMA node
4) Server with multiple NUMA nodes  Greater than 8 logical processors per NUMA node  Keep MAXDOP at 8
```
## Actual change
```
use master
GO   
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE WITH OVERRIDE;  
GO  
EXEC sp_configure 'max degree of parallelism', 8;  
GO  
RECONFIGURE WITH OVERRIDE;  
GO  
```
