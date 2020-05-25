-- generate sql login creation script
-- simple format, and with the same password
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

-- alter all user login wiht the same passowrd
/*-- generate script like
IF(SUSER_ID('TestUser') IS NOT NULL) BEGIN ALTER LOGIN [TestUser] WITH PASSWORD = 0x020026FB1D74A372FC6A0C91EA2E98ABA887943D99F538DAD93BFB1946D8746E94DE3E112355CE5BC65F1A965419531624F586A060C227B0EC1AFBFAAACF3CF1C49EF2AC6405 HASHED;/*SQL_LOGIN*/ END;
*/
SELECT 'IF(SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NOT NULL) BEGIN ALTER LOGIN '+QUOTENAME(SP.name)+
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

-- reset default database and password policy
Select 'ALTER LOGIN '+QUOTENAME(SP.name)+' WITH DEFAULT_DATABASE=[tempdb], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
FROM sys.server_principals AS SP
	LEFT JOIN sys.sql_logins AS SL
    ON SP.principal_id = SL.principal_id
WHERE SP.type_desc ='SQL_LOGIN'
   AND SP.name NOT LIKE '##%##' 
   AND SP.name NOT IN ('SA')
Order by SP.name

-- generate window login creation script
-- simple format
SELECT 'IF(SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN '+QUOTENAME(SP.name)+
       CASE WHEN SP.type_desc = 'SQL_LOGIN'
            THEN ' WITH PASSWORD = '+CONVERT(NVARCHAR(MAX),SL.password_hash,1)+' HASHED'
            ELSE ' FROM WINDOWS'
       END + ';/*'+SP.type_desc+'*/ END;' 
       COLLATE SQL_Latin1_General_CP1_CI_AS
  FROM sys.server_principals AS SP
  LEFT JOIN sys.sql_logins AS SL
    ON SP.principal_id = SL.principal_id
 WHERE SP.type_desc = 'WINDOWS_LOGIN' 
