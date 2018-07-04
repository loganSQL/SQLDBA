msdb..showobjectswithword 'Merlin','FNDM'

USE FNDM; 
select DB_NAME() as searchDB,'Merlin' as searchWord;  
SELECT DISTINCT      o.name AS Object_Name,o.type_desc      
FROM sys.sql_modules        m           
INNER JOIN sys.objects  o 
ON m.object_id=o.object_id      
WHERE m.definition Like '%Merlin%'      
ORDER BY 2,1  