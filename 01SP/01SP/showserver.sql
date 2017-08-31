/*
	store procedure to display server properties
*/
create procedure [dbo].[showserver]
as
Select @@SERVERNAME as [Server\Instance],
-- SQL Server Version
	@@VERSION as SQLServerVersion,
-- SQL Server Instance
	@@ServiceName AS ServiceInstance,
	SERVERPROPERTY('ProductVersion') AS ProductVersion,
SERVERPROPERTY('ProductLevel') AS ProductLevel,
SERVERPROPERTY('Edition') AS Edition,
SERVERPROPERTY('EngineEdition') AS EngineEdition,
	SERVERPROPERTY('Collation') AS Collation,
SERVERPROPERTY('MachineName') AS MachineName,
SERVERPROPERTY('ProcessID') AS ProcessID,
SERVERPROPERTY('SqlCharSetName') AS SqlCharSetName;

GO