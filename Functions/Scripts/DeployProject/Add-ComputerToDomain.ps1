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
            $null = $Error.Clear()
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

			try
			{
				$null = Add-Computer -DomainName $args[0] -ComputerName $args[1] -DomainCredential $args[2] -Restart:$true -ErrorAction stop
				$Succes = $true
			}
			catch
			{
				$Succes = $false
				Write-Log "(Add-ComputerToDomain) Couldn't Join to domain will try again." -color Darkyellow
				for($i=5;$i -gt 0;$i--)
				{
					write-log "Will try again in $i seconds$('.'*$i)" -color darkcyan
					Start-Sleep -Seconds 1
				}
				$Succes = $false
			}

		}

	}
	
	$Credential = $Null
	$UserObject = "$domain\$UserName"
	$Credential = New-Object System.Management.Automation.PSCredential($UserObject, 
									(ConvertTo-SecureString -string $Password -AsPlainText -Force))

	Try {
		$null = Invoke-Command -session $Session -ScriptBlock $Script -ArgumentList $Domain, $ComputerName, $Credential
		Write-Host The background job has ended.
	} catch {
		Write-Host The background job has forceably ended. 
	}
}