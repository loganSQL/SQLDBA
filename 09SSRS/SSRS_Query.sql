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

--
Select MachineName,InstallationID,InstanceName,Client,PublicKey,SymmetricKey from Keys
Where MachineName IS NOT NULL

-- 
Select Name,Value from ConfigurationInfo

-- roles
Select RoleName,Description from Roles