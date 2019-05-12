function Format-Content {
    [CmdletBinding()]
    param (
        # An object with properties corresponding to ScrewTurn PageContent table columns
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [pscustomobject]
        $PageContentRow
    )
    begin {
        Write-Verbose "Beginning content formatting"
        $results = @()
        $replacements = @(
            @{
                find = "\[image(.*?){UP\((.*?)\)\}(.*?\.[a-zA-Z]*)\s*?(\]|\|)((.*?)\])?"
                replace = '!$2^$3!'
            },
            @{
                find = "\[\^?{UP\((.*?)\)\}(.*?)\]"
                replace = '[$1^$2]'
            },
            @{
                find = "\[\^(.*?)\]"
                replace = '[$1]'
            },
            @{
                find = '\[(.*?)\|(.*?)\]'
                replace = '[$2|$1]'
            },
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
                find = '(?<=\r\n|\n|\#)\#(?!(\s|\#))'
                replace = '# '
            },
            @{
                find = '(?<=\r\n|\n|\*)\*(?!(\s|\*))'
                replace = '* '
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
                find = '\<div style\=\"clear\:\s?both\;?\" \/\>'
                replace = ''
            },
            @{
                find = '(\r\n|\n)?=====(.*?)====='
                replace = "`r`n" + 'h4. $2'
            },
            @{
                find = '(\r\n|\n)?====(.*?)===='
                replace = "`r`n" + 'h3. $2'
            },
            @{
                find = '(\r\n|\n)?===(.*?)==='
                replace = "`r`n" + 'h2. $2'
            },
            @{
                find = '(\r\n|\n)?==(.*?)=='
                replace = "`r`n" + 'h1. $2'
            },
            @{
                find = '\{TOC\}'
                replace = '{panel:title=Table of Contents}{TOC}{panel}'
            }
        )
    }
    process {
        $name = $PageContentRow.Name
        $title = $PageContentRow.Title

        Write-Verbose "Beginning formatting of: $title ($name)"
        $toSend = $PageContentRow.Content
        $attachNames = @()
        if ($toSend -ne "") {
            Write-Verbose "Performing basic string replacements on content"
            $replacements | ForEach-Object { $toSend = $toSend -replace $_.find,$_.replace }

            Write-Verbose "Adding conversion note panel"
            $toSend = (Format-PageMetaPanel $PageContentRow) + $toSend

            Write-Verbose "Performing table formatting"
            $toSend = Format-ScrewTurnTables $toSend

            Write-Verbose "Performing attachment name substitution and dependency collection"
            #eliminate page prefixes, noting them as dependencies
            [regex]$prefixes = "(\!|\[)(.*?)\^"
            $prefixes.Matches($toSend) | ForEach-Object {
                #what is going to be replaced
                $original = $_.Value
                
                #remember the name and prefix char
                $preChar = $_.Groups[1].Value
                $foundName = $_.Groups[2].Value
                if ($attachNames -notcontains $foundName) { $attachNames += $foundName}

                #perform the replacement with a simple non-regex swap
                $toSend = $toSend.Replace($original,$preChar)
            }

            do {
                $moreMacros = $false
                try {
                    Write-Verbose "Attempting conversion to storage format"
                    $toSend = ($toSend | Invoke-ConfluenceConvertContentBody -FromFormat "wiki" -ToFormat "storage").Value
                }
                catch {
                    $message = ($_.ErrorDetails.Message | ConvertFrom-Json).Message
                    $errorMatch = "The macro '(.*?)' is unknown"
                    if ($message -match $errorMatch) {
                        $moreMacros = $true

                        [regex]$errors = $errorMatch
                        $macroContents = [regex]::Escape($errors.Matches($message)[0].Groups[1].Value)
                        $toSend = $toSend -ireplace "\{($macroContents)(\:.*?)?\}",'&#0123;$1$2&#0125;'
                        Write-Verbose "Conversion failed due to unexpected macro {$macroContents}.  Replacing braces with ALT codes and trying again."
                    } else {
                        Write-Verbose "Unexpected Error!"
                        throw
                    }
                }
            } while ($moreMacros)
            Write-Verbose "Storage format conversion succeeded"
        } else {
            Write-Verbose "Page is blank"
        }
        Write-Verbose "Finished formatting of: $title ($name)"

        $results += [pscustomobject]@{
            PageContentRow = $PageContentRow
            FormattedContent = $toSend
            Dependencies = $attachNames
        }
    }
    
    end {
        Write-Verbose "Finished content formatting"
        $results
    }
}