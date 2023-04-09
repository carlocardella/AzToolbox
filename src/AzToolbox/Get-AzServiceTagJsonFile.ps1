function Get-AzServiceTagJsonFile {
    <#
    .SYNOPSIS
    Download the service tag json file
    
    .PARAMETER EnvironmentName
    Azure Cloud name to download the json file for. 
    Possible values include: AzureCloud, AzureChinaCloud, AzureUSGovernment, AzureGermanCloud
    
    .PARAMETER OutputFolder
    Folder to download the json file to
    
    .EXAMPLE
    Get-AzServiceTagJsonFile -EnvironmentName AzureCloud -OutputFolder C:\Temp\
    
    .NOTES
    Service Tag ooverview: https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview
    #>
    [CmdletBinding()]
    param(
        [parameter(Position = 0)]
        [ValidateSet('AzureCloud', 'AzureUSGovernment', 'AzureChinaCloud', 'AzureGermanCloud')]
        [Alias('CloudName')]
        [string]$EnvironmentName = 'AzureCloud',

        [parameter(Position = 1, Mandatory)]
        [ValidateScript({
                if (! (Test-Path -Path $(Resolve-Path $_).Path -PathType Container)) {
                    throw "Invalid path: $_"
                }
                $true
            })]
        [string]$OutputFolder
    )

    # https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview
    # Azure Public :         https://www.microsoft.com/download/details.aspx?id=56519 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519
    # Azure US Government :  https://www.microsoft.com/download/details.aspx?id=57063 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57063
    # Azure China :          https://www.microsoft.com/download/details.aspx?id=57062 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57062
    # Azure Germany :        https://www.microsoft.com/download/details.aspx?id=57064 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57064

    $uri = $null
    switch ($EnvironmentName) {
        AzureCloud { $uri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519' }
        AzureUSGovernment { $uri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57063' }
        AzureChinaCloud { $uri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57062' }
        AzureGermanCloud { $uri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57064' }
        Default { throw "Invalid environment name: $EnvironmentName" }
    }
    Write-Debug "Downloading service tag file from $uri"

    # get the link to the actual json file
    $link = (Invoke-WebRequest -Uri $uri).Links | Where-Object 'href' -Like '*.json' | Select-Object 'href' -Unique

    # download the json file
    if ($link) {
        $outFile = Join-Path -Path $OutputFolder -ChildPath (Split-Path $link.href -Leaf)
        Write-Verbose "ServiceTag file: $outFile"
        Invoke-WebRequest -Uri $link.href -UseBasicParsing -OutFile $outFile
    }
    else {
        throw "Unable to find json file for environment: $EnvironmentName"
    }
}