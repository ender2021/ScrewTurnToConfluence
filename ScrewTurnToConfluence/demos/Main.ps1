. $PSScriptRoot\credentials\credentials.ps1
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module

$pages = @(
    [pscustomobject]@{
        Title = "Demo Title 3"
        ContentBody = (New-ConfluenceContentBody "Demo Body 1")
    },
    [pscustomobject]@{
        Title = "Demo Title 4"
        ContentBody = (New-ConfluenceContentBody "Demo Body 2")
    }
)

Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

$pages | Invoke-ConfluenceCreateContent -SpaceKey "IWCTS"

Close-ConfluenceSession