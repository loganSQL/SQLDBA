# SQL Data Encryption
[SQL Server Encryption](<https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/sql-server-encryption?view=sql-server-2017>)

[Encryption Hierarchy](<https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/encryption-hierarchy?view=sql-server-2017>)

[Cryptographic functions (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/t-sql/functions/cryptographic-functions-transact-sql?view=sql-server-2017>)

SQL Server symmetric key encryption can encrypt encrypting a column in a table. The key is to use a symmetric key with a specified password. Given a choice between symmetric and asymmetric keys (to include certificates), encryption via symmetric key algorithms is significantly quicker. 

SQL Server has an encryption hierarchy that needs to be followed in order to support the encryption capabilities. It is the same process as the transparent database encryption (TDE)

## 1. Using Self-Signed SQL Server Certificate (protected by database master key)
### 1.1. SQL Server Service Master Key
The Service Master Key is the root of the SQL Server encryption hierarchy. It is created during the instance creation.
```
USE master;
GO
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##';
GO
```
### 1.2. SQL Server Database Master Key
The next step is to create a database master key. This is accomplished using the CREATE MASTER KEY method. The "encrypt by password" argument is required and defines the password used to encrypt the key. The DMK does not directly encrypt data, but provides the ability to create keys that are used for data encryption. It is important that you keep the encryption password in a safe place and/or keep backups of your SQL Server Database Master Key.
```
-- Create database Key
USE DatabaseABC;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'December2012';
GO

-- check the key in This DB
SELECT * FROM sys.symmetric_keys
```

### 1.3. Create a Self Signed SQL Server Certificate
The next step is to create a self-signed certificate that is protected by the database master key. A certificate is a digitally signed security object that contains a public (and optionally a private) key for SQL Server. An optional argument when creating a certificate is ENCRYPTION BY PASSWORD. This argument defines a password protection method of the certificate's private key. In our creation of the certificate we have chosen to not include this argument; by doing so we are specifying that the certificate is to be protected by the database master key.
```
-- Create self signed certificate
USE DatabaseABC;
GO
CREATE CERTIFICATE CertificateABC
WITH SUBJECT = 'To protect Company ABC data';
GO

-- check
select * from sys.certificates
```

### 1.4. SQL Server Symmetric Key in A Database
A symmetric key is one key that is used for both encryption and decryption. Encryption and decryption by using a symmetric key is fast, and suitable for routine use with sensitive data in the database.

```
-- Create symmetric Key
USE DatabaseABC;
GO
CREATE SYMMETRIC KEY SymmetricKeyABC 
 WITH ALGORITHM = AES_128 
 ENCRYPTION BY CERTIFICATE CertificateABC;
GO

-- check
SELECT * FROM sys.symmetric_keys
```
### 1.5. Encrypt the Columns on a Table in a Database

```
USE DatabaseABC;
GO
-- Create Table first
CREATE TABLE dbo.Customer_data
(Customer_id int constraint Pkey3 Primary Key NOT NULL,
Customer_Name varchar(100) NOT NULL,
Credit_card_number varchar(25) NOT NULL)
-- Populate Table
INSERT INTO dbo.Customer_data 
VALUES (74112,'User1','2147-4574-8475')
GO
INSERT INTO dbo.Customer_data 
VALUES (74113,'User2','4574-8475-2147')
GO
INSERT INTO dbo.Customer_data 
VALUES (74114,'User3','2147-8475-4574')
GO
INSERT INTO dbo.Customer_data 
VALUES (74115,'User4','2157-1544-8875')
GO
-- Verify data
SELECT * FROM dbo.Customer_data
GO

--  Add new column
ALTER TABLE Customer_data 
ADD Credit_card_number_encrypt varbinary(MAX) NULL
GO

-- Encrypt data from existing column to new column
-- Opens the symmetric key for use
OPEN SYMMETRIC KEY SymmetricKeyABC
DECRYPTION BY CERTIFICATE CertificateABC;
GO
UPDATE Customer_data
SET Credit_card_number_encrypt = EncryptByKey (Key_GUID('SymmetricKeyABC'),Credit_card_number)
FROM dbo.Customer_data;
GO
-- Closes the symmetric key
CLOSE SYMMETRIC KEY SymmetricKeyABC;
GO

-- Remove old column
ALTER TABLE Customer_data
DROP COLUMN Credit_card_number;
GO

-- Verify data
SELECT * FROM dbo.Customer_data
GO

-- Add new records
OPEN SYMMETRIC KEY SymmetricKeyABC
DECRYPTION BY CERTIFICATE CertificateABC;
-- Performs the update of the record
INSERT INTO dbo.Customer_data (Customer_id, Customer_Name, Credit_card_number_encrypt)
VALUES (25665, 'User5', EncryptByKey( Key_GUID('SymmetricKeyABC'), CONVERT(varchar,'4545-58478-1245') ) );    
GO


-- Access the encrypted data as a user
Execute as user='test'
GO
SELECT Customer_id, Credit_card_number_encrypt AS 'Encrypted Credit Card Number',
CONVERT(varchar, DecryptByKey(Credit_card_number_encrypt)) AS 'Decrypted Credit Card Number'
FROM dbo.Customer_data;

revert
-- grant permissions on encrypted data
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymmetricKeyABC TO test; 
GO
GRANT VIEW DEFINITION ON Certificate::CertificateABC TO test;
GO

-- execute as user='test' again


-- close
CLOSE SYMMETRIC KEY SymmetricKeyABC;
GO
```

## Using Symetric Key Protected By Password
The above example shows the symmetric key being encrypted by a certificate or asymmetric key which is in turn encrypted by the database master key. 

Since the DBAs control the database master key, they can easily unlock the chain of keys and therefore they are able to decrypt the data.

To prevent this, we never allow the symmetric key to be encrypted by this chain of keys. Instead, we specify a password, one known to the application. When a password is specified, SQL Server will take appropriate steps to shield the password from the standard DBA toolset. As a result, we can rely on encryption of the symmetric key via a password to keep the DBAs' eyes off the data.

```
-- keys always store in master db
use master

select * from sys.symmetric_keys

-- this key won't be protected by certificate
CREATE SYMMETRIC KEY DataEncrypt
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'December2018';

select * from sys.symmetric_keys

-- encrypt data using the key
CREATE TABLE dba.dbo.SecretData (
  SecretCol VARBINARY(128)
);
GO 

use master
go

OPEN SYMMETRIC KEY DataEncrypt
DECRYPTION BY PASSWORD = 'December2018';
GO 


INSERT INTO DBA.dbo.SecretData
(SecretCol)
VALUES
(ENCRYPTBYKEY(KEY_GUID('DataEncrypt'), 'Number 1 billion'));
GO 

SELECT CONVERT(VARCHAR(MAX), DECRYPTBYKEY([SecretCol]))
FROM DBA.[dbo].[SecretData]


-- Close the symmetric key, which simulates the DBA not having the
-- ability to use it because he/she doesn't have the password
CLOSE SYMMETRIC KEY DataEncrypt;
GO 

select * from DBA.dbo.SecretData

OPEN SYMMETRIC KEY DataEncrypt
DECRYPTION BY PASSWORD = 'December2018'

select count(*) from DBA.dbo.SecretData

SELECT CONVERT(VARCHAR(MAX), DECRYPTBYKEY([SecretCol]))
FROM DBA.[dbo].[SecretData]

CLOSE SYMMETRIC KEY DataEncrypt;
GO 
```
[SQL Server Encryption To Block DBAs Data Access](<https://www.mssqltips.com/sqlservertip/2840/sql-server-encryption-to-block-dbas-data-access/>)
But wait. For all these troubles, DBA should be able to just drop the symmetric key.
```
use master
go
drop SYMMETRIC KEY DataEncrypt
drop table DBA.dbo.SecretData
```

