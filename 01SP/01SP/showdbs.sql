/*
	Store Procedure to list all databases and its options
*/

create procedure [dbo].[showdbs]
as
SELECT  @@SERVERNAME AS Server ,
        name AS DBName ,
        recovery_model_Desc AS RecoveryModel ,
        Compatibility_level AS CompatiblityLevel ,
        create_date ,
        state_desc
FROM    sys.databases
ORDER BY Name
/*
SELECT  @@SERVERNAME AS Server ,
        sys.databases.name AS DBName ,
        sys.databases.create_date ,
		CONVERT(VARCHAR,SUM(size)*8/1024)+' MB' AS [Total disk space]  
FROM    sys.databases
JOIN        sys.master_files  
ON          sys.databases.database_id=sys.master_files.database_id  
GROUP BY    sys.databases.name  
ORDER BY    sys.databases.name
*/
GO
