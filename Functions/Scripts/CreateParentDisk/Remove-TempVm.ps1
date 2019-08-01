Function Remove-TempVm
{
    param(
        [string]$Vm
    )   
    $VmRootFolder = (Get-Item -Path (Get-Vm -Name $Vm).Path).parent.FullName
    Write-Log "rootfolder: $VmRootFolder"

    $VM | Remove-VMSwitch -Force
    $Vm | Remove-VM  -Force
  
    Remove-Item $VmRootFolder -Recurse -Force 
}