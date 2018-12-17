# T-SQL: Change Columns Collation

```
-- From: SQL_Latin1_General_CP1_CI_AS
-- system_type_id=167 => varchar
--
SELECT t.name "Table Name",
       c.name "Column Name",c.system_type_id "datatype",c.max_length "length",
       c.collation_name "Collation"
  FROM sys.tables t INNER JOIN
       sys.columns c ON c.object_id=t.object_id INNER JOIN
       sys.types s ON s.user_type_id=c.user_type_id
 WHERE c.collation_name LIKE 'SQL_Latin1_General_CP1_CI_AS'
   AND t.type like 'U'
   AND t.name = 'MyTable'

--
-- To: Latin1_General_CI_AS
-- construct ALTER statements
--
select 'ALTER TABLE MyTable ALTER COLUMN '+ c.name + ' VARCHAR(' + convert(varchar(3), c.max_length)+') COLLATE Latin1_General_CI_AS'
  FROM sys.tables t INNER JOIN
       sys.columns c ON c.object_id=t.object_id INNER JOIN
       sys.types s ON s.user_type_id=c.user_type_id
 WHERE c.collation_name LIKE 'SQL_Latin1_General_CP1_CI_AS'
   AND c.system_type_id = 167
   AND t.type like 'U'
   AND t.name = 'MyTable'
```