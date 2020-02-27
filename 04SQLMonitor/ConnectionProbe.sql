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


--  all the clients
SELECT @@SERVERNAME as Instance,
--SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerName,
--       @@SERVERNAME AS FullInstanceName, @@SERVICENAME AS InstanceName,
session_id, p.loginame, p.hostname, p.status, p.cmd, p.program_name,
       local_net_address AS InstanceIPAddress, local_tcp_port AS InstancePort,
	   client_net_address As ClientIPAddress,
	   client_tcp_port As ClientPort,
	   auth_scheme as AuthScheme,
	   last_read as LastRead,
	   last_write as LastWrite
FROM sys.dm_exec_connections c
,sys.sysprocesses p
where c.session_id = p.spid and client_tcp_port is not null

use msdb
go

create procedure showclient
as
SELECT @@SERVERNAME as Instance,
--SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerName,
--       @@SERVERNAME AS FullInstanceName, @@SERVICENAME AS InstanceName,
session_id, p.loginame, p.hostname as client_machine, p.status, p.cmd, p.program_name,
       local_net_address AS InstanceIPAddress, local_tcp_port AS InstancePort,
	   client_net_address As ClientIPAddress,
	   client_tcp_port As ClientPort,
	   auth_scheme as AuthScheme,
	   last_read as LastRead,
	   last_write as LastWrite
FROM sys.dm_exec_connections c
,sys.sysprocesses p
where c.session_id = p.spid and client_tcp_port is not null
go

msbd.dbo.showcleint

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
SPID = er.session_id
,BlkBy = CASE WHEN lead_blocker = 1 THEN -1 ELSE er.blocking_session_id END
,ElapsedMS = er.total_elapsed_time
,CPU = er.cpu_time
,IOReads = er.logical_reads + er.reads
,IOWrites = er.writes
,Executions = ec.execution_count
,CommandType = er.command
,LastWaitType = er.last_wait_type
,ObjectName = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
,STATUS = ses.STATUS 
,[Login] = ses.login_name 
,Host = ses.host_name 
,DBName = DB_Name(er.database_id) 
,StartTime = er.start_time 
,Protocol = con.net_transport 
,transaction_isolation = CASE ses.transaction_isolation_level WHEN 0 THEN 'Unspecified' WHEN 1 THEN 'Read Uncommitted' WHEN 2 THEN 'Read Committed' WHEN 3 THEN 'Repeatable' WHEN 4 THEN 'Serializable' WHEN 5 THEN 'Snapshot' END 
,ConnectionWrites = con.num_writes 
,ConnectionReads = con.num_reads 
,ClientAddress = con.client_net_address 
,Authentication = con.auth_scheme 
,DatetimeSnapshot = GETDATE() 

echo off
SET /P PC=Please Enter Computer Name
PsLoggedon.exe \\%PC%
pause

wmic /node:"servername or ip address" computersystem get username