function Get-ScrewTurnCategoryBinding {
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

        # An array of category names to exclude from the results
        [Parameter(Position=3,ValueFromPipelineByPropertyName)]
        [string[]]
        $Exclude
    )
    
    begin {
        $results = @()
    }
    
    process {
        $catTable = Read-SqlTableData -ServerInstance $ServerName -DatabaseName $DatabaseName -SchemaName "dbo" -TableName "CategoryBinding" 
        $results += $catTable | Where-Object { ($Exclude -notcontains $_.Category) }
    }
    
    end {
        $results
    }
}