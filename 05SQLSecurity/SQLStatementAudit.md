# SQL Statement Audit
The purpose of SQL Server database auditing is to audit database level activities such as INSERT, UPDATE, DELETE and even data access via the SELECT command.
## 1. Create a Server Audit
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

## 2. Create a Database Audit Specification
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

## 3. Enable a Database Audit Specification
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
## 4. Enable a Server Audit
In SSMS, Server Audit->Right Click->Enable
```
USE [master]
GO

ALTER SERVER AUDIT Audit-Test  
WITH (STATE = ON);  
GO 
```
[ALTER SERVER AUDIT (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-server-audit-transact-sql?view=sql-server-2017>)
## 5. Review Audit Logs
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

## 6. SQL 2016 User Defined Audit
[sp_audit_write (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-audit-write-transact-sql?view=sql-server-2017>)

```
-- server audit definition
USE [master]
GO

CREATE SERVER AUDIT [Audit_User_Defined_Test]
TO FILE 
( FILEPATH = N'E:\DBBackup\Audit'
 ,MAXSIZE = 100 MB
 ,MAX_ROLLOVER_FILES = 2147483647
 ,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 1000
 ,ON_FAILURE = CONTINUE
)
GO

Alter Server Audit [Audit_User_Defined_Test] with(State=ON)
GO

-- Database Level Audit definition
Use [AdventureWorks2016CTP3]
GO

Create Database Audit Specification Test_database_audit
for server audit [Audit_User_Defined_Test]
ADD (User_Defined_Audit_Group)
With(State=ON)
GO

-- Audit action type is set to User_Defined_Audit_Group
-- which basically tracks events raised by the sp_audit_write stored procedure
-- e.g.
--    Exec sp_audit_write @user_defined_event_id=27, @succeeded =1, @user_defined_information = @msg;

-- Suppose we want to audit the Adventureworks database table [Production].[ProductListPriceHistory]
Create Trigger [Production].[ProductListPrice] 
on [Production].[ProductListPriceHistory]
After Update
As
declare @OldListPrice money
,@NewListPrice money,
@productId int,
@msg nvarchar(2500)
select @OldListPrice=d.ListPrice
from deleted d
select @NewListPrice= i.ListPrice , @productId=i.ProductId
from inserted i

If (@OldListPrice*0.80 >@NewListPrice)  -- implement logic condition
begin
 Set @msg='Product '+ Cast (@productid as varchar(50))+' ListPrice is decreased by more than 20%' --print message to be logged
 Exec sp_audit_write @user_defined_event_id=27,
 @succeeded =1, 
 @user_defined_information = @msg;
End
GO
```

## 7. SQL Server 2016 Audit Filtering
```
-- audit the Employee information table for SELECT and UPDATE statements
Use Master --server Audit needs to be created in the Master database
GO

Create Server Audit Audit_Security_Employee
To file (FilePath='C:\mssqltips\Audit');
GO

Alter Server Audit Audit_Security_Employee with(STATE=ON)
GO

Use [AdventureWorks2016CTP3]
GO

Create Database Audit Specification Audit_Employee
for Server Audit Audit_Security_Employee
Add (Select , update  on [HumanResources].[Employee]  by dbo) --Insert condition for which event to be tracked.
With (State=ON);
GO
```

## 8. [Steps to restore a database that has a SQL Server Audit defined](<https://www.mssqltips.com/sqlservertip/2574/steps-to-restore-a-database-that-has-a-sql-server-audit-defined/>)
## 9. [List Enabled Audit Specifications](<https://gist.github.com/nullbind/5da8b5113da007ba0111>)
```
-- Server Audit Details
SELECT a.name 'AuditName',a.type_desc 'AuditFileLocation',
CASE a.is_state_enabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' END 'AuditStatus'
,b.name 'ServerAuditName', 
CASE b.is_state_enabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' END 'ServerAuditStatus'
,c.audit_action_id ,c.audit_action_name ,c.audited_result 
from sys.server_audits a
JOIN sys.server_audit_specifications b ON a.audit_guid = b.audit_guid 
JOIN sys.server_audit_specification_details c ON b.server_specification_id = c.server_specification_id
```
```
-- Database Audit Details
USE DBName 
GO
SELECT a.name 'AuditName',a.type_desc 'AuditFileLocation',
CASE a.is_state_enabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' END 'AuditStatus'
,b.name 'DatabaseAuditName'
,CASE b.is_state_enabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' END 'DatabaseAuditStatus'
,c.audit_action_id ,c.audit_action_name ,c.class_desc ,c.audited_result 
FROM sys.server_audits a
JOIN sys.database_audit_specifications b ON a.audit_guid = b.audit_guid 
JOIN sys.database_audit_specification_details c ON b.database_specification_id = c.database_specification_id
```

## 10. [Get started with Azure SQL Database Managed Instance Auditing](<https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/sql-database/sql-database-managed-instance-auditing.md>)