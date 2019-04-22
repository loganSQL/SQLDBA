# DBA Job Runner

To execute SQL scripts daily from specific directory

## Setup
```
F:

# Create a powershell script directory
mkdir \scripts\jogrunner
copy jobrunner.ps \scripts\jobrunner

# Create 
mkdir \jobrequest
mkdir \Jobrequest\Daily
mkdir \Jobrequest\History
mkdir \Jobrequest\buffer
```

## JobRunner.ps1
```
[CmdletBinding()]

# .\jobrunner.ps1 -servername SERVERNAME -requestpath REQUESTPATH -maillist MAILLIST
# Example
# .\jobrunner.ps1 -servername myserver -requestpath 'F:\JobRequest' -maillist MAILLIST
Param (
#  [string]$servername,
  [string]$requestpath
# , [string]$maillist
)
$servername=hostname
$maillist = 'logan.sql@mycompany.com'
$date = (Get-Date).ToString("yyyy-MM-dd")

$ScriptDir = $requestpath + '\Daily'
$scriptDir
Set-Location $ScriptDir

$scripts = Get-ChildItem $ScriptDir | Where-Object {$_.Extension -eq ".sql"}
if (!$scripts)
{
 Write-output 'No file exists'
 exit
}


$OutputDir = $requestpath + '\History\'+$date
if(!(Test-Path -Path $OutputDir )){
    New-Item -ItemType directory -Path $OutputDir
}

$joglog = $OutputDir + '\sql_execution_summary.txt'

$msg = $servername+" SQL Execution Summary On "+$date
Write-Output $msg > $joblog

Write-Output "----------------------" >>$joblog
Write-Output "The following are the sql scripts: " >>$joblog
dir $ScriptDir\*.sql  >>$joblog


##
foreach ($s in $scripts)
{ 
   $OutputText=$OutputDir+'\'+$s.Name+'.txt'
   Write-Output  "================================" >> $joblog
   # execute the script
   Write-Output  "Running Script : " $s.Name >> $joblog
   Write-Output  "================================" >> $joblog
   sqlcmd -E -S $servername -i $s -e -o $OutputText 
   get-content $OutputText >> $joblog
   Write-Output  "End of Script : " $s.Name >> $joblog
   Write-Output  "--------------------------------------" >> $joblog
   Write-Output  "" >> $joblog
   # move to history
   Move-Item -Path $s.FullName -Destination $OutputDir
}


##
#$maillist = 'logan.sql@mycompany.com'
$subjectline=$servername+'  Ad-hoc sql execution. Please see attached.'

# send email
$sendmailsql="exec msdb..sendOutputEmail '{0}','{1}','{2}'" -f $subjectline,$joblog,$maillist
sqlcmd -E -S $servername -Q $sendmailsql
```

## DBA_JobRunner.SQL
```
USE [msdb]
GO

/****** Object:  Job [DBA-JobRunner] ******/
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA-JobRunner', 
    @enabled=1, 
    @notify_level_eventlog=0, 
    @notify_level_email=2, 
    @notify_level_netsend=0, 
    @notify_level_page=0, 
    @delete_level=0, 
    @description=N'No description available.', 
    @category_name=N'DBA-Admin', 
    @owner_login_name=N'ADL\logan.sql', 
    @notify_email_operator_name=N'sqladmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [JogRunner]    Script Date: 2019-04-17 10:46:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'JobRunner', 
    @step_id=1, 
    @cmdexec_success_code=0, 
    @on_success_action=1, 
    @on_success_step_id=0, 
    @on_fail_action=2, 
    @on_fail_step_id=0, 
    @retry_attempts=0, 
    @retry_interval=0, 
    @os_run_priority=0, @subsystem=N'PowerShell', 
    @command=N'F:
cd \scripts\jobrunner
.\jobrunner.ps1 -requestpath ''F:\JobRequest''', 
    @database_name=N'master', 
    @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA-JobRunner-Daily-8-30PM', 
    @enabled=1, 
    @freq_type=4, 
    @freq_interval=1, 
    @freq_subday_type=1, 
    @freq_subday_interval=0, 
    @freq_relative_interval=0, 
    @freq_recurrence_factor=0, 
    @active_start_date=20181220, 
    @active_end_date=99991231, 
    @active_start_time=203000, 
    @active_end_time=235959, 
    @schedule_uid=N'cabe8822-8312-40f9-a035-571d4a0c91e0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

```
