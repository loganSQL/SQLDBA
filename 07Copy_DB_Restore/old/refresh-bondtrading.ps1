$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
 
E:
CD \scripts

$OutputFileLocation = ".\logs\Bondtrading.txt"
Clear-Content $OutputFileLocation
Start-Transcript -path $OutputFileLocation -append

# redirecting both STDOUT and STDERR (2>&1) to transcript:

.\copy-dbbackup-restore.ps1 -dbname Bondtrading -servername fnsql09 -target_path "E:\backup" -target_svr TORQFNSQL13 2>&1 | out-host


Stop-Transcript