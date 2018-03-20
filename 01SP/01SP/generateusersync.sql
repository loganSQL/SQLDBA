if exists (select name from sysobjects where name='generateusersync' and type='P')
	drop procedure generateusersync
go

create procedure [dbo].[generateusersync] as
-- only those users with the name as matched logins
-- only for SQL Login LOGINPROPERTY(name,'IsLocked') is not NULL
-- windows login supposed sync automaticall due to sid
select 'ALTER USER ['+name+'] WITH  LOGIN =['+name+']'
from sysusers
where SUSER_ID(name) IS not NULL
and (uid>4 and uid<100)
and LOGINPROPERTY(name,'IsLocked') is not NULL
GO