function Set-LogFile
{
	param(
		[string]$LogFolder
	)

	# Create the logfolder
	$LogFolderExists = Test-Path $LogFolder
	if(-Not $LogFolderExists)
	{ 
		$null = New-Item $LogFolder -ItemType Directory 
	}
}