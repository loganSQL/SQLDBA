/* script to create all the windows logins */

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
