# Retrieve All Users And Associated Roles For ALL Databases
## Query

[Retrieve All Users And Associated Roles For ALL Databases](<https://blog.pythian.com/httpconsultingblogs-emc-comjamiethomsonarchive20070209sql-server-2005_3a00_-view-all-permissions-_2800_2_2900_-aspx/>)

```
DECLARE @DB_USers TABLE
(DBName sysname, UserName sysname, LoginType sysname, AssociatedRole varchar(max),create_date datetime,modify_date datetime)
 
INSERT @DB_USers
EXEC sp_MSforeachdb
 
'
use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''+ (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')'' else prin.name end AS UserName,
prin.type_desc AS LoginType,
isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole ,create_date,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) and
prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%'''
 
SELECT
 
dbname,username ,logintype ,create_date ,modify_date ,
 
STUFF(
 
(
 
SELECT ',' + CONVERT(VARCHAR(500),associatedrole)
 
FROM @DB_USers user2
 
WHERE
 
user1.DBName=user2.DBName AND user1.UserName=user2.UserName
 
FOR XML PATH('')
 
)
 
,1,1,'') AS Permissions_user
 
FROM @DB_USers user1
 
GROUP BY
 
dbname,username ,logintype ,create_date ,modify_date
 
ORDER BY DBName,username
```

## Store Procedure
```
USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[showroles]    Script Date: 2018-11-26 11:29:16 AM ******/
DROP PROCEDURE [dbo].[showroles]
GO


CREATE PROCEDURE [dbo].[showroles] @user varchar(255) = NULL 
AS
DECLARE @DB_USers TABLE
(DBName sysname, UserName sysname, LoginType sysname, AssociatedRole varchar(max),create_date datetime,modify_date datetime)


 
INSERT @DB_USers
EXEC sp_MSforeachdb
 
'
use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''+ (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')'' else prin.name end AS UserName,
prin.type_desc AS LoginType,
isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole ,create_date,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) and
prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%'''


if (@user is not null)
  begin
  if not exists (select UserName from @DB_USers where UserName=@user)
    begin
    print @user
    return
    end
  else
    begin
    print 'deleting...'
    delete from @DB_USers where UserName<>@user
    end
  end
   
SELECT
 
dbname,username ,logintype ,create_date ,modify_date ,
 
STUFF(
 
(
 
SELECT ',' + CONVERT(VARCHAR(500),associatedrole)
 
FROM @DB_USers user2
 
WHERE
 
user1.DBName=user2.DBName AND user1.UserName=user2.UserName
 
FOR XML PATH('')
 
)
 
,1,1,'') AS Permissions_user
 
FROM @DB_USers user1
 
GROUP BY
 
dbname,username ,logintype ,create_date ,modify_date
 
ORDER BY DBName,username
GO
```

```

-- test
msdb..showroles
msdb..showroles 'mydomain\myuser'
```