function New-LabVm
{
	param (
		[parameter(mandatory = $true)]
		[string]$ComputerName,
		[parameter(mandatory = $true)]
		[string]$VmSwitch,
		[parameter(mandatory = $true)]
		[string]$VmLabFolder,
		[string]$ProjectName,
		[validateSet(1, 2)]
		[int]$VmGeneration = 2,
		[validateRange(2, 128)]
		[int]$ProccesorCount = 4,
		$InitialMemoryStartupSize = 1024MB,
		[string]$PathToIsoFile
	)
	
	$VirtualMachine = "$ProjectName - $ComputerName"
	Write-log "Creating the VM $VirtualMachine"
	
	$null = $Vm = New-VM -Generation $VmGeneration -Name $ComputerName `
					-MemoryStartupBytes $InitialMemoryStartupSize -BootDevice VHD `
					-SwitchName $VmSwitch -path "$VmLabFolder\$ProjectName" `
					-VHDPath "$VmLabFolder\$ProjectName\$ComputerName\C.vhdx"

		$null = $Vm | Rename-VM -NewName $VirtualMachine
		$null = $Vm | Get-VMProcessor | Set-VMProcessor -Count $ProccesorCount
		$null = $Vm | Get-VMFirmware | Set-VMFirmware -EnableSecureBoot Off
		$null = $Vm | Set-VM -AutomaticStartAction Nothing
		$null = $Vm | Set-VM -CheckpointType Disabled
		$Null = $Vm | Set-Vm -AutomaticCheckpointsEnabled $false
		
		if($VM.Name -like "*Temp_Differencing*")
		{
			write-host "New Iso file path: $PathToIsoFile"
			Add-VMDvdDrive -VMName $Vm.Name -Path $PathToIsoFile
			$DVD = Get-VMDvdDrive $Vm.Name
			$Disk = Get-VMHardDiskDrive -VmName $Vm.Name
			Set-VMFirmware -VMname $Vm.Name -BootOrder $DVD, $Disk
		}
		$Vm | Start-VM
}



