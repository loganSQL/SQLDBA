--- To copy permissions of one user/role to another user/role.

USE [YourUserDB] -- Use the database from which you want to extract the permissions
GO


if exists (select name from sysobjects where name='cloneUser' and type='P')
	drop procedure [cloneUser]
go

CREATE PROCEDURE [dbo].[cloneUser]
	@OldUser varchar(100),
	@NewUser varchar(100)
AS
	SET NOCOUNT ON
	create table #OutText (cloneUserCommands varchar(max))

	-- Starting
	INSERT into #OutText (cloneUserCommands)
	SELECT  '--Cloning permissions from' + SPACE(1) + QUOTENAME(@OldUser) + SPACE(1) + 'to' + SPACE(1) + QUOTENAME(@NewUser)
	-- Database Context
	INSERT into #OutText (cloneUserCommands)
	SELECT  'USE' + SPACE(1) + QUOTENAME(DB_NAME())

	--Role Memberships
	INSERT into #OutText (cloneUserCommands)
	SELECT  'EXEC sp_addrolemember @rolename ='
    + SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(@NewUser, '''')
	FROM    sys.database_role_members AS rm
	WHERE   USER_NAME(rm.member_principal_id) = @OldUser
	ORDER BY rm.role_principal_id ASC

	--Object Level Permissions
	INSERT into #OutText (cloneUserCommands)
	SELECT  CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
		+ SPACE(1) + perm.permission_name + SPACE(1) + 'ON ' + QUOTENAME(USER_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name)
		+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
		+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(@NewUser) COLLATE database_default
		+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END 
	FROM    sys.database_permissions AS perm
		INNER JOIN
		sys.objects AS obj
		ON perm.major_id = obj.[object_id]
		INNER JOIN
		sys.database_principals AS usr
		ON perm.grantee_principal_id = usr.principal_id
		LEFT JOIN
		sys.columns AS cl
		ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
	WHERE   usr.name = @OldUser
	ORDER BY perm.permission_name ASC, perm.state_desc ASC

	--Database Level Permissions
	INSERT into #OutText (cloneUserCommands)
	SELECT  CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
		+ SPACE(1) + perm.permission_name + SPACE(1)
		+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(@NewUser) COLLATE database_default
		+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END
	FROM    sys.database_permissions AS perm
		INNER JOIN
		sys.database_principals AS usr
		ON perm.grantee_principal_id = usr.principal_id
	WHERE   usr.name = @OldUser
	AND perm.major_id = 0
	ORDER BY perm.permission_name ASC, perm.state_desc ASC

	select * from #OutText
RETURN 0

go
