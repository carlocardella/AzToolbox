if (Get-Module 'AzureToolbox') { Remove-Module 'AzureToolbox' -Force }
Import-Module "$PSScriptRoot/../src/AzureToolbox/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzureToolbox' {
}