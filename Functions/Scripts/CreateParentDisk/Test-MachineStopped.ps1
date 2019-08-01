Function Test-MachineStopped
{
    param(
        [string]$VmName
    )

    $State = "Running"
    While($State -ne "Off")
    {
        Write-Log "Checking if virtual machine $VmName has stopped."
        $State = (Get-Vm -Name $VmName).State

        if($State -eq "Off") { break }
        
        For($i=5; $i -gt 0;$i--)
        {
            Write-Log "Will check again in $i seconds"
            Start-Sleep -Seconds 1
        }
    }
}