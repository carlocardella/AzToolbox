function Get-AzResourceProviderApiVersion {
    <#
    .SYNOPSIS
    Lists the available API version(s) for a given Resource Provider and optionally for the specified Resource Type(s)

    .PARAMETER ProviderNamespace
    Resource PRovider namespace to return the API version(s) for

    .PARAMETER ResourceTypes
    Optional Resource Type for the passed Resource Provider

    .EXAMPLE
    Get-AzResourceProviderApiVersion -ProviderNamespace Microsoft.Automation

    2018-06-30
    2018-01-15
    2017-05-15-preview
    2015-10-31
    2015-01-01-preview

    Returns the available APIs across all ResourceTypes for the Resource Provider (Microsoft.Automation).

    .EXAMPLE
    Get-AzResourceProviderApiVersion -ProviderNamespace Microsoft.Automation -ResourceTypes automationaccounts

    ResourceTypeName   ApiVersions
    ----------------   -----------
    automationAccounts {2018-06-30, 2018-01-15, 2017-05-15-preview, 2015-10-31...}

    Returns the available APIs for the specified ResourceType under the Resource Provider

    .EXAMPLE
    Get-AzResourceProviderApiVersion -ProviderNamespace Microsoft.Automation -ResourceTypes automationAccounts, automationAccounts/runbooks

    ResourceTypeName            ApiVersions
    ----------------            -----------
    automationAccounts          {2018-06-30, 2018-01-15, 2017-05-15-preview, 2015-10-31...}
    automationAccounts/runbooks {2018-06-30, 2018-01-15, 2017-05-15-preview, 2015-10-31...}

    Returns the available APIs for the specified ResourceTypes under the Resource Provider
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
            Get-AzResourceProvider -ProviderNamespace $ProviderNamespace | Select-Object -ExpandProperty 'ResourceTypes' | Select-Object -ExpandProperty 'ApiVersions' -Unique
        }
        else {
            foreach ($type in $ResourceTypes) {
                Get-AzResourceProvider -ProviderNamespace $ProviderNamespace |
                    Select-Object -ExpandProperty 'ResourceTypes' |
                    Where-Object 'ResourceTypeName' -EQ $type |
                    Select-Object @{l = 'ResourceTypeName'; e = { $_.ResourceTypeName } }, ApiVersions
            }
        }
    }
}