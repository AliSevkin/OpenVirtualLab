Function Add-Router {
    param(
        [string[]]$Networks
    )


    $BaseSystemConfig = Get-Content $ConfigFile

    New-LabVmDisk -UserName $UserName -password $Password -AppName $AppName -Computer $Computer ProjectPath $ProjectPath
    $DifferencingParentFolder
    $ParentDiskName
    $ProjectName
}