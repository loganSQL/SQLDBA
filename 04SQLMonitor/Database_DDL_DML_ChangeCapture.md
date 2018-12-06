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