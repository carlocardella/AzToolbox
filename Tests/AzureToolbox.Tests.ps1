if (Get-Module 'AzToolbox') { Remove-Module 'AzToolbox' -Force }
Import-Module "$PSScriptRoot/../src/AzToolbox/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzToolbox' {
}