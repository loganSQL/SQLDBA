<#
	.SYNOPSIS

		MSSQL-IOCollector v4.3

		This light-weight script connects to MSSQL instances and gathers information for analysis.
		Use get-help MSSQL-IOCollector.ps1 -detailed to learn more
		Tab completion is your friend

	.DESCRIPTION

		For SOURCE servers, we focus on DB sizes and backups. No data is written on source SQL servers and the script will typically complete in a few seconds.
		For TARGET servers, we focus on I/O. Three small tables are temporarily created in MSDB, one Agent is created. The Agent runs every minute, typically for less than 1 second.

		Data is exported from SQL to CSV and can be compressed for upload to Delphix.

		These fields are currently queried by our script:
		Sources and Targets: SERVERPROPERTY (Servername, MachineName, OSVersion, SQLVersion, Collation, UTCOffset)
		Sources and Targets: sys.databases (DatabaseName, RecoveryModel, DataSize, LogSize, DatabaseCollation, CompatibilityLevel)
		Sources: msdb.dbo.backupset (Database_name, Physical_Device_Name, bkSize, Backup_Start_Date, Backup_Finish_Date, First_LSN, Last_LSN, Type, Server_Name, Recovery_Model)
		Targets: sys.dm_io_virtual_file_stats (Read_MB, Write_MB, Total_MB, IO_Ops)

	.NOTES
		
		This script requires Powershell v3 and .NET v4.5

		v4.1 - Update parameter help for consistency, as well as description detail
		v4.2 - Email output to static filename email.txt, greater process output by default, more output for troubleshooting via -verbose mode, corrected DBIORolled SQL calculation
		v4.3 - Saved email address to file, added column name for CollectionTime, updated web links, updated descriptive wording, added example -samples 2880, fixed int vs bigint size collection, added explicit completion notice when ETA -eq 0, set consistent variable casing
		v4.4 - Changed instance separator from "_" to "~", Added aliases -s (server), -u (user), -t (type), -p (savepass), -z (zip), -up (upload), -a (action)
		
		Internal Note: Make two changes when publishing: set $Uploadsite to prod, and $ErrorActionPreference to silentlycontinue
	
	.PARAMETER dbserver
		The SQL server hostname\instance - note that hostname helps us more than IP in the architecture review (required for IO collection)

	.PARAMETER dbType
		dbType is [S]ource collection or [T]arget collection (required for IO collection)

	.PARAMETER User
		SQL user name. For windows authentication don't provide a -user argument, just run the script while logged in as the account required or use "runas". (optional for IO collection)

	.PARAMETER Action
		For [T]arget dbtype only; ignore autodetected status, then [S]tart a new collection, [G]et current status, [F]inish and download data, or [C]leanup and remove SQL data" (optional for IO collection)

	.PARAMETER Samples
		How many minutes to collect samples - default 1440 (optional for IO collection)

	.PARAMETER Savepass
		Save the SQL password to encr_pw.txt. Delete the file to change SQL user, or when finished data collection. (optional for IO collection)

	.PARAMETER Email
		Your email address - for file naming and company identification purposes (required for ZIP or Upload)

	.PARAMETER Zip
		When selected, the script will compress all collected data. (required for ZIP)

	.PARAMETER Upload
		When selected, attempt to automatically upload your compressed data to https://upload.delphix.com Requires email address. (required for Upload)
		
	.LINK
		Windows Mgt Framework (includes Powershell) - https://www.microsoft.com/en-us/download/details.aspx?id=50395
		The .NET Frameworks - https://msdn.microsoft.com/en-us/library/5a4x27ek(v=vs.110).aspx

	.EXAMPLE
		MSSQL-IOCollector.ps1 -dbserver hostname\instance -dbtype s -user sa -savepass
		Connect to hostname\instance
		dbtype is SOURCE collection
		Authenticate as user SA; prompt for a password
		Save the password to encr_pw.txt. Delete the file to change SQL user, or when finished data collection.
	
	.EXAMPLE
		MSSQL-IOCollector.ps1 -dbserver hostname\instance -dbtype t -samples 2880
		Connect to hostname\instance
		dbtype is TARGET collection
		Authenticate as current windows user (no password prompt)
		Run for 2 days (2880 minutes)
		
	.EXAMPLE
		MSSQL-IOCollector.ps1 -zip -email user@domain.com
		ZIP the collected data into a single file in the current working directory
		Use domain.com to as a unique identifier

	.EXAMPLE
		MSSQL-IOCollector.ps1 -upload -email user@domain.com
		Attempts to automatically upload the ZIP file to https://upload.delphix.com (Please contact Delphix and communicate the results)
		Use domain.com to as a unique identifier
		
