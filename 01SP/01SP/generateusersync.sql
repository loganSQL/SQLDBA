/*
	store procedure to generate a list of sp_change_users_login for user synchronization in a user database
*/

create procedure [dbo].[generateusersync] as

--select 'EXEC sp_change_users_login ''Update_One'', ['+name+'], ['+name+']' from sysusers 

declare @sqltext varchar(200)

set @sqltext = 'select ''EXEC sp_change_users_login ''''Update_One'''', [''+name+''],[''+name+'']'' from sysusers where uid>4'

print @sqltext



GO