Function New-ComputerCollection
{
    Param(
        [int]$ServerCount,
        [string]$Prefix

    )

    if($Null -Ne $Servers) { -Variable -Name $Servers -Value $Null }
    $Servers = @()
    for ($i = 1; $i -le $ServerCount; $i++)
    {
        $Number = "{0:00}" -f $i
        $Server = $Prefix + $Number
        $Servers += $Server
        Write-Log "Creating Server Collection, adding $Server"
    }
    return $Servers
}