/*
	store procedure to show the databases and its physical files / sizes
*/
create procedure [dbo].[showfiles]
as
SELECT
    db.name AS DBName,
    type_desc AS FileType,
    Physical_Name AS Location,
	round(size*8/1024,0) as 'Size(MB)'
FROM
    sys.master_files mf
INNER JOIN 
    sys.databases db ON db.database_id = mf.database_id

GO
