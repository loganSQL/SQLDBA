
-- https://blogs.msdn.microsoft.com/alwaysonpro/2013/07/01/end-to-end-using-a-listener-to-connect-to-a-secondary-replica-read-only-routing/
SELECT	AV.name AS AVGName
	, AVGLis.dns_name AS ListenerName
	, AVGLis.ip_configuration_string_from_cluster AS ListenerIP
FROM	sys.availability_group_listeners AVGLis
INNER JOIN sys.availability_groups AV on AV.group_id = AV.group_id

-- failover mode => Manual
USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG1]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (FAILOVER_MODE = MANUAL)
GO

USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG1]
MODIFY REPLICA ON N'LOGANTEST02' WITH (FAILOVER_MODE = MANUAL)
GO

-- availability_mode => asynchrononous_commit
USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG1]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)
GO

USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG1]
MODIFY REPLICA ON N'LOGANSQLTEST02' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)
GO


-- Primary Role on both replicas
USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (PRIMARY_ROLE(ALLOW_CONNECTIONS = ALL))
GO
USE [master]
GO
ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST02' WITH (PRIMARY_ROLE(ALLOW_CONNECTIONS = ALL))
GO


-- Secondary Roles on both replicas

USE [master]
GO

ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (SECONDARY_ROLE(ALLOW_CONNECTIONS = READ_ONLY))
GO
ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST02' WITH (SECONDARY_ROLE(ALLOW_CONNECTIONS = READ_ONLY))
GO
/*
https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/configure-read-only-routing-for-an-availability-group-sql-server?view=sql-server-2017
*/
-- Add SECONDARY_ROLE : READ_ONLY_ROUTING_URL to all replicas
 
ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://LOGANSQLTEST01.LOGANSQL.NET:1433'))
GO

ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST02' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://LOGANSQLTEST02.LOGANSQL.NET:1433'))
GO

-- check
SELECT replica_server_name
	, read_only_routing_url
	, secondary_role_allow_connections_desc
FROM sys.availability_replicas

-- Add PRIMARY_ROLE : READ_ONLY_ROUTING_LIST to all replicas
ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST01' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('LOGANSQLTEST02','LOGANSQLTEST01')));
GO

ALTER AVAILABILITY GROUP [TestAG2]
MODIFY REPLICA ON N'LOGANSQLTEST02' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('LOGANSQLTEST01','LOGANSQLTEST02')));
GO

-- check
SELECT	  AVGSrc.replica_server_name AS SourceReplica		
		, AVGRepl.replica_server_name AS ReadOnlyReplica
		, AVGRepl.read_only_routing_url AS RoutingURL
		, AVGRL.routing_priority AS RoutingPriority
FROM sys.availability_read_only_routing_lists AVGRL
INNER JOIN sys.availability_replicas AVGSrc ON AVGRL.replica_id = AVGSrc.replica_id
INNER JOIN sys.availability_replicas AVGRepl ON AVGRL.read_only_replica_id = AVGRepl.replica_id
INNER JOIN sys.availability_groups AV ON AV.group_id = AVGSrc.group_id
ORDER BY SourceReplica


--- test from sqlcmd
/* -- PLEASE REMEMBER TO SPECIFY -d dbname!!!!! the readonly is for database specific.
sqlcmd -S testag2listener -E -d TSQL2012 -K ReadOnly
1> select @@servername
2> go
                                                                                                                        
--------------------------------------------------------------------------------------------------------------------------------
LOGANSQLTEST01 

(1 rows affected)
1> create table test1 (f1 int)
2> go
Msg 3906, Level 16, State 2, Server LOGANSQLTEST01, Line 1
Failed to update database "TSQL2012" because the database is read-only.

sqlcmd -S testag2listener -E -d TSQL2012
1> select @@servername
2> go
                                                                                                                        
--------------------------------------------------------------------------------------------------------------------------------
LOGANSQLTEST02

(1 rows affected)
*/

-- test from SSMS
-- => Login: Server Name: TestAG2Listener
-- => option
-- ---=> Connection Properties: Connect to database: TSQL2012
-- ---=> Additional Connection Parameters: ApplicationIntent=ReadOnly


-- If Not working
/*
https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/troubleshoot-always-on-availability-groups-configuration-sql-server?view=sql-server-2017#ROR
*/
-- To verify whether the listener is online:

SELECT * FROM sys.dm_tcp_listener_states;

-- To restart an offline listener:

ALTER AVAILABILITY GROUP [TestAG2] RESTART LISTENER 'TestAG2Listener';

-- To identify readable secondary replicas: sys.availability_replicas (secondary_role_allow_connections_desc column)
select * from sys.availability_replicas

-- To view a read-only routing list: sys.availability_read_only_routing_lists
select * from sys.availability_read_only_routing_lists

-- Every replica in the read_only_routing_list	Ensure that the Windows firewall is not blocking the READ_ONLY_ROUTING_URL port.

/* 
Every replica in the read_only_routing_list	In SQL Server Configuration Manager, verify that:

SQL Server remote connectivity is enabled.

TCP/IP is enabled.

The IP addresses are configured correctly.
*/
/*
Every replica in the read_only_routing_list	Ensure that the READ_ONLY_ROUTING_URL (TCP://system-address:port) 
contains the correct fully-qualified domain name (FQDN) and port number.
*/

/*
Client system	Verify that the client driver supports read-only routing.
*/