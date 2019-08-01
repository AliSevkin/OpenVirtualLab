Function New-TempMachine {

    param(
        [string]$ISOPath,
        [string]$Destination,
        [string]$AppName,
        [string]$ISOFolder = "iso",
        [string]$ProjectName = "ProjectXYZ",
        [string]$PathAutoUnattend = "$PsScriptRoot\autounattend.xml",
        [string]$OsVersion,
        [string]$Password,
        [string]$WindowsType,
        [string]$DriveLetter
    )

    $APPWorkDir = "$env:ProgramData\$AppName\workDir"
    $WinInstallFile = "$env:ProgramData\$AppName\workdir\$($OsVersion)_$($WindowsType)\sources\install.wim"
    $LogFolder = "$env:ProgramData\$AppName\Logs"
    $LogFile = "$($LogFolder)\$($ProjectName).log"

    <# OS SELECTIONS:

	OsVersion: "2012R2", "2016", "2019"
	OsType: "SERVERSTANDARD","SERVERSTANDARDCORE","SERVERDATACENTER","SERVERDATACENTERCORE"

	INFO:

	Da Images in da .wim thing
	===========================

	(1) WINDOWS SERVER 2012/2012R2/2016/2019 SERVERSTANDARD
	(2) WINDOWS SERVER 2012/2012R2/2016/2019 SERVERSTANDARDCORE
	(3) WINDOWS SERVER 2012/2012R2/2016/2019 SERVERDATACENTER
	(4) WINDOWS SERVER 2012/2012R2/2016/2019 SERVERDATACENTERCORE 
#>


 

    # Create Disks for all windows types

        $WinInstallIsoFolderDestination = "$($APPWorkDir)\$($OsVersion)_$($WindowsType)"
        $NewIsoInstallerName = "$($OsVersion)_$($WindowsType)"
        # Set Destinationfolder
        Set-DestinationFolder -WinInstallIsoFolderDestination $WinInstallIsoFolderDestination -LogFile $LogFile

        # Copying the install.wim to the temp iso folder
        Write-Log "Copying the Windows installation files." #-LogFile $LogFile 
        # Copy-Item -path "$($DriveLetter):\*" -recurse -Destination $WinInstallIsoFolderDestination -Force
        Copy-ItemWithProgress -Source "$($DriveLetter):" -Destination $WinInstallIsoFolderDestination

        # Show the selected image for the parent disk
        $ImageName = $NewIsoInstallerName
        Write-Log "Selected image for the parent disk: $ImageName" 

    

        # copy the autounattend to the root of the iso folder
        Set-WindowsSelection -PathAutoUnattend $PathAutoUnattend -DestinationPath $WinInstallIsoFolderDestination `
            -OsVersion $OsVersion -OsType $WindowsType -Password $Password

        # BUILD DA AUTOUNATTEND ISO IMAGE
        $IsoFile = "$APPWorkDir\$NewIsoInstallerName.iso"
        Get-ChildItem $WinInstallIsoFolderDestination | New-IsoFile -Path $IsoFile -force `
            -BootFile "$WinInstallIsoFolderDestination\efi\microsoft\boot\efisys_noprompt.bin"

        # variables needed to build the temp parent vm components
        $TempProject = "Temp_Differencing"
        $TempSwitch = "$TempProject - $($ImageName)"
        $VMLabFolder = "$Destination\$TempProject"
        $ParentDiskName = $ImageName

        # Creating the systemdisk
        Write-Log "Creating .vhdx file for Guest: $VMGuestName"
        New-LabVmSystemDisk -VmGuestName $ImageName -VmLabFolder $VMLabFolder `
            -VmDiferencingParentFolder $Destination -ParentDiskName $ParentDiskName -InitialDisk $True

        # creating the temp vm switch
        New-LabVmSwitch -Name $TempSwitch

        # Creating the temp parent vm
        Write-Log "Creating the guest system: $VMGuestName"
        New-LabVm -ComputerName $ImageName -VmSwitch $TempSwitch -VmLabFolder $Destination -ProjectName $TempProject `
            -VmGeneration 2 -ProccesorCount 4 -InitialMemoryStartupSize 4096MB -PathToIsoFile $IsoFile
}


