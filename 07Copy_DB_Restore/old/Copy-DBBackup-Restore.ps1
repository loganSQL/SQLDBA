[CmdletBinding()]
Param (
  [string]$dbname,
  [string]$servername,
  [string]$target_path,
  [string]$target_svr
)

if (!$dbname -or !$servername -or !$target_path -or !$target_svr )
{
'Copy database DBNAME backup from server SERVERNAME to target path TARGETPATH on TARGETSERVER'
'Copy-DBBackup-Restore -dbname DBNAME -servername SERVERNAME -target_path TARGETPATH -target_svr TARGETSERVER'	
}
else
{
'Copy-DBBackup-Restore {0}, {1}, {2}, {3}' -f $dbname, $servername, $target_path, $target_svr
}


if(!(Test-Path -Path $target_path )){
    New-Item -ItemType directory -Path $target_path
}

$target_path=$target_path+'\'+$servername

if(!(Test-Path -Path $target_path )){
    New-Item -ItemType directory -Path $target_path
}


$myscript="SET NOCOUNT ON; SELECT top 1 rtrim(physical_device_name) FROM msdb.dbo.backupset b JOIN msdb.dbo.backupmediafamily m ON b.media_set_id = m.media_set_id WHERE database_name = '"+$dbname+"' and type='D' ORDER BY backup_finish_date DESC"
$backupfile=sqlcmd -E -S $servername -h-1 -Q $myscript
$backupfile=$backupfile.trim()
$backupfile=$backupfile -replace ":" , "$"

$mysrc="\\"+$servername+"\"+$backupfile
$mydst=$target_path+"\"+$dbname+".bak"
$cmd="copy"
'....=> {0}, {1}, {2}' -f $cmd, $mysrc, $mydst
& $cmd $mysrc $mydst

ls -l $mydst

$restorescript=(Get-Item -Path ".\" -Verbose).FullName + '\restorescripts\' + $dbname+'.sql'

$restorescript

If ((Test-Path $restorescript) -and ($target_svr -eq 'TORQFNSQL13'))
{

  'Running restoring database script : '+$restorescript
  sqlcmd -E -S $target_svr -i $restorescript
}
else 
{
  "Error : Are you serious? The restoring database script doesn't exist : "+$restorescript
}
