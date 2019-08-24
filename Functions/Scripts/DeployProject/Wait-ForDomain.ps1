function Wait-ForDomain
{
	param(
		[string]$ProjectName,
		[string]$DomainControllerName,
		[string]$Domain,
		[string]$UserName,
		[string]$Password
	)
	

	# create a session to the VM
	$Credential = $Null
	$UserObject = "$Domain\$UserName"
	$Credential = New-Object System.Management.Automation.PSCredential($UserObject, 
					(ConvertTo-SecureString -string $Password -AsPlainText -Force))

	$VmName = "$ProjectName - $DomainControllerName"
	Write-log "(Wait-ForGetting Session for $VmName"
	$Session = $Null
	$Counter = 0
	While(-not $Session)
	{
		$Counter++
		Write-Log "Trying To connect to $VmName with credential: $UserObject attempt $Counter"
		try
		{
			$Session = New-PSSession -VMName $VmName -Credential $Credential -ea stop
		}
		catch
		{
			Write-Log "(Wait-ForDomain-1) Could not connect to $VmName, system may still be rebooting, will try again... " -color DarkYellow
			for($i=5; $i -gt 0; $i--)
			{
				Write-Log "Will try again in $i seconds $('.' *$i)" -color DarkCyan
				Start-Sleep -Seconds 1
			}
		}
	}

	
	# Try to get the domain name from the active directory if it is allready up and running
	# else wait and retry again.
	$Script = {
		function Write-Log
		{
			param (
				[parameter(Mandatory=$true, Position = 0)]
				[String]$Message,
				[ValidateSet("Info","Error","Warning")]
				[string]$Type="Info",
				[switch]$Header,
				[switch]$Footer,
				[string]$Color = "Cyan"
			)
			$Time = (Get-Date).ToLongTimeString()	
			Write-Host [$Time] $Message -ForegroundColor $Color
	
		}

		$Counter = 0
		while ($true)
		{
			$DomainName = $null
			$Counter++
			write-log "Checking if finished promoting the domain controller $($args[1]), attempt $Counter"

			try
			{
			$null = $DomainName = (Get-ADDomain).DNSRoot
			}
			catch
			{
				Write-Log "(Wait-ForDomain-2) Domain still not online will try again..."  -Color DarkYellow
			}

			if ($DomainName -eq $args[0])
			{
				Write-log "Domain $DomainName installed on $($args[1])"
				break
			}
			
			for ($i = 10; $i -gt 0; $i--)
			{
				write-log "in $i seconds$('.'*$i)" -color DarkCyan
				Start-Sleep -s 1
			}
		}
	}

	Invoke-Command -Session $Session -ScriptBlock $Script -ArgumentList $Domain, $DomainControllerName
}