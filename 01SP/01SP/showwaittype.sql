/*
	store procedure to show wait type statistics from sysprocesses
*/
create procedure [dbo].[showwaittype] as
select 
	  lastwaittype
	, count(*) as '#ofOccurrences'
	, sum(physical_io) as physicalIO
	, sum(cpu) as cpu
	, sum(memusage) as memusage
from   master.dbo.sysprocesses

group by 
	  lastwaittype

order by
	  count(*) desc


GO