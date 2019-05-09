Import-Module D:\Projects\ScrewturnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence\ScrewTurnToConfluence.psm1 -Force
Import-Module SqlServer -Force
(Get-InstalledModule PowerConfluence).InstalledLocation + "\PowerConfluence.psm1" | Import-Module -Force

$ContentDataSet = Connect-ToDatabase -DatabaseConnectionString "sql1.dev.sa.ucsb.edu,2433" -DatabaseName "KnowledgeBase"

for($i=0;$i -lt $ContentDataSet.Tables[0].Rows.Count; $i++) {

    $Name = $ContentDataSet.Tables[0].Rows[$i]["Name"]
    $Title = $ContentDataSet.Tables[0].Rows[$i]["Title"]
    $Content = $ContentDataSet.Tables[0].Rows[$i]["Content"]

    if ($1 = )
}

#Create-ConfluencePageFromContent -Content "" -SpaceName "IWCTS" -PageName ""
