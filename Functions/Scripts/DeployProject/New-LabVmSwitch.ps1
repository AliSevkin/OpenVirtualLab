Function New-LabVmSwitch
{
	param (
		[parameter(Mandatory = $true)]
		[string]$Name,
		[string]$ManagementIP
	)

	# set the $CheckVmSwitch variable to  null, so we can do a 
	# check on it if the switch allready exists or not.
	$CheckVmSwitch = $Null

	# Try to get the switch from hyperv, 
	# this will generate an error if it doesnt exists
	# but will sillently continue
	Write-Log "Checking if Switch allready exists for Lab $Name"
    $CheckVmSwitch = Get-VMSwitch -Name $Name -ea SilentlyContinue

	#Checking if Switch already exist, if not create it.

	if ($Null -eq $CheckVmSwitch)
	{
		try
		{
			#create the switch
			New-VMSwitch -Name $Name -SwitchType Internal

			$InterFaceAlias = (Get-NetAdapter -Name "*$($Name)*").Name
			New-NetIPAddress -InterfaceAlias $InterFaceAlias -IPAddress $ManagementIP -PrefixLength 24

			Write-Verbose "VMSwitch Created for Lab $CheckVmSwitch"
		}
		catch
		{
			# Creating the switch has ran into an error and couldn't continue
			Write-Log "(New-LabVmSwitch) Some error occured during creation of the vmswitch $CheckVmSwitch"
		}
	}
	else
	{
		# well it means the switch allready exists
		Write-Log "Skipped creating new VMSwitch, VMSwitch for Lab $CheckVmSwitch Allready exists."
	}
}