if (Get-Module 'AzureOps') { Remove-Module 'AzureOps' -Force }
Import-Module "$PSScriptRoot/../src/AzureOps/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzureOps' {
}