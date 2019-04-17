--1. Check status

SELECT DB_NAME(database_id) AS DBName,
[mirroring_state_desc], -- State:  SUSPENDED (0), DISCONNECTED (1), SYNCHRONIZING (2), PENDING_FAILOVER (3), SYNCHRONIZED (4), UNSYNCHRONIZED (5), SYNCHRONIZED (6), NULL 
[mirroring_role_desc], -- Role: PRINCIPAL or MIRROR
[mirroring_safety_level_desc], -- Operating Mode: OFF =>'asynchronous'; FULL => 'synchronous'
[mirroring_partner_name],
[mirroring_partner_instance]
FROM master.sys.database_mirroring 
WHERE mirroring_guid IS NOT NULL
ORDER BY DB_NAME(database_id);

--2. Change to SAFETY FULL
select 'ALTER DATABASE ['+DB_NAME(database_id)+'] SET PARTNER SAFETY FULL;'
FROM master.sys.database_mirroring 
WHERE mirroring_guid IS NOT NULL
ORDER BY DB_NAME(database_id);


--3. Disable Logins On Primary
Select 'ALTER LOGIN '+QUOTENAME(SP.name)+' DISABLE'
FROM sys.server_principals AS SP
	LEFT JOIN sys.sql_logins AS SL
    ON SP.principal_id = SL.principal_id
WHERE SP.type_desc ='SQL_LOGIN'
   AND SP.name NOT LIKE '##%##' 
   AND SP.name NOT IN ('SA')
Order by SP.name


--4. Kill User Active Connections
SELECT 'kill '+convert(char(10),session_id)
FROM sys.dm_exec_sessions 
where login_name in 
(
select name from master..syslogins
where isntuser =0 and isntgroup=0 and name not like '##MS_%' and name <>'sa'
)

--5. Start Failover
select 'ALTER DATABASE ['+DB_NAME(database_id)+'] SET PARTNER FAILOVER;'
FROM master.sys.database_mirroring 
WHERE mirroring_guid IS NOT NULL
ORDER BY DB_NAME(database_id);

--6. MyMirror: ON NEW PRIMARY SITE SET MIRROR ASYNC (SAFETY LEVEL OFF)
SELECT 
  'ALTER DATABASE [' + DB_NAME(database_id) + '] SET PARTNER SAFETY OFF;'
  AS command_to_set_mirrored_database_to_use_synchronous_mirroring_mode
FROM master.sys.database_mirroring 
WHERE mirroring_guid IS NOT NULL
AND mirroring_role_desc = 'PRINCIPAL'
--AND mirroring_safety_level_desc = 'FULL'
ORDER BY DB_NAME(database_id);

--7. MyMirror Sync Users

SELECT [dbname]
      ,[username]
      ,[command]
FROM [DBA].[dbo].[dba_users]
where dbname not in ('DBA', 'mdw','ReportServer') 
order by dbname, username


--8. SUNPFNSQL12 Enable logins
select 'alter login '+name+' enable' from master..syslogins
where isntuser =0 and isntgroup=0 and name not like '##MS_%' and name <>'sa'
order by name


--9. Test connections
exec DBA.[dbo].[dba_test_command_by_instance] 'MYPSQL'

