[CmdletBinding()]
Param (
  [string]$HostList,
  [string]$UserList
)

#

<#
$ipAddress="172.16.50.151"
$hostName=[System.Net.Dns]::GetHostByAddress($ipAddress).Hostname
(Get-WmiObject -Class win32_process -ComputerName $hostName | Where-Object name -Match explorer).getowner().user
#>

<#
-- to finger print those users who use "Micrsoft SQL Server Management Studio%" connect directly to sql server
select host_name, program_name, login_name, client_version, client_interface_name, original_login_name,original_security_id 
from sys.dm_exec_sessions
where program_name like 'Microsoft SQL Server Management Studio%' and login_name='???'
#>

if (!$HostList -or !$UserList )
{
'get current logged on UserList from HostList'
'.\get-user-from-HostList.ps1 -HostList yourHostListInputFilename -UserList yourUserListOutputFilename'	
 exit
}
else
{
'get-user-from-HostList.ps1 {0}, {1}' -f $HostList, $UserList
}
$MyADDomain = "My_AD_Domain"
$MyBinPath="C:\logan\bin"

$MyInput = $HostList
$MyOutput = $UserList

"HostName : UserLoggedOnLocally">$MyOutput
"--------   -------------------">>$MyOutput
Get-Content $MyInput | ForEach-Object{
    $hostname = $_
    $hostname
    # https://docs.microsoft.com/en-us/sysinternals/downloads/psloggedon
    if (!(Get-Command "PsLoggedon.exe" -ErrorAction SilentlyContinue))
      {$env:Path += ";C:\logan\bin"}

    PsLoggedon.exe \\$hostName |findstr $MyADDomain >.\tmp.txt
    if ((get-content "tmp.txt") -eq $Null) {
    $username="The host is offline"
    }
    else
    {
    $myline = Get-Content .\tmp.txt -First 1
    $username = $myline.substring(32)
    }
    $hostname +" : "+ $username >> $MyOutput

    <#$has_explorer = Get-WmiObject -Class win32_process -ComputerName $hostname | Where-Object name -Match explorer
    if ($has_explorer) {
    $username = $has_explorer.getowner().user
    }
    else
    {
    $username ="No one is logged on locally"
    }
    $hostname +" : "+ $username >> $MyOutput
    #>
}
get-content $MyOutput