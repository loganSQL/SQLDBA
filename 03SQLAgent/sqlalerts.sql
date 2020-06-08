/*
Mechanics and guidelines of lease, cluster, and health check timeouts for Always On availability groups
Info: Mechanics and guidelines of lease, cluster, and health check timeouts for Always On availability groups:
https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/availability-group-lease-healthcheck-timeout?view=sql-server-ver15
*/

/*
https://www.sqlrx.com/alwayson-monitoring-and-alerting/
*/

/*
--Purpose:  To script all SQL Alerts, so the the resulting script can be applied to add alerts on to another server
*/


--Run on source server
USE MSDB
GO

SELECT 'IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'''+NAME+'''))
 ---- Delete the alert with the same name.
  EXECUTE msdb.dbo.sp_delete_alert @name = N'''+name+''' 
BEGIN 
EXECUTE msdb.dbo.sp_add_alert @name = N'''+name+''', @message_id = '+CAST(message_id AS VARCHAR(10))+' , @severity = '+CAST(severity AS VARCHAR(10))+' , @enabled = 1, @delay_between_responses = '+CAST(delay_between_responses AS VARCHAR(10))+' , @include_event_description_in = '+CAST(include_event_description AS VARCHAR(10))+', @category_name = N''[Uncategorized]''
END
' FROM [msdb].[dbo].[sysalerts]
--WHERE category_id <> 20


--Add email notifications amend DBA to your operator
SELECT 'EXEC msdb.dbo.sp_add_notification @alert_name=N'''+NAME+''', @operator_name=N''DBA'', @notification_method = 7;'
FROM [msdb].[dbo].[sysalerts]
WHERE category_id <> 20

--Run results on destination server

/*
Sample
*/

USE [msdb]
GO

/* Operator*/
EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dba@logansql.net', 
		@category_name=N'[Uncategorized]'
GO

-- Alerts
USE [msdb]
GO

EXECUTE msdb.dbo.sp_add_alert @name = N'Error Number 823', @message_id = 823 , @severity = 0 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Error Number 824', @message_id = 824 , @severity = 0 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Error Number 825', @message_id = 825 , @severity = 0 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Log shipping Primary Server Alert.', @message_id = 14420 , @severity = 0 , @enabled = 1, @delay_between_responses = 0 , @include_event_description_in = 5, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Log shipping Secondary Server Alert.', @message_id = 14421 , @severity = 0 , @enabled = 1, @delay_between_responses = 0 , @include_event_description_in = 5, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 016', @message_id = 0 , @severity = 16 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 017', @message_id = 0 , @severity = 17 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 018', @message_id = 0 , @severity = 18 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 019', @message_id = 0 , @severity = 19 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 020', @message_id = 0 , @severity = 20 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 021', @message_id = 0 , @severity = 21 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 022', @message_id = 0 , @severity = 22 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 023', @message_id = 0 , @severity = 23 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 024', @message_id = 0 , @severity = 24 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'
EXECUTE msdb.dbo.sp_add_alert @name = N'Severity 025', @message_id = 0 , @severity = 25 , @enabled = 1, @delay_between_responses = 60 , @include_event_description_in = 1, @category_name = N'[Uncategorized]'

go

-- Notification to Operator

EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 016', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 017', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 018', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 019', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 020', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 021', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 022', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 023', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 024', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 025', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 823', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 824', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 825', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Log shipping Primary Server Alert.', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Log shipping Secondary Server Alert.', @operator_name=N'DBA', @notification_method = 7;
go