/*
	SQL connection analysis (connection counts)
*/

use master
go

-- Get a count of SQL connections by IP address
SELECT ec.client_net_address, es.[program_name], 
es.[host_name], es.login_name, 
COUNT(ec.session_id) AS [connection count] 
FROM sys.dm_exec_sessions AS es  
INNER JOIN sys.dm_exec_connections AS ec  
ON es.session_id = ec.session_id   
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  
ORDER BY ec.client_net_address, es.[program_name];

-- Get a count of SQL connections by login_name
SELECT login_name, COUNT(session_id) AS [session_count] 
FROM  sys.dm_exec_sessions
GROUP BY login_name
ORDER BY login_name;

-- Program_Name
/*
But if the developer includes the "Application Name" property in the connection string 
then it will be very easy for the database administrator to see the name of the application that is causing the trouble. 
This will save hours for the DBA and it will make the developer popular amongst the DBAs.
How?
Simply include "Application Name=MyAppName;" in the connection string. 
After that it is also possible to use that value in SQL batches or SPROCs with the command, "SELECT APP_NAME();"
*/
select APP_NAME()

/*
<add name="CustomersDatabase"
connectionString="Server=.;Database=Customers;Trusted_Connection=True;"
providerName="System.Data.SqlClient" />

<add name="CustomersDatabase"
connectionString="Application Name=CustomerService;Server=.;Database=Customers;Trusted_Connection=True;"
providerName="System.Data.SqlClient" />
*/

select session_id, program_name, host_name,
client_interface_name, login_name, nt_user_name
from sys.dm_exec_sessions
where session_id > 50

/*
https://sqlperformance.com/2017/07/sql-performance/find-database-connection-leaks
Connection Leak
*/
-- SQL 2012 / above
select count(*) as sessions,
         s.host_name,
         s.host_process_id,
         s.program_name,
         db_name(s.database_id) as database_name
   from sys.dm_exec_sessions s
   where is_user_process = 1
   group by host_name, host_process_id, program_name, database_id
   order by count(*) desc;

-- SQL 2012 below no database_id
select count(*) as sessions,
         s.host_name,
         s.host_process_id,
         s.program_name
   from sys.dm_exec_sessions s
   where is_user_process = 1
   group by host_name, host_process_id, program_name
   order by count(*) desc;

-- get the suspected highest count host_process_id for inverstigation
-- fingerprint on SQL Server
declare @host_process_id varchar(20) = 2504;
declare @host_name sysname = N'My_Host';
--declare @database_name sysname = N'My_Database';
 
select datediff(minute, s.last_request_end_time, getdate()) as minutes_asleep,
        s.session_id,
        --db_name(s.database_id) as database_name,
        s.host_name,
        s.host_process_id,
        t.text as last_sql,
        s.program_name, s.login_name
from sys.dm_exec_connections c
join sys.dm_exec_sessions s
        on c.session_id = s.session_id
cross apply sys.dm_exec_sql_text(c.most_recent_sql_handle) t
where s.is_user_process = 1
        and s.status = 'sleeping'
        --and db_name(s.database_id) = @database_name
        and s.host_process_id = @host_process_id
        and s.host_name = @host_name
        and datediff(second, s.last_request_end_time, getdate()) > 60
order by s.last_request_end_time;

/*
	fingerprint on Active Directory: 
	.\PsLoggedon.exe \\My_Host
*/