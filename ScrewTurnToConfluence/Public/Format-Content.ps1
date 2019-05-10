function Format-Content {
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
        $replacements = @(
            @{
                find = [char]0x00a0
                replace = '-'
            },
            @{
                find = "\[image\:{UP\(.*?\)\}(.*?\.[a-zA-Z]*)(\]|\|)((.*?)\])?"
                replace = '[[File=$1]]'
            },
            @{
                find = '“'
                replace = '"'
            },
            @{
                find = '”'
                replace = '"'
            },
            @{
                find = [char]0x00ae
                replace = "(R)"
            }
        )
        $toSend = $ContentToConvert
        $replacements | ForEach-Object { $toSend = $toSend -replace $_.find,$_.replace }
        $results += ($toSend | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage").Value
    }
    
    end {
        $results
        
    }
}