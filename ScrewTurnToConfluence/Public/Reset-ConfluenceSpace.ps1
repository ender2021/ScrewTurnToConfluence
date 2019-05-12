function Reset-ConfluenceSpace {
    [CmdletBinding()]
    param (
        # Space key
        [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName)]
        [Alias("Key")]
        [string]
        $SpaceKey,

        # Space title
        [Parameter(Mandatory,Position=1,ValueFromPipelineByPropertyName)]
        [Alias("Name")]
        [string]
        $SpaceName
    )
    begin {
    }
    process {
        #delete the space if it already exists
        try {
            Write-Verbose "Deleting space $SpaceKey"
            $taskHandle = Invoke-ConfluenceDeleteSpace -SpaceKey $SpaceKey
            $deleteSuccess = $true
        }
        catch {
            Write-Verbose "Space with key $SpaceKey does not exist"
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
                    Write-Verbose "Delete $percent% complete, $totalSecs seconds elapsed"
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
            Write-Verbose "Creating space $SpaceName ($SpaceKey)"
            $space = Invoke-ConfluenceCreateSpace -SpaceKey $SpaceKey -Name $SpaceName
        }
        catch {
            Write-Host "Space with key $SpaceKey already exists"
        }
    }
    end {
    }
}