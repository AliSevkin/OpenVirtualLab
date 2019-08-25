Function Get-ExternalSwitch {
    
    $ExternalSwitch = $null
    $ExternalSwitch = Get-VMSwitch | Where-Object SwitchType -eq 'External'
    return $ExternalSwitch.Name 
}