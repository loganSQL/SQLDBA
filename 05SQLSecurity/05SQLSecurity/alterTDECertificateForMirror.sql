/*
	Steps to change the TDE certificate for database mirroring
*/
/*
Furthermore:
Setting up Database mirroring in SQL Server 2008 using T-SQL when the database is encrypted using Transparent Data Encryption
https://blogs.msdn.microsoft.com/sqlserverfaq/2009/03/31/setting-up-database-mirroring-in-sql-server-2008-using-t-sql-when-the-database-is-encrypted-using-transparent-data-encryption/
*/

/*********************************
On Principal Server
*********************************/
USE Master
go

select name,expiry_date,* from sys.certificates
go

drop certificate LoganSQL_Certificate
go

select * from sys.symmetric_keys
go
--Drop the existing Master Key

Use Master
GO

DROP MASTER KEY
Go


Create master key encryption
by password='MyPassword'
go

-- OPEN MASTER KEY DECRYPTION BY PASSWORD = 'MyPassword'

CREATE CERTIFICATE LoganSQL_Old_Certificate WITH SUBJECT = 'LoganSQL_Old_Certificate'
go

BACKUP CERTIFICATE LoganSQL_Old_Certificate
To FILE = 'C:\MyCerts\LoganSQL_Old_Certificate'
WITH PRIVATE KEY (file='C:\MyCerts\LoganSQL_Old_CertKey',
ENCRYPTION BY PASSWORD='LoganSQLMyPassword')
go


CREATE CERTIFICATE LoganSQL_New_Certificate WITH SUBJECT = 'LoganSQL_New_Certificate', expiry_date='12/31/2023'
go

BACKUP CERTIFICATE LoganSQL_New_Certificate
To FILE = 'C:\MyCerts\LoganSQL_NEW_Certificate'
WITH PRIVATE KEY (file='C:\MyCerts\LoganSQL_NEW_CertificateKey',
ENCRYPTION BY PASSWORD='LoganSQLMyPassword')
go

USE TestDB
go

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE LoganSQL_Old_Certificate
GO

use master
go
alter database TestDB set encryption on
go

SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
	   key_algorithm AS key_algorithm, key_length AS key_length, 
	   pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

use master
go

alter database TestDB set encryption off
go


use TestDB
go

DROP DATABASE ENCRYPTION KEY
go

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE LoganSQL_New_Certificate
GO

/* do a transaction log backup to finish log scan */

use master
go

alter database TestDB set encryption on
go

/************************
On Mirror Server
*************************/
USE Master

go
select name,expiry_date,* from sys.certificates
go
select * from sys.symmetric_keys
go

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'MyPassword'
go

drop certificate LoganSQL_Old_Certificate
go

CREATE CERTIFICATE LoganSQLMirror_Old_Certificate
FROM FILE = 'C:\MyCerts\LoganSQL_Old_Certificate'
WITH PRIVATE KEY (file='C:\MyCerts\LoganSQL_Old_CertKey',
DECRYPTION BY PASSWORD='LoganSQLMyPassword')
go

CREATE CERTIFICATE LoganSQLMirror_New_Certificate
To FILE = 'C:\MyCerts\LoganSQL_NEW_Certificate'
WITH PRIVATE KEY (file='C:\MyCerts\LoganSQL_NEW_CertificateKey',
ENCRYPTION BY PASSWORD='LoganSQLMyPassword')
go




SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
	   key_algorithm AS key_algorithm, key_length AS key_length, 
	   pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go