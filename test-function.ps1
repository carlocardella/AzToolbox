# Quick tests for Get-AzVmSkuDetails function

# Test basic functionality
Write-Host "Testing Get-AzVmSkuDetails function..." -ForegroundColor Green

# Test cases
$testCases = @(
    @{ Sku = "DCads_v5"; ExpectedFamily = "DC"; ExpectedCpu = "AMD x86-64"; ExpectedVersion = 5 }
    @{ Sku = "Standard_D4s_v3"; ExpectedFamily = "D"; ExpectedCpu = "Intel x86-64"; ExpectedVersion = 3 }
    @{ Sku = "Dv5"; ExpectedFamily = "D"; ExpectedCpu = "Intel x86-64"; ExpectedVersion = 5 }
    @{ Sku = "NCads_H100_v5"; ExpectedFamily = "NC"; ExpectedCpu = "AMD x86-64"; ExpectedVersion = 5 }
    @{ Sku = "HBv4"; ExpectedFamily = "HB"; ExpectedCpu = "Intel x86-64"; ExpectedVersion = 4 }
)

foreach ($test in $testCases) {
    Write-Host "`nTesting SKU: $($test.Sku)" -ForegroundColor Yellow
    $result = Get-AzVmSkuDetails -VmSku $test.Sku
    
    Write-Host "  Family: $($result.Family) (Expected: $($test.ExpectedFamily))" -ForegroundColor $(if ($result.Family -eq $test.ExpectedFamily) { "Green" } else { "Red" })
    Write-Host "  CPU: $($result.CpuType) (Expected: $($test.ExpectedCpu))" -ForegroundColor $(if ($result.CpuType -eq $test.ExpectedCpu) { "Green" } else { "Red" })
    Write-Host "  Version: $($result.Version) (Expected: $($test.ExpectedVersion))" -ForegroundColor $(if ($result.Version -eq $test.ExpectedVersion) { "Green" } else { "Red" })
    Write-Host "  Features: $($result.Features -join ', ')"
}

Write-Host "`nAll tests completed!" -ForegroundColor Green
