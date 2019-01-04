# Database Mail Records

## Overview
* Database Mail keeps copies of outgoing e-mail messages and displays them in the **sysmail_allitems**, **sysmail_sentitems**, **sysmail_unsentitems** views of the msdb database. 
* The Database Mail external program logs activity and displays the log through the Windows Application Event Log and the **sysmail_event_log** view in the msdb database. To check the status of an e-mail message, run a query against this view. E-mail messages have one of four possible statuses: ***sent, unsent, retrying, and failed***.

## T-SQL
To view the status of the e-mail sent using Database Mail, Select from the **sysmail_allitems** table, specifying the messages of interest by *mailitem_id* or *sent_status*.

To check the status returned from the external program for the e-mail messages, join **sysmail_allitems** to **sysmail_event_log** view on the *mailitem_id* column.

By default, the external program does not log information about messages that were successfully sent. To log all messages, set the logging level to verbose using the *Configure System Parameters* page of the *Database Mail Configuration Wizard*
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

[Check the Status of E-Mail Messages Sent With Database Mail](<https://docs.microsoft.com/en-us/sql/relational-databases/database-mail/check-the-status-of-e-mail-messages-sent-with-database-mail?view=sql-server-2017>)