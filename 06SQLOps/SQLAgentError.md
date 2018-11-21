## SQL Agent Error

```
sp_configure "allow updates", 1 
reconfigure with override 


update syssubsystems 
set subsystem_dll = replace(subsystem_dll,'E:\Program Files','C:\Program Files')  
from syssubsystems 
where subsystem_dll like 'E:\Program Files%' 


sp_configure "allow updates", 0 
reconfigure with override


--Restart SQL Server Agent
``