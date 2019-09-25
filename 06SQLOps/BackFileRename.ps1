# this script is toe remove the timestamp suffix from the backup files
Set-Location "\\YourHost\d$\DBBackup"

$BackupName = ""
get-item *_backup*.bak | 
Foreach-Object {
    $_.Name
     $BackupName = $_.Name.Substring(0,$_.Name.IndexOf('_backup'))+'.bak'
    Rename-Item $_.Name $BackupName

}
