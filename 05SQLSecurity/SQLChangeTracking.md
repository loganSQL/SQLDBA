# SQL Server Change Tracking
## Prerequisite
* The database compatibility level must be set to 90 or greater 
* The tables you want to audit must have a primary key defined.
* Recommended: enable snapshot isolation (to ensure change tracking information consistency)

```
-- Enable snapshot isolation
ALTER DATABASE AdventureWorks
SET READ_COMMITTED_SNAPSHOT ON
GO

ALTER DATABASE AdventureWorks
SET ALLOW_SNAPSHOT_ISOLATION ON
GO
```
## Step 1: Enable Change Tracking on the database

To enable Change Tracking in SQL Server Management Studio

* Right click the database in Object Explorer
* Select Properties
* Select the Change Tracking tab
* Set the parameters

```
ALTER DATABASE AdventureWorks
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 5 DAYS, AUTO_CLEANUP = ON)
```

## Step 2: Enable Change Tracking for each table you want to audit
* Table Property

```
ALTER TABLE Person.Address
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON)
```
Now, all table row changes invoked by INSERT, DELETE, or UPDATE statements will be tracked and stored.

SQL Server Change Tracking shows only the primary key column value for the changed rows, and the type of change – INSERT, DELETE, or UPDATE. 
## Step 3: Read Change Tracking Results
### Change tracking functions
* The ***CHANGETABLE(CHANGES)*** function shows all changes to a table that have occurred after the specified version number. A version number is associated with each changed row. Whenever there is a change on a table where Change tracking is enabled, the database version number counter is increased

* The ***CHANGETABLE (VERSION)*** function “returns the latest change tracking information for a specified row

### How
```
SELECT * FROM CHANGETABLE(CHANGES <table_name>, <version>) AS ChTbl
```
Note that the table used in the CHANGETABLE function has to be aliased!!!
```
--Note that the table used in the CHANGETABLE function has to be aliased!!!
SELECT * FROM CHANGETABLE(CHANGES Person.Address, 1) AS ChTb1
```
The CHANGE_TRACKING_CURRENT_VERSION() function retrieves the current version number, i.e. the version number of the last committed transaction (then you have MinVersion to this number to track!)
```
SELECT NewTableVersion =  CHANGE_TRACKING_CURRENT_VERSION()
```
```
SELECT MinVersion = 
CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person.Address')) 
```
### Detail
```
-- 1. Execute, first version
SELECT TableVersion = CHANGE_TRACKING_CURRENT_VERSION();
SELECT * FROM Person.Address;


-- 2. Modify the records in the Person.Address table
-- update
-- insert
-- delete

-- 3. To read the Change Tracking results

SELECT
NewTableVersion = CHANGE_TRACKING_CURRENT_VERSION()

SELECT
ChVer = SYS_CHANGE_VERSION,
ChCrVer = SYS_CHANGE_CREATION_VERSION,
ChOp = SYS_CHANGE_OPERATION,
AddressID
FROM CHANGETABLE(CHANGES Person.Address, 1) AS ChTbl;

-- 4. Tracking individual column updates
SELECT
ChVer = SYS_CHANGE_VERSION,
ChCrVer = SYS_CHANGE_CREATION_VERSION,
ChOp = SYS_CHANGE_OPERATION,
AddLine1_Changed = CHANGE_TRACKING_IS_COLUMN_IN_MASK
    (COLUMNPROPERTY(OBJECT_ID('Person.Address'), 'AddressLine1', 'ColumnId')
    ,ChTbl.sys_change_columns),
AddLine2_Changed = CHANGE_TRACKING_IS_COLUMN_IN_MASK
    (COLUMNPROPERTY(OBJECT_ID('Person.Address'), 'AddressLine2', 'ColumnId')
    ,ChTbl.sys_change_columns),
AddressID
FROM CHANGETABLE(CHANGES Person.Address, 1) AS ChTbl;
```
[How to read SQL Server Change Tracking results](<https://solutioncenter.apexsql.com/reading-sql-server-change-tracking-results/>)
## Some takeaway
The Change Tracking feature is not designed to return all information about the changes you might need, **it’s designed to be a light auditing solution that indicates whether the row has been changed or not. It shows the ID of the row changed, even the specific column that is changed.** What this feature doesn’t provide are the details about the change. You can match the change information to the database snapshot and the live database to find out more about the changes, but this requires additional coding and still doesn’t bring all the information that might be needed for auditing

**Change tracking doesn’t answer the “who”, “when”, and “how” questions.** Also, if there were multiple changes on a specific row, only the last one is shown. There is no user-friendly GUI that displays the results in just a couple of clicks. To see the change tracking records, you have to write code and use change tracking functions

**The execution of the SELECT statements and database object access is not tracked.** These events have nothing to do with data changes, but as SQL DBAs request these features when it comes to auditing, it should be mentioned

