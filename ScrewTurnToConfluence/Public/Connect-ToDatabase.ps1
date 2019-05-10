function Connect-ToDatabase {
    [CmdletBinding()]
    param (
        # Database connection string
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string]
        $DatabaseConnectionString,

        # Database Name
        [Parameter(Mandatory, Position=1)]
        [string]
        $DatabaseName
    )
    
    begin {
        $DataSet
    }
    
    process {
        $SQLServer = $DatabaseConnectionString
        $SQLDBName = $DatabaseName
        $SqlQuery = "SELECT * FROM PageContent WHERE Revision = -1;"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True;"
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SqlQuery
        $SqlCmd.Connection = $SqlConnection
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
    }
    
    end {
        $DataSet
    }
}