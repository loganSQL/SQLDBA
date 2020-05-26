-- When try to set DB to multi_user 
/*Msg 5064, Level 16, State 1, Line 1
Changes to the state or options of database 'YOUR_DATABASE' cannot be made at this time. The database is in single-user mode, and a user is currently connected to it.
Msg 5069, Level 16, State 1, Line 1
ALTER DATABASE statement failed.
*/

ALTER DATABASE YOURDATABASE
SET MULTI_USER WITH ROLLBACK IMMEDIATE;

--  find the locking user
SELECT request_session_id FROM sys.dm_tran_locks 
WHERE resource_database_id = DB_ID('YourDatabase')

-- kill it
