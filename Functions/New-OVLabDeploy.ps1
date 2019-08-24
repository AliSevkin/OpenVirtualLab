

Function New-OVLabDeploy() {
    <#
    
    .SYNOPSIS
    Creates the virtual machines.
    
    .DESCRIPTION
    Creates the number of given virtual machines, domain controllers and generic serveres in a domain.

    .PARAMETER WindowsVersion
    Specifies the Windows version to use i.e. 2016 for windows server 2016, 2019 for Windows server 2019
    
    .PARAMETER Domain
    Specifies the domainname or workgroupname
    
    .PARAMETER ProjectName
    Specifies the projectsname, includes the foldername for the entire project/domain.
    
    .PARAMETER ProjectPath
    Specifies the folder where all the projects will be saved in.
    
    .PARAMETER GenericServers
    Specifies the number of generic servers with desktop experience that will be deployed.

    .PARAMETER GenericServerscore
    Specifies the number of generic servers with core edition that will be deployed.
    
    .PARAMETER DomainControllers
    Specifies the number of Domain controllers with desktop experience that will be deployed.
    
    .PARAMETER DomainControllerscore
    Specifies the number of Domain controllers with core edition that will be deployed.
    
    .EXAMPLE
    when you want servers (with desktop experience) in a workgroup, only use netbios (i.e.  Cottonfield) name for the -Domain option, 
    that will separete between a domain and a workgroup environment. use the only the option genericServers.

    c:\ps> New-OVLabDeploy -Domain workgroup -ProjectName MyProject -ProjectPath e:\virtualMachines -GenericServers 4

    .EXAMPLE
    when you want servers (With core edition) in a workgroup, 
    only use netbios (i.e.  Cottonfield) name for the -Domain option, and use the genericserverCore option.

    c:\ps> New-OVLabDeploy -Domain workgroup -ProjectName MyProject -ProjectPath e:\virtualMachines -GenericServers 4

    .EXAMPLE
    when you want servers (With core edition and Desktop Experience) in a workgroup, 
    only use netbios (i.e.  Cottonfield) name for the -Domain option, and use the genericserverCore and the genericserver options.

    c:\ps> New-OVLabDeploy -Domain workgroup -ProjectName MyProject -ProjectPath e:\virtualMachines -GenericServers 4

    .EXAMPLE
    When you need a domain with only servers with desktop experience, 
    use FQDN in the Domain Option (i.e. cottonfield.net), and don't use the options ending with Core.

    c:\ps> New-OVLabDeploy -Domain Cottonfield.net -ProjectName MyProject -ProjectPath e:\virtualMachines -Domaincontrollers 2 -GenericServers 4

    .EXAMPLE
    When you need a domain with only servers with Core edition, 
    use FQDN in the Domain Option (i.e. cottonfield.net), and use only the options ending with Core.

    c:\ps> New-OVLabDeploy -Domain Cottonfield.net -ProjectName MyProject -ProjectPath e:\virtualMachines -DomaincontrollersCore 2 -GenericServersCore 4

    When you need a domain with mixed desktop experience and core edition, 
    use FQDN in the domain option and use all the options for domaincontrollers and genericserver including the ones ending with core.

    c:\ps> New-OVLabDeploy -Domain Cottonfield.net -ProjectName MyProject -ProjectPath e:\virtualMachines -Domaincontrollers 2 -GenericServers 4 -DomainControllersCore 2 -GenericServers 8
    
    #>
    [CmdletBinding()]
    param(
        [string]$WindowsVersion,
        [string]$Domain,
        [string]$ProjectName,
        [string]$ProjectPath,
        [int]$DomainControllers,
        [int]$GenericServers,
        [int]$DomainControllersCore,
        [int]$GenericServersCore,
        #[int]$Windows10Pro,
        #[int]$Windows10Enterprse,
        [string]$NetworkIpAddress
    )  

    # starting the stopwatch
    $Global:StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $StopWatch.Start()

    $AppName = "OpenVirtualLab"
    # Check if the config file exists otherwise stop the script
    Clear-Host
    $ParentDiskConfigFile = "$Env:programdata\$AppName\Config\$($WindowsVersion).json"          
    Write-host $parentdiskconfigfile
    If (!(Test-Path $ParentDiskConfigFile )) { 
        Write-host There is no baseimage for $ParentDisk please run the cmdlet New-OVDiskTemplate for first time first before using this cmdlet -ForegroundColor Red
        break
    }

    # Reading the config file from programmdata and intializing the variables
    $ParentDiskConfig = (Get-content $ParentDiskConfigFile) | Out-String | ConvertFrom-Json
    
    $DomainController = @()
    $GenericComputer = @()
    $DomainControllerCore = @()
    $GenericComputerCore = @()

    # Get the variables for the differencing disk from config file
    $UserName = $ParentDiskConfig.UserName
    $Password = $ParentDiskConfig.Password
    $DifferencingParentFolder = $ParentDiskConfig.ParentDiskPath

    $Random = $null
    $UniqueSubProjectNumber = $False
    do {
        $Random = Get-Random -Minimum 0 -Maximum 10
        

        $ProjectFolder = "$ProjectPath\$ProjectName"
        $FileExists = Test-Path "$ProjectFolder\subproject.json"
        
        If (-not $fileExists) {
            [string[]]$SubProjectNumbers += @($Random)
            if(-Not (Test-Path $ProjectFolder)){
                New-Item $ProjectFolder -itemtype Directory
            }

            $SubprojectNumbers|ConvertTo-Json|Out-File -filepath "$ProjectFolder\subproject.json"
            $UniqueSubProjectNumber = $true
        } else {
            $SubProjectNumbers = [string[]](Get-Content "$ProjectFolder\subproject.json" -raw)|ConvertFrom-Json
            If($SubprojectNumbers -contains $Random) { 
                $UniqueSubProjectNumber = $False
            } else { 
                $UniqueSubProjectNumber = $true
            }
        }
    }While (-Not $UniqueSubProjectNumber)
    $SubProjectNumbers += $Random
    $SubprojectNumbers|ConvertTo-Json|Out-File -filepath "$ProjectFolder\subproject.json"

    $ProjectPrefix = "$($ProjectName.substring(0,2))$Random".ToLower()
    # Prefix the computer names with functionality of server
    $DomainController = [string[]](New-ComputerCollection -ServerCount $DomainControllers -Prefix "$($ProjectPrefix)dc")
    $GenericComputer = [string[]](New-ComputerCollection -ServerCount $GenericServers -Prefix "$($ProjectPrefix)svr")
    $DomainControllerCore = [string[]](New-ComputerCollection -ServerCount $DomainControllersCore -Prefix "$($ProjectPrefix)dccore")
    $GenericComputerCore = [string[]](New-ComputerCollection -ServerCount $GenericServersCore -Prefix "$($ProjectPrefix)svrcore")
    #$ClientsPro = New-ComputerCollection -ServerCount $Windows10Pro -Prefix "winpc"
    #$ClientsEnterprise = New-ComputerCollection -ServerCount $Windows10Pro -Prefix "W10Ent"

    $Comps = @()
    $Computers = @()
    $DControllers = @()
    $DCs = @()

    If ($DomainControllerCore.count -gt 0 -and $DomainController.count -gt 0) {
        $DCs = $DomainControllerCore + $DomainController
    }
    elseif ($DomainControllerCore.Count -lt 1 -and $DomainController.count -gt 0) {
        $DCs = [string[]]$DomainController
    }
    elseif ($DomainController.count -lt 1 -and $DomaincontrollerCore.count -gt 0) {
        $DCs = [string[]] $DomaincontrollerCore
    }
    else {
        Write-Host "Couldn't determine the domain controllers, so i quit" -ForegroundColor DarkYellow
        break
    }

    $Comps += $DomainControllerCore 
    $Comps += $DomainController 
    $Comps += $GenericComputerCore 
    $Comps += $GenericComputer

    ForEach ($comp in $Comps ) {
        If (-not [string]::IsNullOrEmpty($Comp)) { [string[]]$Computers += $Comp }
        }

        ForEach ($DC in $DCs ) {
            If (-not [string]::IsNullOrEmpty($dc)) { [string[]]$DControllers += $DC }
            }

        $Computers | ForEach-Object { Write-Host $_  will be created }

        # logging show which computers shall be prepared
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)$($Computers.Count) Virtual Machines to create`n $('-'*$Repeat)" -color magenta
        Write-Log "Going to create the following computers:"

        #Creating the virtual switch
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)Creating The Project Switch`n$('-'*$Repeat)" -color Magenta
        New-LabVmSwitch -Name $ProjectName



        foreach ($Computer in $Computers) {

            if ($Computer -like "*Core*") { 
                $ParentDiskName = "$($WindowsVersion)_serverdatacentercore.vhdx" 
            }
            else { 
                $ParentDiskName = "$($WindowsVersion)_serverdatacenter.vhdx" 
            }

            New-LabVmDisk -Computer $Computer -ProjectPath $ProjectPath -Gateway $Gateway `
                -DnsServer $DnsServer -DifferencingParentFolder $DifferencingParentFolder -ParentDiskName $ParentDiskName `
                -ProjectName $ProjectName -Username $UserName -password $Password -AppName $AppName
        }
    
        # Create and configure all vm's (generic)
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)Creating The Virtual Machines`n$('-'*$Repeat)" -color Magenta
        for ($i = 0; $i -lt $Computers.Count; $i++) {
            Write-log "Creating VM for $($Computers[$i])"

            New-LabVm -ComputerName $Computers[$i] -VmSwitch $ProjectName `
                -VmLabFolder $ProjectPath -ProjectName $ProjectName
        
        }
    
        $lastOctetIndex = $NetworkIPAddress.LastIndexOf('.')
        $DnsServer = ($NetworkIPAddress).substring(0, $lastOctetIndex) + '.1'
        $Gateway = ($NetworkIPAddress).substring(0, $lastOctetIndex) + '.254'
        $NetworkIp = ($NetworkIPAddress).substring(0, $lastOctetIndex)
        $IpCounter = 0

        # rename the network and add the dns server
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)Configuring the Network`n$('-'*$Repeat)" -color Magenta
        for ($i = 0; $i -lt $Computers.Count; $i++) {
        
            $IpCounter++
            $Lanip = "$NetworkIp.$($IpCounter)"
            Write-Host "IP Address will be:  $Lanip"

            Write-log "Going to Configure network for $($Computers[$i])"
            Edit-NetworkAdapter -NewAdapterName "$ProjectName Lan" -DnsServer $DnsServer -ProjectName $ProjectName `
                -Computer $Computers[$i] -Domain $Domain -UserName $UserName -Password $Password -IpAddress $LanIp -Gateway $GateWay
        
        }
    
        # install the role active-directory-services on the first domain controller.
        if ($DControllers.Count -gt 0) {
            Write-Log "$('-'*$RepeatTop)`n$($Tabs)Install The AD-Directory-Service Role on the first domain controller`n$('-'*$Repeat)" -color Magenta
            Write-log "Going to install the active directory services on $($DControllers[0])"
            Install-LabVmWindowsRole -DomainController $DControllers[0] -Username $Username -password $Password `
                -VMGuest "$ProjectName - $($DControllers[0])" -Role "ad-domain-services" -Domain "."
        }
    
        # promote the firs domain controller
        if ($DControllers.Count -gt 0) {
            Write-Log "$('-'*$RepeatTop)`n$($Tabs)Promoting the first domain controller`n$('-'*$Repeat)" -color Magenta
            Write-log "Going to deploy the first domain controller $($DControllers[0])"
            New-FirstDomainController -VMGuestName $DControllers[0] -ProjectName $ProjectName `
                -UserName $UserName -Password $Password -Domain $Domain
        }
    
        # Remove the temporary Mount folder for the project
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)Removing temporary projects folders`n$('-'*$Repeat)" -color Magenta
        $ProgrammDataProjectFolder = "$env:ProgramData\$AppName\$ProjectName"
        if (Test-Path $ProgrammDataProjectFolder) { Remove-Item $ProgrammDataProjectFolder -Recurse -Force }
    
        # Join The generics to the domain.
        if ($DControllers.Length -ge 1) {
            Write-Log "$('-'*$RepeatTop)`n$($Tabs)Join the generic computers to the domain`n$('-'*$Repeat)" -color Magenta
            for ($i = 1; $i -lt $computers.Count; $i++) {
                Wait-ForDomain -ProjectName $ProjectName -DomainControllerName $DControllers[0] `
                    -Domain $Domain -UserName $UserName -Password $Password
    
                Write-log "Adding Computer $($Computers[$i]) to domain $Domain"
                Add-ComputerToDomain -Password $Password -Username $UserName -Domain $Domain -ComputerName $Computers[$i] `
                    -ProjectName $ProjectName
            }
        }
    
        # Install ad-domain-service on additional domain controllers
        if ($DControllers.Count -gt 1) {
            Write-Log "$('-'*$RepeatTop)`n$($Tabs)Install The AD-Directory-Service Role on the additional domain controllers`n$('-'*$Repeat)" -color Magenta
            for ($i = 1; $i -lt $DControllers.Count; $i++) {
   
                Write-log "Going to install the active directory services on $($DControllers[$i])"
                Install-LabVmWindowsRole -DomainController $DControllers[$i] -Username $Username -password $Password `
                    -VmGuest "$ProjectName - $($DControllers[$i])" -Role "ad-domain-services" -Domain "."
            
            }
        }
    
        #Promoting additional domain controllers
        if ($DControllers.Length -gt 1) {
       
            Write-Log "$('-'*$RepeatTop)`n$($Tabs)Promoting additional domain Controllers`n$('-'*$Repeat)" -color Magenta
            for ($i = 1; $i -lt $DControllers.Length; $i++) {
                Write-log "Going to deploy Domain Controller on $($DControllers[$i])"
            
                $PsSession = New-LabPsSession -VMGuest "$ProjectName - $($DControllers[$i])" `
                    -UserName $Username -Password $Password -Domain $Domain
                
                Install-LabVmGuestActiveDirectory -SafeModePassword $Password `
                    -Password $Password -PsSession $PsSession `
                    -Username $UserName -NoRebootOnCompletion:$false `
                    -DomainControllerPurpose "AddDomainController2Domain" -DomainName $Domain
        
            }         
        }
    
        Write-Log "$('-'*$RepeatTop)`n$($Tabs)Finished deploying the project`n$('-'*$Repeat)" -color Magenta
        write-log $Stopwatch.Elapsed
        $StopWatch.Stop()
    } 

    
