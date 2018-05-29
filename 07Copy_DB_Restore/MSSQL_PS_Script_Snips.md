# Backup & Restore Powershell Script Snips  

### sql server database backup with timestamp file name.
```
$dt = Get-Date -Format yyyy_MM_dd_HHmmss_ffffff

# Environment
$inst="MyInstance"
$db = "MyDB"
$bakfile="E:\backup\$($inst)\$($db)_backup_$($dt).bak"

# Backup
Write-Output "backup database $db on $inst to disk file = $bakfile"
Backup-SqlDatabase -ServerInstance $inst -Database $db  -BackupFile $bakfile
```

### backup all databases 
```

# Environment
$Myhost=hostname

# Backup
foreach ($database in (Get-ChildItem "SQLSERVER:\SQL\$($MyHost)\Default\Databases" )) {
     $dt = Get-Date -Format yyyy_MM_dd_HHmmss_ffffff
     $dbName = $database.Name
     $bakfile="E:\backup\$($MyHost)\$($dbName)_backup_$($dt).bak"
     Write-Output "backup database $dbName on $MyHost to disk file = $bakfile"
     Backup-SqlDatabase -ServerInstance $MyHost -Database $dbName  -BackupFile $bakfile}
```

### Archive and Compress

```
# to generate the backup folder
E:\scripts\backup.ps1
$bakdir="E:\backup\MyHost\MyDir"
$bakname=$bakdir+"_"+(Get-Date -Format yyyy_MM_dd_HHmmss_ffffff)+".bak"
compress-archive -Path $bakdir -DestinationPath $bakname -Force
```

### Navigate SQLServer Drive in PS
```
# Check PSProvider
Get-PSProvider

# if SQLSERVER is not loaded

Invoke-Sqlcmd
Get-PSProvider

# Investigate
Set-Location "SQLSERVER:\SQL\MyHost"
dir
cd DEFAULT
cd Databases
Get-ChildItem
# Backup the database from the location
Backup-SqlDatabase -Database "MyDB"
# Backup the transaction Log
Backup-SqlDatabase -Database "MyDB" -BackupAction Log
# Backup all databases
Get-ChildItem "SQLSERVER:\SQL\MyHost\Default\Databases" | Backup-SqlDatabase
#
foreach ($database in (Get-ChildItem)) {
     $dbName = $database.Name
     Backup-SqlDatabase -Database $dbName -BackupFile "\\mainserver\databasebackup\$dbName.bak" }
```

### Simple BCP
```
$database = "DBA"
$schema = "dbo"
$table = "disk_usages_size"
$filename = "C:\logan\Temp\disk_usages_size.txt"

$bcp = "bcp $($database).$($schema).$($table) out $filename -T -c"
Invoke-Expression $bcp
```
### BCP a list of tables
```
Set-Location SQLSERVER:\SQL\"myserver\myinstance"\Databases\"DBA"\Tables
$ServerName = Invoke-Sqlcmd -query "SELECT @@ServerName" 
$timestamp = Get-Date -Format yyyy-MM

$bcpoptions = '-E -T'

$TableList = Invoke-Sqlcmd -query "select name from DBA..sysobjects (nolock) where name like 'MyTablePrefix%' and type = 'U'" 

foreach($item in $TableList) {
  $table = $item.name
  $Query = 'select * from DBA.dbo.' + $table
  #...

  $Target = "\\"+$ServerName.Column1 + '\E$\Backup' + $table + '_' + $timestamp + '.txt'

  bcp $Query  QUERYOUT $Target -n $bcpOptions -S $ServerName.Column1 }
```