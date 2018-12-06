# How to detect any changes to a database (DDL and DML)

## Detect DDL Changes
1) [DDL Triggers](<https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms186406(v=sql.105)>).
2) [Default Trace](<http://www.sqlservercentral.com/articles/SQL+Server+2005/64547/>)

## Detect DML Changes
2) [Change tracking](<http://www.mssqltips.com/sqlservertip/1819/using-change-tracking-in-sql-server-2008/>): wheather the table has changed or not
3) [CDC(Change data Capture)](<https://docs.microsoft.com/en-us/sql/relational-databases/track-changes/about-change-data-capture-sql-server?view=sql-server-2017>): what data has changed (insert, update, delete)
4) [Audit Feature](<http://blogs.msdn.com/b/manisblog/archive/2008/07/21/sql-server-2008-auditing.aspx>): only the Auditing feature provides information about Who / When / How
## Default Trace
[Default Trace in SQL Server 2005](<https://blogs.technet.microsoft.com/vipulshah/2007/04/16/default-trace-in-sql-server-2005/>)

[A Few Cool Things You Can Identify Using the Default Trace](<https://www.databasejournal.com/features/mssql/a-few-cool-things-you-can-identify-using-the-default-trace.html>)

[Default Trace and System Health](<https://blogs.msdn.microsoft.com/askjay/2012/06/28/default-trace-and-system-health/>)
```
-- check the default trace to see if it is enabled.
SELECT * FROM sys.configurations WHERE configuration_id = 1568

-- if not, then enable it
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO

-- Displaying information about the default trace file
SELECT   * FROM sys.traces 
WHERE id = 1;

SELECT   value FROM sys.fn_trace_getinfo(1)
  WHERE property = 2;
  
--get the current trace rollover file name
SELECT * FROM ::fn_trace_getinfo(0)

SELECT traceid, value FROM [fn_trace_getinfo](NULL)
WHERE [property] = 2;

-- get the trace log from the trace file:
-- replace the file name
-- choose database of interest
-- trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj
SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\Database\MSSQL10_50.MSSQLSERVER\MSSQL\Log\log_3293.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE 
    -- databasename = 'myDB' AND
      objectname IS NULL AND --filter by objectname
      e.category_id = 5 AND --category 5 is objects
      e.trace_event_id = 46 
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj
      
-- view information in the current default trace file.
DECLARE   @filename nvarchar(1000);
 
-- 1. Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- view current trace file
SELECT   *
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
  ORDER BY   ftg.StartTime
  
-- 2. Get object created and deleted events from the current default trace file.
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- view current trace file
SELECT   *
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE (ftg.EventClass = 46 or ftg.EventClass = 47)
and   DatabaseName <> 'tempdb' 
and   EventSubClass = 0
ORDER   BY ftg.StartTime;

-- 3. find out every time a database has an Auto-Grow event
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- Find auto growth events in the current trace file
SELECT
    ftg.StartTime
 ,te.name as EventName
 ,DB_NAME(ftg.databaseid) AS DatabaseName  
 ,ftg.Filename
 ,(ftg.IntegerData*8)/1024.0 AS GrowthMB 
 ,(ftg.duration/1000)as DurMS
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE (ftg.EventClass = 92  -- Date File Auto-grow
      OR ftg.EventClass   = 93) -- Log File Auto-grow
ORDER BY   ftg.StartTime

-- 4. security related events
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- process all trace files
SELECT   *  
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE   ftg.EventClass 
      in (102,103,104,105,106,108,109,110,111)
  ORDER BY   ftg.StartTime
```
### Event and Category Queries
```
Event and Category Queries
--list of events 
SELECT *
FROM sys.trace_events
--list of categories 
SELECT *
FROM sys.trace_categories
--list of subclass values
SELECT *
FROM sys.trace_subclass_values
--Get trace Event Columns
SELECT 
     t.EventID,
     t.ColumnID,
     e.name AS Event_Descr,
     c.name AS Column_Descr
FROM ::fn_trace_geteventinfo(1) t
     INNER JOIN sys.trace_events e 
          ON t.eventID = e.trace_event_id
     INNER JOIN sys.trace_columns c 
          ON t.columnid = c.trace_column_id
```
### THE TRACE LOG is limited to 20MB

the log file storing the trace is limited to 20MB. Once the file is filled, SQL Server starts another file. Up to 5 files are used (5x20MB=100MB). 

Here's the code to load info from all 5 of them (and hence see default trace records much farther back in time): 
```
-- read all trace logs from a table
DECLARE @FileName VARCHAR(MAX) 
SELECT @FileName = SUBSTRING(path, 0, LEN(path)-CHARINDEX('\', REVERSE(path))+1) + '\Log.trc' 
FROM sys.traces 
WHERE is_default = 1; 

--select @filename 
SELECT * into trace_table FROM sys.fn_trace_gettable( @FileName, DEFAULT ) AS gt 

select * from trace_table
```
If you wish to get the actual data out of the default trace files – there are 5 by default, then you can do the following to see what configuration and schema changes have been made on your system in the last 5 restarts of your SQL Service or in the last 100 MB of trace data – whichever comes first (the default trace automatically starts a new file at 20MB and maintains 5 files):
```
declare @def_trace nvarchar(250) = (select path from sys.traces where is_default = 1) 
select e.name, x.* from          
    fn_trace_gettable(@def_trace, 5) x 
    join sys.trace_events e 
    on x.EventClass = e.trace_event_id
```
## Detect DDL changes by using trace file
[list of events](<https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-setevent-transact-sql?view=sql-server-2017>)

* ***46  Object:Created***  Indicates that an object has been created, such as for CREATE INDEX, CREATE TABLE, and CREATE DATABASE statements.
* ***47  Object:Deleted***  Indicates that an object has been deleted, such as in DROP INDEX and DROP TABLE statements.
* ***164  Object:Altered***  Occurs when a database object is altered.
```
SELECT 
    te.name AS eventtype
    ,t.loginname
    ,t.spid
    ,t.starttime
    ,t.objectname
    ,t.databasename
    ,t.hostname
    ,t.ntusername
    ,t.ntdomainname
    ,t.clientprocessid
    ,t.applicationname  
FROM sys.fn_trace_gettable
(
    CONVERT
    (VARCHAR(150)
    ,(
        SELECT TOP 1 
            value
        FROM sys.fn_trace_getinfo(NULL)  
        WHERE property = 2
    )),DEFAULT
) T 
INNER JOIN sys.trace_events as te 
    ON t.eventclass = te.trace_event_id 
WHERE eventclass=164
```

## Detect any modification on table and stored procedure 
```
SELECT 
    SO.Name
    ,SS.name 
    ,SO.type_desc 
    ,SO.create_date
    ,SO.modify_date 
 FROM sys.objects AS SO
INNER JOIN sys.schemas AS SS 
    ON SS.schema_id = SO.schema_id 
WHERE DATEDIFF(D,modify_date, GETDATE()) < 50
AND TYPE IN ('P','U')
```

## [Read Default Trace](<https://gallery.technet.microsoft.com/scriptcenter/Read-Default-Trace-ae068150>)

This script will find the path for the default trace and display what it has captured.
```
--http://jongurgul.com/blog/sql-server-profiler-trace/ 
DECLARE @tracefile NVARCHAR(MAX) 
SET @tracefile = (SELECT LEFT([path],LEN([path])-CHARINDEX('\',REVERSE([path])))+ '\log.trc' FROM sys.traces WHERE [is_default] = 1)  
 
 SELECT  
 gt.[ServerName]  
,gt.[DatabaseName]  
,gt.[SPID]  
,gt.[StartTime]  
,gt.[ObjectName]  
,gt.[objecttype] [ObjectTypeID]--http://msdn.microsoft.com/en-us/library/ms180953.aspx  
,sv.[subclass_name] [ObjectType]  
,e.[category_id] [CategoryID]  
,c.[Name] [Category]  
,gt.[EventClass] [EventID]  
,e.[Name] [EventName]  
,gt.[LoginName]  
,gt.[HostName] 
,gt.[ApplicationName]  
,gt.[TextData]  
FROM fn_trace_gettable(@tracefile, DEFAULT) gt  
LEFT JOIN sys.trace_subclass_values sv ON gt.[eventclass] = sv.[trace_event_id] AND sv.[subclass_value] = gt.[objecttype]  
INNER JOIN sys.trace_events e ON gt.[eventclass] = e.[trace_event_id]  
INNER JOIN sys.trace_categories c ON e.[category_id] = c.[category_id]  
WHERE gt.[spid] > 50  
AND (gt.[objecttype] <> 21587 /*Ignore Statistics*/ OR gt.[objecttype] IS NULL)  
AND gt.[databasename] <> 'tempdb' --Ignore tempdb  
AND gt.[starttime] >= DATEADD(DAY,0,DATEDIFF(DAY,0,GETDATE())) --From Today 00:00:00.000
```

If you are interested in what the default trace has been setup to capture you can run this (Note you cannot edit the default trace!):
```
SELECT *  
FROM fn_trace_geteventinfo(1) tg   
INNER JOIN sys.trace_events te ON tg.[eventid] = te.[trace_event_id]  
INNER JOIN sys.trace_columns tc ON tg.[columnid] = tc.[trace_column_id]
```
## [Hidden Gems of DEFAULT TRACE in SQL Server](<https://www.codeproject.com/Articles/1085631/Hidden-Gems-of-DEFAULT-TRACE-in-SQL-Server>)

```
-- The default trace directory:

SELECT [path], start_time, last_event_time, event_count
FROM sys.traces
WHERE is_default = 1

-- what kind of events can be stored in the default trace
SELECT e.trace_event_id, e.name, c.category_id, c.name
FROM sys.trace_categories c
JOIN sys.trace_events e ON c.category_id = e.category_id
```
```
-- track the object changes
SELECT
      EventType = e.name
    , t.DatabaseName
    , t.ApplicationName
    , t.LoginName
    , t.StartTime
    , t.ObjectName
    , ObjectType =
        CASE t.ObjectType
            WHEN 8259 THEN 'Check Constraint'
            WHEN 8260 THEN 'Default Constraint'
            WHEN 8262 THEN 'Foreign Key'
            WHEN 8272 THEN 'Stored Procedure'
            WHEN 8274 THEN 'Rule'
            WHEN 8275 THEN 'System Table'
            WHEN 8276 THEN 'Server Trigger'
            WHEN 8277 THEN 'Table'
            WHEN 8278 THEN 'View'
            WHEN 8280 THEN 'Extended Stored Procedure'
            WHEN 16724 THEN 'CLR Trigger'
            WHEN 16964 THEN 'Database'
            WHEN 17222 THEN 'FullText Catalog'
            WHEN 17232 THEN 'CLR Stored Procedure'
            WHEN 17235 THEN 'Schema'
            WHEN 17985 THEN 'CLR Aggregate Function'
            WHEN 17993 THEN 'Inline Table-valued SQL Function'
            WHEN 18000 THEN 'Partition Function'
            WHEN 18004 THEN 'Table-valued SQL Function'
            WHEN 19280 THEN 'Primary Key'
            WHEN 19539 THEN 'SQL Login'
            WHEN 19543 THEN 'Windows Login'
            WHEN 20038 THEN 'Scalar SQL Function'
            WHEN 20051 THEN 'Synonym'
            WHEN 20821 THEN 'Unique Constraint'
            WHEN 21075 THEN 'Server'
            WHEN 21076 THEN 'Transact-SQL Trigger'
            WHEN 21313 THEN 'Assembly'
            WHEN 21318 THEN 'CLR Scalar Function'
            WHEN 21321 THEN 'Inline scalar SQL Function'
            WHEN 21328 THEN 'Partition Scheme'
            WHEN 21333 THEN 'User'
            WHEN 21572 THEN 'Database Trigger'
            WHEN 21574 THEN 'CLR Table-valued Function'
            WHEN 21587 THEN 'Statistics'
            WHEN 21825 THEN 'User'
            WHEN 21827 THEN 'User'
            WHEN 21831 THEN 'User'
            WHEN 21843 THEN 'User'
            WHEN 21847 THEN 'User'
            WHEN 22601 THEN 'Index'
            WHEN 22611 THEN 'XMLSchema'
            WHEN 22868 THEN 'Type'
        END
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
JOIN sys.trace_events e ON t.EventClass = e.trace_event_id
WHERE e.name IN ('Object:Created', 'Object:Deleted', 'Object:Altered')
    AND t.ObjectType != 21587
    AND t.DatabaseID != 2
    AND i.is_default = 1
    AND t.EventSubClass = 1
```
```
-- server event
SELECT
    CASE WHEN t.EventSubClass = 1
        THEN 'BACKUP' 
        ELSE 'RESTORE'
    END, t.TextData, t.ApplicationName, t.LoginName, t.StartTime
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
WHERE i.is_default = 1
    AND t.EventClass = 115 -- Audit Backup/Restore Event
    
SELECT
      t.StartTime
    , [Type] = CASE WHEN EventSubClass = 1 THEN 'UP' ELSE 'DOWN' END
    , t.IntegerData
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
WHERE t.EventClass = 81 -- Server Memory Change
    AND i.is_default = 1
```