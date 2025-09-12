function Get-AzAvailabilityZoneDistribution {
    <#
    .SYNOPSIS
    Gets the availability zone distribution for Azure regions in a subscription.
    
    .DESCRIPTION
    This function retrieves the mapping between logical and physical availability zones for all regions 
    in an Azure subscription. Each datacenter is assigned to a physical zone, and physical zones are 
    mapped to logical zones in your Azure subscription. Different subscriptions might have different 
    mapping orders.
    
    .PARAMETER SubscriptionId
    The Azure subscription ID to query. If not specified, uses the current subscription from the Azure context.
    
    .PARAMETER TenantId
    The Azure tenant ID. Use this parameter if you encounter authentication issues or need to specify a particular tenant.
    
    .EXAMPLE
    Get-AzAvailabilityZoneDistribution
    
    Gets availability zone distribution for the current subscription.
    
    .EXAMPLE
    Get-AzAvailabilityZoneDistribution -SubscriptionId "12345678-1234-1234-1234-123456789012"
    
    Gets availability zone distribution for a specific subscription.
    
    .EXAMPLE
    Get-AzAvailabilityZoneDistribution -SubscriptionId "12345678-1234-1234-1234-123456789012" -TenantId "87654321-4321-4321-4321-210987654321"
    
    Gets availability zone distribution for a specific subscription and tenant.
    
    .NOTES
    https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-powershell#physical-and-logical-availability-zones

    Each datacenter is assigned to a physical zone. Physical zones are mapped to logical zones in your Azure subscription, and different subscriptions might have a different mapping order. Azure subscriptions are automatically assigned their mapping at the time the subscription is created. Because of this, the zone mapping for one subscription could be different for other subscriptions. For example: Subscription A may have physical zone X mapped to logical zone 1, while subscription B has physical zone X mapped to logical zone 3, instead.

    To understand the mapping between logical and physical zones for your subscription, use the List Locations Azure Resource Manager API (https://learn.microsoft.com/en-us/rest/api/resources/subscriptions/list-locations).
    #>

    [CmdletBinding()]
    [OutputType('AzAvailabilityZoneDistribution')]
    param (
        [parameter()]
        [ValidateScript({ $_ -match '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$' })]
        [string]$SubscriptionId,
        
        [parameter()]
        [string]$TenantId
    )

    # Get current context
    $currentContext = Get-AzContext
    if (!$currentContext) {
        throw "No Azure context found. Please run Connect-AzAccount first."
    }

    if (!$SubscriptionId) {
        $SubscriptionId = $currentContext.Subscription.Id
    }

    # Only switch context if we're not already in the correct subscription
    if ($currentContext.Subscription.Id -ne $SubscriptionId) {
        try {
            $setContextParams = @{
                SubscriptionId = $SubscriptionId
                ErrorAction = 'Stop'
                WarningAction = 'SilentlyContinue'
            }
            
            if ($TenantId) {
                $setContextParams.TenantId = $TenantId
            }
            
            Set-AzContext @setContextParams | Out-Null
        }
        catch {
            Write-Warning "Failed to set Azure context for subscription '$SubscriptionId'. Error: $($_.Exception.Message)"
            Write-Warning "You may need to run: Connect-AzAccount -SubscriptionId '$SubscriptionId'$(if($TenantId){" -TenantId '$TenantId'"})"
            throw
        }
    }

    $response = Invoke-AzRestMethod -Method GET -Path "/subscriptions/$SubscriptionId/locations?api-version=2022-12-01"
    $locations = ($response.Content | ConvertFrom-Json).value

    $locations | ForEach-Object {
        # Create base properties hashtable
        $properties = [ordered]@{
            DisplayName      = $_.displayName
            Name             = $_.name
            RegionType       = $_.metadata.regionType
            RegionCategory   = $_.metadata.regionCategory
            Geography        = $_.metadata.geography
            GeographyGroup   = $_.metadata.geographyGroup
            Longitude        = $_.metadata.longitude
            Latitude         = $_.metadata.latitude
            PhysicalLocation = $_.metadata.physicalLocation
            PairedRegion     = $_.metadata.pairedRegion.name
        }

        # Add zone properties dynamically
        if ($_.availabilityZoneMappings.Count -eq 0) {
            # No zones available - add null values for standard zones
            $properties['Zone1'] = $null
            $properties['Zone2'] = $null  
            $properties['Zone3'] = $null
        }
        else {
            # Create a hashtable to map logical zones to physical zones
            $zoneMapping = @{}
            $_.availabilityZoneMappings | ForEach-Object {
                $zoneMapping[$_.logicalZone] = $_.physicalZone
            }
            
            # Find the maximum zone number to handle regions with more than 3 zones
            $maxZone = ($_.availabilityZoneMappings.logicalZone | Measure-Object -Maximum).Maximum
            
            # Add zone properties for all zones from 1 to maxZone
            for ($i = 1; $i -le [Math]::Max(3, $maxZone); $i++) {
                $properties["Zone$i"] = $zoneMapping["$i"]
            }
        }

        # Create the custom object with all properties
        $result = [pscustomobject]$properties
        $result.PSObject.TypeNames.Insert(0, 'AzAvailabilityZoneDistribution')
        $result
    }

}

