# Generate Database User Synchronization Script
Before failover to mirror databases, it is important to generate the database users synchronization from the principal database side. This will allow to synchronize all the database users on mirrored side once they become principals.

```
use tempdb
go

if exists (select name from sysobjects where name ='dba_users')
  drop table dba_users
go

create table dba_users (dbname varchar(50), username varchar(50), command varchar(500))
go

EXEC sp_MSForEachDB ' Use ?; insert tempdb..dba_users select ''?'' as dbname, name as username, ''use ?; alter user [''+ name+''] with login=[''+name+'']'' as command from ?.sys.database_principals where ''?'' not in (''master'',''model'',''msdb'',''tempdb'') and type in (''U'',''G'',''S'') and name not in (''dbo'', ''guest'', ''INFORMATION_SCHEMA'',''sys'') order by type, name'
go

select mu.* from tempdb..dba_users mu, sys.syslogins ml
where mu.username = ml.name and 
ml.isntgroup=0 and ml.isntname=0 and ml.name not like '##%' and ml.name<>'sa'
go

```
All the commands in command columns of the table can be executed directly on mirrored side as long as all the coresponding logins are matched.