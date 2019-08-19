/*
 Queries of SSRS ReportServer Meta Data
 https://blogs.technet.microsoft.com/dbtechresource/2015/04/04/retrieve-ssrs-report-server-database-information/

 */


-- List all SSRS subscriptions 
USE [ReportServer];  -- You may change the database name. 
GO 
 
SELECT USR.UserName AS SubscriptionOwner 
      ,CAT.[Path] AS ReportPath 
      ,CAT.[Description] AS ReportDescription 
      ,SUB.ModifiedDate 
      ,SUB.[Description] 
      ,SUB.EventType 
      ,SUB.DeliveryExtension 
      ,SUB.LastStatus 
      ,SUB.LastRunTime 
      ,SCH.NextRunTime 
      ,SCH.Name AS ScheduleName       
FROM dbo.Subscriptions AS SUB 
     INNER JOIN dbo.Users AS USR 
         ON SUB.OwnerID = USR.UserID 
     INNER JOIN dbo.[Catalog] AS CAT 
         ON SUB.Report_OID = CAT.ItemID 
     INNER JOIN dbo.ReportSchedule AS RS 
         ON SUB.Report_OID = RS.ReportID 
            AND SUB.SubscriptionID = RS.SubscriptionID 
     INNER JOIN dbo.Schedule AS SCH 
         ON RS.ScheduleID = SCH.ScheduleID 
ORDER BY USR.UserName 
        ,CAT.[Path];


-- List All DS and Dependencies
Select distinct Name from DataSource Where Name is NOT NULL

-- and Dependencies
SELECT
    DS.Name AS DatasourceName,
    C.Name AS DependentItemName, 
    C.Path AS DependentItemPath
FROM
    ReportServer.dbo.Catalog AS C 
        INNER JOIN
    ReportServer.dbo.Users AS CU
        ON C.CreatedByID = CU.UserID
        INNER JOIN
    ReportServer.dbo.Users AS MU
        ON C.ModifiedByID = MU.UserID
        LEFT OUTER JOIN
    ReportServer.dbo.SecData AS SD
        ON C.PolicyID = SD.PolicyID AND SD.AuthType = 1
        INNER JOIN
    ReportServer.dbo.DataSource AS DS
        ON C.ItemID = DS.ItemID
WHERE
    DS.Name IS NOT NULL
ORDER BY
    DS.Name;

-- List all reports

select c.ItemID, c.Path, c.CreationDate, c.ModifiedDate, c.Content, c.Type
from dbo.Catalog c with(nolock)
where c.Type = 2 -- Report

-- list all and owner
Select C.Name,C.Path,U.UserName,C.CreationDate,C.ModifiedDate 
from Catalog C
INNER Join Users U ON C.CreatedByID=U.UserID

-- Detailed types
SELECT
  ItemID -- Unique Identifier
, [Path] --Path including object name
, [Name] --Just the objectd name
, ParentID --The ItemID of the folder in which it resides
, CASE [Type] --Type, an int which can be converted using this case statement.
    WHEN 1 THEN 'Folder'
    WHEN 2 THEN 'Report'
    WHEN 3 THEN 'File'
    WHEN 4 THEN 'Linked Report'
    WHEN 5 THEN 'Data Source'
    WHEN 6 THEN 'Report Model - Rare'
    WHEN 7 THEN 'Report Part - Rare'
    WHEN 8 THEN 'Shared Data Set - Rare'
    WHEN 9 THEN 'Image'
    ELSE CAST(Type as varchar(100))
  END AS TypeName
--, content
, LinkSourceID --If a linked report then this is the ItemID of the actual report.
, [Description] --This is the same information as can be found in the GUI
, [Hidden] --Is the object hidden on the screen or not
, CreatedBy.UserName CreatedBy
, CreationDate
, ModifiedBy.UserName ModifiedBy
, ModifiedDate
FROM 
  ReportServer.dbo.[Catalog] CTG
    INNER JOIN 
  ReportServer.dbo.Users CreatedBy ON CTG.CreatedByID = CreatedBy.UserID
    INNER JOIN
  ReportServer.dbo.Users ModifiedBy ON CTG.ModifiedByID = ModifiedBy.UserID
ORDER BY CTG.Type, CTG.Path

