/* 1. Schema on DBA */
USE [DBA]
GO

/****** Object:  Table [dbo].[Audit_Session_Information] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* 
-- schema can also dynamically created from the following selection 

  SELECT 
      c.session_id, 
      c.net_transport, 
      s.host_name, 
      s.program_name, 
      s.nt_user_name,
      c.connect_time, 
      s.client_interface_name,
      c.client_net_address,
      c.local_net_address, 
      s.login_name, 
      s.nt_domain, 
      s.login_time,
	  getdate() as audit_imte 
  INTO [dbo].[Audit_Session_Information]
  FROM sys.dm_exec_connections AS c
  JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
  WHERE 1=2

*/

CREATE TABLE [dbo].[Audit_Session_Information](
	[session_id] [int] NULL,
	[net_transport] [nvarchar](40) NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[nt_user_name] [nvarchar](128) NULL,
	[connect_time] [datetime] NULL,
	[client_interface_name] [nvarchar](128) NULL,
	[client_net_address] [varchar](48) NULL,
	[local_net_address] [varchar](48) NULL,
	[login_name] [nvarchar](128) NULL,
	[nt_domain] [nvarchar](128) NULL,
	[login_time] [datetime] NULL,
	[audit_time] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Audit_Session_Information] ADD  DEFAULT (getdate()) FOR [audit_time]
GO


/* Monitor Job on msdb */
USE [msdb]
GO

/*

*/

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA-Admin]  ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA-Admin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA-Admin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL_Audit_Session_Information', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'dump the information into a physical table from two DMVs are joined sys.dm_exec_connections and sys.dm_exec_sessions.', 
		@category_name=N'DBA-Admin', 
		@owner_login_name=N'AD\logan.sql', 
		@notify_email_operator_name=N'sqladmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Audit_Session_Information]  ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Audit_Session_Information', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use DBA
go

Insert into Audit_Session_Information
  SELECT 
      c.session_id, 
      c.net_transport, 
      s.host_name, 
      s.program_name, 
      s.nt_user_name,
      c.connect_time, 
      s.client_interface_name,
      c.client_net_address,
      c.local_net_address, 
      s.login_name, 
      s.nt_domain, 
      s.login_time,
	  getdate() as audit_imte 
  FROM sys.dm_exec_connections AS c
  JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
go

-- just keep one month data
delete from [dbo].[Audit_Session_Information] where Audit_Time < DATEADD(month, -1, GETDATE())
go', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'HourlyPlus05', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170710, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=235959, 
		@schedule_uid=N'35768dd5-91fc-4a19-b9c3-713d34903844'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


