# grab functions from files
$privateFiles = Get-ChildItem -Path $PSScriptRoot\private -Recurse -Include *.ps1 -ErrorAction SilentlyContinue
$publicFiles = Get-ChildItem -Path $PSScriptRoot\public -Recurse -Include *.ps1 -ErrorAction SilentlyContinue

if(@($privateFiles).Count -gt 0) { $privateFiles.FullName | ForEach-Object { . $_ } }
if(@($publicFiles).Count -gt 0) { $publicFiles.FullName | ForEach-Object { . $_ } }

Export-ModuleMember -Function $publicFiles.BaseName

if($null -eq $global:ScrewTurnToConfluence) {
	$global:PowerConfluence = @{}
}

$onRemove = {
	Remove-Variable -Name ScrewTurnToConfluence -Scope global
}

$ExecutionContext.SessionState.Module.OnRemove += $onRemove
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $onRemove