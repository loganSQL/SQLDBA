use master
go
-- 1 check SQL Server Service Master Key
select * from sys.symmetric_keys
go

-- 2  create Database Master Key
use DBA
go

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'XXX';
GO

select * from sys.symmetric_keys
go

-- 3. Create a Self Signed SQL Server Certificate
use DBA
go

CREATE CERTIFICATE CertificateDBA
WITH SUBJECT = 'To protect DBA SQL Logins Password';
GO

select * from sys.certificates
go

-- 4. SQL Server Symmetric Key in A Database
use DBA
go


CREATE SYMMETRIC KEY SymmetricKeyDBA 
 WITH ALGORITHM = AES_128 
 ENCRYPTION BY CERTIFICATE CertificateDBA;
GO

-- check
SELECT * FROM sys.symmetric_keys

-- 5. Encrypt Columns on a table in a database
USE [DBA]
GO

/*
DROP TABLE [dbo].[dba_pwd]
GO

CREATE TABLE [dbo].[dba_pwd](
	[instance] [varchar](50) NOT NULL,
	[username] [varchar](50) NOT NULL ,
	[pwd] [varchar](500) NULL,
	[secret] [varbinary](max) NULL,

PRIMARY KEY CLUSTERED 
(
	[instance] ASC,
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



insert into [dbo].[dba_pwd] ([instance],[username],[pwd]) values ('MySQLInstance', 'MyUser', 'MyPass')
go
*/

-- 6. encryption process by batch
OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
go

update [dbo].[dba_pwd]
set [secret]=EncryptByKey(key_GUID('SymmetricKeyDBA'),pwd)
where [pwd]<>'PROCESSED'
go


update [dbo].[dba_pwd]
set [pwd]='PROCESSED'
where [pwd]<>'PROCESSED'
go

-- Closes the symmetric key
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
GO

-- check
SELECT * FROM [DBA].[dbo].[dba_pwd]

-- 7. encryption process one by one
OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
go

insert into [dbo].[dba_pwd] ([username],[pwd], [secret]) 
values ( 'User1','PROCESSED',EncryptByKey(key_GUID('SymmetricKeyDBA'),'Password1?'))
go

-- Closes the symmetric key
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
GO

select * from [dbo].[dba_pwd]

-- 8. decryption
OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
go

select [username],[secret], convert(varchar, decryptByKey(secret)) as origin_pwd
from [dbo].[dba_pwd]
go

-- Closes the symmetric key
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
GO

alter procedure dba_add_pwd (@instance varchar(50), @username varchar(50), @pwd varchar(500)) with encryption
as
begin
DECLARE @original_login sysname;   
if (@original_login <> 'AD\logan.sql') 
	begin
	    print 'Microsoft SQL Audit Alert:'
		raiserror('You do not authorized to run this procedure. Your execution has been traced by big.brother!', 18, 1)
		print 'Your IP and AD login are recorded.'
		return -1
	end

OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
insert into [dbo].[dba_pwd] ([instance],[username],[pwd], [secret]) 
values (@instance, @username,'PROCESSED',EncryptByKey(key_GUID('SymmetricKeyDBA'),@pwd))
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
end

/*

exec dba_add_pwd 'SQLInst1', 'UUser', 'xxxx'
...
exec dba_add_pwd 'SQLInst199', 'User', 'djhjds'


*/

select * from [dbo].[dba_pwd]

alter procedure dba_get_pwd with encryption
as
begin
DECLARE @original_login sysname;   
if (@original_login <> 'AD\logan.sql') 
	begin
	    print 'Microsoft SQL Audit Alert:'
		raiserror('You do not authorized to run this procedure. Your execution has been traced by big.brother!', 18, 1)
		print 'Your IP and AD login are recorded.'
		return -1
	end

OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
select [instance],[username],[secret], convert(varchar, decryptByKey(secret)) as origin_pwd
from [dbo].[dba_pwd]
order by instance, username
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
end

exec dba_get_pwd

alter procedure dba_test_command with encryption
as
begin
DECLARE @original_login sysname;   
if (@original_login <> 'AD\logan.sql') 
	begin
	    print 'Microsoft SQL Audit Alert:'
		raiserror('You do not authorized to run this procedure. Your execution has been traced by big.brother!', 18, 1)
		print 'Your IP and AD login are recorded.'
		return -1
	end

OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
--select [instance],[username],[secret], convert(varchar, decryptByKey(secret)) as origin_pwd
select 'sqlcmd -S '+instance+' -Q "select @@servername" -d tempdb -U '+username+'  -P '''+convert(varchar, decryptByKey(secret))+''''
from [dbo].[dba_pwd]
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
end
go
exec dba_test_command
go

alter procedure dba_test_command_by_instance (@instance varchar(50)) with encryption
as
begin
DECLARE @original_login sysname;   
if (@original_login <> 'AD\logan.sql') 
	begin
	    print 'Microsoft SQL Audit Alert:'
		raiserror('You do not authorized to run this procedure. Your execution has been traced by big.brother!', 18, 1)
		print 'Your IP and AD login are recorded.'
		return -1
	end

OPEN SYMMETRIC KEY SymmetricKeyDBA
DECRYPTION BY CERTIFICATE CertificateDBA;
--select [instance],[username],[secret], convert(varchar, decryptByKey(secret)) as origin_pwd
select 'sqlcmd -S '+instance+' -Q "select @@servername" -d tempdb -U '+username+'  -P '''+convert(varchar, decryptByKey(secret))+''''
from [dbo].[dba_pwd]
where instance=@instance
CLOSE SYMMETRIC KEY SymmetricKeyDBA;
end
go

exec dba_test_command_by_instance 'MySQLInst1'
go
