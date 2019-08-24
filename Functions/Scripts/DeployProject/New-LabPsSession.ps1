function New-LabPsSession
{
	param(
		[Parameter(mandatory = $true)]
		[string]$VMGuest,
		[string]$Domain,
		[string]$UserName,
		[string]$Password
	)
	$Credential = $Null
	$UserObject = "$Domain\$UserName"
	$Credential = New-Object System.Management.Automation.PSCredential($UserObject, 
							(ConvertTo-SecureString -string $Password -AsPlainText -Force))

	$Session = $Null
	$Counter = 0
	While(-not $Session)
	{
		$Counter++
		Write-Log "Trying to connect to $VMguest attempt $Counter"
		try
		{
			if($Session) { Remove-PSSession $Session }
			$Session = New-PSSession -VMName $VMGuest -Credential $Credential -ea Stop
		}
		catch
		{
			write-Log "(New-LabPsSession) Couldn't connect to $VMguest it may still be rebooting." -color DarkYellow
			for($i = 5; $i -gt 0; $i--)
			{
				write-log "wil try again in $i seconds$('.'*$i)" -color darkcyan
				start-sleep -Seconds 1
			}
		}
	}
	return $Session
}


