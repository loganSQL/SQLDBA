/*
	Script to Monitor SQL Agent Jobs via Email Notification
*/

USE msdb;
GO

/* display each SQL Server Agent job that doesn’t have notification set up
	notify_level_email 
	0	no notification
	1	Email
	2	Pager
	3	NET SEND
*/
select name 
from [dbo].[sysjobs]
WHERE notify_level_email = 0
go

/* display each SQL Server Agent job that doesn’t have an operator associated with an email notification operator.*/
select name, notify_email_operator_id
from [dbo].[sysjobs]
where notify_email_operator_id = 0
go

/* Set up an operator */
USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'sqladmin', 
              @enabled=1, 
              @email_address=N'sqladmin@yourdomain.com'
GO

/* Automatically Updating SQL Agent Jobs to Have Notification*/
USE [msdb]
GO
 
SET NOCOUNT ON;
DECLARE @Operator varchar(50) = 'sqladmin' -- place your operator name here
 
SELECT 'EXEC sp_update_job @job_name = ''' + j.[name] + 
       ''', @notify_email_operator_name = ''' + @Operator  +
       ''', @notify_level_email = 2'   -- 1=On Success, 2=On Faulure,3=always       
from [dbo].[sysjobs] j
WHERE j.enabled = 1 
AND j.notify_level_email <> 1
GO

/*
Getting individual SQL Server Agent jobs notifications for failed jobs is one method of being notified of the jobs you need to look at and fix.  
Another method is to get a daily report of all the jobs that failed in the last 24 hours.
*/