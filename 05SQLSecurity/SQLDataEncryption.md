# SQL Data Encryption
[SQL Server Encryption](<https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/sql-server-encryption?view=sql-server-2017>)

[Encryption Hierarchy](<https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/encryption-hierarchy?view=sql-server-2017>)

[Cryptographic functions (Transact-SQL)](<https://docs.microsoft.com/en-us/sql/t-sql/functions/cryptographic-functions-transact-sql?view=sql-server-2017>)

 The key is to use a symmetric key with a specified password. Given a choice between symmetric and asymmetric keys (to include certificates), encryption via symmetric key algorithms is significantly quicker. However, most examples show the symmetric key being encrypted by a certificate or asymmetric key which is in turn encrypted by the database master key. Since the DBAs control the database master key, they can easily unlock the chain of keys and therefore they are able to decrypt the data.

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

