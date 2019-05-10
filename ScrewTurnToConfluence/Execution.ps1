Import-Module D:\Projects\ScrewturnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\demos\Credentials\Credentials.ps1

#Variables
$SpaceKey = "IWCTS"

#Get the content from the database
$ContentDataSet = Connect-ToDatabase -DatabaseConnectionString "sql1.dev.sa.ucsb.edu,2433" -DatabaseName "KnowledgeBase"

Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

Invoke-ConfluenceDeleteSpace -SpaceKey $SpaceKey

Start-sleep -Seconds 10

Invoke-ConfluenceCreateSpace -SpaceKey $SpaceKey -Name "Innovathon Wiki Conversion Test Space"

$ContentDataSet.Tables[0].Rows | ForEach-Object {
    [pscustomobject]@{
        Name = $_["Name"]
        Title = $_["Title"]
        Body = (New-ConfluenceContentBody (Convert-Content -Content $_["Content"]))
    }
} | Invoke-ConfluenceCreateContent -SpaceKey $SpaceKey

Close-ConfluenceSession
