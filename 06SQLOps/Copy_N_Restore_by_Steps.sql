-- Copy and restore a database
-- 

-- get the backup o YOURDATABASE from the source
SELECT top 1 rtrim(physical_device_name) 
FROM msdb.dbo.backupset b JOIN msdb.dbo.backupmediafamily m ON b.media_set_id = m.media_set_id 
WHERE database_name = 'YOURDATABASE' and type='D' ORDER BY backup_finish_date DESC

-- copy backup from source to target 

dir \\sourceserver\backup_file_full_name
copy \\sourceserver\backup_file_full_name \\targetserver\e$\temp

-- create a new database on target
create database YOURDATBASE

-- restore the backup at the targetRESTORE DATABASE YOURDATABSE FROM  DISK = N'E:\temp\YOURDATABASE_backup_2020_05_26_200005_2565224.bak' 
WITH  RECOVERY,  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5

-- copy login from the source, by generate the script
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

-- sync the YourUser with login
use YOURDATABASE
alter user YourUser with login = YourUser