/*
	A store procedure to drop a login and all associated users

	drop a login from a server without leaving any orphan associated users. 
	first you have to iterate through all databases to drop the associated users where the login has access to
*/

use master
go

IF OBJECT_ID('dbo.sp_MSdroploginanduser') IS NOT NULL
BEGIN
DROP PROCEDURE dbo.sp_MSdroploginanduser
IF OBJECT_ID('dbo.sp_MSdroploginanduser') IS NOT NULL
PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_MSdroploginanduser >>>'
ELSE
PRINT '<<< DROPPED PROCEDURE dbo.sp_MSdroploginanduser >>>'
END
go

create procedure sp_MSdroploginanduser
@loginname varchar(30)

as

/*
Drops the specified login from the server, and previously drops all it's associated database users.

Author: César M. Buzzo - 11/11/2010
Email: cesar dot buzzo at gmail dot com
*/

declare @db varchar(30)
declare @cmd varchar(8000)

if not exists (select name from master..syslogins where name = @loginname)
begin
raiserror 50000 'The specified login does not exist'
return 1
end

declare cdb cursor for 
select name
from master..sysdatabases
order by name
for read only

open cdb

fetch from cdb into @db

while @@fetch_status = 0
begin
-- Generates the code to drop associated user for the login (if exists)
select @cmd = 'declare @usr varchar(30) select @usr = name from ' + @db + '.dbo.sysusers where suser_sname(sid) = '' + @loginname + '' if @usr is not null exec ' + @db + '..sp_dropuser @usr'
print @cmd
exec (@cmd)

fetch next from cdb into @db
end

close cdb
deallocate cdb

-- Finally, the login can be dropped
select @cmd = 'exec master..sp_revokelogin [' + @loginname + ']'
print @cmd
exec (@cmd)

if exists (select name from master..syslogins where name = @loginname)
begin
raiserror 50000 'The specified login could not be dropped. Check the output for the executed commands.'
return 1
end
else
begin
select @cmd = 'Login ' + @loginname + ' succesfully dropped.'
print @cmd
end

go
IF OBJECT_ID('dbo.sp_MSdroploginanduser') IS NOT NULL
PRINT '<<< CREATED PROCEDURE dbo.sp_MSdroploginanduser >>>'
ELSE
PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_MSdroploginanduser >>>'
go