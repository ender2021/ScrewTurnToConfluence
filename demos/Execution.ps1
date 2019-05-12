$totalTimer = [system.diagnostics.stopwatch]::StartNew()

Import-Module $PSScriptRoot\..\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\Credentials\Credentials.ps1
. $PSScriptRoot\configs\Config.ps1

#configure space information
$spaceKey = $Config.spaceKey + "2"
$spaceName = $Config.spaceName + " 2"

#open a session
Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

#Reset the space
Reset-ConfluenceSpace $spaceKey $spaceName -Verbose

#get category (aka label) mapping info from ScrewTurn
$labels = Get-ScrewTurnCategoryBinding $Config.dbconnection $Config.dbName

#get attachments directory list
$attachments = Get-ChildItem $Config.attachments

#create a single page as a test
$testPage = Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName | Where-Object { $_.Name -eq "SAIS-Environments" } | New-ConfluencePage -SpaceKey $spaceKey -Labels $labels -Attachments $attachments -Verbose

#fill space with content
#$pages = Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName -Exclude @("WikiMarkup-Reference") | New-ConfluencePage -SpaceKey $spaceKey -Labels $labels -Attachments $attachments -Verbose

#close the session
Close-ConfluenceSession

$totalSeconds = [math]::Round($totalTimer.Elapsed.TotalSeconds,0)
Write-Host "Total script execution time: $totalSeconds seconds"