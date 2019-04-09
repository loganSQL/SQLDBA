# Microsoft SQL Server Service Management
## Get-Service
```
PS C:\Windows\system32> get-service mss*

Status   Name               DisplayName
------   ----               -----------
Running  MSSQLSERVER        SQL Server (MSSQLSERVER)
Running  MSSQLServerOLAP... SQL Server Analysis Services (MSSQL...


PS C:\Windows\system32> get-service SQL*

Status   Name               DisplayName
------   ----               -----------
Stopped  SQLBrowser         SQL Server Browser
Stopped  SQLSERVERAGENT     SQL Server Agent (MSSQLSERVER)
Running  SQLTELEMETRY       SQL Server CEIP service (MSSQLSERVER)
Running  SQLWriter          SQL Server VSS Writer


PS C:\Windows\system32> get-service *Report*

Status   Name               DisplayName
------   ----               -----------
Stopped  PowerBIReportSe... Power BI Report Server
Stopped  ReportServer       SQL Server Reporting Services (MSSQ...
```

## Start-Service / Stop-Service
```
PS C:\Windows\system32> stop-service PowerBIReportServer
PS C:\Windows\system32> start-service PowerBIReportServer
PS C:\Windows\system32> get-service PowerBI*

Status   Name               DisplayName
------   ----               -----------
Running  PowerBIReportSe... Power BI Report Server
```

## Manage services on Remote Hosts
```
PS C:\Windows\system32> get-service -ComputerName RemoteHost SQL*

Status   Name               DisplayName
------   ----               -----------
Stopped  SQLBrowser         SQL Server Browser
Running  SQLSERVERAGENT     SQL Server Agent (MSSQLSERVER)
Stopped  SQLTELEMETRY       SQL Server CEIP service (MSSQLSERVER)
Running  SQLWriter          SQL Server VSS Writer


PS C:\Windows\system32> get-service -ComputerName RemoteHost MSSQL*

Status   Name               DisplayName
------   ----               -----------
Running  MSSQLSERVER        SQL Server (MSSQLSERVER)
Stopped  MSSQLServerOLAP... SQL Server Analysis Services (MSSQL...


PS C:\Windows\system32> get-service -ComputerName RemoteHost *ReportServer*

Status   Name               DisplayName
------   ----               -----------
Running  PowerBIReportSe... Power BI Report Server
Running  ReportServer       SQL Server Reporting Services (MSSQ...


PS C:\Windows\system32> get-service -ComputerName RemoteHost PowerBIReportServer|stop-service
PS C:\Windows\system32> get-service -ComputerName RemoteHost *ReportServer*

Status   Name               DisplayName
------   ----               -----------
Stopped  PowerBIReportSe... Power BI Report Server
Running  ReportServer       SQL Server Reporting Services (MSSQ...


PS C:\Windows\system32> get-service -ComputerName RemoteHost PowerBIReportServer|start-service
PS C:\Windows\system32> get-service -ComputerName RemoteHost *ReportServer*

Status   Name               DisplayName
------   ----               -----------
Running  PowerBIReportSe... Power BI Report Server
Running  ReportServer       SQL Server Reporting Services (MSSQ...


PS C:\Windows\system32> $service=get-service -ComputerName RemoteHost -Name PowerBIReportServer
PS C:\Windows\system32> $service

Status   Name               DisplayName
------   ----               -----------
Running  PowerBIReportSe... Power BI Report Server


PS C:\Windows\system32> $service.Stop()
PS C:\Windows\system32> $service.Refresh()
PS C:\Windows\system32> $service

Status   Name               DisplayName
------   ----               -----------
Stopped  PowerBIReportSe... Power BI Report Server
```

