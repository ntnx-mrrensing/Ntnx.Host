$localModulePath = "C:\_admin\PowerShell\modules"

$moduleName = split-path (split-path $PSScriptRoot -parent) -leaf

Copy-Item -Path "$(Split-Path $PSScriptRoot)\$moduleName" -Destination $localModulePath -Force -Recurse -Verbose