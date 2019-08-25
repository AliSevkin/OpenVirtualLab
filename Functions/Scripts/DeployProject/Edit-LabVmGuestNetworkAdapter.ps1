

function Edit-NetworkAdapter
{
	param (
		[string]$NewAdapterName,
		[string]$DnsServer,
		[string]$GateWay,
		[string]$IpAddress,
		[string]$ProjectName,
		[string]$Computer,
		[string]$Domain,
		[string]$UserName,
		[string]$Password
	)

	while (-not ($Session -is [System.Management.Automation.Runspaces.PSSession]))
	{
		$Session = New-LabPsSession -VMGuest "$ProjectName - $Computer" -Domain $Domain `
					-UserName $UserName -Password $Password
		if(-not ($Session -is [System.Management.Automation.Runspaces.PSSession]))
		{
			Write-Log "The returned value of Session was not type of PsSession." -color darkyellow
			for($i=3;$i -gt 0;$i--)
			{
				write-log "Wil try to get a new session in $i seconds$('.'*$i)"
				Start-Sleep -Seconds 1
			}
		}

	}

	$Script = {
		$null = Set-DnsClientServerAddress -InterfaceAlias ((Get-NetAdapter)[0]|Select-object -ExpandProperty Name) -ServerAddresses $args[3]
		if($args[4] -like '*natcore*' -or $args[4] -like '*natrouter*') {
			$null = (Get-NetAdapter)[0] | New-NetIpaddress -IPAddress $args[1] -AddressFamily IPv4 -PrefixLength 24
		} else {
			$null = (Get-NetAdapter)[0] | New-NetIpaddress -IPAddress $args[1] -DefaultGateway $args[2] -AddressFamily IPv4 -PrefixLength 24
		}
		$null = (Get-NetAdapter)[0]| Rename-NetAdapter -NewName $args[0]
		
		Write-Host Enabling Remote desktop -ForegroundColor Green
		Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0
        Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 0
        Enable-NetFirewallRule -DisplayGroup “Remote Desktop”

		if (Test-Path "C:\unattend.xml")
		{
			Remove-Item "C:\Unattend.xml" -Force
		}
	}
	Invoke-Command -Session $Session -ScriptBlock $Script -ArgumentList $NewAdapterName, $IpAddress, $Gateway, $DnsServer, $Computer
}