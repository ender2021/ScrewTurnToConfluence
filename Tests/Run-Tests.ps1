#Setup the various imports
Import-Module ..\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
Import-Module Pester -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\..\demos\Credentials\Credentials.ps1
. .\Test-FormatContent.ps1

Invoke-Pester