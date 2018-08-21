/*
	To Label a table backup (MyTableBackup) with date and Housekeep for a week
*/

Declare @SQL varchar(255);
Declare @yesterday varchar(10);

-- label it by yesterday date

select @yesterday=CONVERT(char(8), dateadd(dd,-1, cast(getdate() as date)), 112);
set @SQL = 'EXEC sp_rename MyTableBackup, MyTableBackup_' + @yesterday
print @SQL
execute (@SQL);

-- housekeep for a week
-- select DATEADD(day,-7, GETDATE())
DECLARE @name VARCHAR(256)

DECLARE db_cursor CURSOR FOR  
select name from sysobjects where name like 'MyTableBackup_%' and crdate < DATEADD(day,-7, GETDATE())

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name  
WHILE @@FETCH_STATUS = 0   
BEGIN  
	set @SQL = 'drop table , ' + @name
	print @SQL
	--execute (@SQL);
	FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor