# SSRS Security

## Grant sufficient permissions have to Windows User Account Control (UAC) in SSRS

```
User 'DomainName\UserName' does not have required permissions. Verify that sufficient permissions have been granted and Windows User Account Control (UAC) restrictions have been addressed.
```
OR
```
The permissions granted to user 'xx\xx' are insufficient for performing this operation
```

This is the folder permission:
```
* Login to the server where SSRS is installed
* Open http://servername:80/reports
* Click on Home Folder
* Click on Folder Settings
* Add your domain account here by
  * Click on New Role Assignment
  * Enter your domain account name in “Group or Username”
  * Check Content Manager
* Click Ok 
```

## [SQL Server Reporting Services Permissions](<https://www.mssqltips.com/sqlservertip/2793/sql-server-reporting-services-2012-permissions/>)