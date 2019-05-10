Import-Module D:\Projects\ScrewturnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\demos\Credentials\Credentials.ps1

#configure script
$spaceKey = "IWCTS"
$spaceName = "Innovathon Wiki Conversion Test Space"
$dbConnection = "sql1.dev.sa.ucsb.edu,2433"
$dbName = "KnowledgeBase"

#open a session
Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

#delete the space if it already exists, and then wait to make sure it finishes
Invoke-ConfluenceDeleteSpace -SpaceKey $spaceKey

Start-sleep -Seconds 10

#create a fresh space
Invoke-ConfluenceCreateSpace -SpaceKey $spaceKey -Name $spaceName

#fill it with content
Get-ScrewTurnPageContent $dbConnection $dbName | New-PageObject | Invoke-ConfluenceCreateContent -SpaceKey $spaceKey

#close the session
Close-ConfluenceSession
