## Microsoft SSRS DR Scripts
### Primary Server
#### Backup of Databases
```
BACKUP DATABASE [ReportServer] TO  DISK = N'F:\Backup\ReportServer_backup_2018_06_24_200001_8214026.bak' WITH NOFORMAT, NOINIT,  NAME = N'ReportServer-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP DATABASE [ReportServerTempDB] TO  DISK = N'F:\Backup\ReportServerTempDB_backup_2018_06_24_200001_8214026.bak' WITH NOFORMAT, NOINIT,  NAME = N'ReportServerTempDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
```
#### Backup Config Files and Encryption Key
```
copy "C:\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER\Reporting Services\ReportServer\*.config" F:\Database\Backup\RSBackup
echo Y | "C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\rskeymgmt" -e -fF:\Backup\RSBackup\rskey.snk -p "MyRSKeyPwd"
```

### Secondary Server (DR)
#### RS_Copy.ps1: Transfer Files from PrimaryHost to SecondaryHost
```
<#
1.  RS_Copy.ps1: Transfer Files from PrimaryHost to SecondaryHost
#>
#
$srcpath="\\PRIMARYHOST\F$\Backup\RSBackup"
$srcBackupPath="\\PRIMARYHOST\F$\Backup"
$tgtpath="\\DRHOST\f$\DBBackup\RSBackup"
#
cd $srcpath
#
#
# copy Ship the rskey and Config file
#
copy rskey $tgtpath
copy *.config $tgtpath
#
cd $srcBackupPath

#
# Copy ReportServer DB backup
#
$srcfile=Get-ChildItem "ReportServer_**.bak" | select -last 1 name

copy $srcfile.name $tgtpath\ReportServer_backup.bak

#
# Copy ReportServerTempDB backup
#

$srcfile=Get-ChildItem "ReportServerTempDB*.bak" | select -last 1 name

copy $srcfile.name $tgtpath\ReportServerTempDB_backup.bak

#
# Housekeep backup files older than 1 day
#
$today=get-date
$yesterday=$today.AddDays(-1)
Get-CHildItem $tgtpath *.bak | Where-Object { $_.LastWriteTime -lt $yesterday } | Remove-Item

```
### RS_Restore_DB.sql: Restore ReportServer Databases
```
/*
2.  RS_Restore_DB

ASSUMING REPORTING SERVICE IS STOPPED ON Secondary Server (DR Host)
NET STOP "SQL Server Reporting Services (MSSQLSERVER)"
*/

use master
go

-- Skip this when mirror setup
RESTORE DATABASE [ReportServer] 
FROM  DISK = N'F:\RSBackup\ReportServer_backup.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10
GO


RESTORE DATABASE [ReportServerTempDB] 
FROM  DISK = N'F:\RSBackup\ReportServerTempDB_backup.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10
GO
```
### Restore ReportServer Config file
```
copy F:\DBBackup\RSBackup\*.config " D:\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER\Reporting Services\ReportServer "
```

### Start SSRS Service on DR Host
```
@ECHO ON

REM 1) START RS SERVICE
NET START "SQL Server Reporting Services (MSSQLSERVER)"

REM 2) Configure RS
RSConfig -e -m DRHOST -i MSSQLSERVER -d ReportServer


REM 3) Restore Encryption Keys
echo Y|rskeymgmt -a -f F:\DBBackup\RSBackup\rskey -p MyRSKeyPwd

REM 4) Remember to change SSRS to AUTOSTART
```
