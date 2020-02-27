/*
T-SQL Script to create a SQL Mirroring:-
The first thing you need to do when setting up Database Mirroring is perform a full backup followed by a transaction log backup on the principal server.  You then must restore these to the mirror server using the WITH NORECOVERY option of the RESTORE command.  
*/
-- 0. Restore the backup from Principal on Mirror with norecovery
USE [master]
RESTORE DATABASE DatabaseName
FROM  DISK = N'F:\DBBackup\DatabaseName_Mirror.bak' 
WITH  FILE = 1,  
MOVE N'DatabaseName' TO N'E:\Databases\DatabaseName.mdf',  
MOVE N'DatabaseName_log' TO N'E:\Databases\DatabaseName_log.ldf',  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
-- restore log on Mirror with norecovery
RESTORE LOG DatabaseNameFROM  DISK = N'F:\DBBackup\DatabaseName_mirror.bak' 
WITH  FILE = 2,  
NORECOVERY,  NOUNLOAD,  STATS = 5

GO




-- 1. Create endpoints on both servers
--- TCP://SQLHOST01.logansql.net:5022
--- TCP://SQLHOST02.logansql.net:5022
--Endpoint for initial principal server instance, which  
--is the only server instance running on SQLHOST01.  
CREATE ENDPOINT Mirroring  
    STATE = STARTED  
    AS TCP ( LISTENER_PORT = 5022 )  
    FOR DATABASE_MIRRORING (ROLE=PARTNER);  
GO  
--Endpoint for initial mirror server instance, which  
--is the only server instance running on SQLHOST02.  
CREATE ENDPOINT Mirroring  
    STATE = STARTED  
    AS TCP ( LISTENER_PORT = 5022 )  
    FOR DATABASE_MIRRORING (ROLE=PARTNER);  
GO  

-- More detail
CREATE ENDPOINT EndPointName
STATE=STARTED AS TCP(LISTENER_PORT = PortNumber, LISTENER_IP = ALL)
FOR DATA_MIRRORING(ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM RC4)


-- 2. Set partner and setup job on mirror server (SQLHOST02), default port 5022
ALTER DATABASE DatabaseName SET PARTNER = N'TCP://SQLHOST01.logansql.net:5022'
EXEC sys.sp_dbmmonitoraddmonitoring -- default is 1 minute

-- 3. Set partner, set asynchronous mode, and setup job on principal server (SQLHOST01)
ALTER DATABASE DatabaseName SET PARTNER = N'TCP://SQLHOST02.logansql.net:5022'
ALTER DATABASE DatabaseName SET SAFETY OFF
EXEC sys.sp_dbmmonitoraddmonitoring -- default is 1 minute

-- 4. FAILOVER (On principal server : SQLHOST01)
ALTER DATABASE DatabaseName SET PARTNER FAILOVER
ALTER DATABASE DatabaseName SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS

--5 Meta Data
-- Mirroring Endpoint
SELECT * FROM sys.database_mirroring_endpoints;   
-- Database Mirroring
select * from sys.database_mirroring