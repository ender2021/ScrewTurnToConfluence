Import-Module $PSScriptRoot\..\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\Credentials\Credentials.ps1
. $PSScriptRoot\configs\Config.ps1

$spaceKey = $Config.spaceKey #+ "2"
$spaceName = $Config.spaceName #+ " 2"

#open a session
Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

#delete the space if it already exists, and then wait to make sure it finishes
try {
    Write-Host "Deleting space"
    $response = Invoke-ConfluenceDeleteSpace -SpaceKey $spaceKey
    Write-Host "Sleeping for 10 seconds to allow the delete operation to finish"
    Start-sleep -Seconds 10
}
catch {
    Write-Host "Space with key $spaceKey does not exist"
}

#create a fresh space
try {
    Write-Host "Creating space"
    $space = Invoke-ConfluenceCreateSpace -SpaceKey $spaceKey -Name $spaceName
}
catch {
    Write-Host "Space with key $spaceKey already exists"
}

#Read from a text file and attempt to convert (use for testing a single piece of content)
#(Get-Content $PSScriptRoot\body.txt -Delimiter [char]0x0400) | Format-Content -Title "blank" | Out-File "converted.txt"

#create a single page as a test
#Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName | Where-Object { $_.Name -eq "AccuRev-Standards" } | New-ConfluencePage -SpaceKey $spaceKey -Verbose

#fill space with content
$pages = Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName -Exclude @("WikiMarkup-Reference") | New-ConfluencePage -SpaceKey $spaceKey -Verbose

#close the session
Close-ConfluenceSession
