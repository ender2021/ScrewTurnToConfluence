function Get-ScrewTurnSnippet {
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
        $results += Read-SqlTableData -ServerInstance $ServerName -DatabaseName $DatabaseName -SchemaName $DatabaseSchema -TableName "Snippet" 
    }
    
    end {
        $results
    }
}