Function Start-Generalize
{
    param(
        [object]$Session
    )

    Write-Log "Going To Generalize the machine and shutdown"

    $Script = {
        $HostName = (Get-ComputerInfo).CsCaption
        Write-Host "In host $HostName going to start sysprep" -ForegroundColor Cyan
        $sysprep = "$env:systemroot\System32\sysprep\sysprep.exe"
        Write-Host "Command to start $sysprep"
        Start-Process -FilePath $sysprep -ArgumentList '/quiet /generalize /oobe /shutdown' -Wait
    }
    Invoke-Command -Session $Session -ScriptBlock $Script #DevSkim: ignore DS104456 
}