$totalTimer = [system.diagnostics.stopwatch]::StartNew()

Import-Module $PSScriptRoot\..\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer
Import-Module PowerConfluence
. $PSScriptRoot\Credentials\Credentials.ps1
. $PSScriptRoot\configs\Config.ps1

#configure space information
$spaceKey = $Config.spaceKey #+ "2"
$spaceName = $Config.spaceName #+ " 2"

#open a session
Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

#Reset the space
Reset-ConfluenceSpace $spaceKey $spaceName -Verbose

#get snippets
$snippets = Get-ScrewTurnSnippet $Config.dbconnection $Config.dbName

#get category (aka label) mapping info from ScrewTurn
$labels = Get-ScrewTurnCategoryBinding $Config.dbconnection $Config.dbName

#get attachments directory list
$attachments = Get-ChildItem $Config.attachments

#get a list of all pages
$allPages = Get-ScrewTurnPageContent $Config.dbconnection $Config.dbName -Exclude @("WikiMarkup-Reference") -ReplaceColon " -"

#create a splattable object to pass conversion parameters
$convertParams = @{
    SpaceKey = $spaceKey
    AllPages = $allPages
    Snippets = $snippets
    Labels = $labels
    Attachments = $attachments
    Verbose = $true
}

#create specific page as a test
# $testPage = $allPages | Where-Object {
#     @("Data-Access-Layer-Best-Practices-Data-Access-Layer","Data-Access-Layer-Best-Practices-Interface") -contains $_.Name
# } | New-ConfluencePage @convertParams

#fill space with content
$pages = $allPages | New-ConfluencePage @convertParams

#close the session
Close-ConfluenceSession

$totalSeconds = [math]::Round($totalTimer.Elapsed.TotalSeconds,0)
Write-Host "Total script execution time: $totalSeconds seconds"