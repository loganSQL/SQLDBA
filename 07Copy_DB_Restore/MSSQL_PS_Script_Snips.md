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


