Function Set-WindowsSelection
{
	Param(
		[string]$PathAutoUnattend,
		[string]$DestinationPath,
		[string]$OsVersion,
		[string]$OsType,
		[string]$password
	)

	Write-Log "OsVersion: $OsVersion"
	Write-Log "OsType: $OsType"
	$ServerSelection = "Windows Server $OsVersion $OsType"
	Write-Log "ServerSelection: $ServerSelection"

	$AutoUnattend = Get-Content $PathAutoUnattend
	$AutoUnattendFile = "$DestinationPath\autounattend.xml"
	($AutoUnattend -replace "{SERVERTYPE}", $ServerSelection -replace "{AdminPassword}", $Password) | Out-File $AutoUnattendFile -Encoding utf8 -Force
}