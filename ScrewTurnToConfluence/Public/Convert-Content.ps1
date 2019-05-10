function Convert-Content {
    [CmdletBinding()]
    param (
        # A sample parameter
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [Alias("Content")]
        [string]
        $ContentToConvert
    )
    
    begin {
        $results = @()
    }


    process {
        
        $ContentToConvert = ($ContentToConvert -replace [char]0x00a0,'-' | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage").Value
        $ContentToConvert = $ContentToConvert -replace "\[image\|\|\{UP\(.*?\)\}(.*?\.[a-zA-Z]*)\]",'[[File=$1]]'
 
        $results += $ContentToConvert
    }
    
    end {
        $results
        
    }
}