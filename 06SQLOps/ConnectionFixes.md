# SQL Connections

## IP & Port Number
```
-- IP: Query DMV sys.dm_exec_connections 
SELECT dec.local_net_address
FROM sys.dm_exec_connections AS dec
WHERE dec.session_id = @@SPID;
GO

-- Port: From errorlog
USE master
GO
xp_readerrorlog 0, 1, N'Server is listening on' 
GO

-- Current Connection
SELECT  
   CONNECTIONPROPERTY('net_transport') AS net_transport,
   CONNECTIONPROPERTY('protocol_type') AS protocol_type,
   CONNECTIONPROPERTY('auth_scheme') AS auth_scheme,
   CONNECTIONPROPERTY('local_net_address') AS local_net_address,
   CONNECTIONPROPERTY('local_tcp_port') AS local_tcp_port,
   CONNECTIONPROPERTY('client_net_address') AS client_net_address 
GO
-- remote SQL Host and Instance
SELECT SERVERPROPERTY('MachineName'), @@SERVERNAME
GO
```

## SQLCMD
[sqlcmd - Connect to the Database Engine](https://docs.microsoft.com/en-us/sql/ssms/scripting/sqlcmd-connect-to-the-database-engine?view=sql-server-2017)


## SQL Server Connection Strings
[SQL Server Connection Strings](https://www.connectionstrings.com/sql-server/)