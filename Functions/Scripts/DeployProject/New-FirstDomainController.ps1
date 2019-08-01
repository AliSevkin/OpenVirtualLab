function New-FirstDomainController
{
	param(
		[string]$VMGuestName,
		[string]$ProjectName,
		[string]$UserName,
		[string]$Password,
		[string]$Domain
	)

	$Session = New-LabPsSession -VMGuest "$ProjectName - $VMGuestName" -Domain $Domain -UserName $UserName -Password $Password


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

		While ((Get-WindowsFeature ad-domain-services).installstate -ne "installed")
		{
			$Counter++
			Write-Log "(Deploy-FirstDomainController) Checking if the ActiveDirectory-Domain-Service has been installed attempt $Counter" -color Darkyellow
			for($i = 5;$i -gt 0;$i--)
			{
				 
				Write-Log "Will check again in $i seconds$('.'*$i)" -color DarkCyan
				Start-Sleep -Seconds 1
			}
		}

	}

	Invoke-Command -ScriptBlock $Script -Session $session

	# install and configure the active directory service and domain
	Install-LabVmGuestActiveDirectory -PsSession $Session -SkipPrechecks:$false -SafeModePassword $Password -DomainName $Domain `
					-Password $Password -Username $UserName -NoRebootOnCompletion:$false -DomainControllerPurpose NewForest	`
					-CreateDnsDelegation:$False
}