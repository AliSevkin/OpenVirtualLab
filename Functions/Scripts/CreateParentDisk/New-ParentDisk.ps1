
Function New-ParentDisk {
    param( [string]$Password,
           [string]$VmName,
           [string]$UserName,
           [string]$Destination,
           $ParentDiskName)
#
    $Session = Test-MachineAvailability -VmName $VmName -UserName $UserName -Password $Password
    Start-Generalize -Session $Session[-1]
    Test-MachineStopped -VmName $VmName 
    If (!(Test-Path $Destination)) { New-Item $Destination -ItemType Directory }
    Move-VmDisk -VmName $VmName -Destination $Destination -ParentDiskName $ParentDiskName
    Remove-TempVm -Vm $VmName
}
