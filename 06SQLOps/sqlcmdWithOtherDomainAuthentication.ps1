<#
 Run a sqlcmd as another domain user in Windows
#>
whoami

sqlcmd -S YourSQLInstance -E

runas.exe /netonly /user:YourOtherDomain\YourOtherUser "sqlcmd -S YourSQLInstance -E"

## enter password
## T-SQL to query select @@ervername,db_name(), system_user,current_user