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
100U

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

## 7. Import/Export projects to/from SSIS catelog
[Import/Export projects to/from SSIS catelog](<https://gallery.technet.microsoft.com/scriptcenter/ImportExport-projects-bca5f29f>)

Import/Export folders and projects from/to local file system to/from SSIS catalog.

### 7.1 Import  
Import SSIS projects from $ProjectFilePath. The folders under $ProjectFilePath will be imported as folders in the SSIS catalog, with all ispac files under that folder imported accordingly. 

The script will connect to the local SQL Server instance. It will first drop the SSISDB catalog if exists and create a new catalog with a fixed secret. 
```
<#  
.SYNOPSIS  
    Import folders and projects from local file system to SSIS catalog.  
.DESCRIPTION  
    Import SSIS projects from $ProjectFilePath. The folders under $ProjectFilePath 
    will be imported as folders in the SSIS catalog, with all ispac files under that 
    folder imported accordingly.  
     
    The script will connect to the local SQL Server instance. It will first 
    drop the SSISDB catalog if exists and create a new catalog with a fixed secret.  
.EXAMPLE  
    .\CatalogImport  
#>  
 
# Variables 
$ProjectFilePath = "C:\SSIS" 
 
# Load the IntegrationServices Assembly 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null; 
 
# Store the IntegrationServices Assembly namespace to avoid typing it every time 
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices" 
 
Write-Host "Connecting to server ..." 
 
# Create a connection to the server 
$sqlConnectionString = "Data Source=localhost;Initial Catalog=master;Integrated Security=SSPI;" 
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString 
 
# Create the Integration Services object 
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection 
 
Write-Host "Removing previous catalog ..." 
 
# Drop the existing catalog if it exists 
if ($integrationServices.Catalogs.Count -gt 0) { $integrationServices.Catalogs["SSISDB"].Drop() } 
 
Write-Host "Creating new SSISDB Catalog ..." 
 
# Provision a new SSIS Catalog 
$catalog = New-Object $ISNamespace".Catalog" ($integrationServices, "SSISDB", "SUPER#secret1") 
$catalog.Create() 
 
write-host "Enumerating all folders..." 
 
$folders = ls -Path $ProjectFilePath -Directory 
 
if ($folders.Count -gt 0) 
{ 
    foreach ($filefolder in $folders) 
    { 
        Write-Host "Creating Folder " $filefolder.Name " ..." 
 
        # Create a new folder 
        $folder = New-Object $ISNamespace".CatalogFolder" ($catalog, $filefolder.Name, "Folder description") 
        $folder.Create() 
 
        $projects = ls -Path $filefolder.FullName -File -Filter *.ispac 
        if ($projects.Count -gt 0) 
        { 
            foreach($projectfile in $projects) 
            { 
                $projectfilename = $projectfile.Name.Replace(".ispac", "") 
                Write-Host "Deploying " $projectfilename " project ..." 
 
                # Read the project file, and deploy it to the folder 
                [byte[]] $projectFileContent = [System.IO.File]::ReadAllBytes($projectfile.FullName) 
                $folder.DeployProject($projectfilename, $projectFileContent) 
            } 
        } 
    } 
} 
 
Write-Host "All done."
```
### 7.2 Export
Export SSIS projects from the catalog to $ProjectFilePath. Folders in the catalog will be exported as folders in the file system, and projects will be exported as *.ispac files. 

Environments will not be exported.
```
<#  
.SYNOPSIS  
    Export folders and projects from SSIS catalog to local file system.  
.DESCRIPTION  
    Export SSIS projects from the catalog to $ProjectFilePath. Folders in the 
    catalog will be exported as folders in the file system, and projects will 
    be exported as *.ispac files.  
     
    Environments will not be exported.  
.EXAMPLE  
    .\CatalogExport  
#>  
 
# Variables 
$ProjectFilePath = "E:\scripts\ssisiodump" 
 
# Load the IntegrationServices Assembly 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null; 
 
# Store the IntegrationServices Assembly namespace to avoid typing it every time 
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices" 
 
Write-Host "Connecting to server ..." 
 
# Create a connection to the server 
$sqlConnectionString = "Data Source=localhost;Initial Catalog=master;Integrated Security=SSPI;" 
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString 
 
# Create the Integration Services object 
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection 
 
if ($integrationServices.Catalogs.Count -gt 0)  
{  
    $catalog = $integrationServices.Catalogs["SSISDB"] 
 
    write-host "Enumerating all folders..." 
 
    $folders = $catalog.Folders 
 
    if ($folders.Count -gt 0) 
    { 
        foreach ($folder in $folders) 
        { 
            $foldername = $folder.Name 
            Write-Host "Exporting Folder " $foldername " ..." 
 
            # Create a new file folder 
            mkdir $ProjectFilePath"\"$foldername 
 
            # Export all projects 
            $projects = $folder.Projects 
            if ($projects.Count -gt 0) 
            { 
                foreach($project in $projects) 
                { 
                    $fullpath = $ProjectFilePath + "\" + $foldername + "\" + $project.Name + ".ispac" 
                    Write-Host "Exporting to " $fullpath "  ..." 
                    [System.IO.File]::WriteAllBytes($fullpath, $project.GetProjectBytes()) 
                } 
            } 
        } 
    } 
} 
 
Write-Host "All done."
```