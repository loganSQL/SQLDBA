/*
	A function to get a version number
*/

USE [msdb]
GO


IF exists(select name from sysobjects where name='serverversion' and type='FN')
	drop function serverversion

go

CREATE FUNCTION [dbo].[serverversion]()
returns float
AS
BEGIN
	declare @VersionNumber as float
	select @VersionNumber  =
	 CASE 
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 2000
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 2005
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 2008
		 -- 2008 R2 as 2008.5
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 2008.5
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 2012
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 2014
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 2016    
		 ELSE 0
	  END 
	  
	  return @VersionNumber
	END
GO


select [dbo].[serverversion]()
go


/*
	A store procedure to show the sql port
*/

IF exists(select name from sysobjects where name='showport' and type='P')
	drop procedure showport

go

create procedure showport
as
-- for 2012 above, get directly from DMV
if [dbo].[serverversion]()>2009
	SELECT port FROM sys.dm_tcp_listener_states WHERE is_ipv4 = 1 AND [type] = 0 AND ip_address <> '127.0.0.1'
else
-- others from registry
	begin
	SELECT MAX(CONVERT(VARCHAR(15),value_data)) as 'TcpPort' FROM sys.dm_server_registry WHERE registry_key LIKE '%MSSQLServer\SuperSocketNetLib\Tcp\%' AND value_name LIKE N'%TcpPort%' AND CONVERT(float,value_data) > 0;

	SELECT MAX(CONVERT(VARCHAR(15),value_data)) as 'TcpDynamicPort' FROM sys.dm_server_registry WHERE registry_key LIKE '%MSSQLServer\SuperSocketNetLib\Tcp\%' AND value_name LIKE N'%TcpDynamicPort%' AND CONVERT(float,value_data) > 0;

	end
go


exec showport
