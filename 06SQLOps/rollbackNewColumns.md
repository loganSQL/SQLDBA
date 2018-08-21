## Rollback New Columns 
```
-- Sometimes, after adding columns (with DF) to existing table,
-- And you want to rollback

-- 1. Identify those columns

select COLUMN_NAME, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'dbo'
AND TABLE_NAME = N'YourTableName' 
-- from which column
-- and ORDINAL_POSITION>119
order by ORDINAL_POSITION

-- 2. Find all the Constraints

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'YourTableName'
--AND COLUMN_NAME = @ColumnName
---and ORDINAL_POSITION>232

-- 3. Get the default constraints name (DF)

SELECT
  all_columns.name,default_constraints.parent_column_id, 
    default_constraints.name
FROM 
    sys.all_columns

        INNER JOIN
    sys.tables
        ON all_columns.object_id = tables.object_id

        INNER JOIN 
    sys.schemas
        ON tables.schema_id = schemas.schema_id

        INNER JOIN
    sys.default_constraints
        ON all_columns.default_object_id = default_constraints.object_id

WHERE 
        schemas.name = 'dbo'
    AND tables.name = 'COMMITME'
--    AND all_columns.name = 'columnname'
-- AND parent_column_id >232

-- 4. Generate drop constraints SQL

SELECT
    'ALTER TABLE [dbo].[MyTable] DROP CONSTRAINT '+ default_constraints.name
FROM 
    sys.all_columns

        INNER JOIN
    sys.tables
        ON all_columns.object_id = tables.object_id

        INNER JOIN 
    sys.schemas
        ON tables.schema_id = schemas.schema_id

        INNER JOIN
    sys.default_constraints
        ON all_columns.default_object_id = default_constraints.object_id

WHERE 
        schemas.name = 'dbo'
    AND tables.name = 'COMMITME'
--    AND all_columns.name = 'columnname'
-- AND parent_column_id >232

-- 5. Generate drop columns SQL

SELECT 'ALTER TABLE [dbo].[MyTable] DROP COLUMN '+COLUMN_NAME
--select COLUMN_NAME, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'dbo'
AND TABLE_NAME = N'YourTableName' 
-- from which column
-- and ORDINAL_POSITION>119
order by ORDINAL_POSITION

```