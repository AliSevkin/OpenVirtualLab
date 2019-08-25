

function Install-LabVmGuestActiveDirectory
{
	param (
		[System.Management.Automation.Runspaces.PSSession]$PsSession,
		[bool]$CreateDnsDelegation=$false,
		[string]$DatabasePath = "C:\Windows\NTDS",
		[string]$ForestMode = "Win2008R2",
		[string]$DomainMode = "Win2008R2",
		[string]$DomainName = "NoName.net",
		[bool]$InstallDns = $true,
		[string]$LogPath = "C:\Windows\NTDS",
		[bool]$NoRebootOnCompletion = $false,
		[string]$SysVolPath = "C:\Windows\SYSVOL",
		[string]$UserName,
		[string]$Password,
		[bool]$SkipPrechecks = $false,
		[string]$SafeModePassword,
		[parameter(Mandatory=$true)]
		[validateset("AddDomainController2Domain","NewForest","Domain2ExistingForest")]
		[string]$DomainControllerPurpose,
		[string]$Site = "Default-First-Site-Name"
		
	)
	
	$DomainNetbiosName = $DomainName.Split('.')[0]
	$Credential = New-Object -TypeName pscredential("$DomainNetbiosName\$UserName",
		(ConvertTo-SecureString -string $Password -AsPlainText -Force))
	
	switch ($DomainControllerPurpose)
	{
		"NewForest" {
			$Script = {
				Import-Module ADDSDeployment
				Install-ADDSForest `
								   -CreateDnsDelegation:$args[0] `
								   -DatabasePath $args[1] `
								   -DomainMode $args[2] `
								   -DomainName $args[3] `
								   -DomainNetbiosName $args[4] `
								   -ForestMode $args[5] `
								   -InstallDns:$args[6] `
								   -LogPath $args[7] `
								   -NoRebootOnCompletion:$args[8] `
								   -SysvolPath $args[9] `
								   -skipPreChecks:$args[10] `
								   -SafeModeAdministratorPassword (ConvertTo-SecureString -string $args[11] -AsPlainText -Force) `
								   -Force:$true
			}
		}
		
		"AddDomainController2Domain" {
			$Script = {
				Import-Module ADDSDeployment
				Install-ADDSDomainController `
											 -NoGlobalCatalog:$false `
											 -CreateDnsDelegation:$false `
											 -Credential $args[12] `
											 -CriticalReplicationOnly:$false `
											 -DatabasePath $args[1] `
											 -DomainName $args[3] `
											 -InstallDns:$true `
											 -LogPath $args[7] `
											 -NoRebootOnCompletion:$false `
											 -SiteName $args[13] `
											 -SysvolPath $args[9] `
											-Force:$true `
											 -SafeModeAdministratorPassword (ConvertTo-SecureString -string $args[11] -AsPlainText -Force) `
													
				
			}
		}
	}
	
	Write-Log "(Install-LabVmGuestActiveDirectoryRole) Going to install the ActiveDirectory role."
	Invoke-Command -Session $PsSession -ScriptBlock $Script -ArgumentList $CreateDnsDelegation,
				$DatabasePath, 
				$DomainMode, 
				$DomainName, 
				$DomainNetbiosName, 
				$ForestMode, 
				$InstallDns, 
				$LogPath, 
				$NoRebootOnCompletion,
				$SysVolPath,
				$SkipPrechecks, 
				$SafeModePassword, 
				$Credential, 
				$Site, 
				$NoGlobalCatalog
}


