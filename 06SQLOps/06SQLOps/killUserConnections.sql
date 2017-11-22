/*
	Code snippet to kill connections
*/


-- 1. To generate a list of commands to kick out all user connections except sa

SELECT 'kill '+convert(char(10),session_id)
FROM sys.dm_exec_sessions 
where login_name in 
(
select name from master..syslogins
where isntuser =0 and isntgroup=0 and name not like '##MS_%' and name <>'sa'
)


-- 2. To generate a list of commands to kick out all user connections to specific databases
-- display db
select name, database_id from sys.databases

-- kill connections
SELECT p.hostname, d.name, p.program_name, 'kill '+convert(varchar, p.spid)+ '; ' as '--kill commands'
FROM master..sysprocesses p,sys.databases d  
WHERE p.dbid =d.database_id and d.name in ('UserDB1', 'UserDB2')