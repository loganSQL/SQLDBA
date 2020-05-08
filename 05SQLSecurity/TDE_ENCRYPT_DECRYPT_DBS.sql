-- This script is to encrypt / decrypt all the databases
use master
go

-- open master key for use
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'xxx'
go

/***********************************************
   PART 1: Decrypt all the encrypted databases
************************************************/
-- get a list of databases and certificates used
SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
	 -- 'ALTER DATABASE '+Db_name(dek.database_id)+' SET ENCRYPTION OFF;' as off_command,
	 -- 'USE '+Db_name(dek.database_id)+'; DROP DATABASE ENCRYPTION KEY;' as drop_command,
     key_algorithm AS key_algorithm, key_length AS key_length, 
     pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

-- get a list of databases and certificates used, the encrypt_off_command, drop_encrypt_key_command
SELECT @@servername AS server_name,
       Db_name(dek.database_id) AS encrypted_database ,c.name AS Certificate_Name , 
	  'ALTER DATABASE '+Db_name(dek.database_id)+' SET ENCRYPTION OFF;' as off_command,
	  'USE '+Db_name(dek.database_id)+'; DROP DATABASE ENCRYPTION KEY;' as drop_command,
     key_algorithm AS key_algorithm, key_length AS key_length, 
     pvt_key_last_backup_date, create_date AS create_date, expiry_date AS expiry_date
FROM   sys.certificates c 
       INNER JOIN sys.dm_database_encryption_keys dek 
         ON c.thumbprint = dek.encryptor_thumbprint
go

-- run all the encrypt_off_command
ALTER DATABASE MyDB01 SET ENCRYPTION OFF;
ALTER DATABASE MyDB02 SET ENCRYPTION OFF;
ALTER DATABASE MyDBnN SET ENCRYPTION OFF;
-- this can take time
-- check status
select db.name, dek.encryption_state,dek.percent_complete 
from sys.dm_database_encryption_keys dek, sys.databases db
where dek.database_id=db.database_id

-- when all percent_complete = 0
-- run all the drop encryption key commands
USE MyDB01; DROP DATABASE ENCRYPTION KEY;
USE MyDB02; DROP DATABASE ENCRYPTION KEY;
USE MyDBnN; DROP DATABASE ENCRYPTION KEY;


/***********************************************
   PART 2: Encrypt all the user databases
************************************************/
use master
go

-- open master key for use
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'xxx'
go

CREATE CERTIFICATE LoganSQL_SQL_Cert WITH SUBJECT = 'LoganSQL SQL Cert', expiry_date='20231231'
go

-- backup 
BACKUP CERTIFICATE LoganSQL_SQL_Cert
To FILE = 'C:\MyCerts\LoganSQL_SQL_Cert'
WITH PRIVATE KEY (file='C:\MyCerts\LoganSQL_SQL_Cert_Key',
ENCRYPTION BY PASSWORD='xxx')
go

BACKUP MASTER KEY TO FILE = 'C:\MyCerts\LoganSQL_Master_Key'   
    ENCRYPTION BY PASSWORD = 'xxx'
go  

use Camelot
go

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE LoganSQL_SQL_Cert
go

-- get create_encryption_key_commands, alter_encryption_key_on_command

select name, 
'use '+name+'; CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE LoganSQL_SQL_Cert ' as create_encryption_key_commands,
'use master; ALTER DATABASE '+name+' SET ENCRYPTION ON;' as alter_encryption_key_on_command
from sysdatabases where dbid>6

-- run create_encryption_key_commands
use MyDB01 CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE LoganSQL_SQL_Cert 
use MyDB02; CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE LoganSQL_SQL_Cert 
use MyDBnN; CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE LoganSQL_SQL_Cert 

-- run alter_encryption_key_on_command
use master; ALTER DATABASE MyDB01 SET ENCRYPTION ON;
use master; ALTER DATABASE MyDB02 SET ENCRYPTION ON;
use master; ALTER DATABASE MyDBnN SET ENCRYPTION ON;

-- check status
select db.name, dek.encryption_state,dek.percent_complete 
from sys.dm_database_encryption_keys dek, sys.databases db
where dek.database_id=db.database_id