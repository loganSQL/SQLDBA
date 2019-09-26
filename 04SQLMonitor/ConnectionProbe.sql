-- show current active request
exec msdb.dbo.showrequest

-- active connection: command not 'AWAITING COMMAND'
EXEC sp_who 'active'; 

-- all current connection
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerName,
       @@SERVERNAME AS FullInstanceName, @@SERVICENAME AS InstanceName,
       local_net_address AS InstanceIPAddress, local_tcp_port AS InstancePort,
	   client_net_address As ClientIPAddress,
	   client_tcp_port As ClientPort,
	   auth_scheme as AuthScheme,
	   last_read as LastRead,
	   last_write as LastWrite, *
FROM sys.dm_exec_connections 

-- connection with client host
sp_who2 @SPID


