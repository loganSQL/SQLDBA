# Microsoft SQL Transparent Database Encryption Notes
## Overview
[Understanding Transparent Data Encryption (TDE)](<https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/bb934049(v%3dsql.105)>)

## Steps
use TDE, follow these steps.
* Create a master key
* Create or obtain a certificate protected by the master key
* Create a database encryption key and protect it by the certificate
* Set the database to use encryption

## Scripts

### 1. Meta Data
    -- check keys
    select * from sys.symmetric_keys
    go
    
    -- check certificates
    select name,expiry_date,* from sys.certificates
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
    
    -- see encryption percent_complete
    select * from sys.dm_database_encryption_keys
    go

### 2. Instance Setup (Primary: MasterKey, Certificate)
    -- Drop master / recreate if forgetting pwd
    use master
    go
    DROP MASTER KEY
    go
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MyMasterKeyPassword';
    go


    -- open master key for use
    OPEN MASTER KEY DECRYPTION BY PASSWORD = 'MyMasterKeyPassword'
    go

    -- create a new certificate with exipry date
    CREATE CERTIFICATE LoganSQL_Cert WITH SUBJECT = 'Logan SQL Cert', expiry_date='12/31/2023'
    go
    
    -- backup 
    BACKUP CERTIFICATE LoganSQL_Cert
    To FILE = 'C:\DBCerts\LoganSQL_Cert'
    WITH PRIVATE KEY (file='C:\DBCerts\LoganSQL_CertKey',
    ENCRYPTION BY PASSWORD='MyPrivateKeyPassword')
    go
    
    -- don't forget to backup master database!!!
### 3. Instance Setup (Secondary: Obtain the certificate from Primary)    
    -- restore to DR server 
    -- Please copy the file over first.

    -- copy \\LoganSQLPrimary\C$\\DBCerts\* \\LoganSQLDR\C$\\DBCerts\
    --
    USE MASTER
    go
    
    OPEN MASTER KEY DECRYPTION BY PASSWORD = 'MyDRMasterKeyPassword'
    go
    
    -- drop the old cert
    drop certificate LoganSQLDR_Certificate
    go
  
    CREATE CERTIFICATE LoganSQLDR_Certificate
    From FILE = 'C:\DBCerts\2018\LoganSQL_Cert'
    WITH PRIVATE KEY (file='C:\DBCerts\2018\LoganSQL_CertKey',
    DECRYPTION BY PASSWORD='MyPrivateKeyPassword')
    go

    -- don't forget to backup master database!!!
    
### 4. Database Encryption
    /*
      Encrypt testdb
    */     
    use testdb
    go
    
    -- create a database encryption key and protected by the master key
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE LoganSQL_Cert
    GO       
    
    -- Set database to use encryption
    use master
    go
    ALTER DATABASE testdb
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
    
### 5. Database Certificate Replacement (ongoing maintenance)
    /*
      replace cert on testdb
    */
    
    -- turn off original encryption
    USE master
    GO
    
    alter database testdb set encryption off
    go
    
    -- check progress of database encryption scan
    -- you have to wait until the scan completes before proceeding
    select * from sys.dm_database_encryption_keys
    
    -- drop encryption
    use testdb
    go
    
    DROP DATABASE ENCRYPTION KEY
    go
    
    -- Associate the new certificate to Database
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE LoganSQL_Cert
    GO
    
    
    
    -- Enable Encryption the database
    use master
    go
    ALTER DATABASE testdb
    SET ENCRYPTION ON;
    GO
    
    -- For database mirroring, it should be automatically sync on DR
    -- provided the new cert has been restored on DR
    -- backup transaction log here.