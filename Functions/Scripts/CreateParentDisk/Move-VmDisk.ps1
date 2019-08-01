Function Move-VmDisk
{
    param(
        [string]$VmName,
        [string]$Destination,
        [string]$ParentDiskName
    )

    
    $Vm = Get-VM -Name $VmName
    $Source =  "$($vm.Path)\c.vhdx"
    Write-host "VMName is: $VMName and Virtual Machine c drive path: $Source"

  
    $DestinationFile = "$($Destination)\$($ParentDiskName).vhdx"
    Write-host "Destination is :$DestinationFile"
    Move-Item -Path $Source -Destination $DestinationFile
    Set-ItemProperty -Path $DestinationFile -Name IsReadOnly -Value $True
}