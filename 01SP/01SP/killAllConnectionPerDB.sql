/*
	A snippet to disconnect user connection to a database 
	for restore the database
	1. Disable main user
	2. Kill all the connections
	3. Set db single_user
	4. Do your work (restore etc...)
	5. Set db back to multi-user
	6. Enable main user
*/

USE MASTER
go

-- disable
ALTER LOGIN [MyUser] DISABLE
go

-- kill all the connections
DECLARE @kill varchar(8000); SET @kill = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), spid) + ';'  
FROM master..sysprocesses  
WHERE dbid = db_id('MyDB')

EXEC(@kill); 

--Make sure you're the only one, rollback those survivors
ALTER DATABASE MyDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--execute the restore
RESTORE DATABASE [MyDB] FROM  DISK = N'D:\DBBackup\MyDB.bak' WITH  FILE = 1, 
MOVE N'MyDB_Data' TO N'E:\Databases\MyDB.mdf',  
MOVE N'MyDB_Log' TO N'F:\Databases\MyDB_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 10
GO

--Let people/processes back in!
ALTER DATABASE MyDB
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
go

--ALTER DATABASE [MyDB] SET RECOVERY SIMPLE WITH NO_WAIT
--GO


ALTER LOGIN [MyUser] ENABLE
GO
