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

    Context -Name 'Get-AzVmSkuDetails' -Tag 'GetAzVmSkuDetails' {
        It 'Should not throw when parsing valid SKU names' {
            { Get-AzVmSkuDetails -VmSku "DCads_v5" } | Should -Not -Throw
            { Get-AzVmSkuDetails -VmSku "Standard_D4s_v3" } | Should -Not -Throw
            { Get-AzVmSkuDetails -VmSku "Dv5" } | Should -Not -Throw
        }

        It 'Should return proper AzVmSkuDetails object type' {
            $result = Get-AzVmSkuDetails -VmSku "DCads_v5"
            $result.PSObject.TypeNames[0] | Should -BeExactly 'AzVmSkuDetails'
        }

        It 'Should have all required properties' {
            $result = Get-AzVmSkuDetails -VmSku "DCads_v5"
            $result.VmSku | Should -Not -BeNullOrEmpty
            $result.Family | Should -Not -BeNullOrEmpty
            $result.CpuType | Should -Not -BeNullOrEmpty
            $result.Features | Should -Not -BeNull
            $result.Type | Should -Not -BeNullOrEmpty
            $result.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should correctly parse family for <SKU>' -TestCases @(
            @{ SKU = 'DCads_v5'; ExpectedFamily = 'DC' }
            @{ SKU = 'Standard_D4s_v3'; ExpectedFamily = 'D' }
            @{ SKU = 'Dv5'; ExpectedFamily = 'D' }
            @{ SKU = 'NCads_H100_v5'; ExpectedFamily = 'NC' }
            @{ SKU = 'HBv4'; ExpectedFamily = 'HB' }
            @{ SKU = 'Easv5'; ExpectedFamily = 'E' }
            @{ SKU = 'Fsv2'; ExpectedFamily = 'F' }
            @{ SKU = 'Lsv3'; ExpectedFamily = 'L' }
            @{ SKU = 'Basv2'; ExpectedFamily = 'B' }
        ) {
            param($SKU, $ExpectedFamily)
            $result = Get-AzVmSkuDetails -VmSku $SKU
            $result.Family | Should -Be $ExpectedFamily
        }

        It 'Should correctly identify CPU type for <SKU>' -TestCases @(
            @{ SKU = 'DCads_v5'; ExpectedCpu = 'AMD x86-64' }
            @{ SKU = 'Standard_D4s_v3'; ExpectedCpu = 'Intel x86-64' }
            @{ SKU = 'Dv5'; ExpectedCpu = 'Intel x86-64' }
            @{ SKU = 'Dplds_v5'; ExpectedCpu = 'ARM (Microsoft Cobalt or Ampere Altra)' }
            @{ SKU = 'Easv5'; ExpectedCpu = 'AMD x86-64' }
            @{ SKU = 'Eps_v5'; ExpectedCpu = 'ARM (Microsoft Cobalt or Ampere Altra)' }
        ) {
            param($SKU, $ExpectedCpu)
            $result = Get-AzVmSkuDetails -VmSku $SKU
            $result.CpuType | Should -Be $ExpectedCpu
        }

        It 'Should correctly parse version for <SKU>' -TestCases @(
            @{ SKU = 'DCads_v5'; ExpectedVersion = 5 }
            @{ SKU = 'Standard_D4s_v3'; ExpectedVersion = 3 }
            @{ SKU = 'Dv5'; ExpectedVersion = 5 }
            @{ SKU = 'HBv4'; ExpectedVersion = 4 }
            @{ SKU = 'Easv6'; ExpectedVersion = 6 }
        ) {
            param($SKU, $ExpectedVersion)
            $result = Get-AzVmSkuDetails -VmSku $SKU
            $result.Version | Should -Be $ExpectedVersion
        }

        It 'Should correctly identify VM type for <SKU>' -TestCases @(
            @{ SKU = 'DCads_v5'; ExpectedType = 'General purpose - Confidential computing' }
            @{ SKU = 'Standard_D4s_v3'; ExpectedType = 'General purpose' }
            @{ SKU = 'Easv5'; ExpectedType = 'Memory optimized' }
            @{ SKU = 'Fsv2'; ExpectedType = 'Compute optimized' }
            @{ SKU = 'Lsv3'; ExpectedType = 'Storage optimized' }
            @{ SKU = 'NCads_H100_v5'; ExpectedType = 'GPU accelerated' }
            @{ SKU = 'HBv4'; ExpectedType = 'High performance compute' }
        ) {
            param($SKU, $ExpectedType)
            $result = Get-AzVmSkuDetails -VmSku $SKU
            $result.Type | Should -Be $ExpectedType
        }

        It 'Should correctly parse features for SKUs with premium storage' {
            $result = Get-AzVmSkuDetails -VmSku "Standard_D4s_v3"
            $result.Features | Should -Contain 'Premium storage'
        }

        It 'Should correctly parse features for SKUs with local SSD' {
            $result = Get-AzVmSkuDetails -VmSku "DCads_v5"
            $result.Features | Should -Contain 'Local SSD'
        }

        It 'Should add accelerated networking for AMD SKUs' {
            $result = Get-AzVmSkuDetails -VmSku "DCads_v5"
            $result.Features | Should -Contain 'Accelerated networking'
        }

        It 'Should correctly parse GPU features for <SKU>' -TestCases @(
            @{ SKU = 'NCads_H100_v5'; ExpectedGpu = 'H100 GPU' }
            @{ SKU = 'NCas_A100_v4'; ExpectedGpu = 'A100 GPU' }
        ) {
            param($SKU, $ExpectedGpu)
            $result = Get-AzVmSkuDetails -VmSku $SKU
            $result.Features | Should -Contain $ExpectedGpu
        }

        It 'Should handle Standard_ prefix correctly' {
            $result1 = Get-AzVmSkuDetails -VmSku "D4s_v3"
            $result2 = Get-AzVmSkuDetails -VmSku "Standard_D4s_v3"
            
            $result1.Family | Should -Be $result2.Family
            $result1.Features | Should -Be $result2.Features
            $result1.Version | Should -Be $result2.Version
        }

        It 'Should handle -series suffix correctly' {
            $result1 = Get-AzVmSkuDetails -VmSku "Dv5"
            $result2 = Get-AzVmSkuDetails -VmSku "Dv5-series"
            
            $result1.Family | Should -Be $result2.Family
            $result1.Version | Should -Be $result2.Version
        }

        It 'Should work with pipeline input' {
            $skus = @("DCads_v5", "Standard_D4s_v3", "Dv5")
            $results = $skus | Get-AzVmSkuDetails
            
            $results.Count | Should -Be 3
            $results[0].Family | Should -Be 'DC'
            $results[1].Family | Should -Be 'D'
            $results[2].Family | Should -Be 'D'
        }

        It 'Should handle unknown families gracefully' {
            $result = Get-AzVmSkuDetails -VmSku "XYZabc_v1"
            $result.Type | Should -Be 'Unknown'
            $result.Description | Should -Match 'Unknown family'
        }

        It 'Should correctly identify multi-letter families' {
            $multiLetterTests = @(
                @{ SKU = 'DCads_v5'; Family = 'DC' }
                @{ SKU = 'NCads_v5'; Family = 'NC' }
                @{ SKU = 'NDads_v5'; Family = 'ND' }
                @{ SKU = 'HBv4'; Family = 'HB' }
                @{ SKU = 'HCv1'; Family = 'HC' }
                @{ SKU = 'NPads_v1'; Family = 'NP' }
            )
            
            foreach ($test in $multiLetterTests) {
                $result = Get-AzVmSkuDetails -VmSku $test.SKU
                $result.Family | Should -Be $test.Family
            }
        }

        It 'Should provide meaningful descriptions' {
            $result = Get-AzVmSkuDetails -VmSku "DCads_v5"
            $result.Description | Should -Match 'D-family with confidential computing'
            $result.Description | Should -Match 'AMD CPUs'
            $result.Description | Should -Match 'support'
        }

        It 'Should handle invalid input gracefully' {
            { Get-AzVmSkuDetails -VmSku $null } | Should -Throw
            
            # Test with empty string - should complete but may return unknown
            $result = Get-AzVmSkuDetails -VmSku "InvalidSku123"
            $result | Should -Not -BeNull
        }

        It 'Should correctly parse complex SKUs with multiple features' {
            $result = Get-AzVmSkuDetails -VmSku "DCadsil_v5"
            $result.Family | Should -Be 'DC'
            $result.CpuType | Should -Be 'AMD x86-64'
            $result.Features | Should -Contain 'Local SSD'
            $result.Features | Should -Contain 'Premium storage'
            $result.Features | Should -Contain 'Isolated'
            $result.Features | Should -Contain 'Low latency'
            $result.Features | Should -Contain 'Accelerated networking'
        }
    }
}