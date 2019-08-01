function Write-Log
{
	param (
		[parameter(Mandatory=$true, Position = 0)]
		[String]$Message,
		[ValidateSet("Info","Error","Warning")]
		[string]$Type="Info",
		[switch]$Header,
		[switch]$Footer
	)
	$Time = (Get-Date).ToLongTimeString()
	$Elapsed = $StopWatch.Elapsed
	
	$Timer = "$($Elapsed.Hours):$($Elapsed.Minutes):$($Elapsed.Seconds):$($Elapsed.Milliseconds)"
	
	Write-Host [$Timer`t$Time] $Message -ForegroundColor Cyan
	
}

Function Mount-VhdToFolder
{
	[CmdLetBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]$Image,
		[Parameter(Mandatory = $true)]
		[String]$MountFolder,
		[string]$ComputerName
	)

		# Gets a mounted disk image
		Write-Log "mounting vhd for $ComputerName"
		Write-Log "Image path= $image"
		$mountedDisk = Mount-VHD -Path $Image -NoDriveLetter -Passthru

		# Get all of the partitions
		Write-Log "Disknumber is: $($Mounteddisk.Number)"
		$partitions = $mountedDisk|Get-Partition 
		write-Log -message "The Partitions are: $($partitions| ForEach-Object{" $($_.partitionNumber),"})"
		

		foreach ($partition in $partitions)
		{
			$partitionFolder = $Null
			$partitionFolder = $null
			$partitionFolder = "$MountFolder\$($partition.PartitionNumber)"
			
			Write-log "Checking and creating softlink for partition $partitionFolder"
			# Clean up this folder if it exists
			if (Test-Path $partitionFolder)
			{
				Write-Log "Removeing old softlink for $partitionFolder"
				Remove-Item -Force $partitionFolder -Confirm:$false -Recurse
			}
			
			# Make the new folder
			if(-not (Test-Path $partitionFolder)) { $null = New-Item -path $partitionFolder -type directory }
			
			write-Log "creating softlink for Partition PartitionNumber for $ComputerName"
			[int]$WindowsPartitionNumber = Get-WindowsPartition -PartitionFolder $partitionFolder -PartitionNumber $partition.PartitionNumber
			if($WindowsPartitionNumber) { 
			write-Log "Before returning the value is: $WindowsPartitionNumber"  
			}   
		}

		return [int]$WindowsPartitionNumber
}

Function Get-WindowsPartition
{
	param(
		[string]$PartitionFolder,
		[int] $PartitionNumber
	)

	if(!$partitionFolder) { return $null }

	try
	{
		# Add the access path for the disk
		$null = Add-PartitionAccessPath -AccessPath $partitionFolder -PartitionNumber $partition.PartitionNumber -DiskNumber $mountedDisk.DiskNumber -ea Stop
	}
	catch
	{
		Write-log "Could not add access path '$($partitionFolder)' for partition '$($partition.PartitionNumber)' for $ComputerName"
	}

	# check if wondows directory exists in the partition, if so then return the full path to the windows directory
	$WindowsRootFolder= $null
	$WindowsRootFolder = "$partitionFolder\windows"
	write-Log "checking for Windows folder on $partitionFolder"
	$PathExists = Test-Path $WindowsRootFolder
	Write-Log "The windows directory testpath returned: $PathExists on $partitionFolder"                  
	if (-not $PathExists) { return $null }
	
	Write-Log "Found windows Directory on partition $PartitionNumber"
	return [int]$PartitionNumber
}



function New-MountFolder
{
	param (
		[string]$ComputerName,
		[string]$Project,
		[string]$AppName
	)
	
	if (-not (Test-Path "$env:ProgramData\$AppName\$Project\$ComputerName"))
	{
		write-Log "creating mountpoint for vhd of $ComputerName"
		$null = New-Item "$Env:ProgramData\$AppName\$Project\$ComputerName" -ItemType directory
	}
}

function Start-LabVmUniqify
{
	param (
		[string]$Project,
		[string]$ComputerName,
		[string]$ProjectRootFolder,
		[string]$UserName = "Administrator",
		[string]$Password = "Amsterdam01",
		[string]$UsesrFullname = "Administrator",
		[string]$Organization = "$AppName",
		[string]$UserDescription = "User who has full control over this computer.",
		[string]$UserGroup = "Administrators",
		[string]$RegisteredOrganization = "$AppName",
		[string]$RegisteredOwner = "$AppName",
		[string]$Gateway,
		[string]$NetworkAdappterIdentifier,
		[string]$UserDisplayName,
		[string]$AppName
	)
	
	$Extention = "vhdx" 
	$VmVhdPath = "$ProjectRootFolder\$Project\$ComputerName\C.$Extention"
	$MountFolder = "$env:ProgramData\$AppName\$Project\$ComputerName"
	New-MountFolder -ComputerName $ComputerName -Project $Project -AppName $AppName
	write-Log "Mount Folder Name: $MountFolder"
	$WindowsPartitionNumber = $null
	$WindowsPartitionNumber = (Mount-VhdToFolder -image $VmVhdPath -MountFolder $MountFolder -ComputerName $ComputerName)[-1]
	$SystemRootdisk = $null
	Write-log "At this point The System rootdisk should be $null after this message it will be populated with the path"
	$SystemRootdisk = "$MountFolder\$WindowsPartitionNumber"

	write-log "The mountfolder point is: $MountFolder"
	Write-log "The Returned partition number is: $WindowsPartitionNumber"
	Write-log "The Systemrootdisk is mounted on: $SystemRootdisk"

	if(-not (Test-Path $SystemRootdisk\windows)) 
	{ 
		write-Log "No systemdisk found, returned value: $WindowsPartitionNumber" 
		Dismount-VHD $VmVhdPath
		break 
	}

	Write-log "making unique unattend for $ComputerName"
	$TemplateUnattend = Get-Content $PsScriptRoot\unattend.base
		$Unatend = $TemplateUnattend `
		-Replace "{UsesrFullname}", $UsesrFullname `
		-Replace "{UserName}", $UserName `
		-Replace "{ComputerName}", $ComputerName `
		-Replace "{Organization}", $Organization `
		-Replace "{Password}", $Password `
		-Replace "{UserDescription}", $UserDescription `
		-Replace "{UserDisplayName}", $UserDisplayName `
		-Replace "{UserGroup}", $UserGroup `
		-Replace "{RegisteredOrganization}", $RegisteredOrganization `
		-Replace "{RegisteredOwner}", $RegisteredOwner `
		-Replace "{IpAddress}", $IpAddress `
		-Replace "{Gateway}", $Gateway `
		-Replace "{NetworkComponent}", $NetworkComponent	
	$Unatend|Set-Content "$SystemRootdisk\unattend.xml"
	
	DisMount-Vhd $VmVhdPath
	if ($MountFolder -ne $null)
	{
		Write-Log "Removing mounted vhd of $ComputerName"
		Remove-Item -Path $MountFolder -Recurse -Confirm:$false -Force:$true	
	}
}




