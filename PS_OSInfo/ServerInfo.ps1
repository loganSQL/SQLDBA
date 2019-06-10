
# The scrip run a standard script on a list of sql instance
# it consolidates the result into the table of report instance

$MyRptInstance="MyRptInstance"
sqlcmd -S  -E -Q "truncate table DBA..ServerInfo"

$servers=@(
"MyInst1",
"MyInst2") 

$Query = "
drop table tempdb..ServerInfo;
SELECT SERVERPROPERTY('ServerName') AS [SQLServerName]
, SERVERPROPERTY('ProductVersion') AS [SQLProductVersion]
, SERVERPROPERTY('ProductMajorVersion') AS [ProductMajorVersion]
, SERVERPROPERTY('ProductMinorVersion') AS [ProductMinorVersion]
, SERVERPROPERTY('ProductBuild') AS [ProductBuild]
,LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')),4) As 'ProductionVersion'
, CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')),4) 
   WHEN '8.00' THEN 'SQL Server 2000'
   WHEN '9.00' THEN 'SQL Server 2005'
   WHEN '10.0' THEN 'SQL Server 2008'
   WHEN '10.5' THEN 'SQL Server 2008 R2'
   WHEN '11.0' THEN 'SQL Server 2012'
   WHEN '12.0' THEN 'SQL Server 2014'
   ELSE 'SQL Server 2016+'
  END AS [SQLVersionBuild]
, SERVERPROPERTY('ProductLevel') AS [SQLServicePack]
, SERVERPROPERTY('Edition') AS [SQLEdition]
, RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3) as [WindowsVersionNumber]
, CASE RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3)
   WHEN '5.0' THEN 'Windows 2000'
   WHEN '5.1' THEN 'Windows XP'
   WHEN '5.2' THEN 'Windows Server 2003/2003 R2'
   WHEN '6.0' THEN 'Windows Server 2008/Windows Vista'
   WHEN '6.1' THEN 'Windows Server 2008 R2/Windows 7'
   WHEN '6.2' THEN 'Windows Server 2012/Windows 8'
   WHEN '6.3' THEN 'Windows Server 2012 R2'
   ELSE 'Windows 2012 R2+, Windows Server 2016,RTM'
  END AS [WindowsVersionBuild]
into tempdb..ServerInfo"


foreach ($server in $servers) {

 Write-Host $server 
 $myfile="C:\TEMP\"+$server+".txt"
 
 # get the information into tempdb..ServerInfo
 sqlcmd -E -S $server -Q $Query

 # bcp out
 bcp ServerInfo out $myfile -S $server -d tempdb -T -t -c

 # bcp in
 bcp ServerInfo in $myfile -S MyRptInstance -d DBA -T -t -c

 # remove the temp file
 remove-item $myfile
 }