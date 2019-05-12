function Format-PageMetaPanel {
    [CmdletBinding()]
    param (
        # An object with properties corresponding to ScrewTurn PageContent table columns
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [pscustomobject]
        $PageContentRow
    )
    begin {
        $results = @()
    }
    process {
        $createBy = $PageContentRow.Create_By
        $createDate = Get-Date $PageContentRow.Create_Date -Format f
        $updateBy = $PageContentRow.Last_Update_By
        $updateDate = Get-Date $PageContentRow.Last_Update_Date -Format f

        $message = @("This page was originally created by *$createBy* on *$createDate*",
                     "Prior to migration, it was last updated by *$updateBy* on *$updateDate*") -join "`r`n"
        $results += "{note:title=Page Migrated From ScrewTurn!}$message{note}`r`n"
    }
    end {
        $results
    }
}