## More detail service management via WMI
```
PS C:\Windows\system32> $service = Get-WmiObject -ComputerName RemoteHost -Class Win32_Service -Filter "Name='PowerBIReportServer'"
PS C:\Windows\system32> $service


ExitCode  : 0
Name      : PowerBIReportServer
ProcessId : 15296
StartMode : Auto
State     : Running
Status    : OK

PS C:\Windows\system32> $Service | Get-Member -Type Method


   TypeName: System.Management.ManagementObject#root\cimv2\Win32_Service

Name                  MemberType Definition
----                  ---------- ----------
Change                Method     System.Management.ManagementBaseObject Change(System.String DisplayName, System.String PathName, System.Byte ServiceType, System.Byte
ChangeStartMode       Method     System.Management.ManagementBaseObject ChangeStartMode(System.String StartMode)
Delete                Method     System.Management.ManagementBaseObject Delete()
GetSecurityDescriptor Method     System.Management.ManagementBaseObject GetSecurityDescriptor()
InterrogateService    Method     System.Management.ManagementBaseObject InterrogateService()
PauseService          Method     System.Management.ManagementBaseObject PauseService()
ResumeService         Method     System.Management.ManagementBaseObject ResumeService()
SetSecurityDescriptor Method     System.Management.ManagementBaseObject SetSecurityDescriptor(System.Management.ManagementObject#Win32_SecurityDescriptor Descriptor)
StartService          Method     System.Management.ManagementBaseObject StartService()
StopService           Method     System.Management.ManagementBaseObject StopService()
UserControlService    Method     System.Management.ManagementBaseObject UserControlService(System.Byte ControlCode)

PS C:\Windows\system32> $service.StopService()


__GENUS          : 2
__CLASS          : __PARAMETERS
__SUPERCLASS     :
__DYNASTY        : __PARAMETERS
__RELPATH        :
__PROPERTY_COUNT : 1
__DERIVATION     : {}
__SERVER         :
__NAMESPACE      :
__PATH           :
ReturnValue      : 0
PSComputerName   :



PS C:\Windows\system32> $service = Get-WmiObject -ComputerName RemoteHost -Class Win32_Service -Filter "Name='PowerBIReportServer'"
PS C:\Windows\system32> $service


ExitCode  : 0
Name      : PowerBIReportServer
ProcessId : 0
StartMode : Auto
State     : Stopped
Status    : OK



PS C:\Windows\system32> $service.StartService()


__GENUS          : 2
__CLASS          : __PARAMETERS
__SUPERCLASS     :
__DYNASTY        : __PARAMETERS
__RELPATH        :
__PROPERTY_COUNT : 1
__DERIVATION     : {}
__SERVER         :
__NAMESPACE      :
__PATH           :
ReturnValue      : 0
PSComputerName   :
```
## Invoke-WMIMethod
```
PS C:\Windows\system32> Invoke-WmiMethod -Path "Win32_Service.Name='PowerBIReportServer'" -Name StopService -ComputerName RemoteHost


__GENUS          : 2
__CLASS          : __PARAMETERS
__SUPERCLASS     :
__DYNASTY        : __PARAMETERS
__RELPATH        :
__PROPERTY_COUNT : 1
__DERIVATION     : {}
__SERVER         :
__NAMESPACE      :
__PATH           :
ReturnValue      : 0
PSComputerName   :
PS C:\Windows\system32> Invoke-WmiMethod -Path "Win32_Service.Name='PowerBIReportServer'" -Name StartService -ComputerName RemoteHost


__GENUS          : 2
__CLASS          : __PARAMETERS
__SUPERCLASS     :
__DYNASTY        : __PARAMETERS
__RELPATH        :
__PROPERTY_COUNT : 1
__DERIVATION     : {}
__SERVER         :
__NAMESPACE      :
__PATH           :
ReturnValue      : 0
PSComputerName   :



PS C:\Windows\system32> $service = Get-WmiObject -ComputerName RemoteHost -Class Win32_Service -Filter "Name='PowerBIReportServer'"
PS C:\Windows\system32> $service


ExitCode  : 0
Name      : PowerBIReportServer
ProcessId : 53376
StartMode : Auto
State     : Running
Status    : OK

```

## [Deactivate the Customer Experience Improvement Program (CEIP)](<https://blog.dbi-services.com/sql-server-tips-deactivate-the-customer-experience-improvement-program-ceip/>)