#>

#region Initialize-Parameters

[CmdletBinding(DefaultParameterSetName="DBwork") ]

Param(
    [Alias("s")]
	[Parameter(Mandatory=$true, ParameterSetName="DBwork", HelpMessage="Which SQL hostname\instance will you connect to?")]
		$dbserver,

    [Alias("t")]
	[Parameter(Mandatory=$True, ParameterSetName="DBwork", HelpMessage="[S]ource dbtype, [T]arget dbtype")]
	[ValidateSet("t","s")]
		$dbtype,

	[Alias("u")]
    [Parameter(Mandatory=$False, ParameterSetName="DBwork", HelpMessage="This is a SQL user name. If you require windows authentication, login as the user or leverage runas. (optional)")]
		$User,

    [Alias("a")]
	[Parameter(Mandatory=$False, ParameterSetName="DBwork", HelpMessage="For targets only; Don't use unless requested. Manually [S]tart a new collection, [G]et current status, or [F]inish and download data, [C]leanup and remove SQL data")]
		[ValidateSet("S","G","F","C")]
		[string]$action,

	[Parameter(Mandatory=$False, ParameterSetName="DBwork", HelpMessage="How many samples should we collect? (Typically at least 1440, with 1 minute intervals)")]
		$samples=1440,

    [Alias("p")]
	[Parameter(Mandatory=$false, ParameterSetName="DBwork", HelpMessage="Save the SQL password to encr_pw.txt. Delete the file to change SQL user, or when finished data collection.")]
		[switch]$Savepass,

    [Alias("e")]
	[Parameter(Mandatory=$false, ParameterSetName="ZipAndUpload", HelpMessage="Your email address - for file naming and company identification purposes")]
		$email,

    [Alias("z")]
	[Parameter(Mandatory=$false, ParameterSetName="ZipAndUpload", HelpMessage="ZIP all collected data")]
		[switch]$zip,

    [Alias("up")]
	[Parameter(Mandatory=$False, ParameterSetName="ZipAndUpload", HelpMessage="Attempt to automatically upload your results to http://upload.delphix.com")]
		[switch]$upload

)

#endregion Initialize-Parameters
#region Create-functions

