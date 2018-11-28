/*
	An encrypted stored procedure for recreating a linkserver with hardcore password, assigned as a startup proc
*/


use master
go

IF EXISTS (SELECT name from sysobjects where name='recreateLinkserver' and type='P')
	drop procedure recreateLinkserver
go

create procedure recreateLinkserver with encryption as
begin
IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'MYPROD') 
	EXEC master.dbo.sp_dropserver @server=N'MYPROD', @droplogins='droplogins'

/****** Object:  LinkedServer [MYPROD]    Script Date: 09/15/2017 09:28:47 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'MYPROD', @srvproduct=N'MYDBPRODUCT', @provider=N'MYDBPROVIDER', @datasrc=N'MYPROD', @provstr=N'DEFAULT COLLECTION=MY_PROD', @catalog=N'S1098c7e'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MYPROD',@useself=N'False',@locallogin=N'MYDOMAIN\USER1',@rmtuser=N'REMOTEUSER',@rmtpassword='PWD'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MYPROD',@useself=N'False',@locallogin=N'MYDOMAIN\USER2',@rmtuser=N'REMOTEUSER',@rmtpassword='PWD'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MYPROD',@useself=N'False',@locallogin=N'MYDOMAIN\USER3',@rmtuser=N'REMOTEUSER',@rmtpassword='PWD'

EXEC master.dbo.sp_serveroption @server=N'MYPROD', @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MYPROD', @optname=N'data access', @optvalue=N'true'
end
go

/* Assign a sp for startup */
exec sp_procoption N'recreateLinkserver', 'startup', 'on'
go

/* Check all the startup sps */
SELECT name,create_date,modify_date
FROM sys.procedures
WHERE OBJECTPROPERTY(OBJECT_ID, 'ExecIsStartup') = 1
go

/* test exec */
exec recreateLinkserver
go
