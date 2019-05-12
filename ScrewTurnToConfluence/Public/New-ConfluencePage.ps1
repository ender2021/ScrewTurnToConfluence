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
        $SpaceKey,

        # A list containing labels for all pages supplied to the function
        [Parameter(Position=2)]
        [pscustomobject[]]
        $Labels,

        # A list of directories with page names, containing attachments for the page
        [Parameter(Position=3)]
        [object[]]
        $Attachments
    )
    begin {
        Write-Verbose "Beginning page creation"
        $results = @()
    }
    process {
        $name = $PageContentRow.Name
        $title = $PageContentRow.Title

        Write-Verbose "Beginning page: $title ($name)"

        Write-Verbose "Converting content format"
        $content = (Format-PageMetaPanel $PageContentRow) + $PageContentRow.Content
        $formatted = (New-ConfluenceContentBody (Format-Content $content $title))

        Write-Verbose "Creating page"
        $page = Invoke-ConfluenceCreateContent -SpaceKey $SpaceKey -Title $title -ContentBody $formatted

        $relevantLabels = $Labels | Where-Object { $_.Page -eq $name }
        if ($relevantLabels.Count -gt 0) {
            Write-Verbose "Applying page labels"
            $labelsResults = $relevantLabels | ForEach-Object { $_.Category -replace " ","-" } | Invoke-ConfluenceAddContentLabels -Id $page.id
        }

        $relevantAttachments = $Attachments | Where-Object { $_.Name -eq "SAIS-Environments" } | Get-ChildItem
        if ($relevantAttachments.Count -gt 0) {
            Write-Verbose "Uploading attachments"
            $attachResults = $relevantAttachments | ForEach-Object {
                Write-Verbose ("Uploading " + $_.Name)
                Invoke-ConfluenceCreateOrUpdateAttachment -ContentId $page.id -Attachment $_
            } 
        }

        $results += [pscustomobject]@{
            Page = $page
            Labels = $labelsResults
            Attachments = $attachResults
        }

        Write-Verbose "Completed page: $title ($name)"
    }
    end {
        Write-Verbose "Page creation completed"
        $results
    }
}