function Create-SQLObjects {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass,
		[Parameter(Mandatory=$False)]$samples
    )

	#There is a variable for $samples in the SQL statement below. 
	write-host "Calling Create-SQLObjects"
	
	$sql = "

		/****** Cleanup ******/

		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_DBIORaw'))
		BEGIN
			DROP TABLE [dbo].[DLPX_DBIORaw];
		END

		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_DBIORolled'))
		BEGIN
			DROP TABLE [dbo].[DLPX_DBIORolled];
		END

		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_CollectionStatus'))
		BEGIN
			DROP TABLE [dbo].[DLPX_CollectionStatus];
		END

		If (EXISTS(SELECT * FROM msdb.dbo.sysjobs WHERE (name = N'DLPX_IOCollection')))
		BEGIN
			EXEC msdb.dbo.sp_delete_job @job_name=N'DLPX_IOCollection'
		END

		/****** Create DLPX_CollectionStatus Table ******/

		CREATE TABLE [dbo].[DLPX_CollectionStatus](
			[JobStatus] [nvarchar](10) NOT NULL,
			[SPID] [int] NOT NULL,
			[CollectionStartTime] [datetime] NOT NULL,
			[CollectionEndTime] [datetime] NULL,
			[Max_Sample_ID] [bigint] NOT NULL,
			[Current_Sample_ID] [bigint] NOT NULL
		) ON [PRIMARY]

		/****** Insert Data -- INCLUDES VARIABLE FROM PARENT SCRIPT -- ******/

		Declare @Total_Samples bigint
		Select @Total_Samples = $Samples

		INSERT dbo.DLPX_CollectionStatus (JobStatus, SPID, CollectionStartTime, Max_Sample_ID, Current_Sample_ID)
		SELECT 'Running',@@SPID,GETDATE(),@Total_Samples,0;

		/****** Create DLPX_DBIORaw Table  ******/

		CREATE TABLE [dbo].[DLPX_DBIORaw](
			[Sample_ID] [bigint] NOT NULL,
			[Database_ID] [int] NULL,
			[DBName] [nvarchar](400) NOT NULL,
			[MBRead] [real] NOT NULL,
			[MBWritten] [real] NOT NULL,
			[TotalMB] [real] NOT NULL,
			[TotalIOPs] [bigint] NOT NULL,
			[CollectionTime] [datetime] NOT NULL
		) ON [PRIMARY]

		/****** Create DLPX_DBIORolled Table  ******/

		CREATE TABLE [dbo].[DLPX_DBIORolled](
			[Sample_ID] [bigint] NOT NULL,
			[Database_ID] [bigint] NOT NULL,
			[DBName] [nvarchar](400) NOT NULL,
			[MBRead] [real] NOT NULL,
			[MBWritten] [real] NOT NULL,
			[TotalMB] [bigint] NOT NULL,
			[TotalIOPs] [bigint] NOT NULL,
			[CollectionTime] [datetime] NOT NULL
		) ON [PRIMARY]

		/****** Create DLPX_IOCollection Agent  ******/

		BEGIN TRANSACTION
		DECLARE @ReturnCode INT
		SELECT @ReturnCode = 0

		/****** Object:  JobCategory [[Uncategorized (Local)]]]    		******/
		IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
		BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		END

		DECLARE @jobId BINARY(16)
		EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DLPX_IOCollection',
				@enabled=1,
				@notify_level_eventlog=0,
				@notify_level_email=0,
				@notify_level_netsend=0,
				@notify_level_page=0,
				@delete_level=0,
				@category_name=N'[Uncategorized (Local)]',
				@owner_login_name=N'sa', @job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		/****** Object:  Step [Check_Status]    						 ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check_Status',
				@step_id=1,
				@cmdexec_success_code=0,
				@on_success_action=1,
				@on_success_step_id=0,
				@on_fail_action=2,
				@on_fail_step_id=0,
				@retry_attempts=0,
				@retry_interval=0,
				@os_run_priority=0, @subsystem=N'TSQL',
				@command=N'Declare @Current_Sample_ID Bigint

		If (Select Max_Sample_ID - Current_Sample_ID  from DLPX_CollectionStatus) >  0
			BEGIN
			update dbo.DLPX_CollectionStatus
			set Current_Sample_ID  = Current_Sample_ID  + 1

			Set @Current_Sample_ID = (Select Current_Sample_ID from DLPX_CollectionStatus);

			INSERT dbo.DLPX_DBIORaw
				SELECT
				@Current_Sample_ID,
				d.Database_ID,
				d.name,
				SUM(fs.num_of_bytes_read /1024.0 /1024.0),
				SUM(fs.num_of_bytes_written /1024.0 /1024.0),
				SUM((fs.num_of_bytes_read /1024.0 /1024.0)+(fs.num_of_bytes_written /1024.0 /1024.0)) ,
				SUM(fs.num_of_reads + fs.num_of_writes) ,
				GETDATE()
			FROM sys.dm_io_virtual_file_stats(default, default) AS fs
				INNER JOIN sys.databases d (NOLOCK) ON d.Database_ID = fs.Database_ID
			WHERE d.name NOT IN (''master'',''model'',''msdb'',''tempdb'', ''distribution'', ''ReportServer'',''ReportServerTempDB'')
			and d.state = 0
			GROUP BY d.name, d.Database_ID;

			Insert into DLPX_DBIORolled
			Select @Current_Sample_ID,
			DR1.Database_ID,
			DR1.DBName,
			DR2.MBRead - DR1.MBRead,
			DR2.MBWritten - DR1.MBWritten,
			DR2.TotalMB - DR1.TotalMB,
			DR2.TotalIOPs - DR1.TotalIOPs,
			DR2.CollectionTime
			from dbo.DLPX_DBIORaw as DR1
			Inner Join dbo.DLPX_DBIORaw as DR2 ON DR1.Database_ID = DR2.Database_ID
			where DR1.Sample_ID = @Current_Sample_ID -1
			and DR2.Sample_ID = @Current_Sample_ID;
			END
		Else
			BEGIN
			update dbo.DLPX_CollectionStatus
			set [JobStatus] = ''Finished'',
			[CollectionEndTime] = GETDATE()
			EXEC msdb.dbo.sp_update_job @job_name=N''DLPX_IOCollection'',
			@enabled=0
		END',
				@database_name=N'msdb',
				@flags=0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
			EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
			EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'EveryMinute',
			@enabled=1,
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=4, 
			@freq_subday_interval=1, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0,
			@active_start_date=20160426,
			@active_end_date=99991231,
			@active_start_time=0,
			@active_end_time=235959
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
			EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
			COMMIT TRANSACTION
			GOTO EndSave
			QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		EndSave:

		/********* End ************/
	"

	$SQLCreateStatusTable = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	Write-host "All SQL Collection objects created"
}

