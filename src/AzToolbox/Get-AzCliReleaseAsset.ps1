function Get-AzCliReleaseAsset {
    <#
    .SYNOPSIS
    Lists newest Azure CLI release available on GitHub
    
    .PARAMETER ListAvailable
    Lists all available releases

    .EXAMPLE
    Get-AzCliReleaseAsset

    Name        : Azure CLI 2.9.1
    ReleaseDate : 7/16/2020 9:57:01 AM
    Url         : https://github.com/Azure/azure-cli/releases/tag/azure-cli-2.9.1
    Tag         : azure-cli-2.9.1
    PreRelease  : False
    #>
    [cmdletbinding()]
    [OutputType('AzCliReleaseAsset')]
    [OutputType('AzCliReleaseAssetRaw')]
    Param(
        [parameter()]
        [switch]$ListAvailable
    )

    $uri = 'https://api.github.com/repos/azure/azure-cli/releases'

    $assets = Invoke-RestMethod -Uri $uri -Method 'Get' -ErrorAction 'Stop'

    if ($assets) {
        foreach ($asset in $assets) {
            $outObj = $null
            $outObj = $asset | Select-Object -Property @{l = 'Name'; e = { $_.name } },
            @{l = 'ReleaseDate'; e = { $_.published_at } },
            @{l = 'Url'; e = { $_.html_url } },
            @{l = 'Tag'; e = { $_.tag_name } },
            @{l = 'PreRelease'; e = { $_.prerelease } }

            $outObj.PSObject.TypeNames.Insert(0, 'AzCliReleaseAsset')
            $outObj

            if (! $ListAvailable) {
                break
            }
        }
    }
}