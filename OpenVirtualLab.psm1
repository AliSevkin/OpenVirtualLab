# dot source the helper scripts
$HelperFiles = (Get-ChildItem $PSScriptRoot\Functions -recurse -File -include "*.ps1")
foreach($File in $HelperFiles)
{
    . ($File.FullName)
}

# export the functions
$Functions = Get-ChildItem $PSScriptRoot\Functions -File|%($_.Name) {$_.Name -replace ".ps1",""}
Export-ModuleMember -Function $Functions

$Repeat = 120
$RepeatTop = 107
$Tabs = "`t`t`t"