CEIP is present for 3 SQL server services:

For SQL Server Engine, you have a SQL Server CEIP service
For SQL Server Analysis Service (SSAS), you have a SQL Analysis Services CEIP
For SQL Server Integration Service (SSIS), you have a SQL Server Integration Services CEIP service 13.0

One CEIP service per instance per service. For the Engine & SSAS and one just for SSIS(shared component).
If you have a look on each service, the patterns for the name are the same:

For SQL Server CEIP service, you have a SQLTELEMETRY$<InstanceName>
For SQL Analysis Services CEIP, you have a SSASTELEMETRY$<InstanceName>
For SQL Server Integration Services CEIP service 13.0 CEIP, you have just SSISTELEMETRY130
### Disable CEIP services
```
##################################################
# Disable CEIP services  #
##################################################
Get-Service |? name -Like "*TELEMETRY*" | select -property name,starttype,status
Get-Service -name "*TELEMETRY*" | Stop-Service -passthru | Set-Service -startmode disabled
Get-Service |? name -Like "*TELEMETRY*" | select -property name,starttype,status
##################################################
```

### Set all CEIP registry keys to 0
```
##################################################
#  Deactivate CEIP registry keys #
##################################################
# Set all CustomerFeedback & EnableErrorReporting in the key directory HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server to 0
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\***\CustomerFeedback=0
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\***\EnableErrorReporting=0
# *** --> Version of SQL Server (100,110,120,130,140,...)
# For the Engine
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSSQL**.<instance>\CPE\CustomerFeedback=0
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSSQL**.<instance>\CPE\EnableErrorReporting=0
# For SQL Server Analysis Server (SSAS)
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSAS**.<instance>\CPE\CustomerFeedback=0
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSAS**.<instance>\CPE\EnableErrorReporting=0
# For Server Reporting Server (SSRS)
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSRS**.<instance>\CPE\CustomerFeedback=0
# Set HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\MSRS**.<instance>\CPE\EnableErrorReporting=0
# ** --> Version of SQL Server (10,11,12,13,14,...)
##################################################
$Key = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server'
$FoundKeys = Get-ChildItem $Key -Recurse | Where-Object -Property Property -eq 'EnableErrorReporting'
foreach ($Sqlfoundkey in $FoundKeys)
{
$SqlFoundkey | Set-ItemProperty -Name EnableErrorReporting -Value 0
$SqlFoundkey | Set-ItemProperty -Name CustomerFeedback -Value 0
}
##################################################
# Set HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft SQL Server\***\CustomerFeedback=0
# Set HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft SQL Server\***\EnableErrorReporting=0
# *** --> Version of SQL Server(100,110,120,130,140,...)
##################################################
$WowKey = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server"
$FoundWowKeys = Get-ChildItem $WowKey | Where-Object -Property Property -eq 'EnableErrorReporting'
foreach ($SqlFoundWowKey in $FoundWowKeys)
{
$SqlFoundWowKey | Set-ItemProperty -Name EnableErrorReporting -Value 0
$SqlFoundWowKey | Set-ItemProperty -Name CustomerFeedback -Value 0
}
```

### Do it One by One
```
Get-Service |? name -Like "SQLTELEMETRY*" | select -property name,starttype,status
Get-Service |? name -Like "SSASTELEMETRY*" | select -property name,starttype,status
Get-Service |? name -Like "SSISTELEMETRY*" | select -property name,starttype,status


##################################################
# Disable CEIP services  #
##################################################
Get-Service |? name -Like "*TELEMETRY*" | select -property name,starttype,status
# Stop all CEIP services
Get-Service |? name -Like "*TELEMETRY*" | ? status -eq "running" | Stop-Service
Get-Service |? name -Like "*TELEMETRY*" | select -property name,starttype,status
# Disable all CEIP services
Get-Service |? name -Like "*TELEMETRY*" | Set-Service -StartMode Disabled
Get-Service |? name -Like "*TELEMETRY*" | select -property name,starttype,status
```