# Database Mail Records
```
-- 
USE msdb ;  
GO 

-- mail items sent to a recipient during a period
select * from [dbo].[sysmail_mailitems] 
where recipients LIKE 'sqlalert%'
and send_request_date between '2018-12-17' and '2019-01-07'
GO


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
    ,l.description 
FROM dbo.sysmail_faileditems as items  
      INNER JOIN dbo.sysmail_event_log AS l  
      ON items.mailitem_id = l.mailitem_id  
WHERE items.recipients LIKE '%danw%'    
    OR items.copy_recipients LIKE '%danw%'   
    OR items.blind_copy_recipients LIKE '%danw%'  
GO  

-- test operator

EXECUTE msdb.dbo.sp_notify_operator @name=N'sqlalert',@subject=N'MyDB Full Backup Completion',@body=N'MyDB Full Backup Completes successfully.'
```