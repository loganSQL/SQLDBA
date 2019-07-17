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

## PortQry
[PortQry 2.0](https://support.microsoft.com/en-ca/help/832919/new-features-and-functionality-in-portqry-version-2-0)
PortQry is a command-line utility that you can use to help troubleshoot TCP/IP connectivity issues. This utility reports the port status of target TCP and User Datagram Protocol (UDP) ports on a local computer or on a remote computer.

### For SQL Server 
PortQry queries UDP port 1434 to query all the SQL Server named instances that are running. PortQry sends a query that is formatted in the way that SQL Server accepts to determines whether this port is listening.
```
# 
portqry -n LoganSQLSvr -e 1434 -p udp

```
```
Querying target system called:

 LoganSQLSvr

Attempting to resolve name to IP address...


Name resolved to 172.32.25.51

querying...

UDP port 1434 (ms-sql-m service): LISTENING or FILTERED

Sending SQL Server query to UDP port 1434...

Server's response:

ServerName LoganSQLSvr
InstanceName MSSQLSERVER
IsClustered No
Version 10.50.6000.34
tcp 1433
np \\LoganSQLSvr\pipe\sql\query

ServerName LoganSQLSvr
InstanceName LoganSQLSvr16A
IsClustered No
Version 13.2.5026.0
tcp 58956

ServerName LoganSQLSvr
InstanceName LoganSQLSvrQA
IsClustered No
Version 13.2.5026.0
tcp 65425
np \\FNSQL10\pipe\MSSQL$LoganSQLSvrQA\sql\query

ServerName LoganSQLSvr
InstanceName SQL2019
IsClustered No
Version 15.0.1500.28
tcp 49361

 

==== End of SQL Server query response ====

UDP port 1434 is LISTENING
```