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

    Context -Name 'Get-AzClientCertificate' -Tag 'GetAzClientCertificate' {
        It 'Can retrieve the Public ARM certificate using the default parameter' {
            { Get-AzClientCertificate } | Should -Not -Throw
            (Get-AzClientCertificate).Certificate  | Should -Not -BeNullOrEmpty
            @(Get-AzClientCertificate).Count | Should -Not -BeGreaterThan 2
        }

        It 'Returns an error for an invalid Azure Cloud name' {
            Get-AzClientCertificate -Environment 'NonExistingCloud' -ErrorVariable 'err' -ErrorAction 'SilentlyContinue'
            $err.Count | Should -Not -Be 0
            $err[0].Exception.Message | Should -Be 'Invalid envorinment: NonExistingCloud'

        }

        It 'Can retrieve the ARM certificate for <Name>' {
            { Get-AzClientCertificate $Name } | Should -Not -Throw
            (Get-AzClientCertificate $Name).Certificate  | Should -Not -BeNullOrEmpty
            @(Get-AzClientCertificate $Name).Count | Should -Not -BeGreaterThan 2

        } -TestCases @(
            Get-AzEnvironment | ForEach-Object {
                @{'Name' = $_.Name }
            }
        ) -Tag 'Slow'
    }

    Context -Name 'Get-AzResourceProviderApiVersion' -Tag 'GetAzResourceProviderApiVersion', 'Slow' {
        # todo: mock Get-AzResourceProvider
        It "Returns API version for <RP>" {
            { Get-AzResourceProviderApiVersion $RP } | Should -Not -Throw
            $ov = Get-AzResourceProviderApiVersion -ProviderNamespace $RP
            $ov.Count | Should -BeGreaterThan 1
        } -TestCases @(
            @{'RP' = 'Microsoft.Automation' },
            @{'RP' = 'Microsoft.ContainerService' },
            @{'RP' = 'Microsoft.Storage' }
        )
    }
}