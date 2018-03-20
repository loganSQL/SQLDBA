USE MASTER
go

--kick off current users/processes
ALTER DATABASE [mydb]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
go

-- restore backup
RESTORE DATABASE [mydb] FROM  DISK = N'E:\backup\myserver\mydb.bak' 
WITH  FILE = 1,  MOVE N'mydb_Data' TO N'D:\databases\mydb.MDF',  
MOVE N'mydb_Log' TO N'E:\databases\mydb.LDF',  
NOUNLOAD,  REPLACE,  STATS = 5

GO

--Let people/processes back in!
ALTER DATABASE [mydb]
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
go

-- sync users
USE [mydb]
GO

ALTER USER [mydbuser] WITH LOGIN = [mydbuser], DEFAULT_SCHEMA=[dbo]
GO