function Cleanup-SQLObjects {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )

	$sql = "
		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_DBIORaw'))
		BEGIN
			DROP TABLE [dbo].[DLPX_DBIORaw];
		END

		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_DBIORolled'))
		BEGIN
			DROP TABLE [dbo].[DLPX_DBIORolled];
		END

		IF (EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' and TABLE_NAME='DLPX_CollectionStatus'))
		BEGIN
			DROP TABLE [dbo].[DLPX_CollectionStatus];
		END

		If (EXISTS(SELECT * FROM msdb.dbo.sysjobs WHERE (name = N'DLPX_IOCollection')))
		BEGIN
			EXEC msdb.dbo.sp_delete_job @job_name=N'DLPX_IOCollection'
		END
	"

	$SQLCleanup = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	Write-host "Cleanup Completed"
}

function Connect-SQLServer{

    Param(
        [Parameter(Mandatory=$True)]$dbserver,
        [Parameter(Mandatory=$True)]$DBName,
		[Parameter(Mandatory=$False)]$sql,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )
	write-verbose "Calling Connect-SQLServer"

	write-verbose "Savepass: $($Savepass)"
	
	# check to see if the user provided a Username
	if ($User -eq $null) {
	
		write-host "Using windows authentication: use -user <Username> for SQL authentication"
        		
    } else {

		write-verbose "Using SQL user: $User"

		# Set an encrypted filename for later use, if needed
        $Encr_pw_file = ($PWD.tostring() + "\encr_pw.txt")

		# Check to see if there's an existing connection
		if ($connectionString -ne $null) {
		
			write-verbose "Already have SQL connection"

		} else {
		
			write-verbose "No existing connection found, checking for $($Encr_pw_file)"

			#check to see if we have a password saved OR prompt for one and save
			If (Test-path ($Encr_pw_file) ) {
				write-host "Reading password from: $Encr_pw_file. Delete the file to change SQL user, or when finished data collection."
				$pass = Get-Content $Encr_pw_file | ConvertTo-SecureString  
			
			} else {
			
				write-verbose "Prompting for password"
				$pass = read-host "Enter Password" -AsSecureString
				if ($Savepass -eq $true) { 
					write-verbose "Savepass: $($Savepass)"
					$pass | ConvertFrom-SecureString | Out-File $Encr_pw_file 
					write-host "Saving password for $User to $encr_pw_file. Delete the file to change SQL user, or when finished data collection" 
				} else {
					write-host "Password not saved. Consider using -savepass to save an encrypted version of this password in encr_pw.txt"
				}
			}

			$script:MyCredential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $pass
			write-verbose "Username: $($MyCredential.Username)"
	
		}
	}
	
	if ($Mycredential){
		$script:connectionString = "Server=$dbserver;Database=$DBName;User Id=$User;Password=$($MyCredential.GetNetworkCredential().password)"
		#Record the authmode so we can tell the user if/when it fails
		$authmode = "SQL"
		$authuser = "$User"
	} else {
		$script:connectionString = "Server=$dbserver;Database=$DBName;Integrated Security=True"
		$authmode = "Windows"
		$authuser = [Environment]::UserDomainName +"\"+ [Environment]::Username
	}

	write-verbose "Creating connection string"
	#clear errors so we can check the connection status

	$error.clear()
	$sqlConnection = new-object System.Data.SqlClient.SqlConnection $connectionString
	$sqlConnection.Open()

	if ($error) {
		write-warning "SQL connection failed for dbserver: $($dbserver) using Authmode: $($authmode) and Username: $($authuser). Use -user <Username> for SQL authentication."
		exit
	}
	
	$sqlCommand = $sqlConnection.CreateCommand()
	$sqlCommand.CommandText=$sql
	$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
	$dataset = New-Object System.Data.DataSet
	$adapter.Fill($dataset)|Out-Null
	#$sqlConnection.Close()
	$dataTable = New-Object System.Data.DataTable "SQL"
	$dataTable = $dataset.Tables[0]
	return, $dataTable
	write-host "Got data from SQL"
}

