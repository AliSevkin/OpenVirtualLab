Function Mount-Iso
{
	param(
		[string]$PathIsoFile
	)

	# Mounting the iso file
	Write-Log "Mounting the Windows Iso file"
	Write-Log "path to the Iso file: $PathIsoFile"
	$MountedISO = Mount-DiskImage $PathIsoFile -StorageType ISO -Access ReadOnly -PassThru
	$DriveLetter = $MountedISO|Get-Volume|select-object -ExpandProperty Driveletter
	Write-Log "ISO mounted on driveletter: $DriveLetter"
	return $DriveLetter
}