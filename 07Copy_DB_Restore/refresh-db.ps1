[CmdletBinding()]

# .\refresh-db.ps1 -dbname DBNAME -servername SERVERNAME -target_path TARGETPATH -target_svr TARGETSERVER

Param (
  [string]$dbname,
  [string]$servername,
  [string]$target_path,
  [string]$target_svr
)

if (!$dbname -or !$servername -or !$target_path -or !$target_svr )
{
'refresh database DBNAME backup from server SERVERNAME to target path TARGETPATH on TARGETSERVER'
'.\refresh-db.ps1 -dbname DBNAME -servername SERVERNAME -target_path TARGETPATH -target_svr TARGETSERVER'	
 exit
}
else
{
'refresh-db {0}, {1}, {2}, {3}' -f $dbname, $servername, $target_path, $target_svr
}


# create target directories 
if(!(Test-Path -Path $target_path )){
    New-Item -ItemType directory -Path $target_path
}

# create log directory under current script dir
$OutputFileLocation = (Get-Item -Path ".\" -Verbose).FullName +'\logs'
if(!(Test-Path -Path $OutputFileLocation )){
    New-Item -ItemType directory -Path $OutputFileLocation
}

$OutputFileLocation = $OutputFileLocation + '\'+$dbname+'.txt'
Clear-Content $OutputFileLocation

# create dump directory under target
$target_path=$target_path+'\'+$servername

if(!(Test-Path -Path $target_path )){
    New-Item -ItemType directory -Path $target_path
}

# prepare and start transcript

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"

Start-Transcript -path $OutputFileLocation -append

# redirecting both STDOUT and STDERR (2>&1) to transcript:

.\copy-dbbackup-restore.ps1 -dbname $dbname -servername $servername -target_path $target_path -target_svr $target_svr 2>&1 | out-host


Stop-Transcript