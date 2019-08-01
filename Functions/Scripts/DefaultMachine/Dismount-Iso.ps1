Function Dismount-Iso
{
	param(
		[string]$LogFile,
		[string]$IsoPath
	)

	# Unmounting the Iso file
	Write-Log "Dismounting the Windows Iso file."
	Dismount-DiskImage -ImagePath $IsoPath
}