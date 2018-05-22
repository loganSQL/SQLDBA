
/*

MS SQL : Logon Triggers
-----------------------
https://docs.microsoft.com/en-us/sql/relational-databases/triggers/logon-triggers?view=sql-server-2017
Logon triggers fire stored procedures in response to a LOGON event. LOGON event corresponds to the AUDIT_LOGIN SQL Trace event, which can be used in Event Notifications. 
The primary difference between triggers and event notifications is that triggers are raised synchronously with events, 
whereas event notifications are asynchronous. This means, for example, that if you want to stop a session from being established, 
you must use a logon trigger. An event notification on an AUDIT_LOGIN event cannot be used for this purpose.


WHITELIST
---------
Whitelist => a list of people or organizations that have been approved to receive special considerations”. 
In SQL, “special consideration” is access to the SQL Server only if your workstation IP address is on the whitelist.

USER CASE
---------
Let’s say you have a company policy that prohibits anyone from using a common login to connect to a SQL Server. 
But your application uses a single SQL login to make its connection to SQL Server, and EVERY developer in the company knows the password. 
Even though there is a written policy in place, what would prevent one of those developers form connecting to SQL Server to fix a bug, 
or worse, change data to circumvent the application logic. 
http://www.patrickkeisler.com/2015/11/create-whitelist-for-sql-server.html
*/
USE master;
GO

IF OBJECT_ID('dbo.WhiteList') IS NOT NULL
  DROP TABLE dbo.WhiteList;
GO

CREATE TABLE dbo.WhiteList
(
   Id INT IDENTITY(1,1) PRIMARY KEY
  ,LoginName VARCHAR(255)
  ,HostName VARCHAR(255)
  ,HostIpAddress VARCHAR(50)
  ,Comments VARCHAR(2000)
);
GO

GRANT SELECT ON dbo.WhiteList TO PUBLIC;
GO

INSERT dbo.WhiteList(LoginName,HostName,HostIpAddress,Comments)
VALUES
   ('*','MYWORKSTATION','*','Any user from the workstation "MYWORKSTATION" is allowed to connect, regardless of IP address.')
  ,('WebSiteLogin','webserver1','192.168.100.55','Only the WebSiteLogin from webserver1 with an IP of 192.168.100.55 is allowed access.');
GO

CREATE TRIGGER WhiteListTrigger
ON ALL SERVER FOR LOGON
AS
BEGIN
  DECLARE 
     @LoginName VARCHAR(255) = ORIGINAL_LOGIN()
    ,@HostName VARCHAR(255) = HOST_NAME()
    ,@HostIpAddress VARCHAR(50) = CONVERT(VARCHAR(50),CONNECTIONPROPERTY('client_net_address'));

  IF 
  (
    SELECT COUNT(*) FROM dbo.WhiteList
    WHERE 
    (
      (LoginName = @LoginName) OR (LoginName = '*')
    )
    AND
    (
      (HostName = @HostName) OR (HostName = '*')
    )
    AND
    (
      (HostIpAddress = @HostIpAddress) OR (HostIpAddress = '*')
    )
  ) = 0
  ROLLBACK;
END;
GO

/* Testing */
CREATE LOGIN LogonTriggerTest WITH PASSWORD = 'Password1';
GO

grant VIEW SERVER STATE to LogonTriggerTest
go

SELECT CONNECTIONPROPERTY(‘client_net_address’);
GO

USE master;
GO
SELECT
   ORIGINAL_LOGIN() AS 'LoginName'
  ,HOST_NAME() AS 'HostName'
  ,CONNECTIONPROPERTY('client_net_address') AS 'HostIpAddress';
GO
SELECT * FROM dbo.WhiteList;
GO

/*
In the event you lock yourself (or everyone) out of the SQL Server, 
there is a quick way to restore access. You’ll need to connect to SQL Server using the Dedicated Admin Connection, 
either through Management Studio or the SQLCMD command line using a login with SysAdmin permission. 
Once connected, you can disable the logon trigger.
*/

disable trigger WhiteListTrigger on ALL SERVERS
go