function Get-SQLInstanceData {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )

	write-host "Calling Get-SQLInstanceData"

	$sql = "
		SET NOCOUNT ON; SELECT
		CAST(SERVERPROPERTY('ServerName') as nvarchar(400)) as ServerName,
		CAST(SERVERPROPERTY('MachineName') as nvarchar(400)) as MachineName,
		CAST(SERVERPROPERTY('IsClustered') as int) as IsClustered,
		CASE
			WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3) = '5.2' THEN 'Windows Server 2003 (R2)'
			WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3) = '6.0' THEN 'Windows Server 2008'
			WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3) = '6.1' THEN 'Windows Server 2008 R2'
			WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3) = '6.2' THEN 'Windows Server 2012'
			ELSE 'Undefined'
		END as 'OSVersion',
		SUBSTRING(CAST(SERVERPROPERTY ('ProductVersion') as varchar(20)),1,CHARINDEX('.',CAST(SERVERPROPERTY ('ProductVersion') as varchar(20)))-1) as SQLVersionNum,
		CASE
			WHEN CHARINDEX('9.00',CAST(SERVERPROPERTY('productversion') as varchar(10))) > 0 THEN 'SQL Server 2005 ' + CAST(SERVERPROPERTY ('edition') as varchar(100)) + ' ' + CAST(SERVERPROPERTY ('productlevel') as varchar(100))
			WHEN CHARINDEX('10.0',CAST(SERVERPROPERTY('productversion') as varchar(10))) > 0 THEN 'SQL Server 2008 ' + CAST(SERVERPROPERTY ('edition') as varchar(100)) + ' ' + CAST(SERVERPROPERTY ('productlevel') as varchar(100))
			WHEN CHARINDEX('10.50',CAST(SERVERPROPERTY('productversion') as varchar(10))) > 0 THEN 'SQL Server 2008 R2 ' + CAST(SERVERPROPERTY ('edition') as varchar(100)) + ' ' + CAST(SERVERPROPERTY ('productlevel') as varchar(100))
			WHEN CHARINDEX('11.0',CAST(SERVERPROPERTY('productversion') as varchar(10))) > 0 THEN 'SQL Server 2012 ' + CAST(SERVERPROPERTY ('edition') as varchar(100)) + ' ' + CAST(SERVERPROPERTY ('productlevel') as varchar(100))
			WHEN CHARINDEX('12.0',CAST(SERVERPROPERTY('productversion') as varchar(10))) > 0 THEN 'SQL Server 2014 ' + CAST(SERVERPROPERTY ('edition') as varchar(100)) + ' ' + CAST(SERVERPROPERTY ('productlevel') as varchar(100))
			ELSE 'Undefined'
		END as 'SQLVersion',
		CAST(SERVERPROPERTY('Collation') as varchar(100)) as 'SqlInstanceCollation',
		DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) as 'UTCOffset'
	"

	$SQLInstanceData = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	$SQLInstanceFile = $outputPath+"\"+($dbserver.replace('\','~').Toupper())+"^"+$dbtypeExt+"^"+$timestamp+"^DLPX_SQLInstanceData.csv"
	$SQLInstanceData | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"', ''} | out-file  $SQLInstanceFile
	Write-host "SQLInstanceData written to $($SQLInstanceFile)"
}

function Get-SQLDBData {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )
	write-host "Calling Get-SQLDBData"

	
	$sql = "
		SET NOCOUNT ON;
		SELECT
			db.Database_ID,
			DB_NAME(db.Database_ID) as DatabaseName,
			ISNULL(CONVERT(bigint,(CAST(mfrows.RowSize AS FLOAT)*8)/1024),0) as DataSize,
			ISNULL(CONVERT(bigint,(CAST(mflog.LogSize AS FLOAT)*8)/1024),0) as LogSize,
			db.recovery_model_desc as RecoveryModel,
			--CASE
			--	WHEN exists (select is_encrypted from sys.databases db2 where is_encrypted = 1 and db2.Database_ID = db.Database_ID)
			--	THEN 'Yes'
			--	ELSE 'No'
			--END AS IsEncrypted,
			'N/A' as IsEncrypted,
			CAST(DATABASEPROPERTYEX(DB_NAME(db.Database_ID),'Collation') as varchar(100)) as DatabaseCollation,
			CASE compatibility_level
				WHEN 90  THEN '2005'
				WHEN 100 THEN '2008/R2'
				WHEN 110 THEN '2012'
				WHEN 120 THEN '2014'
				When 130 THEN '2016'
			END AS CompatibilityLevel
		FROM sys.databases db
			LEFT JOIN (
				SELECT Database_ID, 
				SUM(CONVERT(bigint,size)) RowSize
				FROM sys.master_files
				WHERE type = 0
				GROUP BY Database_ID, type
				) 
				mfrows ON mfrows.Database_ID = db.Database_ID
			LEFT JOIN (
				SELECT Database_ID,
				SUM(CONVERT(bigint,size)) LogSize
				FROM sys.master_files
				WHERE type = 1 GROUP BY Database_ID, type
				) 
				mflog ON mflog.Database_ID = db.Database_ID
		WHERE DB_NAME(db.Database_ID) NOT IN ('master','model','msdb','tempdb','distribution', 'ReportServer', 'ReportServerTempDB');
	"

	$SQLDBData = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	$SQLDBDatafile=$outputPath+"\"+($dbserver.replace('\','~').Toupper())+"^"+$dbtypeExt+"^"+$timestamp+"^DLPX_DBData.csv"
	$SQLDBData | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"', ''} | out-file $SQLDBDatafile
	Write-host "SQLDBData written to $($SQLDBDatafile)"
}

