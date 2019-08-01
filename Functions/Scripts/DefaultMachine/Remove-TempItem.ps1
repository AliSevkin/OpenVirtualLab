Function Remove-TempItem
{
    param(
        [string]$appName
    ) 
    
    if ($null -eq $AppName) { break }
    $Path = "$env:ProgramData\$appName\Workdir"
    Remove-Item $Path -Force -Recurse
}