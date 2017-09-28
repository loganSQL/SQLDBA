#
# Get_SQLHostInfo.ps1
#
<#
	Get_SQLHostInfo
	
	To Obtain Machine, OS, Disk Sizes, SQL Services from a machine or a list of machines

	Examples:
		Get_SQLHostInfo    <- To obtain info from the current machine only
		$myhost = ('myhost1','myhost2',...,'hostN')
		$myhost | Get_SQLHostInfo		<- To obtain info from the list of hosts
#>
Set-StrictMode -Version 2

Function Get_SQLHostInfo
{
Param(
	[parameter(ValueFromPipeline=$true)]
	[String]$computerName = $env:COMPUTERNAME
)
Process
{
	$os = Get-WmiObject -Query:'SELECT Version, BuildNumber, ServicePackMajorVersion FROM Win32_OperatingSystem' -Computername:"$computerName"
	$cs = Get-WmiObject -Query:'SELECT Model, Manufacturer, TotalPhysicalMemory, NumberOfProcessors, NumberOfLogicalProcessors, SystemType FROM Win32_ComputerSystem' -Computername:"$computerName"
	$props = [ordered]@{
		'ComputerName' = $computerName;
		'OSVersion' = $os.version;
		'OSBuild' = $os.buildnumber;
		'SPVersion' = $os.servicepackmajorversion;
		'Model' = $cs.model;
		'Manufacturer' = $cs.manufacturer;
		'RAM' = '{0} GB' -f $($cs.totalphysicalmemory / 1GB -as [int]);
		'Sockets' = $cs.numberofprocessors;
		'Cores' = $cs.numberoflogicalprocessors;
		'SystemType' = $cs.SystemType;
	}
	#
	# Host / OS Info
	#
	echo "1) HOST DETAILS"
	New-Object -TypeName PSObject -Property $props
	#
	# Disk Info
	#
	echo "2) STORAGE DETAILS"
	$disks = Get-WmiObject -Query:'SELECT DeviceID, VolumeName, Size, FreeSpace FROM Win32_LogicalDisk WHERE DriveType=3' -Computername:"$computerName"
	$disks | format-table DeviceID, VolumeName,
		@{ Label='TotalGB'; Expression={[math]::round($_.Size / 1GB,2)}}, 
		@{ Label='FreeGB'; Expression={[math]::round($_.FreeSpace / 1GB,2)}},
		@{ Label='%Free'; Expression={[math]::round(($_.FreeSpace / $_.Size
		)*100,2)}}

	#
	# NetAdapter
	#
	# for Windows Server 2012 onward, better info
	#Get-NetAdapter -physical -CimSession "$computerName" | format-table Name, InterfaceDescription, LinkSpeed
	# old way
	echo "3) NETWORK DETAILS"
	get-wmiobject win32_networkadapter -computername "$computerName" -filter "netconnectionstatus = 2" |format-table DeviceID,ServiceName, Name, @{ Label='Speed(Gbps)'; Expression={[math]::round($_.Speed / 1000000000,0)}}

<#	foreach ($disk in $disks)
	{
		if ($disk.Size -gt 0)
		{
			$props["$($disk.DeviceID)Drive_TotalSize"] = '{0:0.00} GB' -f [math]::Round($disk.Size / 1GB, 2)
			$props["$($disk.DeviceID)Drive_FreeSpace"] = '{0:0.00} GB' -f [math]::Round($disk.FreeSpace / 1GB, 2)
			$props["$($disk.DeviceID)Drive_%Free"] = '{0:0.00}%' -f [math]::Round(($disk.FreeSpace/$disk.Size)*100, 2)
		}
	}
	
#>

	#
	# SQL Services Info
	#
	echo "4) SQL SERVICES"
	Get-Service -computername "$computerName" | Where-Object{$_.DisplayName -like "*SQL*"} | format-table -property Status, Name, DisplayName


date
}
}
cls
Get_SQLHostInfo