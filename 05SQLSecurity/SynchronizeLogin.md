# SQL Login Synchronization
## Script out all SQL logins
```
--Generate all sql logins
SELECT 'IF(SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN '+QUOTENAME(SP.name)+
       CASE WHEN SP.type_desc = 'SQL_LOGIN'
            THEN ' WITH PASSWORD = '+CONVERT(NVARCHAR(MAX),SL.password_hash,1)+' HASHED'
            ELSE ' FROM WINDOWS'
       END + ';/*'+SP.type_desc+'*/ END;' 
       COLLATE SQL_Latin1_General_CP1_CI_AS
  FROM sys.server_principals AS SP
  LEFT JOIN sys.sql_logins AS SL
    ON SP.principal_id = SL.principal_id
 WHERE SP.type_desc ='SQL_LOGIN'
   AND SP.name NOT LIKE '##%##' 
   AND SP.name NOT IN ('SA');
```
This will generate a list login creation sql scripts with passwords.
## Script out all Windows Logins
```
SELECT 'IF(SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL)BEGIN CREATE LOGIN '+QUOTENAME(SP.name)+
       CASE WHEN SP.type_desc = 'SQL_LOGIN'
            THEN ' WITH PASSWORD = '+CONVERT(NVARCHAR(MAX),SL.password_hash,1)+' HASHED'
            ELSE ' FROM WINDOWS'
       END + ';/*'+SP.type_desc+'*/ END;' 
       COLLATE SQL_Latin1_General_CP1_CI_AS
  FROM sys.server_principals AS SP
  LEFT JOIN sys.sql_logins AS SL
    ON SP.principal_id = SL.principal_id
 WHERE SP.type_desc IN ('WINDOWS_GROUP','WINDOWS_LOGIN')
   AND SP.name NOT LIKE 'NT%' 
   AND SP.name NOT IN ('');
```

## Create on a new server
```
-- SQL Logins
IF(SUSER_ID('testuser1') IS NULL) BEGIN CREATE LOGIN [testuser1] WITH PASSWORD = 0x0100A992C62C075EDCBD8EDD56ECB724819361E13F31C6CC6DA2 HASHED;/*SQL_LOGIN*/ END;
IF(SUSER_ID('testuser2') IS NULL) BEGIN CREATE LOGIN [testuser2] WITH PASSWORD = 0x0100F39DFD6D2AAE945E9A45E81ACF20D8AD785E4B8FB9BFFA98 HASHED;/*SQL_LOGIN*/ END;
IF(SUSER_ID('testgroup3') IS NULL) BEGIN CREATE LOGIN [testgroup3] WITH PASSWORD = 0x0100D0E17057810B1AA3FAA933E83D0A66D55411280987762DFB HASHED;/*SQL_LOGIN*/ END;

-- Windows Logins

IF(SUSER_ID('TestDomain\test.user1') IS NULL)BEGIN CREATE LOGIN [TestDomain\test.user1] FROM WINDOWS;/*WINDOWS_LOGIN*/ END;
IF(SUSER_ID('TestDomain\test.user2') IS NULL)BEGIN CREATE LOGIN [TestDomain\test.user2] FROM WINDOWS;/*WINDOWS_LOGIN*/ END;
IF(SUSER_ID('TestDomain\test.user3') IS NULL)BEGIN CREATE LOGIN [TestDomain\test.user3] FROM WINDOWS;/*WINDOWS_GROUP*/ END;
```
## Synchronize Users in databases
```
EXEC sp_MSForEachDB ' Use ?; select ''?'' as dbname, ''use ?; alter user [''+ name+''] with login=[''+name+'']'' as command from ?.sys.database_principals where ''?'' not in (''master'',''model'',''msdb'',''tempdb'') and type in (''U'',''G'',''S'') and name not in (''dbo'', ''guest'', ''INFORMATION_SCHEMA'',''sys'') order by type, name'
```
## Reset password if needed
```
ALTER LOGIN testuser1 WITH PASSWORD = 'testuser1', CHECK_POLICY = OFF;  
ALTER LOGIN testuser2 WITH PASSWORD = 'testuser2', CHECK_POLICY = OFF;  
ALTER LOGIN testuser3 WITH PASSWORD = 'testuser3', CHECK_POLICY = OFF;  
```
## Test connections
```
Sqlcmd -S testsql  -Q "print 'OK'" -d tempdb   -U testuser1 -P testuser1
Sqlcmd -S testsql  -Q "print 'OK'" -d tempdb   -U testuser2 -P testuser2
Sqlcmd -S testsql  -Q "print 'OK'" -d tempdb   -U testuser3 -P testuser3
```