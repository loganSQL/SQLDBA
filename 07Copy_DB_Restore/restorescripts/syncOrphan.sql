set nocount on;
select 'ALTER USER ['+name+'] WITH  LOGIN =['+name+'], DEFAULT_SCHEMA=[dbo]'
from sysusers
where SUSER_ID(name) IS not NULL
and (uid>4 and uid<100)
and LOGINPROPERTY(name,'IsLocked') is not NULL;