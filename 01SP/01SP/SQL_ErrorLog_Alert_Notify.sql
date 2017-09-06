/*
	Store Procedure to Obtain the new msg and send email alert
*/

USE [msdb]
GO


CREATE PROCEDURE [dbo].[SQL_ErrorLog_Alert_Notify]
@LKDSVRNAME VARCHAR(128) = NULL
AS
BEGIN
SET NOCOUNT ON;
DECLARE @SUBJECT  VARCHAR(8000)
DECLARE @MSGBODY  VARCHAR(8000)
 IF @LKDSVRNAME IS NOT NULL  
    /* A linked server name is passed, so alert will be for the linked server.*/
  
 BEGIN
   
  CREATE TABLE #ERRTBL ([TEXT] VARCHAR(8000)) 
  /* Temporary table to poll the linked server 
  and store the error data to be used in the cursor, in the next step */
 
  INSERT INTO #ERRTBL
  EXEC('SELECT [Text] FROM ' + @LKDSVRNAME + '.msdb.DBO.SQL_ErrorLog')
  
  SET @SUBJECT = @LKDSVRNAME + ' SQL-SERVER ERROR LOG SUMMARY'
  DECLARE CURSOR1 CURSOR
  FOR SELECT [TEXT] FROM #ERRTBL
  
  OPEN CURSOR1
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'sqlamdin', -- Modify the profile name
    @recipients = 'youremail@yourdomain.com',-- Modify the email
    @body = @MSGBODY, 
    @subject = @SUBJECT ; 
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  END 
  CLOSE CURSOR1
  DEALLOCATE CURSOR1 
  EXEC ('DELETE FROM ' + @LKDSVRNAME + '.msdb.DBO.SQL_ErrorLog') 
     
     -- Modify the database name
     
  DROP TABLE #ERRTBL
   
 END
  ELSE  
  /* A linked server name is not passed, 
  so alert will be for the local server. */
   
 BEGIN
    
  SET @SUBJECT = @@SERVERNAME + ' SQL-SERVER ERROR LOG SUMMARY'
  DECLARE CURSOR1 CURSOR
  FOR SELECT [TEXT] FROM SQL_ErrorLog
  OPEN CURSOR1
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  WHILE @@FETCH_STATUS = 0
  BEGIN  
    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'sqladmin', -- Modify the profile name
    @recipients = 'youremail@yourdomain.com',-- Modify the email
    @body = @MSGBODY, 
    @subject = @SUBJECT ; 
 
  FETCH NEXT FROM CURSOR1
  INTO @MSGBODY
  END 
  CLOSE CURSOR1
  DEALLOCATE CURSOR1   
  DELETE FROM SQL_ErrorLog   -- Modify the database name
 END
END



GO