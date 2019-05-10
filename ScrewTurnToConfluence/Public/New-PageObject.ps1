function New-PageObject {
    [CmdletBinding()]
    param (
        # An object with properties corresponding to ScrewTurn PageContent table columns
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [pscustomobject]
        $PageContentRow
    )
    begin {
        $results = @()
    }
    process {
        $results += [pscustomobject]@{
            Title = $PageContentRow.Title
            Body = (New-ConfluenceContentBody (Format-Content $PageContentRow.Content))
        }
    }
    end {
        $results
    }
}