function Get-AzVmSkuDetails {
    <#
    .SYNOPSIS
    Parses Azure VM SKU names and returns detailed information about the SKU components

    .DESCRIPTION
    This function takes an Azure VM SKU name as input and parses it according to Azure's VM size naming conventions
    to extract information about the family, subfamily, CPU type, features, and version.
    
    Based on the structure: [Family][Subfamily][CPU][Features]_v[Version]-series
    
    .PARAMETER VmSku
    The VM SKU name to parse (e.g., "DCads_v5", "Standard_D4s_v3", "Dv5")

    .EXAMPLE
    Get-AzVmSkuDetails -VmSku "DCads_v5"

    VmSku        : DCads_v5
    Family       : DC
    Subfamily    : 
    CpuType      : AMD x86-64
    Features     : {Accelerated networking, Premium storage}
    Version      : 5
    Type         : General purpose - Confidential computing
    Description  : D-family with confidential computing, AMD CPUs, accelerated networking and premium storage support

    .EXAMPLE
    Get-AzVmSkuDetails -VmSku "Standard_D4s_v3"

    VmSku        : Standard_D4s_v3
    Family       : D
    Subfamily    : 
    CpuType      : Intel x86-64
    Features     : {Premium storage}
    Version      : 3
    Type         : General purpose
    Description  : D-family for enterprise-grade applications, Intel CPUs with premium storage support

    .NOTES
    This function follows Azure VM size naming conventions as documented at:
    https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview

    Naming structure breakdown:
    1. Family: Most families use one letter (D, E, F, etc.), GPU families use two (ND, NV, NC, etc.)
    2. Subfamily: Single uppercase letter for variations within a family
    3. CPU: No letter = Intel x86-64, 'a' = AMD, 'p' = ARM (Microsoft Cobalt or Ampere Altra)
    4. Features: Various letters indicating capabilities (s = premium storage, d = local SSD, etc.)
    5. Version: Only appears if multiple versions exist (_v2, _v3, etc.)
    #>
    [CmdletBinding()]
    [OutputType('AzVmSkuDetails')]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$VmSku
    )

    process {
        # Initialize output object
        $skuDetails = [PSCustomObject]@{
            VmSku = $VmSku
            Family = $null
            Subfamily = $null
            CpuType = $null
            Features = @()
            Version = $null
            Type = $null
            Description = $null
        }

        # Define family mappings
        $familyMappings = @{
            # General Purpose
            'A' = @{ Type = 'General purpose'; Description = 'Entry-level economical VMs' }
            'B' = @{ Type = 'General purpose'; Description = 'Burstable performance VMs' }
            'D' = @{ Type = 'General purpose'; Description = 'Enterprise-grade applications, relational databases, in-memory caching, data analytics' }
            'DC' = @{ Type = 'General purpose - Confidential computing'; Description = 'D-family with confidential computing' }
            
            # Compute Optimized
            'F' = @{ Type = 'Compute optimized'; Description = 'Medium traffic web servers, network appliances, batch processes, application servers' }
            'FX' = @{ Type = 'Compute optimized'; Description = 'Electronic Design Automation (EDA), large memory relational databases' }
            
            # Memory Optimized
            'E' = @{ Type = 'Memory optimized'; Description = 'Relational databases, medium to large caches, in-memory analytics' }
            'Eb' = @{ Type = 'Memory optimized'; Description = 'E-family with high remote storage performance' }
            'EC' = @{ Type = 'Memory optimized - Confidential computing'; Description = 'E-family with confidential computing' }
            'M' = @{ Type = 'Memory optimized'; Description = 'Extremely large databases, large amounts of memory' }
            
            # Storage Optimized
            'L' = @{ Type = 'Storage optimized'; Description = 'High disk throughput and IO, Big Data, SQL and NoSQL databases' }
            
            # GPU Accelerated
            'NC' = @{ Type = 'GPU accelerated'; Description = 'Compute-intensive, graphics-intensive, visualization workloads' }
            'ND' = @{ Type = 'GPU accelerated'; Description = 'Large memory compute-intensive, graphics-intensive, visualization workloads' }
            'NG' = @{ Type = 'GPU accelerated'; Description = 'Virtual Desktop (VDI), cloud gaming' }
            'NV' = @{ Type = 'GPU accelerated'; Description = 'Virtual desktop (VDI), single-precision compute, video encoding and rendering' }
            
            # FPGA Accelerated
            'NP' = @{ Type = 'FPGA accelerated'; Description = 'Machine learning inference, video transcoding, database search and analytics' }
            
            # High Performance Compute
            'HB' = @{ Type = 'High performance compute'; Description = 'High memory bandwidth, fluid dynamics, weather modeling' }
            'HC' = @{ Type = 'High performance compute'; Description = 'High density compute, finite element analysis, molecular dynamics' }
            'HX' = @{ Type = 'High performance compute'; Description = 'Large memory capacity, Electronic Design Automation (EDA)' }
        }

        # Define feature mappings
        $featureMappings = @{
            's' = 'Premium storage'
            'd' = 'Local SSD'
            'i' = 'Isolated'
            'l' = 'Low latency'
            'n' = 'Network optimized'
            'r' = 'RDMA capable'
            't' = 'Tiny'
            'c' = 'Confidential'
            'm' = 'Medium memory'
            'h' = 'High memory'
        }

        # Remove "Standard_" prefix if present and any trailing "-series"
        $cleanSku = $VmSku -replace '^Standard_', '' -replace '-series$', ''
        
        # Define known multi-letter families
        $multiLetterFamilies = @('DC', 'NC', 'ND', 'NG', 'NV', 'NP', 'HB', 'HC', 'HX', 'FX', 'Eb', 'EC')
        
        # Try to identify the family first
        $family = $null
        $remainder = $cleanSku
        
        # Check for two-letter families first
        foreach ($multiFamily in $multiLetterFamilies) {
            if ($cleanSku.StartsWith($multiFamily)) {
                $family = $multiFamily
                $remainder = $cleanSku.Substring($multiFamily.Length)
                break
            }
        }
        
        # If no multi-letter family found, assume single letter
        if (-not $family) {
            if ($cleanSku.Length -gt 0 -and $cleanSku[0] -match '[A-Z]') {
                $family = $cleanSku[0].ToString()
                $remainder = $cleanSku.Substring(1)
            }
        }
        
        $skuDetails.Family = $family
        
        # Parse remainder step by step to handle complex patterns
        $sizeIndicator = $null
        $possibleSubfamily = $null
        $cpuIndicator = $null
        $features = ""
        $version = $null
        $special = $null
        
        # First, extract version if present
        $workingRemainder = $remainder
        if ($workingRemainder -match '(.*)_v(\d+)$') {
            # Pattern: "ads_v5" -> "ads"
            $workingRemainder = $matches[1]
            $version = $matches[2]
        } elseif ($workingRemainder -match '(.*)v(\d+)$') {
            # Pattern: "adsv5" -> "ads"  
            $workingRemainder = $matches[1]
            $version = $matches[2]
        }
        
        # Then extract special features (like H100, A100, etc.)
        # Handle both "_H100_" and "_H100" patterns
        if ($workingRemainder -match '(.*)_([A-Z0-9]+)_?$') {
            $workingRemainder = $matches[1]
            $special = $matches[2]
        }
        
        # Now parse the remaining part for size, subfamily, CPU, and features
        if ($workingRemainder -match '^(\d+)?([A-Z])?([ap])?([a-z]*)$') {
            $sizeIndicator = $matches[1]
            $possibleSubfamily = $matches[2]
            $cpuIndicator = $matches[3]
            $features = $matches[4]
        }
            
            # If we have both possibleSubfamily and cpuIndicator, first is subfamily
            # However, if possibleSubfamily is a single lowercase letter, it might be a feature
            if ($possibleSubfamily -and $cpuIndicator) {
                $skuDetails.Subfamily = $possibleSubfamily
            } elseif ($possibleSubfamily -and $possibleSubfamily -in @('a', 'p')) {
                # If possibleSubfamily is actually a CPU indicator
                $cpuIndicator = $possibleSubfamily
                $possibleSubfamily = $null
            } elseif ($possibleSubfamily -and $possibleSubfamily -cmatch '^[a-z]$') {
                # If it's a lowercase letter, it's likely a feature, not a subfamily
                $features = $possibleSubfamily + $features
                $possibleSubfamily = $null
            } else {
                $skuDetails.Subfamily = $possibleSubfamily
            }
            
            # Determine CPU type
            switch ($cpuIndicator) {
                'a' { $skuDetails.CpuType = 'AMD x86-64' }
                'p' { $skuDetails.CpuType = 'ARM (Microsoft Cobalt or Ampere Altra)' }
                default { $skuDetails.CpuType = 'Intel x86-64' }
            }
            
            # Parse feature letters
            $featureList = @()
            if ($features) {
                $featureChars = $features.ToCharArray()
                foreach ($char in $featureChars) {
                    $charStr = $char.ToString()
                    if ($featureMappings[$charStr]) {
                        $featureList += $featureMappings[$charStr]
                    }
                }
            }
            
            # Add accelerated networking for AMD CPUs
            if ($cpuIndicator -eq 'a') {
                $featureList += 'Accelerated networking'
            }
            
            # Add special features like GPU types
            if ($special) {
                if ($special -match 'H100') {
                    $featureList += 'H100 GPU'
                } elseif ($special -match 'A100') {
                    $featureList += 'A100 GPU'
                } elseif ($special -match 'V620') {
                    $featureList += 'V620 GPU'
                } elseif ($special -match 'MI300X') {
                    $featureList += 'MI300X GPU'
                } else {
                    $featureList += $special
                }
            }
            
            $skuDetails.Features = $featureList
            
            # Parse version
            if ($version) {
                $skuDetails.Version = [int]$version
            }
        
        # Set type and description based on family
        $familyKey = $skuDetails.Family
        if ($familyMappings.ContainsKey($familyKey)) {
            $skuDetails.Type = $familyMappings[$familyKey].Type
            $description = $familyMappings[$familyKey].Description
            
            # Add CPU and feature information to description
            $cpuInfo = switch ($skuDetails.CpuType) {
                'AMD x86-64' { 'AMD CPUs' }
                'ARM (Microsoft Cobalt or Ampere Altra)' { 'ARM CPUs' }
                default { 'Intel CPUs' }
            }
            
            $description += ", $cpuInfo"
            
            if ($skuDetails.Features.Count -gt 0) {
                $featureList = $skuDetails.Features -join ', '
                $description += " with $featureList support"
            }
            
            $skuDetails.Description = $description
        } else {
            $skuDetails.Type = 'Unknown'
            $skuDetails.Description = "Unknown family: $familyKey"
        }

        # Set the custom type name for formatting
        $skuDetails.PSObject.TypeNames.Insert(0, 'AzVmSkuDetails')
        
        return $skuDetails
    }
}