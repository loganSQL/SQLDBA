/*SQL Server Agent Alerts

The best method for creating alerts for your AG that will notify you as soon as any problem or event occurs, is the SQL Server Agent Alerts. These alerts are a great way to be proactive in monitoring your AG, and there are several alerts specifically related to AlwaysOn Availability Groups. In order to find which error codes correspond to an AG event you can run this query:
*/
use master
go

select message_id as ErrorNumber, text
from sys.messages
where text LIKE (‘%availability%’)
and language_id = 1033

-- This will give you a result set with 293 rows. You can peruse through and determine which errors are important for you, but I have devised a list with what we feel is the most important information to be alerted on:

-- All AG related timeout errors
select message_id as ErrorNumber, text, message_id, severity
from sys.messages
where text LIKE ('%availability%') and text like ('%timeout%')
and language_id = 1033

SELECT 'IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'''+convert(varchar(10), message_id)+'''))
 ---- Delete the alert with the same name.
  EXECUTE msdb.dbo.sp_delete_alert @name = N'''+convert(varchar(10), message_id)+''' 
BEGIN 
EXECUTE msdb.dbo.sp_add_alert @name = N'''+convert(varchar(10), message_id) +''', @message_id = '+CAST(message_id AS VARCHAR(10))+' , @severity = '+CAST(severity AS VARCHAR(10))+' , @enabled = 1, @category_name = N''[Uncategorized]''
END
'
from sys.messages
where text LIKE ('%availability%') and text like ('%timeout%')
and language_id = 1033


-- construct add_alert for AG related to connection timeout
--Doesn't work +' , @severity ='+CAST(severity AS VARCHAR(10))
SELECT 'IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'''+convert(varchar(10), message_id)+'''))
BEGIN
  EXECUTE msdb.dbo.sp_delete_alert @name = N'''+convert(varchar(10), message_id)+''' 
END
ELSE
BEGIN 
EXECUTE msdb.dbo.sp_add_alert @name = N'''+CAST(message_id AS VARCHAR(10)) +''', @message_id ='+CAST(message_id AS VARCHAR(10))+',@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N''[Uncategorized]''
END
'
from sys.messages
where text LIKE ('%availability%') and text like ('%timeout%')
and language_id = 1033

--Add email notifications amend DBA to your operator
-- you need to add dba as an operator
SELECT 'EXEC msdb.dbo.sp_add_notification @alert_name=N'''+convert(varchar(10), message_id)+''', @operator_name=N''DBA'', @notification_method = 7;'
from sys.messages
where text LIKE ('%availability%') and text like ('%timeout%')
and language_id = 1033


/*
Sample script generated
*/
USE msdb ;  
GO  
select * from syscategories

EXEC dbo.sp_add_category  
    @class=N'ALERT',  
    @type=N'NONE',  
    @name=N'Alerts-AlwaysOn' ;  
GO  


--EXEC dbo.sp_delete_category  'ALERT', 'Alerts-AlwaysOn'

-- EXEC dbo.sp_delete_category  'ALERT', 'DBA-AlwaysOn'
EXEC dbo.sp_add_category  
    @class=N'ALERT',  
    @type=N'NONE',  
    @name=N'Alerts-AlwaysOn' ;  
GO  

IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'19419'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'19419'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'19419', @message_id =19419,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'19421'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'19421'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'19421', @message_id =19421,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'35201'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'35201'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'35201', @message_id =35201,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'35206'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'35206'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'35206', @message_id =35206,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'35214'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'35214'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'35214', @message_id =35214,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'35229'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'35229'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'35229', @message_id =35229,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'35256'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'35256'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'35256', @message_id =35256,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'41149'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'41149'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'41149', @message_id =41149,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  
IF (EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'41165'))  BEGIN    EXECUTE msdb.dbo.sp_delete_alert @name = N'41165'   END  ELSE  BEGIN   EXECUTE msdb.dbo.sp_add_alert @name = N'41165', @message_id =41165,@enabled=1, @delay_between_responses=0, @include_event_description_in=0, @category_name=N'Alerts-AlwaysOn'  END  


USE [msdb]
GO

/****** Object:  Operator [DBA]    Script Date: 2020-06-08 3:37:52 PM ******/
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



EXEC msdb.dbo.sp_add_notification @alert_name=N'19419', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'19421', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'35201', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'35206', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'35214', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'35229', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'35256', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'41149', @operator_name=N'DBA', @notification_method = 7;
EXEC msdb.dbo.sp_add_notification @alert_name=N'41165', @operator_name=N'DBA', @notification_method = 7;