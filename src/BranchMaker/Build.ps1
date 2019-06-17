#Install-Module -Name newtonsoft.json
#Install tfx-cli using npm
#npm install -g tfx-cli
$ErrorActionPreference = "Stop"

$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).FullName
$buildFolder = Join-Path $scriptLocation "build"

Remove-Item -Path "$buildFolder\*" -Filter *.vsix

$task = Get-Content -Path ".\Task\task.json" -raw | ConvertFrom-JsonNewtonsoft
$currentVersion = "$($task.version.Major).$($task.version.Minor).$($task.version.Patch)"
$task.version.Patch = "$([System.Convert]::ToInt32($task.version.Patch) + 1)"
[string]$newVersionNumber = "$($task.version.Major).$($task.version.Minor).$($task.version.Patch)"
$task | ConvertTo-JsonNewtonsoft | set-content ".\Task\task.json"

Write-Host "Updating Task: $($task.name)" -ForegroundColor Yellow
Write-Host "Current Version: $currentVersion"
Write-Host "New Version: $newVersionNumber"

$extensionJson = Get-Content -Path "vss-extension.json" -raw | ConvertFrom-JsonNewtonsoft
$currentExtensionVersion = $extensionJson.version
$extensionJson.version = "$newVersionNumber"
$extensionJson | ConvertTo-JsonNewtonsoft | set-content "vss-extension.json"

Write-Host "Updated VSS-Extension: $($extensionJson.name)" -ForegroundColor Yellow
Write-Host "Current Version: $($currentExtensionVersion)"
Write-Host "New Version: $newVersionNumber"

tfx login --service-url "http://devads/DefaultCollection" --authType pat --token "dk26fcbmrkf6nq4tkiedm3fopdegscheeb257ufoc7uzrwp67yra"

tfx extension create --manifest vss-extension.json --output-path .\build\

tfx build tasks upload --task-path .\Task