# Query to generate the db user permission
## 
```
SELECT
  (
    dp.state_desc + ' ' +
    dp.permission_name collate latin1_general_cs_as + 
    ' ON ' + '[' + s.name + ']' + '.' + '[' + o.name + ']' +
    ' TO ' + '[' + dpr.name + ']'
  ) AS GRANT_STMT
FROM sys.database_permissions AS dp
  INNER JOIN sys.objects AS o ON dp.major_id=o.object_id
  INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
  INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
WHERE dpr.name='youruser'
--WHERE dpr.name NOT IN ('public','guest')
--  AND o.name IN ('My_Procedure')      -- Uncomment to filter to specific object(s)
--  AND dp.permission_name='EXECUTE'    -- Uncomment to filter to just the EXECUTEs
```

##
```
SELECT
  CASE
      WHEN dp.class_desc = 'OBJECT_OR_COLUMN' THEN
        dp.state_desc + ' ' + dp.permission_name collate latin1_general_cs_as + 
        ' ON ' + '[' + obj_sch.name + ']' + '.' + '[' + o.name + ']' +
        ' TO ' + '[' + dpr.name + ']'
      WHEN dp.class_desc = 'DATABASE' THEN
        dp.state_desc + ' ' + dp.permission_name collate latin1_general_cs_as + 
        ' TO ' + '[' + dpr.name + ']'
      WHEN dp.class_desc = 'SCHEMA' THEN
        dp.state_desc + ' ' + dp.permission_name collate latin1_general_cs_as + 
        ' ON SCHEMA :: ' + '[' + SCHEMA_NAME(dp.major_id) + ']' +
        ' TO ' + '[' + dpr.name + ']'
      WHEN dp.class_desc = 'TYPE' THEN
        dp.state_desc + ' ' + dp.permission_name collate Latin1_General_CS_AS + 
        ' ON TYPE :: [' + s_types.name + '].[' + t.name + ']'
            + ' TO [' + dpr.name + ']'
      WHEN dp.class_desc = 'CERTIFICATE' THEN 
        dp.state_desc + ' ' + dp.permission_name collate latin1_general_cs_as + 
        ' TO ' + '[' + dpr.name + ']' 
      WHEN dp.class_desc = 'SYMMETRIC_KEYS' THEN 
        dp.state_desc + ' ' + dp.permission_name collate latin1_general_cs_as + 
      ' TO ' + '[' + dpr.name + ']' 
      ELSE 
        'ERROR: Unhandled class_desc: ' + dp.class_desc
  END
 AS GRANT_STMT
FROM sys.database_permissions AS dp 
  JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
  LEFT JOIN sys.objects AS o ON dp.major_id=o.object_id
  LEFT JOIN sys.schemas AS obj_sch ON o.schema_id = obj_sch.schema_id
  LEFT JOIN sys.types AS t ON dp.major_id = t.user_type_id
  LEFT JOIN sys.schemas AS s_types ON t.schema_id = s_types.schema_id
WHERE dpr.name = 'youruser'
-- dpr.name NOT IN ('public','guest') 
--  AND o.name IN ('My_Procedure')      -- Uncomment to filter to specific object(s)
--  AND (o.name NOT IN ('My_Procedure') or o.name is null)  -- Uncomment to filter out specific object(s), but include rows with no o.name (VIEW DEFINITION etc.)
--  AND dp.permission_name='EXECUTE'    -- Uncomment to filter to just the EXECUTEs
--  AND dpr.name LIKE '%user_name%'     -- Uncomment to filter to just matching users
ORDER BY dpr.name, dp.class_desc, dp.permission_name
```