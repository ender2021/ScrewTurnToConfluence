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
        $DatabaseSchema="dbo"
    )
    
    begin {
        $results = @()
    }
    
    process {
        $pageTable = Read-SqlTableData -ServerInstance $ServerName -DatabaseName $DatabaseName -SchemaName "dbo" -TableName "PageContent" 
        $results += $pageTable | Where-Object { $_.Revision -eq -1 }
    }
    
    end {
        $results
    }
}