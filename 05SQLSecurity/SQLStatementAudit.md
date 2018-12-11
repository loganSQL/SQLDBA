# SQL Statement Audit
## Create a Server Audit
In SSMS, Instance->Security->Audits->Right Click->New Audit

```
USE [master]
GO

-- There are 3 possible destinations: 
-- 1. the Application event log, 
-- 2. the Security event log,
-- 3. a file folder
-- (make sure the directory E:\DBBackup\Audit-Test was created first)
CREATE SERVER AUDIT [Audit-Test]
TO FILE 
(  FILEPATH = N'E:\DBBackup\Audit-Test'
  ,MAXSIZE = 0 MB
  ,MAX_ROLLOVER_FILES = 2147483647
  ,RESERVE_DISK_SPACE = OFF
)
WITH
(  QUEUE_DELAY = 1000
  ,ON_FAILURE = CONTINUE
)
GO

-- alternatively, APPLICATION_LOG
CREATE SERVER AUDIT [Audit-Test]
TO APPLICATION_LOG
WITH
(  QUEUE_DELAY = 1000
  ,ON_FAILURE = CONTINUE
)

GO

```

## Create a Database Audit Specification
In SSMS, Instance->Database->Security->Database Audit Specification->New...
```
USE [MyDB]
GO

-- For example, To audit SELECT from MyTable (by testuser)
CREATE DATABASE AUDIT SPECIFICATION [MyDB_Select_MyTable]
FOR SERVER AUDIT [Audit-Test]
ADD (SELECT ON OBJECT::[dbo].[MyTable] BY [testuser])
WITH (STATE = OFF)
GO
```

## Enable a Database Audit Specification
In SSMS, Database Audit Specification->Right Click->Enable
```
USE [MyDB]
GO

ALTER DATABASE AUDIT SPECIFICATION [MyDB_Select_MyTable]  
FOR SERVER AUDIT [Audit-Test]  
    ADD (SELECT  
         ON OBJECT::dbo.Table1  
         BY dbo)  
    WITH (STATE = ON);  
GO  
```
[ALTER DATABASE AUDIT SPECIFICATION (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-audit-specification-transact-sql?view=sql-server-2017>)
## Enable a Server Audit
In SSMS, Server Audit->Right Click->Enable
```
USE [master]
GO

ALTER SERVER AUDIT Audit-Test  
WITH (STATE = ON);  
GO 
```
[ALTER SERVER AUDIT (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-server-audit-transact-sql?view=sql-server-2017>)
## Review Audit Logs
In SSMS, Instance->Security-Audit->Right Click->View Audit Logs
```
SELECT event_time
  ,action_id
  ,session_server_principal_name AS UserName
  ,server_instance_name
  ,database_name
  ,schema_name
  ,object_name
  ,statement
FROM sys.fn_get_audit_file('E:\DBBackup\Audit-Test\*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ( 'SL', 'IN', 'DR', 'LGIF' , '%AU%' )
```
[How to analyze and read SQL Server Audit information](<https://solutioncenter.apexsql.com/analyze-and-read-sql-server-audit-information/>)