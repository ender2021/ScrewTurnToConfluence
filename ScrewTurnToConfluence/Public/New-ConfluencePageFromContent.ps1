function New-ConfluencePageFromContent {
    [CmdletBinding()]
    param (
        # The content to convert
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String]
        $Content,

        # Parameter help description
        [Parameter(Mandatory, Position=1)]
        [String]
        $SpaceName,

        # The name of the page to create
        [Parameter(Mandatory, Position=2)]
        [String]
        $PageName
    )
    
    begin {


        

    }    

    process {
        # Open a Confluence Session
        Open-ConfluenceSession -UserName $UserName -Password $ApiToken -HostName $HostName

        # replace the content and convert it
        # the first bit is to deal with a formatting issue. (?)
        $Content = $content -replace [char]0x00a0,'-' | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage"

        ($_["Content"] -replace [char]0x00a0,'-' | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage")
        Invoke-ConfluenceCreateContent $SpaceName -Body (New-ConfluenceContentBody "")
    }
    
    end {
        
        
    }
}

#Invoke-ConfluenceConvertContentBody "my unwrapped content" -FromFormat "wiki" -ToFormat "storage"
