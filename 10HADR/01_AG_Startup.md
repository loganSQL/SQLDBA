# 1. Windows Failover Cluster Feature Installation
```
## You need at least two hosts from the same AD
## node 1 hostname
## node 2 hostname
```
* Server Manager
* Add roles and features
* Select Features
* Select the Failover Clustering checkbox
* Add Features 
* Next

# 2. Windows Failover Clustering Configuration

##  2.1. Failover Cluster Validation
```
## node 1 hostname, subnet, ip
## node 2 hostname, subnet, ip
## proposed cluster name
## one ip for each subnet
```
* Server Manager => Failover Cluster Manager => Validate Configuration => Validate a Configuration Wizard dialog box
* Select Servers or a Cluster dialog box => add server hostnames => Next
* Testing Options => n Run all tests (recommended) => Next
* Confirmation => Next
* Summary => Finished

The Failover Cluster Validation Wizard is expected to return several Warning messages, especially if you will not be using shared storage. 
There is no need to use shared storage to create the Windows Server Failover Cluster that we will use for our Availability Group. 
Just be aware of these Warning messages as we will configure a file share witness for our cluster quorum configuration. 
However, if you see any Error messages, you need to fix those first prior to creating the Windows Server Failover Cluster.

##  2.2. Create a cluster: Failover Cluster Configuration (Access Point for Administering) the Cluster

* Access Point for Administering the Cluster dialog box => Enter virtual server name and virtual IP address
* Confirmation => Next
* Summary => verify the configuration successfully

##  2.3. To configure the cluster quorum configuration to use a file share
```
## file share host
## local directory
## don't precreate the file share, let the following Quorum configuration Wizard to create it
```
* right-click on the cluster name, select More Actions and click Configure Cluster Quorum Settings
* In the Select Quorum Configuration page, select the Add or change the quorum witness option. Click Next
* In the Select Quorum Witness page, select the Configure a file share witness (recommended for special configuration) option. Click Next	
* In the Configure File Share Witness page, type path of the file share that you want to use in the File Share Path: text box. Click Next
* In the Confirmation page, click Next.
* In the Summary page, click Finish.

# 3. Enable SQL Server AlwaysOn Availability Groups Feature
```
Enable-SqlAlwaysOn -ServerInstance YourInstance
```
Repeat the following on primary and all the replicas
* Open SQL Server Configuration Manager. 
* Double-click the SQLServer (MSSQLSERVER) service to open the Properties dialog box
* select the AlwaysOn High Availability tab
* Check the Enable AlwaysOn Availability Groups check box
* Restart the SQL Server service.

# 4. Create file share for backup and replicas
```
## any fileshare for backup transfer
```
This is like setup log shipping before.
* Create a file share on one of the servers
* Give read/write access to all your service accounts.

# 5. Create SQL Server AlwaysOn Availability Groups
In SSMS go to Management, right click Availability Groups and click New Availability Group Wizard,
* Specify Name for AG
* Select Databases
* Specify Replicas: connect to another server (instance)
* Replica Mode : Automatic Failover, High Performance, or High Safety.
•	Automatic Failover: This replica will use synchronous-commit availability mode and support both automatic failover and manual failover.
•	High Performance: This replica will use asynchronous-commit availability mode and support only forced failover (with possible data loss).
•	High Safety: This replica will use synchronous-commit availability mode and support only manual failover.
* Connection Mode in Secondary :  Disallow connections, Allow only read-intent connections, or Allow all connections.
•	Disallow connections: This availability replica will not allow any connections.
•	Allow only read-intent connections: This availability replica will only allow read-intent connections.
•	Allow all connections: This availability replica will allow all connections for read access, including connections running with older clients. For this example, I'll choose Automatic Failover and Disallow connections to my secondary role and click Next.

# 6. Specify Availability Group Listener
take defaults and choose Next.

# 7. Select Data Synchronization
	Perform initial data synchronization (need a shared location – fileshare)

# 8. Validation & Summary & Script & Finish
* Configures endpoints 
* Create Availability Group 
* Create Availability Group Listener
* Join secondary replica to the Availability Group 
* Create a full backup of DB1 
* Restore DB1 to secondary server 
* Backup log of DB1 
* Restore DB1 log to secondary server 
* Join DB1 to Availability Group on secondary server 
* Create a full backup of DB2 
* Restore DB2 to secondary server 
* Backup log of DB2 
* Restore DB2 log to secondary server 
* Join DB2 to Availability Group on secondary server

# 9. View the Availability Group in SSMS
In SSMS, drill down to Management => Availability Groups. 
* Availability Replicas
* Availability Databases
* Availability Group Listeners.
In the dashboard will help you determine if your databases are Synchronized and Healthy.

```
--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect logansqltest01

use [master]


GO

USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [logansql\mssqlsvc]

GO

:Connect torqfnsqltest01

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

USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [logansql\mssqlsvc]

GO

:Connect midqfnsqltest01

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect torqfnsqltest01

USE [master]

GO

CREATE AVAILABILITY GROUP [TestAG1]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
BASIC,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE)
FOR DATABASE [TSQL2012]
REPLICA ON N'MIDQFNSQLTEST01' WITH (ENDPOINT_URL = N'TCP://logansqltest01.logansql.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, SEEDING_MODE = MANUAL, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
	N'TORQFNSQLTEST01' WITH (ENDPOINT_URL = N'TCP://logansqltest02.logansql.net:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, SEEDING_MODE = MANUAL, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));

GO

:Connect midqfnsqltest01

ALTER AVAILABILITY GROUP [TestAG1] JOIN;

GO

:Connect torqfnsqltest01

BACKUP DATABASE [TSQL2012] TO  DISK = N'\\LOGANSQLTEST01\dbbackup\TSQL2012.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect midqfnsqltest01

RESTORE DATABASE [TSQL2012] FROM  DISK = N'\\LOGANSQLTEST01\dbbackup\TSQL2012.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect torqfnsqltest01

BACKUP LOG [TSQL2012] TO  DISK = N'\\LOGANSQLTEST01\dbbackup\TSQL2012.trn' WITH NOFORMAT, INIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect midqfnsqltest01

RESTORE LOG [TSQL2012] FROM  DISK = N'\\LOGANSQLTEST01\dbbackup\TSQL2012.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect logansqltest02


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'TestAG1'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [TSQL2012] SET HADR AVAILABILITY GROUP = [TestAG1];

GO


GO

```