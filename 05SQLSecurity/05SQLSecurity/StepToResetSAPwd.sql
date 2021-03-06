﻿/*

Steps to Reset SA Password on the Host

1. Start the SQL Server instance using single user mode (or minimal configuration which will also put SQL Server in single user mode)

From the command prompt type: SQLServr.Exe –m (or SQLServr.exe –f)

Note: If the Binn folder is not in your environmental path, you’ll need to navigate to the Binn folder.

(Usually the Binn folder is located at: C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Binn)

2. Once SQL Server service has been started in single user mode or with minimal configuration, you can now use the SQLCMD command from command prompt to connect to SQL Server and perform the following operations to add yourself back as an Admin on SQL Server instance.

SQLCMD –S <Server_Name\Instance_Name>

You will now be logged in to SQL Server as an Admin.

3. Once you are logged into the SQL Server using SQLCMD, issue the following commands to create a new account or add an existing login to SYSADMIN server role.

To create a new login and add that login to SYSADMIN server role:

1> CREATE LOGIN ‘<Login_Name>’ with PASSWORD=’<Password>’

2> go

1> SP_ADDSRVROLEMEMBER '<Login_Name>','SYSADMIN'

2>go

To add an existing login to SYSADMIN server role, execute the following:

1> SP_ADDSRVROLEMEMBER ‘<LOGIN_NAME>’,’SYSADMIN’

The above operation will take care of granting SYSADMIN privileges to an existing login or to a new login.

4. Once the above steps are successfully performed, the next step is to stop and start SQL Server services using regular startup options. (This time you will not need –f or –m)			
--------------------------------------------------------------------------------------
*/
