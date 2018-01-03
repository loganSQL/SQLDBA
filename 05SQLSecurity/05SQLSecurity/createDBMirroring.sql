/*
	basic steps for creating a database mirroring session without a witness
*/

-- 0. Checking
select name,expiry_date,* from sys.certificates

select * from sys.endpoints

SELECT name,type_desc,port, * FROM sys.tcp_endpoints

-- Determine if a database mirroring endpoint already exists by using the following statement: 
SELECT role_desc, state_desc, * FROM sys.database_mirroring_endpoints  


-- 1.	On the principal server instance (default instance on PARTNERHOST1), 
--		create an endpoint that supports all roles using port 7022: 

--create an endpoint for this instance  
CREATE ENDPOINT Endpoint_Mirroring  
    STATE=STARTED   
    AS TCP (LISTENER_PORT=7022)   
    FOR DATABASE_MIRRORING (ROLE=ALL)  
GO  
--Partners under same domain user; login already exists in master.  

-- 2.	On the mirror server instance (default instance on PARTNERHOST5), 
--		create an endpoint that supports all roles using port 7022:
--create an endpoint for this instance  
CREATE ENDPOINT Endpoint_Mirroring  
    STATE=STARTED   
    AS TCP (LISTENER_PORT=7022)   
    FOR DATABASE_MIRRORING (ROLE=ALL)  
GO  
--Partners under same domain user; login already exists in master.  

/*
If the instances of SQL Server run as services under different domain accounts (in the same or trusted domains), 
the login of each account must be created in master on each of the remote server instances and 
that login must be granted CONNECT permissions on the endpoint.
*/
USE master;  
GO  
CREATE LOGIN [Adomain\Otheruser] FROM WINDOWS;  
GO  
GRANT CONNECT on ENDPOINT::Endpoint_Mirroring TO [Adomain\Otheruser];  
GO  


-- 3. On the principal server instance (on PARTNERHOST1), back up the database:
BACKUP DATABASE AdventureWorks   
    TO DISK = 'C:\AdvWorks_dbmirror.bak'   
    WITH FORMAT  
GO 

-- 4. On the mirror server instance (on PARTNERHOST5), restore the database: 
RESTORE DATABASE AdventureWorks   
    FROM DISK = 'Z:\AdvWorks_dbmirror.bak'   
    WITH NORECOVERY  
GO  

-- 5. After you create the full database backup, you must create a log backup on the principal database.
--	For example, the following Transact-SQL statement backs up the log to the same file used by the preceding database backup: 
BACKUP LOG AdventureWorks   
    TO DISK = 'C:\AdventureWorks.bak'   
GO  

-- 6. Before you can start mirroring, you must apply the required log backup (and any subsequent log backups). 
RESTORE LOG AdventureWorks   
    FROM DISK = 'C:\ AdventureWorks.bak'   
    WITH FILE=1, NORECOVERY  
GO  


-- 7. On the mirror server instance, set the server instance on PARTNERHOST1 as the partner (making it the initial principal server): 
USE master;  
GO  
ALTER DATABASE AdventureWorks   
    SET PARTNER =   
    'TCP://PARTNERHOST1:7022'  
GO 

-- 8. On the principal server instance, set the server instance on PARTNERHOST5 as the partner (making it the initial mirror server): 
USE master;  
GO  
ALTER DATABASE AdventureWorks   
    SET PARTNER = 'TCP://PARTNERHOST5:7022'  
GO  

/*
Furthermore:
Setting up Database mirroring in SQL Server 2008 using T-SQL when the database is encrypted using Transparent Data Encryption
https://blogs.msdn.microsoft.com/sqlserverfaq/2009/03/31/setting-up-database-mirroring-in-sql-server-2008-using-t-sql-when-the-database-is-encrypted-using-transparent-data-encryption/
*/