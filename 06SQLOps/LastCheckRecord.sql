select  @@SERVERNAME as server, getdate() as runtime

--EXEC sp_MSforeachdb 'USE ? SELECT ''?'', SF.filename, SF.size FROM sys.sysfiles SF'

-- create a table to record the last check time per database
EXEC sp_MSforeachdb 'USE ? SELECT ''?'' as db, @@SERVERNAME as server, getdate() as runtime into dba_xyz_checkpoint'

-- query them
EXEC sp_MSforeachdb 'USE ? SELECT * from dba_xyz_checkpoint'

-- drop the table (clean up)
EXEC sp_MSforeachdb 'USE ? drop table dba_xyz_checkpoint'

