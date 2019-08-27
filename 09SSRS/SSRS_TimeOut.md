# SSRS - Timeout Settings
## 1. Query Execution Timeout

You can increase the Query Execution Timeout by opening report into the BI studio

For SQL 2008, follow below step

* Go to Report Data Explorer.
* You will see the List of the DataSets
* Right click on the Appropriate Dataset
* Select appropriate the Data Set and click on property. You will find the Timeout Setting. Time out is in the seconds.
* In New window Click on the Query tab,You will see the Timeout drop down at bottom

## 2. Report Execution Timeout

You can set the report to never timeout by setting the processing time out setting to  ‘Do not timeout report execution’
If timeout is caused by length of the execution of the report then you change the Processing Option.

By default, the value is set to 1800 seconds
Either you can set for specific report or you can  set value for all reports.

* Follow this step to set value for specific report

Go to http://localhost/reports
Select the appropriate report and click on the report and choose "Manage" option.
Click on the tab "Processing Options" and choose the option "Report Timeout".

* Follow this step for global setting

Go to http://localhost/reports
Click on "Site Settings" links at top
On the Site Setting Page, choose the "General" tab and choose the Report Timeout to "Do not timeout report

## 3. HTTP Timeout

You can set the httpruntime to run the large report,

You can alter the value of attribute executionTimeout  of tag httpRuntime, default value if 9000 and value is in the seconds.

<system.web>
    <httpRuntime executionTimeout = "9000" />
</system.web>

Open the Report Server’s Web.config file generally located at <Drive>:\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER\Reporting Services\ReportServer
Locate the HttpRuntime parameter and alter the value. If it doesn't exist, you will have to create it within the section

## 4. DatabaseQueryTimeout

You can alter the value for DatabaseQueryTimeout in the RSReportServer.config located at
```
<Drive>:\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER\Reporting Services\ReportServer
```

The value of timeout is in seconds and default value is 120.

This value is passed to the System.Data.SQLClient.SQLCommand.CommandTimeout property.

## 5. SessionTimeout and SystemReportTimeout

This the settings controlling the SSRS user session.

The default value of "SessionTimeout" is in seconds and default value is 600 and 1800 for "SystemReportTimeout".

You can edit this value from ConfigurationInfo  table of report server.
```
select * from ConfigurationInfo
where Name in ('SessionTimeout','SystemReportTimeout')
```

##6 . RecycleTime

This specifies the recycling period for the Reporting Web Service.
This setting has been found in RSReportServer.config, If it doesn't exist, you will have to create it within the section.
The default is 720 and it is in minutes.
 

## 7. SessionState Timeout

You can alter this setting in the web.config located at <Drive>\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER\Reporting Services\ReportManager

default value is 20 minutes.

this require iis restart.

## 8. executionTimeout

this setting is asp.net related.

this setting found in the machine.config file located at <Drive>:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG

<httpRuntime executionTimeout = "1800" maxRequestLength = "4096" >

executiontimeout is in second and default value is 110 seconds.

report might be timeout from asp.net due to the large volume of the data, you can increase the value of maxRequestLength. size is in the mb.

this doesn't require system reboot.