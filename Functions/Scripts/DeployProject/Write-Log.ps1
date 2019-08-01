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