/*
	Job: SQL_Job_Activity_Report
	Script to create a job to 
		Check all the job activity (not successful) for last 24 hours
		And send email alert 
	Depending on msdb..showjobactivity
*/

USE [msdb]
GO

/****** Object:  Job [SQL_Job_Activity_Report]  ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

/****** Object:  JobCategory [DBA-Admin] ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA-Admin' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA-Admin'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

/****** Object:  Job [SQL_Job_Activity_Report]  ******/
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL_Job_Activity_Report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBA-Admin', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'sqladmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [jobactivityreport] ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'jobactivityreport', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @mysubject varchar(100)
select @mysubject=@@servername+'' Job Activity Report (Some not Successful)''
if exists (
	SELECT name 
	FROM   sysjobhistory SJH  
	JOIN   sysjobs SJ  
	ON     SJH.job_id=sj.job_id  
	WHERE  step_id=0  
	AND    DATEADD(S,  
	  (run_time/10000)*60*60 /* hours */  
	  +((run_time - (run_time/10000) * 10000)/100) * 60 /* mins */  
	  + (run_time - (run_time/100) * 100)  /* secs */,  
	  CONVERT(DATETIME,RTRIM(run_date),113)) >= DATEADD(d,-1,GetDate())  
	and 
	SJH.run_status <> 1)
EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''sqladmin'',
@recipients = ''youremail@yourdomain.com;'',
@subject = @mysubject,
@query = N''set nocount on;exec msdb..showjobactivity'',
@attach_query_result_as_file = 1,
@query_attachment_filename = ''JobActivity.csv'',
@query_result_header= 1,
@query_result_separator = ''	'',
@query_result_no_padding = 1,
@query_result_width =2000

', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/****** Object:  schedule At9AM  ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'AT9AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160906, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'3a710a03-b822-4bbf-ad65-90a267c95be1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO