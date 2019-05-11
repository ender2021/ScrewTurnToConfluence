function New-ConfluencePage {
    [CmdletBinding()]
    param (
        # An object with properties corresponding to ScrewTurn PageContent table columns
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [pscustomobject]
        $PageContentRow,

        # Space key for the space to create the page in
        [Parameter(Mandatory,Position=1,ValueFromPipelineByPropertyName)]
        [string]
        $SpaceKey
    )
    begin {
        $results = @()
    }
    process {
        Write-Verbose ("Formatting page: " + $PageContentRow.Name)
        $obj = [pscustomobject]@{
            Title = $PageContentRow.Title
            Body = (New-ConfluenceContentBody (Format-Content $PageContentRow.Content $PageContentRow.Title))
        }
        Write-Verbose ("Creating page: " + $obj.Title)
        $results += Invoke-ConfluenceCreateContent -SpaceKey $SpaceKey -Title $obj.Title -ContentBody $obj.Body
    }
    end {
        $results
    }
}