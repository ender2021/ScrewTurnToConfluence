function Connect-ToDatabase {
    [CmdletBinding()]
    param (
        # A sample parameter
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string]
        $DatabaseConnectionString

        ,

        # Parameter help description
        [Parameter(Mandatory, Position=1)]
        [string]
        $DatabaseName

        ,
        # Parameter help description
        [Parameter(Mandatory, Position=2)]
        [PSCredential]
        $Credentials
    )
    
    begin {
        $DatabaseConnection = ""

        #creds will be in the $Credentials parameter

        #$tables = invoke-sqlcmd -server $DatabaseConnectionString -Database $DatabaseName "select ss.name as schema_name, so.name as table_name, ss.name+'.'+so.name as full_name from sysobjects so inner join sys.schemas ss on ss.schema_id=so.uid where type='u' order by ss.name, so.name" 



       # $tables = Invoke-Sqlcmd -server $DatabaseConnectionString -Database $DatabaseName -Username "" -Password ""

    }
    


    process {
        $DatabaseConnection += $DatabaseConnectionString
    }
    
    end {
        $DatabaseConnection + $DatabaseName
        
    }
}