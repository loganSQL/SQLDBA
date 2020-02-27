use msdb
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[sendOutputEmail]    Script Date: 2019-12-02 12:22:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[sendOutputEmail] 
(@job_name varchar(255), @outfile varchar(1024), @emails varchar(1024))
as
select @job_name= @job_name+' Daily Run At '+	CONVERT(VARCHAR(24), GETDATE(), 113)
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'sqladmin',
@recipients = @emails,
@body = 'The result has been attached.',
@file_attachments = @outfile,
@subject = 	@job_name ;
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showbackups]    Script Date: 2019-12-02 12:25:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[showbackups]
as
--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
msdb.dbo.backupset.expiration_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
msdb.dbo.backupset.backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name, 
msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1) 
ORDER BY 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_finish_date 

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showclient]    Script Date: 2019-12-02 12:26:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[showclient]
as
SELECT @@SERVERNAME as Instance,
--SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerName,
--       @@SERVERNAME AS FullInstanceName, @@SERVICENAME AS InstanceName,
session_id, p.loginame, p.hostname as client_machine, p.status, p.cmd, p.program_name,
       local_net_address AS InstanceIPAddress, local_tcp_port AS InstancePort,
	   client_net_address As ClientIPAddress,
	   client_tcp_port As ClientPort,
	   auth_scheme as AuthScheme,
	   last_read as LastRead,
	   last_write as LastWrite
FROM sys.dm_exec_connections c
,sys.sysprocesses p
where c.session_id = p.spid and client_tcp_port is not null
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showclientOutlaw]    Script Date: 2019-12-02 12:26:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showclientOutlaw]
as
SELECT @@SERVERNAME as Instance,
--SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerName,
--       @@SERVERNAME AS FullInstanceName, @@SERVICENAME AS InstanceName,
session_id, p.loginame, p.hostname as client_machine, p.status, p.cmd, p.program_name,
       local_net_address AS InstanceIPAddress, local_tcp_port AS InstancePort,
	   client_net_address As ClientIPAddress,
	   client_tcp_port As ClientPort,
	   auth_scheme as AuthScheme,
	   last_read as LastRead,
	   last_write as LastWrite
FROM sys.dm_exec_connections c
,sys.sysprocesses p
where c.session_id = p.spid and client_tcp_port is not null and program_name like 'Microsoft SQL Server Management Studio%' and auth_scheme='SQL'
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showdbs]    Script Date: 2019-12-02 12:26:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[showdbs]
as
SELECT  @@SERVERNAME AS Server ,
        name AS DBName ,
        recovery_model_Desc AS RecoveryModel ,
        Compatibility_level AS CompatiblityLevel ,
        create_date ,
        state_desc
FROM    sys.databases
ORDER BY Name

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showexeccount]    Script Date: 2019-12-02 12:27:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showexeccount] as
SELECT qs.execution_count,
    SUBSTRING(qt.text,qs.statement_start_offset/2 +1, 
                 (CASE WHEN qs.statement_end_offset = -1 
                       THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2 
                       ELSE qs.statement_end_offset end -
                            qs.statement_start_offset
                 )/2
             ) AS query_text, 
     qt.dbid, dbname= DB_NAME (qt.dbid), qt.objectid
--	 ,qs.total_rows, qs.last_rows, qs.min_rows, qs.max_rows
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt 
WHERE qt.text like '%SELECT%' 
ORDER BY qs.execution_count DESC;

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showfiles]    Script Date: 2019-12-02 12:27:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[showfiles]
as
SELECT
    db.name AS DBName,
    type_desc AS FileType,
    Physical_Name AS Location,
	round(size*8/1024,0) as 'Size(MB)'
FROM
    sys.master_files mf
INNER JOIN 
    sys.databases db ON db.database_id = mf.database_id

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showjobactivity]    Script Date: 2019-12-02 12:27:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showjobactivity] as
WITH CTE_MostRecentJobRun AS  
 (  
 -- For each job get the most recent run (this will be the one where Rnk=1)  
 SELECT job_id,run_status,run_date,run_time  
 ,RANK() OVER (PARTITION BY job_id ORDER BY run_date DESC,run_time DESC) AS Rnk  
 FROM sysjobhistory  
 WHERE step_id=0  
 )  
