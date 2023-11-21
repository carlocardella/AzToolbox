function Get-AzQuota {
    [CmdletBinding()]
    param(
        [parameter()]
        [string]$ApiVersion = '2021-03-15-preview'
    )

    $uri = "https://management.azure.com/{scope}/providers/Microsoft.Quota/quotas/{resourceName}?api-version=$ApiVersion"
}
