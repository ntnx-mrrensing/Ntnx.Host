param(
    [parameter()]
    [ValidateSet("MAJOR","MINOR","BUILD","REVISION")]
    [string]
    $VersionRev = "REVISION",

    [parameter()]
    [switch]
    $PushToModulePath=$true,

    [parameter()]
    [switch]
    $ReloadModule=$true
)

$moduleName = Split-Path (Split-Path $PSScriptRoot) -Leaf

$moduleRoot = Join-Path -Path (Split-Path $PSScriptRoot) -ChildPath $moduleName

$manifestPath = "$moduleRoot\$moduleName.psd1"
#

#Test-Path -Path $moduleRoot

$publicFunctions = (Get-ChildItem -Path "$moduleRoot\Public" -Filter '*.ps1').BaseName
#$publicFunctions

if(Test-Path -Path $manifestPath){
    $maniVer = (Test-ModuleManifest -Path $manifestPath).Version

    if($maniVer.Build -eq -1){
        $maniVer.Build = 0
    } 
    if($maniVer.Revision -eq -1){
        $maniVer.Revision = 0
    } 

    $verUpdate = @{
        Major = if ($VersionRev -eq "MAJOR"){$maniVer.Major + 1} else {$maniVer.Major}
        Minor = if ($VersionRev -eq "MINOR"){$maniVer.Minor + 1} else {$maniVer.Minor}
        Build = if ($VersionRev -eq "BUILD"){$maniVer.Build + 1} else {$maniVer.Build}
        Revision = if ($VersionRev -eq "REVISION"){$maniVer.Revision + 1} else {$maniVer.Revision}
    }

    $newVer = [version]::new($verUpdate.Major, $verUpdate.Minor, $verUpdate.Build, $verUpdate.Revision)

    Update-ModuleManifest -Path $manifestPath -FunctionsToExport $publicFunctions -ModuleVersion $newVer.tostring()

}

if($PushToModulePath){
    . $PSScriptRoot\pushToModulePath.ps1
}

if($ReloadModule){
    Import-Module $moduleName -force
}