SELECT   
	name  AS [Job Name]
	,CONVERT(VARCHAR,DATEADD(S,(run_time/10000)*60*60 /* hours */  
	+((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
	+ (run_time - (run_time/100) * 100)  /* secs */,  
	CONVERT(DATETIME,RTRIM(run_date),113)),100) AS [Time Run] 
	,CASE WHEN enabled=1 THEN 'Enabled'  
		ELSE 'Disabled'  
	END [Job Status]
	,CASE WHEN run_status=0 THEN 'Failed'
				WHEN run_status=1 THEN 'Succeeded'
				WHEN run_status=2 THEN 'Retry'
				WHEN run_status=3 THEN 'Cancelled'
		ELSE 'Unknown' 
		END [Job Outcome]
FROM     CTE_MostRecentJobRun MRJR  
JOIN     sysjobs SJ  
ON       MRJR.job_id=sj.job_id  
WHERE    Rnk=1  
--AND      run_status=0 -- i.e. failed  
ORDER BY name  
/*
-- list all jobs in last 24 hour
SELECT name AS [Job Name]
         ,CONVERT(VARCHAR,DATEADD(S,(run_time/10000)*60*60 /* hours */  
          +((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
          + (run_time - (run_time/100) * 100)  /* secs */
           ,CONVERT(DATETIME,RTRIM(run_date),113)),100) AS [Time Run]
         ,CASE WHEN enabled=1 THEN 'Enabled'  
               ELSE 'Disabled'  
          END [Job Status]
         ,CASE WHEN SJH.run_status=0 THEN 'Failed'
                     WHEN SJH.run_status=1 THEN 'Succeeded'
                     WHEN SJH.run_status=2 THEN 'Retry'
                     WHEN SJH.run_status=3 THEN 'Cancelled'
               ELSE 'Unknown'  
          END [Job Outcome]
FROM   sysjobhistory SJH  
JOIN   sysjobs SJ  
ON     SJH.job_id=sj.job_id  
WHERE  step_id=0  
AND    DATEADD(S,  
  (run_time/10000)*60*60 /* hours */  
  +((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
  + (run_time - (run_time/100) * 100)  /* secs */,  
  CONVERT(DATETIME,RTRIM(run_date),113)) >= DATEADD(d,-1,GetDate())  
ORDER BY name,run_date,run_time 
*/
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showmissingindex]    Script Date: 2019-12-02 12:28:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[showmissingindex] as
SELECT CAST(SERVERPROPERTY('ServerName') AS [nvarchar](256)) AS [SQLServer]
    ,db.[database_id] AS [DatabaseID]
    ,db.[name] AS [DatabaseName]
    ,id.[object_id] AS [ObjectID]
    ,id.[statement] AS [FullyQualifiedObjectName]
    ,id.[equality_columns] AS [EqualityColumns]
    ,id.[inequality_columns] AS [InEqualityColumns]
    ,id.[included_columns] AS [IncludedColumns]
    ,gs.[unique_compiles] AS [UniqueCompiles]
    ,gs.[user_seeks] AS [UserSeeks]
    ,gs.[user_scans] AS [UserScans]
    ,gs.[last_user_seek] AS [LastUserSeekTime]
    ,gs.[last_user_scan] AS [LastUserScanTime]
    ,gs.[avg_total_user_cost] AS [AvgTotalUserCost]
    ,gs.[avg_user_impact] AS [AvgUserImpact]
    ,gs.[system_seeks] AS [SystemSeeks]
    ,gs.[system_scans] AS [SystemScans]
    ,gs.[last_system_seek] AS [LastSystemSeekTime]
    ,gs.[last_system_scan] AS [LastSystemScanTime]
    ,gs.[avg_total_system_cost] AS [AvgTotalSystemCost]
    ,gs.[avg_system_impact] AS [AvgSystemImpact]
    ,gs.[user_seeks] * gs.[avg_total_user_cost] * (gs.[avg_user_impact] * 0.01) AS [IndexAdvantage]
    ,'CREATE INDEX [Missing_IXNC_' + OBJECT_NAME(id.[object_id], db.[database_id]) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(id.[equality_columns], ''), ', ', '_'), '[', ''), ']', '') + CASE
        WHEN id.[equality_columns] IS NOT NULL
            AND id.[inequality_columns] IS NOT NULL
            THEN '_'
        ELSE ''
        END + REPLACE(REPLACE(REPLACE(ISNULL(id.[inequality_columns], ''), ', ', '_'), '[', ''), ']', '') + '_' + LEFT(CAST(NEWID() AS [nvarchar](64)), 5) + ']' + ' ON ' + id.[statement] + ' (' + ISNULL(id.[equality_columns], '') + CASE
        WHEN id.[equality_columns] IS NOT NULL
            AND id.[inequality_columns] IS NOT NULL
            THEN ','
        ELSE ''
        END + ISNULL(id.[inequality_columns], '') + ')' + ISNULL(' INCLUDE (' + id.[included_columns] + ')', '') AS [ProposedIndex]
    ,CAST(CURRENT_TIMESTAMP AS [smalldatetime]) AS [CollectionDate]
FROM [sys].[dm_db_missing_index_group_stats] gs WITH (NOLOCK)
INNER JOIN [sys].[dm_db_missing_index_groups] ig WITH (NOLOCK)
    ON gs.[group_handle] = ig.[index_group_handle]
