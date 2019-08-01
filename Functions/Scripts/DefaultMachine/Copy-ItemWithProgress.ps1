Function Copy-ItemWithProgress
{

 [CmdletBinding()]

	 Param(
		 [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]$Source,
		 [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]$Destination
	 )

	$Source=$Source.tolower()
	$Filelist=Get-Childitem $Source -Recurse
	$Total=$Filelist.count
	$Position=0

	foreach ($File in $Filelist)
	{
		$Filename=$File.Fullname.tolower().replace($Source,'')
		$DestinationFile=($Destination+$Filename)
		Write-Progress -Activity "Copying data from $source to $Destination" `
				-Status "Copying File $Filename" -PercentComplete (($Position/$total)*100)

		Copy-Item $File.FullName -Destination $DestinationFile -Force
		$Position++
	}
}