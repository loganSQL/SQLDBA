/*
To test the backup compression with TDE on TestBigDB database 
*/
-- get a list of databases and certificates used
SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
     key_algorithm AS key_algorithm, c.key_length AS key_length, 
     pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date, dek.encryption_state
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'XXXXX'
go

use master
go
ALTER DATABASE TestBigDB
SET ENCRYPTION ON;
GO

-- check progress of database encryption scan (maybe take some time)
-- check errorlog for the spid 
select * from sys.dm_database_encryption_keys
go

-- get a list of databases and certificates used
SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
     key_algorithm AS key_algorithm, key_length AS key_length, 
     pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go   

select * from sys.databases where name='TestBigDB'
select encryption_state,percent_complete 
from sys.dm_database_encryption_keys 
where database_id=17


/*
It is important to know that while backing up a TDE-enable database, 
the compression will kick in ONLY if MAXTRANSFERSIZE is specified in the BACKUP command. 
Moreover, the value of MAXTRANSFERSIZE must be greater than 65536 (64 KB). 

The minimum value of the MAXTRANSFERSIZE parameter is 65536, and if you specify MAXTRANSFERSIZE = 65536 in the BACKUP command, 
then compression will not kick in. It must be “greater than” 65536. 

In fact, 65537 will do just good. It is recommended that you determine your optimum MAXTRANSFERSIZE through testing, 
based on your workload and storage subsystem. The default value of MAXTRANSFERSIZE for most devices is 1 MB, however, 

if you rely on the default, and skip specifying MAXTRANSFERSIZE explicitly in your BACKUP command, 
compression will be skipped.
*/
/*
https://docs.microsoft.com/en-us/sql/t-sql/statements/backup-transact-sql?view=sql-server-ver15
--Data Transfer Options
   BUFFERCOUNT = { buffercount | @buffercount_variable }
 | MAXTRANSFERSIZE = { maxtransfersize | @maxtransfersize_variable }

 MAXTRANSFERSIZE = { maxtransfersize | @ maxtransfersize_variable } 
 Specifies the largest unit of transfer in bytes to be used between SQL Server and the backup media. 
 The possible values are multiples of 65536 bytes (64 KB) ranging up to 4194304 bytes (4 MB).

 Try 1 MB
 MAXTRANSFERSIZE = 1048576
*/
-- Backup FN database which is TDE-enabled on SQL 2016
-- with MAXTRANSFERSIZE = 1048576 (1MB)
-- with Compression
BACKUP DATABASE [FN] TO  DISK = N'E:\temp\TestBigDB_backup_2019_11_14_Compress_With_TDE.bak' 
WITH NOFORMAT, NOINIT,  
NAME = N'TestBigDB_backup_2019_11_14_Compress_With_TDE', 
MAXTRANSFERSIZE = 1048576,
SKIP, REWIND, NOUNLOAD, COMPRESSION,  
STATS = 10 
GO 


SELECT 
@@SERVERNAME AS Server, 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
msdb.dbo.backupset.expiration_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
msdb.dbo.backupset.backup_size,
msdb.dbo.backupset.compressed_backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name, 
msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1) 
and backupset.type='D'
go