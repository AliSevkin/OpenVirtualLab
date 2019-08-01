Function New-LabVmDisk {
    param(
        [string]$ProjectPath,
        [string]$DifferencingParentFolder,
        [string]$ParentDiskName,
        [string]$ProjectName,
        [string]$UserName,
        [string]$Password,
        [string]$AppName,
		[string]$Computer
    )



        # Create the differencing disk for the vm 
        Write-Host "(New-LabVmDisk) projectfolder folder is: $ProjectPath\$ProjectName VmName is: $VmGuestName "
        New-LabVmSystemDisk -VmGuestName $Computer -VmLabFolder "$ProjectPath\$ProjectName" `
            -VmDiferencingParentFolder $DifferencingParentFolder -ParentDiskName $ParentDiskName -InitialDisk $False

        # Deploy custom unattend file to the root folder of the disk created earlier
        Start-LabVmUniqify -Project $ProjectName -ComputerName $Computer -ProjectRootFolder $ProjectPath `
            -UserName $UserName -Password $Password -DnsServer $DnsServer -Gateway $Gateway `
            -NetworkAdappterIdentifier "Ethernet" -AppName $Appname
    
}