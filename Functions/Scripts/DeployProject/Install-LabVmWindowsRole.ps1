
Function Install-LabVmWindowsRole
{
	param (
		[string[]]$Role,
		[string]$VMGuest,
		[string]$Domain,
		[string]$UserName,
		[string]$Password
	)
	
	
	$Credential = $Null
	$UserObject = "$($domain)\$($UserName)"
	$Credential = New-Object System.Management.Automation.PSCredential($UserObject, (ConvertTo-SecureString -string $Password -AsPlainText -Force))
	Write-log "Getting Session for $VMGuest"

	$Session = $Null
	$Counter = 0
	While(-not $Session)
	{

		$Counter++
		Write-Log "Trying To connect to $VMguest attempt $Counter"
		try
		{
			$Session = New-PSSession -VMName $VMGuest -Credential $Credential
		}
		catch
		{
			Write-Log "(Install-LabVmWindowsRole) Couldn't get session to $VMguest, maybe still rebooting, will try again..." -color DarkYellow
		}

		if($session) { $i=0 } else { $i = 5 }
		While($i -gt 0)
		{
				write-log "in $i seconds$('.'*$i)" -color DarkCyan
				$i--
				start-sleep -Seconds 1
		}
	}

	$Script = {
		Install-WindowsFeature $Args[0] -IncludeAllSubFeature -IncludeManagementTools
	}

	Write-Log "Installing the role/feature $Role"
	Invoke-Command -Session $Session -ScriptBlock $Script -ArgumentList $Role
}
