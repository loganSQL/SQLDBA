use msdb
go

create procedure showReportDocument
as 
SELECT 
Name
,Path
INTO #ReportList
FROM ReportServer.dbo.Catalog 
WHERE Content IS NOT NULL
ORDER BY Name;

 SELECT DISTINCT Name as ReportName
,ParameterName = Paravalue.value('Name[1]', 'VARCHAR(250)') 
  ,ParameterType = Paravalue.value('Type[1]', 'VARCHAR(250)') 
  ,ISNullable = Paravalue.value('Nullable[1]', 'VARCHAR(250)') 
  ,ISAllowBlank = Paravalue.value('AllowBlank[1]', 'VARCHAR(250)') 
  ,ISMultiValue = Paravalue.value('MultiValue[1]', 'VARCHAR(250)') 
  ,ISUsedInQuery = Paravalue.value('UsedInQuery[1]', 'VARCHAR(250)') 
  ,ParameterPrompt = Paravalue.value('Prompt[1]', 'VARCHAR(250)') 
  ,DynamicPrompt = Paravalue.value('DynamicPrompt[1]', 'VARCHAR(250)') 
  ,PromptUser = Paravalue.value('PromptUser[1]', 'VARCHAR(250)') 
  ,State = Paravalue.value('State[1]', 'VARCHAR(250)') 
INTO #ReportParameters
 FROM (  
SELECT top 1000 C.Name,CONVERT(XML,C.Parameter) AS ParameterXML
FROM  ReportServer.dbo.Catalog C
WHERE  C.Content is not null
AND  C.Type  = 2
 ) a
CROSS APPLY ParameterXML.nodes('//Parameters/Parameter') p ( Paravalue )
ORDER BY ReportName,ParameterName;

WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition', 'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd )
SELECT DISTINCT ReportName = name
    ,DataSetName = x.value('(@Name)[1]', 'VARCHAR(250)') 
 ,DataSourceName = x.value('(Query/DataSourceName)[1]','VARCHAR(250)')
 ,CommandText = x.value('(Query/CommandText)[1]','VARCHAR(250)')
 ,Fields = df.value('(@Name)[1]','VARCHAR(250)')
 ,DataField = df.value('(DataField)[1]','VARCHAR(250)')
 ,DataType = df.value('(rd:TypeName)[1]','VARCHAR(250)')
 ,ConnectionString = x.value('(ConnectionProperties/ConnectString)[1]','VARCHAR(250)')
INTO #ReportFields
 FROM ( SELECT C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
      FROM ReportServer.dbo.Catalog C
     WHERE C.Content is not null
      AND C.Type = 2
 ) a
 CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet') r ( x )
 CROSS APPLY x.nodes('Fields/Field') f(df) 
ORDER BY name 

SELECT 
a.Name AS ReportName
,a.Path
,SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)) AS ReportFolder
,'http://'+@@servername+'/Reports/Pages/Report.aspx?ItemPath='+REPLACE(SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)),'/','%2f')+REPLACE(a.Name,' ','+') AS ReportLink
,'User Input' AS FieldType
,b.ParameterPrompt AS DataSetOrPromptName
,b.ParameterName AS FieldOrParameterName
FROM #ReportList a
LEFT OUTER JOIN #ReportParameters b ON a.Name = b.ReportName
WHERE b.ParameterName IS NOT NULL
UNION
SELECT 
a.Name AS ReportName
,a.Path
,SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)) AS ReportFolder
,'http://'+@@servername+'/Reports/Pages/Report.aspx?ItemPath='+REPLACE(SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)),'/','%2f')+REPLACE(a.Name,' ','+') AS ReportLink
,'Data Point' AS FieldType
,b.DataSetName AS DataSetOrPromptName
,b.Fields AS FieldOrParameterName
FROM #ReportList a
LEFT OUTER JOIN #ReportFields b ON a.Name = b.ReportName
WHERE b.Fields IS NOT NULL
ORDER BY Name,Path,FieldType,ParameterPrompt,ParameterName
go