-- list report contents
SELECT
  [Path]
, CASE [Type]
    WHEN 2 THEN 'Report'
    WHEN 5 THEN 'Data Source'    
  END AS TypeName
, CAST(CAST(content AS varbinary(max)) AS xml)
, [Description]
FROM ReportServer.dbo.[Catalog] CTG
WHERE
  [Type] IN (2, 5);


-- Execution Log
SELECT * FROM dbo.ExecutionLog

-- more detail 
SELECT * FROM dbo.ExecutionLog2

-- more more
SELECT * FROM dbo.ExecutionLog3

SELECT
  [ItemPath] --Path of the report
, [UserName]  --Username that executed the report
, [RequestType] --Usually Interactive (user on the scree) or Subscription
, [Format] --RPL is the screen, could also indicate Excel, PDF, etc
, [TimeStart]--Start time of report request
, [TimeEnd] --Completion time of report request
, [TimeDataRetrieval] --Time spent running queries to obtain results
, [TimeProcessing] --Time spent preparing data in SSRS. Usually sorting and grouping.
, [TimeRendering] --Time rendering to screen
, [Source] --Live = query, Session = refreshed without rerunning the query, Cache = report snapshot
, [Status] --Self explanatory
, [RowCount] --Row count returned by a query
, [Parameters]
FROM ReportServer.dbo.ExecutionLog3


-- subscription
SELECT
  ctg.[Path]
, s.[Description] SubScriptionDesc
, sj.[description] AgentJobDesc
, s.LastStatus
, s.DeliveryExtension
, s.[Parameters]
FROM
  ReportServer.dbo.[Catalog] ctg 
    INNER JOIN 
  ReportServer.dbo.Subscriptions s on s.Report_OID = ctg.ItemID
    INNER JOIN
  ReportServer.dbo.ReportSchedule rs on rs.SubscriptionID = s.SubscriptionID
    INNER JOIN
  msdb.dbo.sysjobs sj ON CAST(rs.ScheduleID AS sysname) = sj.name
ORDER BY
  rs.ScheduleID;

-- machine and installation ID  for SSRS
Select MachineName,InstallationID,InstanceName,Client,PublicKey,SymmetricKey from Keys
Where MachineName IS NOT NULL

-- configuration
Select Name,Value from ConfigurationInfo

-- roles
Select RoleName,Description from Roles



-- oldest time stamp
SELECT COUNT(*),
       MIN(ExecutionLog.TimeStart)
FROM [ReportServer].[dbo].ExecutionLog(NOLOCK);

-- Last 100 execution
SELECT TOP 100 c.Name,
               c.[Path],
               l.InstanceName,
               l.ReportID,
               l.UserName,
               l.RequestType,
               l.Format,
               l.Parameters,
               l.TimeStart,
               l.TimeEnd,
               l.TimeDataRetrieval,
               l.TimeProcessing,
               l.TimeRendering,
               l.Source,
               l.Status,
               l.ByteCount,
               l.[RowCount]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
ORDER BY l.TimeStart DESC;

-- list all reports last time time
SELECT c.Name,
       c.[Path],
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastRun]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
GROUP BY l.ReportId,
         c.Name,
         c.[Path];


-- List the reports with the number of executions and time last run, including datasources
SELECT c.Name,
       c.[Path],
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastRun],
(
    SELECT SUBSTRING(
                    (
                        SELECT CAST(', ' AS VARCHAR(MAX))+CAST(c1.Name AS VARCHAR(MAX))
                        FROM [ReportServer].[dbo].[Catalog] AS c
                        INNER JOIN [ReportServer].[dbo].[DataSource] AS d ON c.ItemID = d.ItemID
                        INNER JOIN [ReportServer].[dbo].[Catalog] c1 ON d.Link = c1.ItemID
                        WHERE c.Type = 2
                              AND c.ItemId = l.ReportId
                        FOR XML PATH('')
                    ), 3, 10000000) AS list
) AS DataSources
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
GROUP BY l.ReportId,
         c.Name,
         c.[Path];

