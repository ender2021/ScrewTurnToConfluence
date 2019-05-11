Import-Module $PSScriptRoot\..\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force
. $PSScriptRoot\Credentials\Credentials.ps1
. $PSScriptRoot\configs\Config.ps1

$spaceKey = $Config.spaceKey #+ "2"
$spaceName = $Config.spaceName #+ " 2"

#open a session
Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

#delete the space if it already exists
try {
    Write-Host "Deleting space"
    $taskHandle = Invoke-ConfluenceDeleteSpace -SpaceKey $spaceKey
    $deleteSuccess = $true
}
catch {
    Write-Host "Space with key $spaceKey does not exist"
    $deleteSuccess = $false
}

#if the delete request succeeded, wait for it to finish
if ($deleteSuccess) {
    try {
        $timer = [system.diagnostics.stopwatch]::StartNew()
        do {
            Start-sleep -Seconds 5
            $percent = (Invoke-ConfluenceGetLongRunningTask $taskHandle.id).percentageComplete
            $totalSecs =  [math]::Round($timer.Elapsed.TotalSeconds,0)
            Write-Host "Delete task is $percent% complete, with $totalSecs seconds elapsed"
        } while ($percent -lt 100)
        $timer.Stop()
    } catch {
        if($timer.IsRunning()) {$timer.Stop()}
        Write-Error "Error encountered while waiting for space delete to finish.  Terminating script."
        throw
        exit
    }
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
