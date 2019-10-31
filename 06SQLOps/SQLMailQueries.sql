use msdb
go

-- mail status
EXECUTE sysmail_help_status_sp  
go
-- queue status
EXECUTE msdb.dbo.sysmail_help_queue_sp ;  
GO  
-- mail account
EXECUTE msdb.dbo.sysmail_help_account_sp ;  
go

-- mail profile
EXECUTE msdb.dbo.sysmail_help_profile_sp; 
go

-- sysmail_event_log
select * from sysmail_event_log 

--
SELECT is_broker_enabled FROM sys.databases WHERE name = 'msdb';
-- https://docs.microsoft.com/en-us/sql/relational-databases/database-mail/database-mail-common-errors?view=sql-server-ver15#database-mail-queued-no-entries-in-sysmail_event_log-or-windows-application-event-log

-- sysmail_allitems
select * from sysmail_allitems 

--
-- Show the subject, the time that the mail item row was last  
-- modified, and the log information.  
-- Join sysmail_faileditems to sysmail_event_log   
-- on the mailitem_id column.  
-- In the WHERE clause list items where danw was in the recipients,  
-- copy_recipients, or blind_copy_recipients.  
-- These are the items that would have been sent  
-- to danw.  
  
SELECT items.subject,  
    items.last_mod_date  
    ,l.description FROM dbo.sysmail_faileditems as items  
INNER JOIN dbo.sysmail_event_log AS l  
    ON items.mailitem_id = l.mailitem_id  
WHERE items.recipients LIKE '%danw%'    
    OR items.copy_recipients LIKE '%danw%'   
    OR items.blind_copy_recipients LIKE '%danw%'  
GO  

-- determine the status of the test e-mail message:
SELECT * FROM msdb.dbo.sysmail_allitems 
WHERE mailitem_id = 12345;
-- to view the error message
SELECT * FROM msdb.dbo.sysmail_event_log 
WHERE mailitem_id = 12345 ;