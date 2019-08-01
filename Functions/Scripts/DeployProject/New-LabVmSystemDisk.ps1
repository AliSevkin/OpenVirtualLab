function New-LabVmSystemDisk
{
	param (
		[string]$VmGuestName,
		[string]$VmLabFolder,
		[string]$VmDiferencingParentFolder,
		[string]$ParentDiskName,
		[ValidateSet(1, 2)]
		[int]$Generation = 2,
		[bool]$InitialDisk = $false
	)
	
	Write-Host "(New-LabVmSystemDisk) VMFolder is:$VmLabFolder guestname is: $VmGuestName "
	$DiskPath = "$VmLabFolder\$VmGuestName\c.vhdx"

	if (-not (Test-Path $DiskPath))
	{
		if($InitialDisk -eq $False)
		{
			$null = New-VHD -Path $DiskPath -Differencing -ParentPath "$VmDiferencingParentFolder\$ParentDiskName"
			Write-Log "Disk created for $VmGuestName" -color white	
		}
		elseif($InitialDisk -eq $True)
		{
			$DiskSize = 127GB
			write-log "(New-LabVmSystemDisk) Path name to hardiskfile is $DiskPath with a size of $DiskSize, the disk is dynamic"
			$null = New-VHD -Path $DiskPath -Dynamic -SizeBytes $DiskSize
			Write-Log "(New-LabVmSystemDisk) Disk created for $VmGuestName" -color white
		}
		else {
			write-host could not create the system disk, some strange error has occured. quiting script
			break
		}

	}
	else
	{
		Write-Log "(New-LabVmSystemDisk)  C:\ disk allready exists for this $VmGuestName" -color DarkYellow
	}
}


