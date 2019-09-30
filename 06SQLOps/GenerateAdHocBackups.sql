use msdb
go
 
CREATE PROCEDURE GenerateBackups (@backuppath varchar(100)='C:\temp\')
As

if (@backuppath is null)
	print 'C:\temp\';

DECLARE  @dbname nvarchar(50), @message varchar(1000);

DECLARE dbs_cursor CURSOR  
    FOR SELECT name FROM master..sysdatabases where dbid>4

OPEN dbs_cursor  
FETCH NEXT FROM dbs_cursor INTO @dbname  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	PRINT ' '  
    --SELECT @message = 'DBNAME = ' + @DBNAME  
    --PRINT @message  
	SELECT @message = 'BACKUP DATABASE '+@DBNAME+' TO DISK = '''+@backuppath+@DBNAME+'.bak'' WITH FORMAT, COPY_ONLY'
	PRINT @message  
    FETCH NEXT FROM dbs_cursor INTO @dbname  
END  
  
CLOSE dbs_cursor  
DEALLOCATE dbs_cursor  
go