function Get-AzTrafficManagerProfileInfo {
    <#
    .SYNOPSIS
    Queries a given Azure Subscription and returns the Traffic Manager profile and endpoint configuration

    .EXAMPLE
    Get-AzTrafficManagerProfileInfo -ProfileName MyTmProfile

    ProfileName           : MyTmProfile
    ProfileStatus         : Enabled
    ResourceGroupName     : myResourceGroup
    Endpoint              : myCloudService.cloudapp.net
    Priority              : 1
    Weight                : 1
    EndpointStatus        : Disabled
    EndpointMonitorStatus :

    ProfileName           : MyTmProfile
    ProfileStatus         : Enabled
    ResourceGroupName     : myResourceGroup
    Endpoint              : myCloudService.cloudapp.net
    Priority              : 2
    Weight                : 1
    EndpointStatus        : Enabled
    EndpointMonitorStatus :
    #>
    [OutputType('Microsoft.Azure.AzureTrafficManagerProfileInfo')]
    param (
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)]
        ## Profile name to use as filter; accepts wildcards (uses the -Like operator)
        [string[]]$ProfileName
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ProfileName)) {
            $ProfileName = Get-AzTrafficManagerProfile
        }
    }

    process {
        foreach ($name in $ProfileName) {
            $tmProfile = $null
            $tmProfile = Get-AzTrafficManagerProfile | Where-Object Name -eq $name

            if ($tmProfile) {
                $tmProfile.Endpoints | Select-Object -Property `
                @{l = 'ProfileName'; e = { $tmProfile.Name } }, `
                @{l = 'ProfileStatus'; e = { $tmProfile.ProfileStatus } }, `
                @{l = 'ResourceGroupName'; e = { $tmProfile.ResourceGroupName } }, `
                @{l = 'Endpoint'; e = { $_.Target } }, `
                    Priority, Weight, EndpointStatus, EndpointMonitorStatus
            }
        }
    }
}
