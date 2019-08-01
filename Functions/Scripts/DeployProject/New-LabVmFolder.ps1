Function New-LabVmFolder
{
	param (
		[string]$ProjectRootFolder,
		[string]$ProjectName
	)
	
	$ProjectPath = "$ProjectRootFolder\$ProjectName"
	if (!(Test-Path $ProjectPath))
	{
		$null = (New-Item -Path $ProjectPath -ItemType directory)
		Write-Log "Lab folder $ProjectPath created" -color white
	}
	else
	{
		Write-Log "Skipped creating new Lab Folder $ProjectPath , Lab Folder Allready exists." -color DarkYellow
	}
}