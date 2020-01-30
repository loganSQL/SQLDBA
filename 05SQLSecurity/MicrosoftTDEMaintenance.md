# TDE maintenance Tasks
## [1. Rotating TDE Certificates without re-encrypting data](https://matthewmcgiffen.com/2018/03/28/rotating-tde-certificates-without-re-encrypting-data/)
## [2. TDE – Regenerating the Database Encryption Key](https://matthewmcgiffen.com/2018/04/03/tde-regenerating-the-database-encryption-key/)


-- check MasterKey
select @@SERVERNAME, * from sys.symmetric_keys
go

-- check certificate
select name, certificate_id, pvt_key_encryption_type_desc, start_date, expiry_date,pvt_key_last_backup_date from sys.certificates where name not like '##%##'
go

-- check database which certificate in use
SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
     key_algorithm AS key_algorithm, key_length AS key_length, 
     pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

-- use old password
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'CurrentPassword'
go

-- create a new certificate with expiry date
CREATE CERTIFICATE LoganSQL_Cert_2020
WITH SUBJECT = 'LoganSQL_Cert_2020',
EXPIRY_DATE = '20201231'

-- backup
USE Master
GO

-- backup master key
-- password for keyfile
BACKUP MASTER KEY TO FILE = 'C:\DBCerts\LoganSQL_Master_Key'   
    ENCRYPTION BY PASSWORD = 'MyBackupPassword'
go

-- backup certificate
-- password for keyfile: MyBackupPassword1
BACKUP CERTIFICATE LoganSQL_Cert_2020
To FILE = 'C:\DBCerts\LoganSQL_Cert_2020'
WITH PRIVATE KEY (file='C:\DBCerts\LoganSQL_Cert_2020_Key',
ENCRYPTION BY PASSWORD='MyBackupPassword1')
Go

/*
-- make sure to copy LoganSQL_Cert_2020 to sql instance: LoganSQLDR
-- For Database Mirroring or AG
-- this is on LoganSQLDR
CREATE CERTIFICATE LoganSQL_Cert_2020
From FILE = 'C:\DBCerts\LoganSQL_Cert_2020'
WITH PRIVATE KEY (file='C:\DBCerts\LoganSQL_Cert_2020_Key',
DECRYPTION BY PASSWORD='MyBackupPassword1')
go
*/

-- to rotate the certificate for database encryption
-- get the following and run one by one
-- rotate certificate doesn't need to scan for encryption because no password change yet
-- like:
-- use MyTest;	
-- ALTER DATABASE ENCRYPTION KEY  ENCRYPTION BY SERVER CERTIFICATE LoganSQL_Cert_2020;

SELECT 'use '+ Db_name(dek.database_id)+';',
'ALTER DATABASE ENCRYPTION KEY
ENCRYPTION BY SERVER CERTIFICATE LoganSQL_Cert_2020;' as commands
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

-- Now it is change the master key with new password
-- this will cause all the related database rescan one by one
-- new password My2020Password

ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'My2020Password';
go

-- New use the new password
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'My2020Password'
go

-- check
select * from sys.dm_database_encryption_keys
go

-- backup Again
USE Master
GO

-- backup master key
-- password for keyfile
BACKUP MASTER KEY TO FILE = 'C:\DBCerts\LoganSQL_Master_Key'   
    ENCRYPTION BY PASSWORD = 'MyBackupPassword'
go

-- backup certificate
-- password for keyfile: MyBackupPassword1
BACKUP CERTIFICATE LoganSQL_Cert_2020
To FILE = 'C:\DBCerts\LoganSQL_Cert_2020'
WITH PRIVATE KEY (file='C:\DBCerts\LoganSQL_Cert_2020_Key',
ENCRYPTION BY PASSWORD='MyBackupPassword1')
Go
