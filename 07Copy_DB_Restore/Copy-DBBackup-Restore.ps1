[CmdletBinding()]
Param (
  [string]$dbname,
  [string]$servername,
  [string]$target_path,
  [string]$target_svr
)

#
# Assume the params are checked.
# .\creationscripts\$dbname.sql were run first
# .\restorescripts\$dbname.sql exist
# 
'=> Copy-DBBackup-Restore.ps1 -dbname DBNAME -servername SERVERNAME -target_path TARGETPATH -target_svr TARGETSERVER'	
$myscript="SET NOCOUNT ON; SELECT top 1 rtrim(physical_device_name) FROM msdb.dbo.backupset b JOIN msdb.dbo.backupmediafamily m ON b.media_set_id = m.media_set_id WHERE database_name = '"+$dbname+"' and type='D' ORDER BY backup_finish_date DESC"
$backupfile=sqlcmd -E -S $servername -h-1 -Q $myscript
$backupfile=$backupfile.trim()
$backupfile=$backupfile -replace ":" , "$"

$mysrc="\\"+$servername+"\"+$backupfile
$mydst=$target_path+"\"+$dbname+".bak"
$cmd="copy"
'=> {0} {1} {2}' -f $cmd, $mysrc, $mydst
& $cmd $mysrc $mydst

ls -l $mydst

$restorescript=(Get-Item -Path ".\" -Verbose).FullName + '\restorescripts\' + $dbname+'.sql'

$restorescript

If (Test-Path $restorescript)
{

  'Running restoring database script : '+$restorescript
  sqlcmd -E -S $target_svr -i $restorescript
}
else 
{
  "Error : Are you serious? The restoring database script doesn't exist : "+$restorescript
}
