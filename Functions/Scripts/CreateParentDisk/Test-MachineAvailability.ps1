Function Test-MachineAvailability {
    param(
        [string]$VmName,
        [string]$UserName,
        [String]$Password
    )

    Write-Log "UserName: $UserName password: $Password VMName: $VMName"
    $Credential = New-Object pscredential($UserName, (ConvertTo-SecureString -AsPlainText $Password -Force))

    $Session = $Null
    $counter = 0
    $Timer = 40
    While (-not $Session) {
        try {
            $Counter += 1
            Write-Log "Trying to connect to $VmName attempt $Counter"
            $Session = New-PSSession -VMName $VmName -Credential $Credential -ErrorAction  Stop
        }
        catch {
            Write-Log "Will sleep for $Timer seconds before next attempt"
            Write-Log "Virtual Machine still preparing to start" -Color "Red"
            For ($i = $Timer; $i -gt 0; $i--) {
                Write-Progress -CurrentOperation "Will attempt to connect in: " ("$i Seconds ")
                Start-Sleep -Seconds 1
            }
        }  
    }

    Write-Log "Got Session to $VmName"
    return $Session
}