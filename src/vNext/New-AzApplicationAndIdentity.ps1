function New-AzApplicationAndIdentity {
    <#
    .SYNOPSIS
    Create a new Azure AD Application and Service Principal

    .PARAMETER DisplayName
    Display name of the new application

    .PARAMETER Password
    The password to be associated with the application

    .PARAMETER Homepage
    The URL to the application homepage

    .PARAMETER MultiTenant
    The value specifying whether the application is a single tenant or a multi-tenant

    .EXAMPLE
    New-AzApplicationAndIdentity -AppDisplayName myAdApplication -Password (Convertto-SecureString -AsPlainText -Force 'xxxxxxxxxxx')
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0)]
        [string]$DisplayName,

        [parameter(Mandatory, Position = 1)]
        [securestring]$Password,

        [parameter()]
        [string]$Homepage,

        [parameter()]
        [Alias('AvailableToOtherTenants')]
        [switch]$MultiTenant
    )

    $azureAppParams = @{
        'DisplayName'    = $DisplayName;
        'Password'       = $Password;
        'IdentifierUris' = $Homepage
    }
    if ($Homepage) { $azureAppParams.Homepage = $Homepage }
    if ($MultiTenant) { $azureAppParams.AvailableToOtherTenants = $true }

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
