<#
.SYNOPSIS
Create a new Azure AD Application and Service Principal

.PARAMETER DisplayName
.PARAMETER Password
.PARAMETER Homepage
.PARAMETER AvailableToOtherTenants

.EXAMPLE
#>
function New-AzApplicationAndIdentity {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 1)]
        [string]$DisplayName,

        [parameter(Mandatory, Position = 2)]
        [securestring]$Password,

        [parameter()]
        [string]$Homepage,

        [parameter()]
        [Alias('AvailableToOtherTenants')]
        [switch]$AvailableToOtherTenants
    )

    $azureAppParams = @{
        'DisplayName'    = $DisplayName;
        'Password'       = $Password;
        'IdentifierUris' = $Homepage
    }
    if ($Homepage) { $azureAppParams.Homepage = $Homepage }
    if ($AvailableToOtherTenants) { $azureAppParams.AvailableToOtherTenants = $true }

    try {
        $azureApp = New-AzADApplication @azureAppParams -ErrorAction Stop

        $azureSP = New-AzADServicePrincipal -ApplicationId $azureApp.ApplicationId

        $azureApp
        $azureSP
    }
    catch {
        Write-Error $_
    }
}
