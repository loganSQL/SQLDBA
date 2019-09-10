
-- kill all the connections
DECLARE @kill varchar(8000); SET @kill = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), spid) + ';'  
FROM master..sysprocesses  
WHERE dbid = db_id(myDB)

EXEC(@kill); 

ALTER DATABASE [myDB]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
go

USE [master]
RESTORE DATABASE [myDB] FROM  DISK = N'E:\DBBackup\temp\myDB.bak' WITH  FILE = 1,  MOVE N'myDB_Data' TO N'E:\Databases\myDB.mdf',  MOVE N'myDB_Log' TO N'E:\Databases\myDB.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

GO


ALTER DATABASE [myDB]
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
go