-- List the reports with the number of executions and time last run, including datasources and who has been using the report
SELECT c.Name,
       c.[Path],
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastRun],
(
    SELECT SUBSTRING(
                    (
                        SELECT CAST(', ' AS VARCHAR(MAX))+CAST(c1.Name AS VARCHAR(MAX))
                        FROM [ReportServer].[dbo].[Catalog] AS c
                        INNER JOIN [ReportServer].[dbo].[DataSource] AS d ON c.ItemID = d.ItemID
                        INNER JOIN [ReportServer].[dbo].[Catalog] c1 ON d.Link = c1.ItemID
                        WHERE c.Type = 2
                              AND c.ItemId = l.ReportId
                        FOR XML PATH('')
                    ), 3, 10000000) AS list
) AS DataSources,
(
    SELECT SUBSTRING(
                    (
                        SELECT CAST(', ' AS VARCHAR(MAX))+CAST(REPLACE(t.UserName, 'DOMAIN_NAME\', '') AS VARCHAR(MAX))
                        FROM
                        (
                            SELECT TOP 100000 l2.UserName+'('+CAST(COUNT(*) AS VARCHAR(100))+')' AS UserName
                            FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l2
                            WHERE l2.ReportID = l.ReportId
                            GROUP BY l2.UserName
                            ORDER BY COUNT(*) DESC
                        ) AS t
                        FOR XML PATH('')
                    ), 3, 10000000)
) AS UsedBy
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
GROUP BY l.ReportId,
         c.Name,
         c.[Path];

-- Reports that haven’t been run since the last time the log was cleared.
SELECT c.Name,
       c.[Path]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
RIGHT OUTER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
      AND l.ReportID IS NULL;

-- Reports by count that have been run in the last 24 hours
SELECT c.Name,
       c.[Path],
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastRun]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
      AND l.TimeStart > GETDATE() - 1
GROUP BY l.ReportId,
         c.Name,
         c.[Path];


-- Reports by count that have been run in the last 7 days
SELECT c.Name,
       c.[Path],
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastRun]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
      AND l.TimeStart > GETDATE() - 7
GROUP BY l.ReportId,
         c.Name,
         c.[Path];

-- reports used by user
SELECT l.UserName,
       COUNT(*) AS TimesRun,
       MAX(l.TimeStart) AS [LastReportRun]
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
GROUP BY l.UserName;
 
-- Reports Datasource

SELECT c.name,
       c1.Name datasource,
       c.ItemId
FROM [ReportServer].[dbo].[Catalog] AS c
INNER JOIN [ReportServer].[dbo].[DataSource] AS d ON c.ItemID = d.ItemID
INNER JOIN [ReportServer].[dbo].[Catalog] c1 ON d.Link = c1.ItemID
WHERE c.Type = 2;

-- 
SELECT TOP 100 c.Name,
               c.[Path],
               AVG(l.TimeDataRetrieval + l.TimeProcessing + l.TimeRendering) / 1000.0 [AverageExecutionTimeSeconds],
               SUM(l.TimeDataRetrieval + l.TimeProcessing + l.TimeRendering) / 1000.0 [TotalExecutionTimeSeconds],
               SUM(l.TimeDataRetrieval + l.TimeProcessing + l.TimeRendering) / 1000.0 / 60 [TotalExecutionTimeMinutes],
               COUNT(*) TimesRun
FROM [ReportServer].[dbo].[ExecutionLog](NOLOCK) AS l
INNER JOIN [ReportServer].[dbo].[Catalog](NOLOCK) AS c ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
GROUP BY c.Name,
         c.[Path],
         l.InstanceName,
         l.ReportID
HAVING AVG(l.TimeDataRetrieval + l.TimeProcessing + l.TimeRendering) / 1000.0 > 1
ORDER BY AVG(l.TimeDataRetrieval + l.TimeProcessing + l.TimeRendering) DESC;
 

-- Long Running Reports by average execution time
SELECT c.Name,
       c.[Path],
       MAX(l.TimeStart) AS [LastRun]
FROM [ReportServer].[dbo].[ExecutionLog] AS l WITH (NOLOCK)
INNER JOIN [ReportServer].[dbo].[Catalog] AS c WITH (NOLOCK) ON l.ReportID = C.ItemID
WHERE c.Type = 2 -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
GROUP BY l.ReportId,
         c.Name,
         c.[Path]
ORDER BY [LastRun] DESC;
