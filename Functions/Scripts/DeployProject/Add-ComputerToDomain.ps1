Function Add-ComputerToDomain
{
	Param(
		[string]$Domain,
		[string]$UserName,
		[string]$Password,
		[string]$ComputerName,
		[string]$ProjectName
	)
	$VmGuest = "$ProjectName - $ComputerName"
	try{
	$Session = New-LabPsSession -VMGuest $VmGuest `
					-Domain "." -UserName $UserName -Password $Password
	} catch {
		Write-Host "Couldn't get session to host $Vmguest"
	}

	$Script = { 	
		$Succes = $false
		While($Succes -eq $false)
		{
            $Error.Clear()
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
				$Elapsed = $StopWatch.Elapsed
	
				$Timer = "$($Elapsed.Hours):$($Elapsed.Minutes):$($Elapsed.Seconds):$($Elapsed.Milliseconds)"
	
				Write-Host [$Time] $Message -ForegroundColor $Color
	
			}

			try
			{
				Add-Computer -DomainName $args[0] -ComputerName $args[1] -DomainCredential $args[2] -Restart:$true -ErrorAction stop
				if($error -eq $null) { $Succes = $true } else { $Succes = $false }
			}
			catch
			{
				$Succes = $false
				Write-Log "(Add-ComputerToDomain) $($args[2]) Couldn't Join to domain $($args[0]) will try again." -color Darkyellow
				for($i=5;$i -gt 0;$i--)
				{
					write-log "Will try again in $i seconds$('.'*$i)" -color darkcyan
					Start-Sleep -Seconds 1
				}
			}

		}

	}
	
	$Credential = $Null
	$UserObject = "$domain\$UserName"
	$Credential = New-Object System.Management.Automation.PSCredential($UserObject, 
									(ConvertTo-SecureString -string $Password -AsPlainText -Force))

	Try {
		Invoke-Command -session $Session -ScriptBlock $Script -ArgumentList $Domain, $ComputerName, $Credential
		Write-Host The background job has ended.
	} catch {
		Write-Host The background job has forceably ended. 
	}
}