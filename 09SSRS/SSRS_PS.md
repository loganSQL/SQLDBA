## SSRS Powershell Scripts
### PowerShell : ReportingServicesTools

* GitHub Project: https://github.com/Microsoft/ReportingServicesTools
* PowerShell Gallery: ***ReportingServicesTools***
* Installation of latest copy:
```
# PowerShell Gallery will host the latest stable version of our scripts
Install-Module -Name ReportingServicesTools
```
* Installation of development/test beta
```
# downloading the development/beta version of our scripts
Invoke-Expression (Invoke-WebRequest https://aka.ms/rstools)
```
* Help
```
# get a list of all functions: wrapping all functions into a signle PS module
Get-Command -Module ReportingServicesTools
```
* Blog: <https://blogs.msdn.microsoft.com/sqlrsteamblog/2016/11/07/community-contributions-to-the-powershell-scripts-for-reporting-services/>

### Script: List the ownership of all subscriptions
```
# Name: ListAll_SSRS_Subscriptions.ps1
# Parameters: 
#    server   - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
# Syntax: .\ListAll_SSRS_Subscriptions.ps1 "[server]/reportserver" "/"

Param(  
    [string]$server,  
    [string]$site  
   )  

$rs2010 += New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
$subscriptions += $rs2010.ListSubscriptions($site); # use "/" for default native mode site  

Write-Host " "  
Write-Host "----- $server's Subscriptions: "  
$subscriptions | select Path, report, Description, Owner, SubscriptionID, lastexecuted, Status
```
### Script: List all subscriptions owned by a specific user
```
# Name: ListAll_SSRS_Subscriptions4User.ps1
# Parameters:  
#    currentOwner - DOMAIN\USER that owns the subscriptions you wish to change  
#    server        - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
#    site        - use "/" for default native mode site  
# Syntax: .\ListAll_SSRS_Subscriptions4User.ps1 "[Domain]\[user]" "[server]/reportserver" "/"  
Param(  
    [string]$currentOwner,  
    [string]$server,  
    [string]$site  
)  

$rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
$subscriptions += $rs2010.ListSubscriptions($site);  

Write-Host " "  
Write-Host " "  
Write-Host "----- $currentOwner's Subscriptions: "  
$subscriptions | select Path, report, Description, Owner, SubscriptionID, lastexecuted,Status | where {$_.owner -eq $currentOwner}
```
### Script: Change ownership for all subscriptions owned by a specific user
```
# Name: ChangeALL_SSRS_SubscriptionOwner.ps1
# Parameters:  
#    currentOwner - DOMAIN\USER that owns the subscriptions you wish to change  
#    newOwner      - DOMAIN\USER that will own the subscriptions you wish to change  
#    server        - server and instance name (e.g. myserver/reportserver, myserver/reportserver_db2, myserver/_vti_bin/reportserver)  
# Syntax: \ChangeALL_SSRS_SubscriptionOwner.ps1 "[Domain]\current owner]" "[Domain]\[new owner]" "[server]/reportserver"

Param(  
    [string]$currentOwner,  
    [string]$newOwner,  
    [string]$server  
)  

$rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
$items = $rs2010.ListChildren("/", $true);  

$subscriptions = @();  

ForEach ($item in $items)  
{  
    if ($item.TypeName -eq "Report")  
    {  
        $curRepSubs = $rs2010.ListSubscriptions($item.Path);  
        ForEach ($curRepSub in $curRepSubs)  
        {  
            if ($curRepSub.Owner -eq $currentOwner)  
          # if ($curRepSub.Owner -eq $previousOwner)
            {  
                $subscriptions += $curRepSub;  
            }  
        }  
    }  
}  

Write-Host " "  
Write-Host " "  
Write-Host -foregroundcolor "green" "-----  $currentOwner's Subscriptions changing ownership to $newOwner : "  
$subscriptions | select SubscriptionID, Owner, Path, Description,  Status  | format-table -AutoSize  

ForEach ($sub in $subscriptions)  
{  
    $rs2010.ChangeSubscriptionOwner($sub.SubscriptionID, $newOwner);  
}  

$subs2 = @();  

ForEach ($item in $items)  
{  
    if ($item.TypeName -eq "Report")  
    {  
        $subs2 += $rs2010.ListSubscriptions($item.Path);  
    }  
}
```
### Script: List all subscriptions associated with a specific report
```
# Name: List_SSRS_One_Reports_Subscriptions.ps1
# Parameters:  
#    server      - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
#    reportpath  - path to report in the report server, including report name e.g. /reports/test report >> pass in  "'/reports/title only'"  
#    site        - use "/" for default native mode site  
# Syntax: .\List_SSRS_One_Reports_Subscriptions.ps1 "[server]/reportserver" "'/reports/title only'" "/"  
Param  
(  
      [string]$server,  
      [string]$reportpath,  
      [string]$site  
)  

$rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
$subscriptions += $rs2010.ListSubscriptions($site);  

Write-Host " "  
Write-Host " "  
Write-Host "----- $reportpath 's Subscriptions: "  
$subscriptions | select Path, report, Description, Owner, SubscriptionID, lastexecuted,Status | where {$_.path -eq $reportpath}
```
### Script: Change ownership of a specific subscription
```
# Name: Change_SSRS_Owner_One_Subscription.ps1
# Parameters:  
#    newOwner       - DOMAIN\USER that will own the subscriptions you wish to change  
#    server         - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
#    site        - use "/" for default native mode site  
#    subscriptionID - guid for the single subscription to change  
# Syntax: .\Change_SSRS_Owner_One_Subscription.ps1 "[Domain]\[new owner]" "[server]/reportserver" "/" "ac5637a1-9982-4d89-9d69-a72a9c3b3150" 

Param(  
    [string]$newOwner,  
    [string]$server,  
    [string]$site,  
    [string]$subscriptionid  
   )  
$rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential;  

$subscription += $rs2010.ListSubscriptions($site) | where {$_.SubscriptionID -eq $subscriptionid};  

Write-Host " "  
Write-Host "----- $subscriptionid's Subscription properties: "  
$subscription | select Path, report, Description, SubscriptionID, Owner, Status  

$rs2010.ChangeSubscriptionOwner($subscription.SubscriptionID, $newOwner)  

#refresh the list  
$subscription = $rs2010.ListSubscriptions($site) | where {$_.SubscriptionID -eq $subscriptionid}; # use "/" for default native mode site  
Write-Host "----- $subscriptionid's Subscription properties: "  
$subscription | select Path, report, Description, SubscriptionID, Owner, Status
```
### Script: Run (fire) a single subscription
```
# Name: FireSubscription.ps1
# Parameters  
#    server         - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
#    site           - use $null for a native mode server  
#    subscriptionid - subscription guid  
# Syntax: .\FireSubscription.ps1 "[server]/reportserver" $null "70366e82-2d3c-4edd-a216-b97e51e26de9"

Param(  
  [string]$server,  
  [string]$site,  
  [string]$subscriptionid  
  )  

$rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
#event type is case sensative to what is in the rsreportserver.config  
$rs2010.FireEvent("TimedSubscription",$subscriptionid,$site)  

Write-Host " "  
Write-Host "----- Subscription ($subscriptionid) status: "  
#get list of subscriptions and filter to the specific ID to see the Status and LastExecuted  
Start-Sleep -s 6 # slight delay in processing so ListSubscription returns the updated Status and LastExecuted  
$subscriptions = $rs2010.ListSubscriptions($site);   
$subscriptions | select Status, Path, report, Description, Owner, SubscriptionID, EventType, lastexecuted | where {$_.SubscriptionID -eq $subscriptionid}
```
### Script: Security Auditing
```
# Name: SSRSSecurityAuditReport.ps1
# Synopsis:   List out all SSRS (native mode) folders & their security policies & output dataset to CSV file
# Syntax: .\SSRSSecurityAuditReport.ps1 "server"

Param(  
  [string]$server
  )
# Clear-Host 
$ReportServerUri = New-WebServiceProxy -Uri "http://$server/reportserver/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
$InheritParent = $true
$SSRSroot = "/"
$rsPerms = @()
$rsResult = @()
 
#List out all subfolders under the parent directory and Select their "Path"
$folderList = $rsProxy.ListChildren($SSRSroot, $InheritParent) | Select -Property Path, TypeName | Where-Object {$_.TypeName -eq "Folder"} | Select Path
#Iterate through every folder 
foreach($folder in $folderList)
{
  #Return all policies on this folder
  $Policies = $rsProxy.GetPolicies( $folder.Path, [ref] $InheritParent )
  #For each policy, add details to an array
  foreach($rsPolicy in $Policies)
  {
    [array]$rsResult = New-Object PSObject -Property @{
    "Path" = $folder.Path;
    "GroupUserName" = $rsPolicy.GroupUserName;
    "Role" = $rsPolicy.Roles[0].Name
    }
    $rsPerms += $rsResult
  }
}
#Output array to csv named after instance URL    
$CSVFile=$server+"_SSRS_security_audit.csv"
$rsPerms | Export-Csv -Path $CSVFile -NoTypeInformation
ls $CSVFile
```