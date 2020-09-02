function Get-AzResourceProviderLocation {
    <#
    .SYNOPSIS
    Lists the available locations for a given Resource Provider and optionally for the specified Resource Type(s)
    
    .PARAMETER ProviderNamespace
    Resource PRovider namespace to return the available locations for
    
    .PARAMETER ResourceTypes
    Optional Resource Type for the passed Resource Provider
    
    .EXAMPLE
    Get-AzResourceProviderLocation -ProviderNamespace Microsoft.Compute

    East US
    East US 2 
    West US   
    Central US
    North Central US
    South Central US
    North Europe
    West Europe
    East Asia
    Southeast Asia
    Japan East
    Japan West
    Australia East
    Australia Southeast
    Australia Central
    Brazil South
    South India
    Central India
    West India
    Canada Central
    Canada East
    West US 2
    West Central US
    UK South
    UK West
    Korea Central
    Korea South
    France Central
    South Africa North
    UAE North
    Switzerland North
    Germany West Central
    Norway East

    .EXAMPLE
    Get-AzResourceProviderLocation -ProviderNamespace Microsoft.Compute -ResourceTypes hostGroups

    ResourceTypeName Locations
    ---------------- ---------
    hostGroups       {Central US, East US 2, West Europe, Southeast Asia…}
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$ProviderNamespace,

        [parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [string[]]$ResourceTypes
    )

    process {
        if ([string]::IsNullOrWhiteSpace($ResourceTypes)) {
            Get-AzResourceProvider -ProviderNamespace $ProviderNamespace | Select-Object -ExpandProperty 'ResourceTypes' | Select-Object -ExpandProperty 'Locations' -Unique
        }
        else {
            foreach ($type in $ResourceTypes) {
                Get-AzResourceProvider -ProviderNamespace $ProviderNamespace |
                    Select-Object -ExpandProperty 'ResourceTypes' |
                    Where-Object 'ResourceTypeName' -EQ $type |
                    Select-Object @{l = 'ResourceTypeName'; e = { $_.ResourceTypeName } }, Locations
            }
        }
    }
}