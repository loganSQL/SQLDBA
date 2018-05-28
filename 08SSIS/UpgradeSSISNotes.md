# Upgrade SSIS from SQL 2008 R2 to SQL 2016
Compiled and Documented By Logan

## 1. Install Integration Services
* [Install Integration Services](<https://docs.microsoft.com/en-us/sql/integration-services/install-windows/install-integration-services?view=sql-server-2017>)

* [Installing Integration Services Versions Side by Side](<https://docs.microsoft.com/en-us/sql/integration-services/install-windows/installing-integration-services-versions-side-by-side?view=sql-server-2017>)

* [Upgrade Integration Services](<https://docs.microsoft.com/en-us/sql/integration-services/install-windows/upgrade-integration-services?view=sql-server-2017>)
## 2. Create the SSIS Catalog on SQL 2016

### 2.1 To create the SSISDB catalog in SQL Server Management Studio
[Create the SSIS Catalog on SQL 2016](<https://msdn.microsoft.com/en-us/library/gg471509(v=sql.120).aspx>)

Remember run SSMS as a administrator!!
Pwd Hints: 100U

### 2.2. To create the SSISDB catalog programmatically

    # Load the IntegrationServices Assembly  
    [Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices")  
    
    # Store the IntegrationServices Assembly namespace to avoid typing it every time  
    $ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"  
    
    Write-Host "Connecting to server ..."  
    
    # Create a connection to the server  
    $sqlConnectionString = "Data Source=localhost;Initial Catalog=master;Integrated Security=SSPI;"  
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString  
    
    # Create the Integration Services object  
    $integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection  
    
    # Provision a new SSIS Catalog  
    $catalog = New-Object $ISNamespace".Catalog" ($integrationServices, "SSISDB", "P@assword1")  
    $catalog.Create()  

## 3. Download SQL Server Data Tools (SSDT)
[Download SQL Server Data Tools (SSDT)](<https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-2017>)

## 4. Upgrade SSIS Packages
[Upgrade Integration Services Packages](<https://docs.microsoft.com/en-us/sql/integration-services/install-windows/upgrade-integration-services-packages?view=sql-server-2017>)
### 4.1. Using SSDT with Visual Studio (2015 or 2017)
* Start VS
* New Project: Templates (Business Intelligence, Integration Services Project)
* Project: **Add Existing Packages**
  * Package Location: file System ( from 2008 R2 SSMS SSIS package export)
  * Package path
  * OK
* Project: **Deploy Package**. This will start **Integration Service Deployment Wizard**
  * Select Destination: SQL 2016 Instance, Connect, Path, next
  * Validate, next;
  * Save Report if you want
* Verify the package in SQL 2016 Instance by using SSMS (run as Admin)
### 4.2. Using the SSIS Package Upgrade Wizard
[Using the SSIS Package Upgrade Wizard](<https://docs.microsoft.com/en-us/sql/integration-services/install-windows/upgrade-integration-services-packages-using-the-ssis-package-upgrade-wizard?view=sql-server-2017>)

## 5. Execute a Deployed Package from the SSIS Catalog
* [How to execute a Deployed Package from the SSIS Catalog with various options](<https://www.sqlshack.com/execute-deployed-package-ssis-catalog-various-options/>)

      Declare @execution_id bigint
      EXEC [SSISDB].[catalog].[create_execution] 
        @package_name=N'importMTable00_new.dtsx', 
        @execution_id=@execution_id OUTPUT, 
        @folder_name=N'DW', 
        @project_name=N'importMTable00', 
        @use32bitruntime=False, 
        @reference_id=Null
      Select @execution_id
      
      DECLARE @var0 smallint = 1
      EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
        @execution_id,  
        @object_type=50, 
        @parameter_name=N'LOGGING_LEVEL', 
        @parameter_value=@var0,
        @parameter_name=N'SYNCHRONIZED', 
        @parameter_value=1
      EXEC [SSISDB].[catalog].[start_execution] @execution_id
      GO
* [SQL Server Agent Jobs for Packages](<https://docs.microsoft.com/en-us/sql/integration-services/packages/sql-server-agent-jobs-for-packages?view=sql-server-2017>)
## 6. Backup, Restore, and Move the SSIS Catalog
[Backup, Restore, and Move the SSIS Catalog](<https://msdn.microsoft.com/en-us/library/hh213291(v=sql.120).aspx>)