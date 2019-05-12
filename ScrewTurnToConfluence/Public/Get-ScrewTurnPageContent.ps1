function Get-ScrewTurnPageContent {
    [CmdletBinding()]
    param (
        # Database connection string
        [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName)]
        [Alias("ConnectionString")]
        [string]
        $ServerName,

        # Database Name
        [Parameter(Mandatory, Position=1,ValueFromPipelineByPropertyName)]
        [string]
        $DatabaseName,

        # schema
        [Parameter(Position=2,ValueFromPipelineByPropertyName)]
        [string]
        $DatabaseSchema="dbo",

        # An array of page names to exclude from the results
        [Parameter(Position=3,ValueFromPipelineByPropertyName)]
        [string[]]
        $Exclude
    )
    
    begin {
        $results = @()
    }
    
    process {
        $pageTable = Read-SqlViewData -ServerInstance $ServerName -DatabaseName $DatabaseName -SchemaName $DatabaseSchema -ViewName "vw_PageContent_Current_And_First" 
        $results += $pageTable | Where-Object { $Exclude -notcontains $_.Name }
    }
    
    end {
        $results
    }
}