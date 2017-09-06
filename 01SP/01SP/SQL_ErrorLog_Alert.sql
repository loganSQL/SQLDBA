/*
	Store Procedure to abstract the new error msg from SQL Server ErrorLog
	into [dbo].[SQL_ErrorLog]
*/

USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[SQL_ErrorLog_Alert]    Script Date: 2017-09-06 1:40:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SQL_ErrorLog_Alert]
@Minutes [int] = NULL  
AS
BEGIN
SET NOCOUNT ON;
DECLARE @ERRORMSG varchar(8000)
DECLARE @SNO INT
DECLARE @Mins INT
DECLARE @SQLVERSION VARCHAR(4)
IF @Minutes IS NULL  -- If the optional parameter is not passed, @Mins value is set to 6
 SET @Mins = 6
ELSE
 SET @Mins = @Minutes
  /* Fetches the numeric part of SQL Version */
 SELECT @SQLVERSION = RTRIM(LTRIM(SUBSTRING(@@VERSION,22,5))) 

IF @SQLVERSION = '2000'  
 /* Checks the version of SQL Server and executes 
 the code depending on it since the output of the 
 sp_readerrorlog varies between SQL 2000 and the next versions */
 BEGIN
  
 /*Temporary table to store the output from execution of sp_readerrorlog */
  
 CREATE Table #ErrorLog2000 
 (ErrorLog varchar(4000),ContinuationRow Int) 
 INSERT INTO  #ErrorLog2000  -- Stores the output of sp_readerrorlog
 EXEC sp_readerrorlog
 /* The code below deletes the rows in the error log which are mostly 
 the SQL startup messages written into the error log */
  
 DELETE FROM #ErrorLog2000 
 WHERE (LEFT(LTRIM(ErrorLog),4) NOT LIKE DATEPART(YYYY,GETDATE()) 
    AND ContinuationRow = 0) 
 OR (ErrorLog LIKE '%Intel X86%')
 OR (ErrorLog LIKE '%Copyright %')
 OR (ErrorLog LIKE '%Microsoft %')
 OR (ErrorLog LIKE '%All rights reserved.%')
 OR (ErrorLog LIKE '%Server Process ID is %')
 OR (ErrorLog LIKE '%Logging SQL Server messages in file %')
 OR (ErrorLog LIKE '%Errorlog has been reinitialized%')
 OR (ErrorLog LIKE '%Starting up database %')
 OR (ErrorLog LIKE '%SQL Server Listening %')
 OR (ErrorLog LIKE '%SQL Server is ready %')
 OR (ErrorLog LIKE '%Clearing tempdb %')
 OR (ErrorLog LIKE '%Recovery %')
 OR (ErrorLog LIKE '%to execute extended stored procedure %')
 OR (ErrorLog LIKE '%Analysis of database %')
 OR (ErrorLog LIKE '%Edition%')
 OR LEN(ErrorLog) < 25 
 OR (CAST(LEFT(LTRIM(ErrorLog),23) AS DATETIME) 
  < CAST(DATEADD(MI,-@Mins,GETDATE()) AS VARCHAR(23)))

  /* Once the SQL Server startup and other information prior to 
  @Mins is deleted from the temporary table, the below code starts 
  concatenating the remaining rows in the temporary table 
  and stores into single variable */
  
 SELECT @ERRORMSG = COALESCE(@ERRORMSG + CHAR(13) , '')  
   + ErrorLog FROM #ErrorLog2000
  
 DROP TABLE #ErrorLog2000 
 END
ELSE
 BEGIN
 CREATE TABLE #ErrorLog2005 
 (LogDate DATETIME, ProcessInfo VARCHAR(50) ,[Text] VARCHAR(4000))
 INSERT INTO #ErrorLog2005 
 EXEC sp_readerrorlog
 DELETE FROM #ErrorLog2005 
 WHERE LogDate < CAST(DATEADD(MI,-@Mins,GETDATE()) AS VARCHAR(23))
 OR ([Text] LIKE '%Intel X86%')
 OR ([Text] LIKE '%Copyright%')
 OR ([Text] LIKE '%All rights reserved.%')
 OR ([Text] LIKE '%Server Process ID is %')
 OR ([Text] LIKE '%Logging SQL Server messages in file %')
 OR ([Text] LIKE '%Errorlog has been reinitialized%')
 OR ([Text] LIKE '%This instance of SQL Server has been using a process ID %')
 OR ([Text] LIKE '%Starting up database %')
 OR ([Text] LIKE '%SQL Server Listening %')
 OR ([Text] LIKE '%SQL Server is ready %')
 OR ([Text] LIKE '%Clearing tempdb %')
 OR ([Text] LIKE '%to execute extended stored procedure %')
 OR ([Text] LIKE '%Analysis of database %')
 OR ProcessInfo = 'Backup' -- Deletes backup information
 SELECT  @ERRORMSG = COALESCE(@ERRORMSG + CHAR(13) , '') 
   + CAST(LogDate AS VARCHAR(23)) + '  ' 
   + [Text] FROM #ErrorLog2005
  
 DROP TABLE #ErrorLog2005
 END
IF @ERRORMSG IS NOT NULL 
  -- There is some data in SQL error log that needs to be stored
 BEGIN
  IF  EXISTS (SELECT * FROM dbo.sysobjects 
    WHERE  id = OBJECT_ID(N'[dbo].[SQL_ErrorLog]') 
    AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   
   INSERT INTO [dbo].[SQL_ErrorLog]
   SELECT @ERRORMSG
   
  ELSE
   
  BEGIN
   
  CREATE TABLE [dbo].[SQL_ErrorLog](
   [TEXT] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
   ) ON [PRIMARY]
  INSERT INTO [dbo].[SQL_ErrorLog]
  SELECT @ERRORMSG
   
  END
 END
ELSE  -- No error messages have been in the last @Mins minutes
 Print 'No Error Messages'
END



GO