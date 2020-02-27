/*
Filesystem security for TDE Keys and Certificates
https://www.sqlserverscience.com/security/data-security/filesystem-security-tde-keys-certificates/?utm_medium=referral&utm_source=dba.stackexchange.com&utm_campaign=233040
*/

-- How to backup Keys and Certificates
BACKUP SERVICE MASTER KEY TO FILE = N'D:\SQLServer\Backups\Service_Master_Key.key'
ENCRYPTION BY PASSWORD = N'#GobsNicuTestaSweden7';
 
BACKUP MASTER KEY TO FILE = N'D:\SQLServer\Backups\Master_Key.key'
ENCRYPTION BY PASSWORD = N'#BlotchOwenLonganOrly8';
 
BACKUP CERTIFICATE TDETestCert 
TO FILE = N'D:\SQLServer\Backups\TDETestCert.cert'
WITH PRIVATE KEY (
    FILE = N'D:\SQLServer\Backups\TDETestCert.key'
    , ENCRYPTION BY PASSWORD = N'=BebopAcetalCareReims1'
    );

-- ALTER MASTER KEY
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-master-key-transact-sql?view=sql-server-2017

ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'password';

/*
The REGENERATE option re-creates the database master key and all the keys it protects. 
The keys are first decrypted with the old master key, and then encrypted with the new master key. 
This resource-intensive operation should be scheduled during a period of low demand, 
unless the master key has been compromised.
*/