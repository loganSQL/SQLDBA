USE [master]
GO

/* Remove Listener From AG */
ALTER AVAILABILITY GROUP [TestAG1]
REMOVE LISTENER N'TestAG1Listener';
GO

/* Remove Database From AG */
ALTER AVAILABILITY GROUP [TestAG1]
REMOVE DATABASE [TSQL2012];
GO

/* Drop AG */
DROP AVAILABILITY GROUP [TestAG1];
GO

/* Need to remove all the copies of database on Secondary */

/*************************************************
Recreate AG2 : scripts were generated from Wizard
*************************************************/
--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect logansqltest01

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [LOGANSQL\sql.dba]

GO

:Connect logansqltest01

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect logansqltest02

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [FIRSTNATIONAL\logan.chen]

GO

:Connect logansqltest02

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect logansqltest01

USE [master]

GO

CREATE AVAILABILITY GROUP [TestAG2]
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE)
FOR DATABASE [TSQL2012], [WideWorldImporters]
REPLICA ON N'logansqltest01' WITH (ENDPOINT_URL = N'TCP://logansqltest01.logansql.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
	N'logansqltest02' WITH (ENDPOINT_URL = N'TCP://logansqltest02.logansql.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));

GO

:Connect logansqltest02

ALTER AVAILABILITY GROUP [TestAG2] JOIN;

GO

ALTER AVAILABILITY GROUP [TestAG2] GRANT CREATE ANY DATABASE;

GO


GO