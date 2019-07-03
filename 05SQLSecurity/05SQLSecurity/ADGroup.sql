-- Windows Groups As Logins
DECLARE @YourGroup VARCHAR(200)
IF (SUSER_ID(@YourGroup) IS NULL) BEGIN CREATE LOGIN [@YourGroup] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb], DEFAULT_LANGUAGE=[us_english] END;
-- 
select 'CREATE LOGIN ['+ name+'] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb], DEFAULT_LANGUAGE=[us_english]' from syslogins where isntgroup=1

-- disable all the groups
select 'alter login ['+name+'] disable' from syslogins where isntgroup=1

-- revoke or grant
select 'revoke connect SQL to ['+name+']' from syslogins where isntgroup=1
select 'grant connect SQL to ['+name+']' from syslogins where isntgroup=1

-- get group members
select 'EXEC xp_logininfo ['+ name+'], [members]' from syslogins where isntgroup=1