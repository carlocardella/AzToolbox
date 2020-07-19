if (Get-Module 'AzToolbox') { Remove-Module 'AzToolbox' -Force }
Import-Module "$PSScriptRoot/../src/AzToolbox/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzToolbox' {
    Context -Name 'Get-AzCliReleaseAsset' -Tag 'GetAzCliReleaseAsset' {
        It 'Gets the latest Az CLI Release assets' {
            { Get-AzCliReleaseAsset } | Should -Not -Throw
            @(Get-AzCliReleaseAsset).Count | Should -BeGreaterOrEqual 1
        }
        
        It 'Returns a proper AzCliReleaseType object' {
            (Get-AzCliReleaseAsset | Get-Member).TypeName[0] | Should -BeExactly 'AzCliReleaseAsset'
            $assetObject = Get-AzCliReleaseAsset
            $assetObject.Name | Should -not -BeNullOrEmpty
            $assetObject.ReleaseDate | Should -not -BeNullOrEmpty
            $assetObject.Url | Should -not -BeNullOrEmpty
            $assetObject.Tag | Should -not -BeNullOrEmpty
            $assetObject.PreRelease | Should -not -BeNullOrEmpty
        }
    }

    Context -Name 'Save-AzCliReleaseAsset' -Tag 'SaveAzCliReleaseAsset', 'Slow' {
        It 'Can download Az CLI release asset' {
            { Save-AzCliReleaseAsset -Package 'MSI' -OutputFolder $TestDrive } | Should -Not -Throw
        }
    }
}