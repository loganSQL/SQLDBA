/*
	Restore an encrypted database with Transparent Data Encryption
	Ref: https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/transparent-data-encryption
	Attn: https://simonmcauliffe.com/technology/tde/

*/

/*


The solution here is to encrypt the sensitive data in the database and protect the keys that are used to encrypt the data with a certificate. 
This prevents anyone without the keys from using the data, but this kind of protection must be planned in advance. 

TDE performs real-time I/O encryption and decryption of the data and log files. The encryption uses a database encryption key (DEK), 
which is stored in the database boot record for availability during recovery. 

The DEK is a symmetric key secured by using a certificate stored in the master database of the server 
or an asymmetric key protected by an EKM module. TDE protects data "at rest", meaning the data and log files. 
(https://docs.microsoft.com/en-us/sql/relational-databases/security/sql-server-certificates-and-asymmetric-keys)

It provides the ability to comply with many laws, regulations, and guidelines established in various industries. 
This enables software developers to encrypt data by using AES and 3DES encryption algorithms without changing existing applications. 

TDE does not provide encryption across communication channels. 
(https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/enable-encrypted-connections-to-the-database-engine)

Encryption of the database file is performed at the page level. The pages in an encrypted database are encrypted before they are written to disk and decrypted when read into memory. 
TDE does not increase the size of the encrypted database. 

When using TDE with SQL Database V12 the server-level certificate stored in the master database is automatically created for you by SQL Database. 
To move a TDE database on SQL Database you must decrypt the database, move the database, 
and then re-enable TDE on the destination SQL Database.
*/

-- Step 1: Additional files that should be obtained in order to restore the database on another server


USE master;
GO
BACKUP MASTER KEY TO FILE = '<Master Key File>.key' 
ENCRYPTION BY PASSWORD = 'The backup password for the master key!'
GO
BACKUP CERTIFICATE MyServerCert TO FILE = '<Certificate File>.cer' 
WITH PRIVATE KEY (
FILE = '<Private Key File>.key', 
ENCRYPTION BY PASSWORD = 'The backup password for the private key!'
);
GO

-- Step 2: How to prepare the target server to restore the encrypted database

USE master;
GO
RESTORE MASTER KEY FROM FILE = '<Master Key File>.key' 
DECRYPTION BY PASSWORD = 'The backup password for the master key!' 
ENCRYPTION BY PASSWORD = '<UseStrongPasswordHere>'
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<UseStrongPasswordHere>'
GO
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY
GO
CREATE CERTIFICATE MyServerCert
FROM FILE = '<Certificate File>.cer'
WITH PRIVATE KEY (
FILE = '<Private Key File>.key',
DECRYPTION BY PASSWORD = 'The backup password for the private key!'
);
GO

-- Remarks: In case the target server has already a Master Key defined and/or the certificate MyServerCert defined, 
-- the steps below will be used to reset them:

USE master;
GO
DROP CERTIFICATE MyServerCert
GO
DROP MASTER KEY
GO


/*
	Sample
*/
USE master; 
GO 
BACKUP CERTIFICATE TDECert1
TO FILE = 'E:\Backup\certificate_TDE_Test_Certificate.cer'
WITH PRIVATE KEY
(FILE = 'E:\Backup\certificate_TDE_Test_Key.pvk',
ENCRYPTION BY PASSWORD = 'Password12#')

-- Create a Master Key in destination server.
-- The password provided here is different from the one we used in the source server 
-- since we are creating a new master key for this server.
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'D1ffPa$$w0rd'

--After a master key has been created, create a certificate by importing the certificate we created earlier. 
-- Here the ‘Decryption By Password’ parameter is same as that provided to export the certificate to a file.
CREATE CERTIFICATE TDECert2
FROM FILE = 'E:\cert_Backups\ certificate_TDE_Test_Certificate.cer'     
WITH PRIVATE KEY (FILE = 'E:\cert_Backups\certificate_TDE_Test_Key.pvk', 
DECRYPTION BY PASSWORD = 'Password12#')

-- Restore Database in destination server
-- We will now be able to restore the encrypted database backup successfully.
USE [master]
RESTORE DATABASE [TDE_Test] FROM  DISK = N'F:\Backup\TDE_Test_withtde.bak' 
WITH  FILE = 1, NOUNLOAD,  REPLACE,  STATS = 5
