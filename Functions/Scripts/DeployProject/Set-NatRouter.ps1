Function Set-NatRouter {
    param(
        [string]$Username,
        [string]$Password,
        [string]$Domain,
        [string]$VmName,
        [string]$Gateway,
        [string]$ProjectName
    )

    $ExternalSwitch = $null
    $ExternalSwitch = Get-ExternalSwitch

    Add-VMNetworkAdapter -VMName $VMName -SwitchName $ExternalSwitch
    
    $Scripts= @({
        Rename-NetAdapter -Name "$($Args[0]) Lan" -NewName "Internal"
        Rename-NetAdapter -Name "Ethernet" -NewName "Internet"

        Install-WindowsFeature routing -includeManagementTools
        Install-RemoteAccess -vpntype Vpn
        #Restart-computer
    },
    <#
    {   
        $Wait = $true
        $RoutingInstalled = $False
        Do {
        $RoutingInstalled = (Get-WindowsFeature Routering).InstallState
        if($RoutingInstalled) { $Wait = $false }
        Start-Sleep -Seconds 1
        }While ($Wait)
    }, #>
    {
        Write-Host 'Changing the IP address for the gateway' -ForegroundColor yellow
        Get-NetAdapter -Name "Internal" |
            New-NetIPAddress -IPAddress $Args[1] -AddressFamily IPv4 -PrefixLength 24      


        Write-Host 'Enabling firewall rulle for ping' -ForegroundColor yellow
        Netsh advfirewall firewall set rule name="file and printer sharing (Echo Request - ICMPv4-In)" new enable=yes
        
        Write-Host 'Installing nat on remote acces' -ForegroundColor yellow
        Write-Host 'configuring the interfaces for NAT' -ForegroundColor yellow

            netsh routing ip nat install
            netsh routing ip nat add interface name="Internet" mode=full
            netsh routing ip nat add interface name="Internal" mode=private
    })

    foreach($Script in $Scripts){

        $Session = New-LabPsSession -VMGuest $VmName -Username $Username -Domain $Domain -Password $Password
        
        try {
        Invoke-Command -ScriptBlock $Script -Session $Session -ArgumentList $ProjectName, $Gateway
        } catch {
            Write-Host "system maybe rebooting..." -ForegroundColor yellow
        }
    }
}