function Get-SQLSourceData {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )

	write-host "Calling Get-SQLSourceData"

	$sql = "
		SELECT
		s.database_name,
		m.physical_device_name,
		CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
		CAST(DATEDIFF(second, s.backup_start_date,
		s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' Duration,
		convert(varchar, s.backup_start_date, 121) as Backup_Start_Time,
		CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
		CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
		CASE s.[type]
			WHEN 'D' THEN 'Full'
			WHEN 'I' THEN 'Differential'
			WHEN 'L' THEN 'Transaction Log'
			END AS BackupType,
		s.server_name,
		s.recovery_model
		FROM msdb.dbo.backupset s
		INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
		WHERE s.database_name Not in ('master','model' ,'tempdb','msdb','ReportServer', 'ReportServerTempDB', 'distribution')
		ORDER BY backup_start_date DESC, backup_finish_date;
	"

	$SQLSourceData = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	$SourceOutFile = $outputPath+"\"+($dbserver.replace('\','~').Toupper())+"^"+$dbtypeExt+"^"+$timestamp+"^DLPX_BKData.csv"
	$SQLSourceData | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"', ''} | out-file $SourceOutFile
	Write-host "SQLSourceData written to $($SourceOutFile)"
	Return
}

function Get-SQLTargetData {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )
	write-host "Calling Get-SQLTargetData"

	$sql = "
		SELECT [Sample_ID]
		--,[Database_ID]
		,[DBName]
		,[MBRead]
		,[MBWritten]
		--,[TotalMB]
		,[TotalIOPs]
		,convert(varchar, CollectionTime, 121) as CollectionTime
		from msdb.dbo.DLPX_DBIORolled;
	"
	$SQLTargetResponse = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
	$TargetOutFile = $outputPath+"\"+($dbserver.replace('\','~').Toupper())+"^"+$dbtypeExt+"^"+$timestamp+"^DLPX_DBIORolled.csv"
	$SQLTargetResponse | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"', ''} | out-file $TargetOutFile
	Write-host "SQLTargetdata written to $($TargetOutFile)"
}

