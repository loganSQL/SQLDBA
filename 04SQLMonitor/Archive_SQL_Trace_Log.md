# Archive SQL Trc Logs

By default, SQL default trace is limited 20MB per log file. Once the file is filled, SQL Server starts another file. Up to 5 files are used (5x20MB=100MB).

It is very critical to move the sql trace log files to another folder before they are deleted. The following powershell script will do the trick.

```
[CmdletBinding()]   
 PARAM(
  [string]$servername
 ) 

## 1. Automatically obtain servername from hostname
if (!$servername)
{
'.\trc_archiver.ps1 -servername SERVERNAME'  
 $servername=$(hostname)
## exit
}

$servername


## 2. Get SQL Trace Log file / path
$trcfile=sqlcmd -E -S $servername -h-1 -Q "SET NOCOUNT ON; SELECT PATH FROM sys.traces WHERE id=1"
$trcfile=(Get-ChildItem $trcfile.Trim())
$SQLLog=$trcfile.DirectoryName

$SQLLog

## 3. Get backup default folder
$BackupDir=sqlcmd -E -S $servername -h-1 -Q "
SET NOCOUNT ON;
DECLARE @path NVARCHAR(4000);
EXEC  master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory',@path OUTPUT;
select @PATH as BackupDir
"
$BackupDir=$BackupDir.Trim()

## 4. Create .\trc_archive directory under $BackupDir
$BackupDir=$BackupDir+'\trc_archive'

if (!(test-path $BackupDir)) {
  mkdir $BackupDir
}


## 5. Get all current trace logs  
dir $SQLLog/*.trc

## 6. Archive them
cd $BackupDir
copy $SQLLog\*.trc .\

## 7. Housekeep  .\trc_archive for 365 days
## housekeep after 365 days
## FORFILES /p $BackupDir /s /m log_*.trc /d -365 /c "CMD /C echo @FILE to be deleted"
FORFILES /p $BackupDir /s /m log_*.trc /d -365 /c "CMD /C del /Q /F @FILE" 2>$BackupDir/trc_archive_housekeep_log.txt 
```