INNER JOIN [sys].[dm_db_missing_index_details] id WITH (NOLOCK)
    ON ig.[index_handle] = id.[index_handle]
INNER JOIN [sys].[databases] db WITH (NOLOCK)
    ON db.[database_id] = id.[database_id]
WHERE id.[database_id] > 4 -- Remove this to see for entire instance
ORDER BY [IndexAdvantage] DESC
OPTION (RECOMPILE);

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showReportCatalog]    Script Date: 2019-12-02 12:28:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[showReportCatalog] as 
SELECT 
@@servername ServerName, 
C.NAME as ReportName, 
C.PATH as ReportPath,
CASE 
WHEN C.type = 1 THEN '1-Folder' 
WHEN C.type = 2 THEN '2-Report' 
WHEN C.type = 3 THEN '3-File' 
WHEN C.type = 4 THEN '4-Linked Report' 
WHEN C.type = 5 THEN '5-Datasource' 
WHEN C.type = 6 THEN '6-Model' 
WHEN C.type = 8 THEN '8-Shared Dataset'
WHEN C.type = 9 THEN '9-Report Part'
WHEN C.type = 11 THEN 'KPI'
WHEN C.type = 12 THEN 'Mobile Report (folder)'
WHEN C.type = 13 THEN 'Power BI Desktop Document'
ELSE 'Unknown' END AS ReportType
--CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.CONTENT))) AS REPORTXML
FROM  REPORTSERVER.DBO.CATALOG C
WHERE  C.TYPE not in (1,5)
GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showrequest]    Script Date: 2019-12-02 12:28:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showrequest]
as
SELECT 
	  [spid] = session_Id
	, ecid
	, [blockedBy] = blocking_session_id 
	, [database] = DB_NAME(sp.dbid)
	, [user] = nt_username
	, [status] = er.status
	, [wait] = wait_type
	, [current stmt] = 
		SUBSTRING (
			qt.text, 
	        er.statement_start_offset/2,
			(CASE 
				WHEN er.statement_end_offset = -1 THEN DATALENGTH(qt.text)	
				ELSE er.statement_end_offset 
			END - er.statement_start_offset)/2)
	,[current batch] = qt.text
	, reads
	, logical_reads
	, cpu
	, [time elapsed (ms)] = DATEDIFF(mi, start_time,getdate())
	, program = program_name
	, hostname
	--, nt_domain
	, start_time
	, qt.objectid
FROM sys.dm_exec_requests er
INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
WHERE session_Id > 50              -- Ignore system spids.
AND session_Id NOT IN (@@SPID)     -- Ignore this current statement.
ORDER BY 1, 2

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showserver]    Script Date: 2019-12-02 12:29:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[showserver]
as
Select @@SERVERNAME as [Server\Instance],
-- SQL Server Version
	@@VERSION as SQLServerVersion,
-- SQL Server Instance
	@@ServiceName AS ServiceInstance,
	SERVERPROPERTY('ProductVersion') AS ProductVersion,
SERVERPROPERTY('ProductLevel') AS ProductLevel,
SERVERPROPERTY('Edition') AS Edition,
SERVERPROPERTY('EngineEdition') AS EngineEdition,
	SERVERPROPERTY('Collation') AS Collation,
SERVERPROPERTY('MachineName') AS MachineName,
SERVERPROPERTY('ProcessID') AS ProcessID,
SERVERPROPERTY('SqlCharSetName') AS SqlCharSetName;

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showsysadmin]    Script Date: 2019-12-02 12:29:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showsysadmin] as
SELECT  p.name AS [loginname] ,
        p.type ,
        p.type_desc ,
        p.is_disabled,
        CONVERT(VARCHAR(10),p.create_date ,101) AS [created],
        CONVERT(VARCHAR(10),p.modify_date , 101) AS [update]
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
        AND s.sysadmin = 1
GO


USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showtop20]    Script Date: 2019-12-02 12:29:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showtop20] as
SELECT TOP 20 query_stats.query_hash AS "Query Hash", 
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",
    MIN(query_stats.statement_text) AS "Statement Text"
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;
GO


USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showwait]    Script Date: 2019-12-02 12:29:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[showwait] as
SELECT wt.session_id, wt.wait_type
, er.last_wait_type AS last_wait_type
, wt.wait_duration_ms
, wt.blocking_session_id, wt.blocking_exec_context_id, resource_description
FROM sys.dm_os_waiting_tasks wt
JOIN sys.dm_exec_sessions es ON wt.session_id = es.session_id
JOIN sys.dm_exec_requests er ON wt.session_id = er.session_id
WHERE es.is_user_process = 1
AND wt.wait_type <> 'SLEEP_TASK'
ORDER BY wt.wait_duration_ms desc

GO

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showwaittype]    Script Date: 2019-12-02 12:30:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



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
