function Get-SQLStatus {
    Param(
        [Parameter(Mandatory=$True)]$dbserver,
		[Parameter(Mandatory=$True)]$DBName,
        [Parameter(Mandatory=$False)]$User,
		[Parameter(Mandatory=$False)]$Savepass
    )
	write-host "Calling Get-SQLStatus"

	$sql = "
		if (exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DLPX_CollectionStatus' ) )
			begin
				select JobStatus,SPID,CollectionStartTime,CollectionEndTime,Max_Sample_ID,Current_Sample_ID from DLPX_CollectionStatus
			end
			else
				select 'New' as JobStatus, 0 as Current_Sample_ID, 0 as Max_Sample_ID
	"

	$global:SQLStatus = Connect-SQLServer -dbserver $dbserver -DBName $DBName -user $User -sql $sql -savepass $Savepass
}

function Create-folder {
	write-verbose "Calling Create-folder"

	#Timestamp and dbtypeExt is used in source and target CSV filenames
	if ($dbtype -eq "t") {$script:dbtypeExt = "TARGET"}
	if ($dbtype -eq "s") {$script:dbtypeExt = "SOURCE"}

	#Scope expanded to "script" for file output functions to read
	$script:timestamp = get-date -uformat %Y%m%d%H%M%S
	$script:outputPath = $PWD.ToString()+"\"+"SQLIO"

	# Output all local and script scoped variables - only shows in verbose mode
	$localscoped = Get-Variable -scope local -exclude Cons*,erro*,exec*,shel*,verb*,maxi*,inpu*,ps*,my*,home,host,pid,?,null,true,false |% {"`r{0}: {1}`n" -f $_.Name,$_.Value }
	write-verbose "`nLocalscoped: `n`n$($Localscoped)"
	# $scriptscoped = Get-Variable -scope script -exclude Cons*,erro*,exec*,shel*,verb*,maxi*,inpu*,ps*,my*,home,host,pid,?,null,true,false |% {"`r{0}: {1}`n" -f $_.Name,$_.Value }
	# write-verbose "`nScriptscoped: `n`n$($scriptscoped)"

	write-host "Output folder: $outputPath"

	mkdir $outPutPath -Force |Out-Null
}


function get-email {
    Param(
		[Parameter(Mandatory=$false)]$email
	)

	# Check to see if an email is in file already and read it in if so
	write-verbose "Emailpath: $outPutPath\email.txt"
	
	If (Test-path ("$outPutPath\email.txt") ) {
		write-host "Reading email from: $outPutPath\email.txt. Delete the file to change email address, or when finished data collection."
		$email = Get-Content "$outPutPath\email.txt"
		write-verbose "Got email: $($email) from file" 
	} else {
		write-verbose "We didn't read email from a file"
		# Since we didn't have email via a file, check to see if we have a valid email variable from the command line, or read it in now. Save email to the file.
		if ($email -notmatch "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$") {
			do {$email = read-host -prompt "Your email address - for file naming and company identification purposes" 
			write-verbose "Got email: $($email)"}
			until ($email -match "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$")
		}
		$email | Out-File "$outPutPath\email.txt"
	}

	# Move any locally-scoped email variable to the larger script scope
	$script:email = $local:email
	
}

function Compress-Folder {
    Param(
		[Parameter(Mandatory=$false)]$email
	)
	write-verbose "Calling Compress-folder"

	#Scope expanded to "script" for file output functions to read
	$script:outputPath = $PWD.ToString()+"\"+"SQLIO"

	get-email -email $email
	$local:email = $script:email
	
	$script:companyname = $email.Split("@")[1].split(".")[0].Toupper()
	$ZipFile =  $PWD.ToString()+"\"+$companyname+"-SQLIO"+".zip"
	
	#write-verbose "dbtype: $($dbtype), `nCompanyName: $($companyname) `nPWD: $($PWD) `nOut: $($OutputPath) `nZip: $($Zipfile)"
	
	#Cleanup
	If(Test-path $ZipFile) {Remove-item $ZipFile}

	$CompressionLevel = "Optimal"
	write-host "Compressing files from $($OutputPath) `nto `n$($ZipFile)"

	Add-Type -AssemblyName System.IO.Compression.FileSystem
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::$CompressionLevel
    [System.IO.Compression.ZipFile]::CreateFromDirectory($outputPath, $zipFile, $CompressionLevel, $IncludeParentDir)
}

function UploadTo-MySite {
    Param(
		[Parameter(Mandatory=$false)]$email
	)
	write-verbose "Calling Compress-folder"

	#Scope expanded to "script" for file output functions to read
	$script:outputPath = $PWD.ToString()+"\"+"SQLIO"

	get-email -email $email
	$local:email = $script:email
	
	$script:companyname = $email.Split("@")[1].split(".")[0].Toupper()
	$ZipFile =  $PWD.ToString()+"\"+$companyname+"-SQLIO"+".zip"
	
	$zipFileName = Split-Path -Path $ZipFile -Leaf

	$UploadSite = "https://upload.mysite.com" # Prod upload
	# $UploadSite = "http://dlpx-upload-test.herokuapp.com" # Test Upload

	#write-verbose "dbtype: $($dbtype), `nCompanyName: $($companyname) `nPWD: $($PWD) `nOut: $($OutputPath) `nZip: $($Zipfile)"
	write-host "Uploading to:" $UploadSite

	$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
	if ($proxyAddr) { write-verbose "Uploading via Proxy: $($proxyAddr)" 
	} else { write-verbose "No proxy found, attempting direct upload."}
	
	$url =  "$UploadSite/files?file-name=$zipFileName&case-id=$CaseID&start-byte=0&is-last=true";
	
	# clear errors before trying upload
	$error.clear()

	$uploadresults = Invoke-RestMethod -Uri $url -Infile $ZipFile -Method Post -ContentType "application/octet-stream"

	if ($error) {
		write-warning "Automated upload seems to have failed; please email the ZIP file to MySite manually."
		exit
	} else { write-verbose "Upload Results $($uploadresults)" }
}

#endregion Create-functions

$ErrorActionPreference='silentlycontinue'
# $ErrorActionPreference='stop'

#region Main

write-host "Use get-help $($MyInvocation.MyCommand.Name) -detailed to learn more about this process." -foreground "yellow"

#region Check-PSversion
if (($PSVersionTable.PSVersion.Major) -lt 3) {
	write-warning "Minimum requirement: Powershell v3 (included in Windows Management Framework v3) and .NET v4.5."
	exit
} else { write-verbose "PSVersion: $($PSVersionTable.PSVersion.Major) OK" }
#endregion Check-PSversion

#region SOURCE-Collection
if ($dbtype -eq 's') {

	write-verbose "DBType is Source"

	Create-folder
	Get-SQLInstanceData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
	Get-SQLDBData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
	Get-SQLSourceData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
} else { write-verbose "DBType is not Source" }

#endregion Source-Collection

#region TARGET-Collection
if ($dbtype -eq 't') {

	write-verbose "DBType is Target"
	
	#Action autodetect if $action is not set
	if (get-variable $action -Scope Global -ErrorAction SilentlyContinue) {

		write-verbose "Running Autodetection"
		Get-SQLStatus -dbserver $dbserver -DBName msdb -user $User -savepass $Savepass

		if ($SQLStatus.JobStatus -match "New") { $action = "S" }
		if ($SQLStatus.JobStatus -match "Running") { $action = "G" }
		if ($SQLStatus.JobStatus -match "Finished") { $action = "F" }
		write-verbose "Autodetection - action detected as: $($action)"
		
	} else { 
		write-warning "You picked action: $($action.Toupper()). Except for [C]leanup, don't use the action argument unless specifically requested - the script will normally detect and execute the proper " 
	}
	
	if ($action -eq "S") {
		write-host "Action: Start Collection"
		create-SQLObjects -dbserver $dbserver -DBName msdb -user $User -savepass $Savepass -samples $samples
		write-host "The SQL collection process has started and will run for $samples minutes. (Note: 1440 mins = 24 hours) Run this script again with -dbtype [t]arget to get the latest status, or to download the data when complete. Check the documentation to cancel, cleanup or run a collection with different parameters."
		#create-DLPXAgent
	}
	
	if ($action -eq "G") {
		if ($SQLStatus.JobStatus -notmatch "Running") {
		write-host "Action: Get Status"
		write-verbose "SQLStatus: $($Sqlstatus)"
		Get-SQLStatus -dbserver $dbserver -DBName msdb -user $User -savepass $Savepass
		} else { write-verbose "Already autodetected status - skipping redundant Get-SQLstatus call" }
		write-verbose "Status: $($SQLStatus.JobStatus), CurrentSample: $($SQLStatus.Current_Sample_ID), MaxSample: $($SQLStatus.Max_Sample_ID)"

		#Calculate time remaining -- needs to be updated to work with samplerate if that is added
		$ETA = [math]::Round( (($SQLStatus.Max_Sample_ID - $SQLStatus.Current_Sample_ID) / 60),2 )
		if ($ETA -eq 0) {
			write-host "The collection has completed! your data is ready to download."
		} else {
			write-host "Completion ETA:" $ETA "hours. `nRun this script again with -dbtype [t]arget to get the latest status, or to download the data when complete."
		}
	}

	if ($action -eq "F") {
		write-host "Action: Finish and get data"

		Create-folder
		Get-SQLInstanceData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
		Get-SQLDBData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
		Get-SQLTargetData -dbserver $dbserver -DBName master -user $User -savepass $Savepass
	}

	if ($action -eq "C") {
		write-host "Action: Cleanup DB data"
		Cleanup-SQLObjects -dbserver $dbserver -DBName msdb -user $User -savepass $Savepass
	}
} else { write-verbose "DBType is not Target" }

#endregion Target

#region Compress Data
if ($zip -eq $true) {
	write-host "Calling compression... "

	Compress-Folder -email $email
	
} else { write-verbose "ZIP not called" }
#endregion Compress Data

#region Upload

if ($upload -eq $true) {
	write-host "Calling upload function... "

	UploadTo-Delphix
	write-host "Please contact Delphix and confirm receipt of this file."

} else { write-verbose "Upload not called" }
#endregion Upload

#endregion Main
write-host "Done"