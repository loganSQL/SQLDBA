[CmdletBinding()]
# Make a database creation script from template MyDB.sql
# .\make_a_script_for_a_db.ps1 -dbname DBNAME
Param (
  [string]$dbname
)

if (!$dbname )
{
'Create a script for a database.
 Usage: .\make_a_script_for_a_db.ps1 -dbname DBNAME'	
 exit
}
else
{
# make a script file from template script MyDB.sql
$myfile=$dbname+'.sql'
(Get-Content .\MyDB.sql).replace('MyDB', $dbname) > $myfile

$myfile
'---------------------'
Get-content $myfile
}
