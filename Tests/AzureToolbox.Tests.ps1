if (Get-Module 'AzToolbox') { Remove-Module 'AzToolbox' -Force }
Import-Module "$PSScriptRoot/../src/AzToolbox/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzToolbox' {
    Context -Name 'Get-AzCliReleaseAsset' -Tag 'GetAzCliReleaseAsset' {
        It 'Gets the latest Az CLI Release assets' {
            { Get-AzCliReleaseAsset } | Should -Not -Throw
            (Get-AzCliReleaseAsset | Get-Member).TypeName[0] | Should -BeExactly 'AzCliReleaseAsset'
            @(Get-AzCliReleaseAsset).Count | Should -BeGreaterOrEqual 1
        }
    }

    Context -Name 'Save-AzCliReleaseAsset' -Tag 'SaveAzCliReleaseAsset', 'Slow' {
        It 'Can download Az CLI release asset' {
            { Save-AzCliReleaseAsset -Package 'MSI' -OutputFolder $TestDrive } | Should -Not -Throw
        }
    }
}