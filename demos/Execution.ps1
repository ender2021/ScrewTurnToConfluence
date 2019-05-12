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

#Read from a text file and attempt to convert (use for testing a single piece of content)
#(Get-Content $PSScriptRoot\body.txt -Delimiter [char]0x0400) | Format-Content -Title "blank" | Out-File "converted.txt"

#create a single page as a test
Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName | Where-Object { $_.Name -eq "eGrades-Sync-Service" } | New-ConfluencePage -SpaceKey $spaceKey -Labels $labels -Verbose

#fill space with content
#$pages = Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName -Exclude @("WikiMarkup-Reference") | New-ConfluencePage -SpaceKey $spaceKey -Labels $labels -Verbose

#close the session
Close-ConfluenceSession

$totalSeconds = [math]::Round($totalTimer.Elapsed.TotalSeconds,0)
Write-Host "Total script execution time: $totalSeconds seconds"