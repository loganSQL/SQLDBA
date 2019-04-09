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

## Remote Serve services
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
PS C:\Windows\system32> Invoke-WmiMethod -Path "Win32_Service.Name='PowerBIReportServer'" -Name StartService -ComputerName TORQFNSQL13


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



PS C:\Windows\system32> $service = Get-WmiObject -ComputerName TORQFNSQL13 -Class Win32_Service -Filter "Name='PowerBIReportServer'"
PS C:\Windows\system32> $service


ExitCode  : 0
Name      : PowerBIReportServer
ProcessId : 53376
StartMode : Auto
State     : Running
Status    : OK

```