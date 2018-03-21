[CmdletBinding()]
#
# .\make_a_script_for_a_db_restore.ps1 -dbname DBNAME
Param (
  [string]$dbname
)

$MyServer='MyServer'

if (!$dbname )
{
'Create a script for a database.
 Usage: .\make_a_script_for_a_db_restore.ps1 -dbname DBNAME'	
 exit
}
else
{
# make a script file from template script MyDB.sql
$myfile=$dbname+'.sql'
(Get-Content .\MyDB.sql).replace('MyDB', $dbname) > $myfile



# Append Orphan Fixer to the script

'--Orphan Fixer' >> $myfile

sqlcmd -S $MyServer -d $dbname -E -h -1 -i .\syncOrphan.sql >> $myfile
'GO' >> $myfile

# Show the file
$myfile
'---------------------'
Get-content $myfile
}
