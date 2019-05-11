# Test the Confluence Content Conversion function
# This test will fail if there is malformed content (i.e. conversion failed)
Describe "Test the page content conversion call to Confluence is working correctly" {
    It "succesfully converts the content" {
        # Open a Confluence Connection
        Open-ConfluenceSession $ConfluenceCredentials.UserName $ConfluenceCredentials.ApiToken $ConfluenceCredentials.HostName

        $Content = Get-Content ./SamplePageContent 
        { Format-Content -ContentToConvert ($Content -join "") } | should -not -Throw

        #Close the Confluence Connection (Like a Boss)
        Close-ConfluenceSession
    }
}