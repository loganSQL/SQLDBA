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

# Job to Copy it Between Instances
```
-- using local tempdb to gather the information by looping thru the databases one by one
use tempdb
go

if exists (select name from sysobjects where name ='dba_users')
  drop table dba_users
go

create table dba_users (dbname varchar(50), username varchar(50), command varchar(500))
go

EXEC sp_MSForEachDB ' Use ?; insert tempdb..dba_users select ''?'' as dbname, name as username, ''use ?; alter user [''+ name+''] with login=[''+name+'']'' as command from ?.sys.database_principals where ''?'' not in (''master'',''model'',''msdb'',''tempdb'') and type in (''U'',''G'',''S'') and name not in (''dbo'', ''guest'', ''INFORMATION_SCHEMA'',''sys'') order by type, name'
go

-- keep a clean copy in DBA database
truncate table dba.dbo.dba_users
go
insert into dba.dbo.dba_users (dbname, username, command)
select mu.* 
from tempdb..dba_users mu, sys.syslogins ml
where mu.username = ml.name and 
ml.isntgroup=0 and ml.isntname=0 and ml.name not like '##%' and ml.name<>'sa'
go

-- keep a copy on remote via linkserver [MirrorInstance]
delete from [MirrorInstance].[DBA].[dbo].[dba_users]
go

insert into [MirrorInstance].[DBA].[dbo].[dba_users](dbname, username, command)
select* from dba.dbo.dba_users
go

-- send out the CSV via email (offline copy)
declare @subject varchar(100), @filename varchar(100)
select  @subject=@@SERVERNAME+' : DBA Mirror User List',
    @filename=@@SERVERNAME+'_Mirror_User_List.CSV'
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'logansql',
@recipients = 'logansql@yourcompany.com;',
@subject = @subject,
@query = N'set nocount on;select * from dba.dbo.dba_users;',
@attach_query_result_as_file = 1,
@query_attachment_filename = @filename,
@query_result_header= 1,
@query_result_separator = '  ',
@query_result_no_padding = 1,
@query_result_width =2000
go
```