function Format-ScrewTurnTables {
    [CmdletBinding()]
    param (
        # Content string
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string]
        $Content
    )
    begin {
        $results = @()
        #define replacements to perform on each row
        $rowReplace = @(
            @{
                find = '\r\n'
                replace = ''
            },
            @{
                find = '\| '
                replace = '|'
            },
            @{
                find = '\|\|'
                replace = '|'
            },
            @{
                find = '\!'
                replace = '||'
            }
        )
    }
    process {
        #stick the input value into a new param
        $updatedContent = $Content

        #look for instances of tables in the screwturn format, and replace each of them
        [regex]$regex = '\{\|((.|\r\n|\n)*?)\|\}'
        $regex.matches($Content) | ForEach-Object {
            #get the original content inside the table
            $originalMatch = $_.Value
            $tableContents = $_.Groups[1].Value
            
            #split the rows and modify each row individually
            $rows = $tableContents.Split("|-") | ForEach-Object {
                #perform replacements on the row
                $formatted = $_.Trim()
                $rowReplace | ForEach-Object { $formatted = $formatted -replace $_.find,$_.replace }
                if (!$formatted.EndsWith("|")) { $formatted += "|" }
                if ($formatted.Contains("||")) { $formatted += "|" }

                #return the reformatted row
                $formatted
            }
            
            #rejoin the rows with carriage return and new line
            $newFormat = $rows -join "`r`n"

            #replace the old string in the new content
            $updatedContent = $updatedContent.Replace($originalMatch,$newFormat)
        }

        #add the modified content to the return array
        $results += $updatedContent
    }
    end {
        $results
    }
}