function Get-AzAvailabilityZoneDistribution {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER SubscriptionId
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-powershell#physical-and-logical-availability-zones

    Each datacenter is assigned to a physical zone. Physical zones are mapped to logical zones in your Azure subscription, and different subscriptions might have a different mapping order. Azure subscriptions are automatically assigned their mapping at the time the subscription is created. Because of this, the zone mapping for one subscription could be different for other subscriptions. For example: Subscription A may have physical zone X mapped to logical zone 1, while subscription B has physical zone X mapped to logical zone 3, instead.

    To understand the mapping between logical and physical zones for your subscription, use the List Locations Azure Resource Manager API (https://learn.microsoft.com/en-us/rest/api/resources/subscriptions/list-locations).
    #>

    param (
        [parameter()]
        [ValidateScript({ $_ -match '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$' })]
        [string]$SubscriptionId
    )

    if (!$SubscriptionId) {
        $SubscriptionId = (Get-AzContext).Subscription.Id
    }

    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction 'Stop' | Out-Null

    $response = Invoke-AzRestMethod -Method GET -Path "/subscriptions/$SubscriptionId/locations?api-version=2022-12-01"
    $locations = ($response.Content | ConvertFrom-Json).value

    $locations | ForEach-Object {
        $obj = [pscustomobject]@{
            DisplayName = $_.displayName
            Name = $_.name
            RegionType = $_.metadata.regionType
            RegionCategory = $_.metadata.regionCategory
            Geography = $_.metadata.geography
            GeographyGroup = $_.metadata.geographyGroup
            Longitude = $_.metadata.longitude
            Latitude = $_.metadata.latitude
            PhysicalLocation = $_.metadata.physicalLocation
            PairedRegion = $_.metadata.pairedRegion.name
            # AvailabilityZoneMappings = $_.availabilityZoneMappings
        }
        
        $_.availabilityZoneMappings | ForEach-Object {
            Add-Member -MemberType NoteProperty -Name "Zone$($_.logicalZone)" -Value $_.PhysicalZone -InputObject $obj -Force
        }

        $obj
    }

}

