function Format-Content {
    [CmdletBinding()]
    param (
        # A sample parameter
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Content")]
        [AllowEmptyString()]
        [string]
        $ContentToConvert,

        # The title of the content
        [Parameter(Position=1,ValueFromPipelineByPropertyName)]
        [string]
        $Title="Unknown"
    )
    begin {
        $results = @()
        $replacements = @(
            @{
                find = "\[image(.*?){UP\(.*?\)\}(.*?\.[a-zA-Z]*)\s*?(\]|\|)((.*?)\])?"
                replace = '!$2!'
            },
            @{
                find = "\[\^?{UP\(.*?\)\}(.*?)\]"
                replace = ('[' + $Title + '^$1]')
            },
            # @{
            #     find = '(?<!\{)\{(?!(\{|TOC))'
            #     replace = '&#0123;'
            # },
            # @{
            #     find = '(?<!(\}|TOC))\}(?!\})'
            #     replace = '&#0125;'
            # },
            @{
                find = "@@(xml|js|csharp|sql)?(\r\n|\n)?((.|\n)*?)@@"
                replace = ('{code:language=$1}' + "`r`n" + '$3{code}')
            },
            @{
                find = "\{code\:language\=\}"
                replace = "{code}"
            },
            @{
                find = "\{code\:language\=csharp\}"
                replace = "{code:language=C#}"
            },
            @{
                find = "\{code\:language\=js\}"
                replace = "{code:language=javascript}"
            },
            @{
                find = '{br}'
                replace = '<br />'
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
                find = [char]0x00a0
                replace = ''
            },
            @{
                find = [char]0x00ae
                replace = "(R)"
            },
            @{
                find = [char]0x00b7
                replace = "&#9679;"
            },
            @{
                find = [char]0x00E9
                replace = '&eacute;'
            },
            @{
                find = [char]0x00a7
                replace = '&sect;'
            },
            @{
                find = [char]0x000B
                replace = ''
            },
            @{
                find = "\'\'\'(.*?)\'\'\'"
                replace = '*$1*'
            },
            @{
                find = "\(\(\(((.|\n|\r\n)*?)\)\)\)"
                replace = ('{panel}$1{panel}')
            },
            @{
                find = '======(.*?)======'
                replace = 'h6. $1'
            },
            @{
                find = '=====(.*?)====='
                replace = 'h5. $1'
            },
            @{
                find = '====(.*?)===='
                replace = 'h4. $1'
            },
            @{
                find = '===(.*?)==='
                replace = 'h3. $1'
            },
            @{
                find = '==(.*?)=='
                replace = 'h2. $1'
            }
            # @{
            #     find = '=(.*?)='
            #     replace = 'h1. $1'
            # }
        )
    }
    process {
        $toSend = $ContentToConvert
        if ($toSend -ne "") {
            $replacements | ForEach-Object { $toSend = $toSend -replace $_.find,$_.replace }
            $toSend = Format-ScrewTurnTables $toSend
            do {
                $moreMacros = $false
                try {
                    $results += ($toSend | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage").Value            
                }
                catch {
                    $message = ($_.ErrorDetails.Message | ConvertFrom-Json).Message
                    $errorMatch = "The macro '(.*?)' is unknown"
                    if ($message -match $errorMatch) {
                        $moreMacros = $true

                        [regex]$regex = $errorMatch
                        $match = $regex.Matches($message)
                        $macroContents = [regex]::Escape($match[0].Groups[1].Value)
                        $toSend = $toSend -ireplace "\{($macroContents)(\:.*?)?\}",'&#0123;$1$2&#0125;'
                    } else {
                        $_
                    }
                }
            } while ($moreMacros)
        } else {
            $results += $toSend
        }
    }
    
    end {
        $results
    }
}