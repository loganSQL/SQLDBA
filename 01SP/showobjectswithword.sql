/*
	store procedure to show all objects with definition text contains the SearchWord
*/
use msdb
go

alter procedure [dbo].[showobjectswithword] @SearchWord varchar(255), @searchDB nvarchar(255)
as
declare @sqlstr nvarchar(MAX)
select @sqlstr=N'USE '+@searchDB+'; select DB_NAME() as searchDB,'''+ @SearchWord+''' as searchWord;'
+'
SELECT DISTINCT
    o.name AS Object_Name,o.type_desc
    FROM sys.sql_modules        m 
        INNER JOIN sys.objects  o ON m.object_id=o.object_id
    WHERE m.definition Like '+'''%'+@SearchWord+'%'''+'
    ORDER BY 2,1
'
select @sqlstr
EXECUTE sp_executesql @sqlstr
GO

exec msdb..[showobjectswithword] 'MySearchWord','MyDB'