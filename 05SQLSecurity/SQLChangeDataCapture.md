# SQL Server Change Data Capture
## 1. Overview
SQL Server Change Data Capture was introduced in SQL Server 2008 to make the extract, transform, and load processes easier. It also captures information about data changes – inserts, deletes and updates, but it provides more details than SQL Server Change Tracking. The mechanism used for capturing and the information captured are different

In Change Data Capture, the information is retrieved by periodic querying of the online transaction log. The process is asynchronous. Database performance is not affected; performance overhead is lower than with other solutions (e.g. using triggers)

As Change Data Capture reads committed transactions from the online transaction log, it uses the transaction commit time, so there are no problems in determining the sequence of long-running and overlapping transactions

Change Data Capture is a process that can delay log truncation

“Even if the recovery mode is set to simple recovery the log truncation point will not advance until all the changes that are marked for capture have been gathered by the capture process. If the capture process is not running and there are changes to be gathered, executing CHECKPOINT will not truncate the log.” [1]

**SQL Server Change Data Capture requires no schema changes of the existing tables, no columns for timestamps are added to the tracked (source) tables, and no triggers are created. It captures the information and stores it in tables called change tables. For reading the change tables, Change Data Capture provides table-valued functions**

Like with Change Tracking, there is a built-in clean-up solution that removes old captured information after a specified time

Both Change Tracking and Change Data Capture can be enabled on the same database at the same time

## 2. Setup Change Data Capture (CDC)
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

```
-- List of Jobs with '%cdc%'
SELECT 
    [sJOB].[job_id] AS [JobID]
    , [sJOB].[name] AS [JobName]
    , [sDBP].[name] AS [JobOwner]
    , [sCAT].[name] AS [JobCategory]
    , [sJOB].[description] AS [JobDescription]
    , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [IsEnabled]
    , [sJOB].[date_created] AS [JobCreatedOn]
    , [sJOB].[date_modified] AS [JobLastModifiedOn]
    , [sSVR].[name] AS [OriginatingServerName]
    , [sJSTP].[step_id] AS [JobStartStepNo]
    , [sJSTP].[step_name] AS [JobStartStepName]
    , CASE
        WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
        ELSE 'Yes'
      END AS [IsScheduled]
    , [sSCH].[schedule_uid] AS [JobScheduleID]
    , [sSCH].[name] AS [JobScheduleName]
    , CASE [sJOB].[delete_level]
        WHEN 0 THEN 'Never'
        WHEN 1 THEN 'On Success'
        WHEN 2 THEN 'On Failure'
        WHEN 3 THEN 'On Completion'
      END AS [JobDeletionCriterion]
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
WHERE [sJob].[name] like '%cdc%' 
ORDER BY [JobName]

--- Output of query (Funny, the JobCategory is REPL)
JobName  JobOwner  JobCategory  JobDescription
cdc.DBA_capture  dbo  REPL-LogReader  CDC Log Scan Job
cdc.DBA_cleanup  dbo  REPL-Checkup  CDC Cleanup Job

```
The capture job is in charge of capturing data changes and processing them into change tables

Like other SQL Server jobs, the capture job can be stopped and started. When the job is stopped, the online transaction log is not scanned for the changes, and changes are not added to the capture tables. The change capturing process is not broken, as the changes will be processed once the job is started again. 

As the feature that can cause a delay in log truncating, the un-scanned transactions will not be overwritten, unless the feature is disabled on the database. However, the capture job should be stopped only when necessary, such as in peak hours when scanning logs can add load, and restarted afterwards

Examples
“It runs continuously, processing a maximum of 1000 transactions per scan cycle with a wait of 5 seconds between cycles. The cleanup job runs daily at 2 A.M. It retains change table entries for 4320 minutes or 3 days, removing a maximum of 5000 entries with a single delete statement.” 


### A capture table and up to two table valued functions created. 
``` 

-- see what have been created for dbo_address
select name, type from sysobjects where name like '%dbo_addresses%'

-- output
name  type
dbo_addresses_CT  U 
fn_cdc_get_all_changes_dbo_addresses  IF
fn_cdc_get_net_changes_dbo_addresses  IF
```
For dbo.addresses table, these are :
* cdc.dbo_addresses_CT table, and 
* cdc.fn_cdc_get_all_changes_dbo_addresses and 
* cdc.fn_cdc_get_net_changes_dbo_addresses ( The latter one is created only when the @supports_net_changes parameter is set to 1). 

These functions are used to query change tables
### Take Away
Change Data Capture can be enabled only using code, as SQL Server Management Studio offers no options for the feature. It has to be enabled for each table individually. 

For each tracked table, a new system table and up to two functions are created, which brings additional load to the database. 

**Although it captures more information about transactions than SQL Server Change Tracking, it doesn’t answer the “who”, “when”, and “how” questions**

[How to enable and use SQL Server Change Data Capture](<https://solutioncenter.apexsql.com/enable-use-sql-server-change-data-capture/>)

## 3. Analyze Change Data Capture Records
[How to analyze and read Change Data Capture (CDC) records](<https://solutioncenter.apexsql.com/analyzing-and-reading-change-data-capture-cdc-records/>)

### Tables for Tracked Database
The following tables are automatically created in the tracked database when Change Data Capture is enabled:

**cdc.captured_columns** – contains a row for each column tracked in the tracked (source) tables

**cdc.change_tables** – contains a row for each change table in the tracked database

**cdc.ddl_history** – contains a row for each structure (Data Definition Language) change of source tables

**cdc.index_columns** – contains a row for each index column associated with a change table. The index columns are used to uniquely identify rows in the source tables

**cdc.lsn_time_mapping** – contains a row for each transaction in the source tables. It maps Log Sequence Number values to the time the transaction was committed

**msdb.dbo.cdc_jobs** - stores configuration parameters for capture and cleanup jobs is the only system table created in the msdb database

### Tables for Tracked Table
When the feature is enabled on a table, the change table named **cdc.<captured_instance>_CT** is automatically created in the tracked database. 

The table contains a row for each insert and delete on the source table, and two rows for each update. The first one is identical to the row before the update, and the second one to the row after the update. To query the table, use the **cdc.fn_cdc_get_all_changes** and **cdc.fn_cdc_get_net_changes** functions

The first five columns contain the metadata necessary for the feature, the rest are the exact replica of the source table:

**__$start_lsn** – the Log Sequence Number of the commited transaction. Every change committed in the same transaction has its own row in the change table, but the same __$start_lsn

**__$end_lsn**  – the column is always NULL in SQL Server 2012, future compatibility is not guarantee

**__$seqval** – the sequence value used to order the row changes within a transaction

**__$operation** – indicates the change type made on the row (*Delete,Insert,Updated row before the change, Updated row after the change*)

**__$update_mask** – similar to the update mask available in Change Tracking, a bit mask used to identify the ordinals of the modified columns

### The system table valued functions
**cdc.fn_cdc_get_all_changes_<capture_instance>** – returns a row for each change in the source table that belongs to the Log Sequence Number in the range specified by the input parameters

### Samples
```
use DBA
go

select top 10 * from [dbo].[addresses]
go

-- make changes
insert [dbo].[addresses] ([street], [city], [region], [country], [code], [phone]) 
values ('2300 University Ave', 'Toronto', 'ON', 'CA', 'M8J-8D5','(417) 980-4545')
go

select max(id) from [dbo].[addresses]
go

update [dbo].[addresses]
set street = '10 King St West' 
where id = 51
go

update [dbo].[addresses]
set code='N6H-5H1'
where id = 1
go

-- Both cdc.fn_cdc_get_all_changes and cdc.fn_cdc_get_net_changes functions require two parameters 
-– the maximal and minimal Log Sequence Number (LSN) for the queried set of records
SELECT sys.fn_cdc_get_min_lsn('dbo_addresses') AS min_lsn
SELECT sys.fn_cdc_get_max_lsn() AS max_lsn

-- sys.fn_cdc_get_column_ordinal – returns the ordinal of the column in a source table.
SELECT sys.fn_cdc_get_column_ordinal( 'dbo_addresses', 'street') 

-- To read all captured information 
DECLARE @from_lsn binary (10), @to_lsn binary (10)

SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_addresses')
SET @to_lsn = sys.fn_cdc_get_max_lsn()

SELECT *
FROM cdc.fn_cdc_get_all_changes_dbo_addresses(@from_lsn, @to_lsn, 'all')
ORDER BY __$seqval

-- street column is 2
SELECT sys.fn_cdc_is_bit_set(2, __$update_mask) as 
'Street_Updated'
FROM cdc.fn_cdc_get_all_changes_dbo_addresses(@from_lsn, @to_lsn, 'all')
ORDER BY __$seqval


```