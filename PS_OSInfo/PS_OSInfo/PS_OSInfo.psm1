<#
	Get-LogicalDiskInfo
	
	To Obtain Machine, OS, Disk Sizes from a machine or a list of machines

	Examples:
		Get-LogicalDiskInfo    <- To obtain info from the current machine only
		$myhost = ('myhost1','myhost2',...,'hostN')
		$myhost | Get-LogicalDiskInfo		<- To obtain info from the list of hosts
#>
Set-StrictMode -Version 2

Function Get-LogicalDiskInfo
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
	$disks = Get-WmiObject -Query:'SELECT DeviceID, Size, FreeSpace FROM Win32_LogicalDisk WHERE DriveType=3' -Computername:"$computerName"
	foreach ($disk in $disks)
	{
		if ($disk.Size -gt 0)
		{
			$props["$($disk.DeviceID)Drive_TotalSize"] = '{0:0.00} GB' -f [math]::Round($disk.Size / 1GB, 2)
			$props["$($disk.DeviceID)Drive_FreeSpace"] = '{0:0.00} GB' -f [math]::Round($disk.FreeSpace / 1GB, 2)
			$props["$($disk.DeviceID)Drive_%Free"] = '{0:0.00}%' -f [math]::Round(($disk.FreeSpace/$disk.Size)*100, 2)
		}
	}
	New-Object -TypeName PSObject -Property $props
}
}

cls
$computerNames | Get-LogicalDiskInfo