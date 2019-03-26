use msdb
go
create procedure showReportCatalog as 
SELECT 
@@servername ServerName, 
C.NAME as ReportName, 
C.PATH as ReportPath,
CASE 
WHEN C.type = 1 THEN '1-Folder' 
WHEN C.type = 2 THEN '2-Report' 
WHEN C.type = 3 THEN '3-File' 
WHEN C.type = 4 THEN '4-Linked Report' 
WHEN C.type = 5 THEN '5-Datasource' 
WHEN C.type = 6 THEN '6-Model' 
WHEN C.type = 8 THEN '8-Shared Dataset'
WHEN C.type = 9 THEN '9-Report Part'
WHEN C.type = 11 THEN 'KPI'
WHEN C.type = 12 THEN 'Mobile Report (folder)'
WHEN C.type = 13 THEN 'Power BI Desktop Document'
ELSE 'Unknown' END AS ReportType
--CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.CONTENT))) AS REPORTXML
FROM  REPORTSERVER.DBO.CATALOG C
--WHERE  C.TYPE not in (1,5)
go