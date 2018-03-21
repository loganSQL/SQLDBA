USE MASTER
go

--kick off current users/processes
ALTER DATABASE [MyDB]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
go

-- restore backup
RESTORE DATABASE [MyDB] FROM  DISK = N'E:\backup\MyServer\MyDB.bak' 
WITH  FILE = 1,  
MOVE N'MyDB_Data' TO N'D:\databases\MyDB.MDF',  
MOVE N'MyDB_Log' TO N'E:\databases\MyDB.LDF',  
NOUNLOAD,  REPLACE,  STATS = 5

GO

--Let people/processes back in!
ALTER DATABASE [MyDB]
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
go

USE [MyDB]
go


