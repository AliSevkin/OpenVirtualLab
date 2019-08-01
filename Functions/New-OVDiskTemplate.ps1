

Function New-OvDiskTemplate {
    <#
    
    .SYNOPSIS
    Creates the intial parent disk.
    
    .DESCRIPTION
    Creates the intial parent disk (differencing). for future usage with creation of the virtuallabs.
    This command should be used only once per Windows Version.
    
    .PARAMETER Destination
    Specifies where the parent disk should be saved, for future usage.
    
    .PARAMETER IsoPath
    Specifies where the Windows Installer Iso file can be found.

    .PARAMETER OsVersion
    Specify wich Windowsversion to use, i.e. 2016 for windows server 2016 and 2019 for windows server 2019
    
    .EXAMPLE
    c:\ps> New-OVDiskTemplate -Destination "D:\ParentDisks" -IsoPath "C:\temp\Windows 2016.iso" -OsVersion 2016
    
    .EXAMPLE
    c:\ps> New-OVDiskTemplate -Destination "D:\ParentDisks" -IsoPath "C:\temp\Windows 2016.iso" -OsVersion 2016  -Password "P@ssword01"
 
    #>
    [CmdletBinding()]
    param(
        [parameter(mandatory = $True)]
        [string]$Destination,
        [parameter(mandatory = $True)]
        [string]$IsoPath,
        [parameter(mandatory = $True)]
        [ValidateSet("2016", "2019")]
        [string]$OsVersion = "2016",
        [string]$Password = "Amsterdam01"
    )

 

    clear-host

    # Mount the iso
    Write-Log -message "Mounting Iso file to a driveletter" -Header #-Logfile $LogFile
    $DriveLetter = Mount-Iso -PathIsoFile $ISOPath

    $WindowsTypes = @("SERVERDATACENTER", "SERVERDATACENTERCORE")

    foreach ($WindowsType in $WindowsTypes) {
        $UserName = "Administrator"  
        $ParentDiskName = "$($OsVersion)_$($WindowsType)"
        $AppName = "OpenVirtualLab"
        $ParentDiskConfig = New-Object psobject -ArgumentList @{
            UserName       = $UserName
            ParentDiskPath = $Destination
            ParentDiskName = $ParentDiskName
            Password       = $Password
        }
    
        If (!(Test-Path "$Env:ProgramData\$AppName\Config")) { New-Item "$Env:ProgramData\$AppName\Config" -ItemType Directory }
        $ParentDiskConfig | Convertto-Json | out-file -FilePath "$Env:ProgramData\$AppName\Config\$OsVersion.json" -Force
    
        New-TempMachine -Destination $Destination -IsoPath $IsoPath -AppName $AppName `
                        -Password $Password -Osversion $OsVersion -WindowsType $WindowsType -DriveLetter $DriveLetter
        
                        $VmName = (Get-VM -Name "Temp_Differencing*").Name.ToString()
        New-ParentDisk -Password $Password -VmName $VmName -UserName $UserName -Destination $Destination -ParentDiskName $ParentDiskName
    }

    # Unmounting The iso Thing
    Dismount-Iso -IsoPath $ISOPath -LogFile $LogFile
    Remove-TempItem -AppName $AppName
}
    