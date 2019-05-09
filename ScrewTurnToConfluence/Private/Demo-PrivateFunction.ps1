function Demo-PrivateFunction {
    [CmdletBinding()]
    param (
        # A sample parameter
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string]
        $MyString
    )
    
    begin {
        $results = @()
    }
    
    process {
        $results += $MyString
    }
    
    end {
        $results
    }
}