Function Set-DestinationFolder
{
	param(
		[string]$WinInstallIsoFolderDestination,
		[string]$LogFile
	)
	# Destiniation for the install.wim
	Write-Log "Source is: $WinInstallIsoFolderDestination"

	# check if the destiniationfolder exists
	$ISODestinationFolderExists = Test-Path $WinInstallIsoFolderDestination
	Write-Log "Windows temp ISO folder exists: $ISODestinationFolderExists"

	# Creating the destinationfolder if it doesn't exists
	if(-not $ISODestinationFolderExists)
	{
		Write-Log "Creating the destinationfolder: $WinInstallIsoFolderDestination"
		$null = New-Item $WinInstallIsoFolderDestination -ItemType Directory
	}
}