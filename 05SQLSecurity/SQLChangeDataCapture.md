# SQL Server Change Data Capture
## Overview
SQL Server Change Data Capture was introduced in SQL Server 2008 to make the extract, transform, and load processes easier. It also captures information about data changes – inserts, deletes and updates, but it provides more details than SQL Server Change Tracking. The mechanism used for capturing and the information captured are different

In Change Data Capture, the information is retrieved by periodic querying of the online transaction log. The process is asynchronous. Database performance is not affected; performance overhead is lower than with other solutions (e.g. using triggers)

As Change Data Capture reads committed transactions from the online transaction log, it uses the transaction commit time, so there are no problems in determining the sequence of long-running and overlapping transactions

Change Data Capture is a process that can delay log truncation

“Even if the recovery mode is set to simple recovery the log truncation point will not advance until all the changes that are marked for capture have been gathered by the capture process. If the capture process is not running and there are changes to be gathered, executing CHECKPOINT will not truncate the log.” [1]

**SQL Server Change Data Capture requires no schema changes of the existing tables, no columns for timestamps are added to the tracked (source) tables, and no triggers are created. It captures the information and stores it in tables called change tables. For reading the change tables, Change Data Capture provides table-valued functions**

Like with Change Tracking, there is a built-in clean-up solution that removes old captured information after a specified time

Both Change Tracking and Change Data Capture can be enabled on the same database at the same time

##
The feature is available only in SQL Server Enterprise and Developer editions, starting with. It can be enabled only using system stored procedures. SQL Server Management Studio provides a wide range of code templates for various feature related actions.
SSMS -> View -> Template Explorer -> SQL Server Template -> Change Data Capture -> Enable Database for CDC

### Enable CDC on Database
```
-- ================================
-- Enable Database for CDC Template
-- ================================
USE DBA
GO

EXEC sys.sp_cdc_enable_db
GO

-- Check Which Database IS_CDC_ENABLE
SELECT name, is_cdc_enabled FROM sys.databases
```

### Enable CDC on a Table in a Database
```
-- Enable CDC on a table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'addresses',
    @role_name     = NULL,
    @supports_net_changes = 1
GO

-- To check whether Change Data Capture is enabled on the table
SELECT name, is_tracked_by_cdc FROM sys.tables
where name = 'addresses'
-- 
```
```
-- By default, all columns in the table are tracked.
-- to track specific column
-- @captured_column_list = N'street, city, region'

-- Change the default location of change table
-- @filegroup_name = N'SECONDARY'

-- When the @role_name parameter is set to NULL, 
-- only members of sysadmin and db_owner roles have full access to captured information. 
-- When set to a specific role, only the members of the role (called a gating role) 
-- can access the changed data table.
-- @role_name = N'cdc_Admin'
```
### Results
#### Two SQL Agent Jobs Created
```
Job 'cdc.DBA_capture' started successfully.
Job 'cdc.DBA_cleanup' started successfully.
```
### A capture table and up to two table valued functions created. 
For the Person.Address table, these are :
* cdc.Person_Address_CT table, and 
* cdc.fn_cdc_get_all_changes_Person_Address and 
* cdc.fn_cdc_get_net_changes_Person_Address ( The latter one is created only when the @supports_net_changes parameter is set to 1). 

These functions are used to query change tables
### Take Away
Change Data Capture can be enabled only using code, as SQL Server Management Studio offers no options for the feature. It has to be enabled for each table individually. 

For each tracked table, a new system table and up to two functions are created, which brings additional load to the database. 

**Although it captures more information about transactions than SQL Server Change Tracking, it doesn’t answer the “who”, “when”, and “how” questions**

[How to enable and use SQL Server Change Data Capture](<https://solutioncenter.apexsql.com/enable-use-sql-server-change-data-capture/>)
