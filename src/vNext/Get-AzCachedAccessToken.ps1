function Get-AzCachedAccessToken() {
    <#
    .SYNOPSIS
        Returns the cached user Azure access token (available after the user run Login-AzAccount or Add-AzAccount), the token can be used as Bearer authentication header in Azure ARM and RDFE REST calls

    .Parameter Force
        Prompts to authenticate to Azure if the Context (Get-AzContext) is not already set

    .EXAMPLE
        Get-AzCachedAccessToken

    .NOTES
        Credit to Stephane Lapointe
        https://www.codeisahighway.com/how-to-easily-and-silently-obtain-accesstoken-bearer-from-an-existing-azure-powershell-session/

        Authenticate to Azure Service Manager: https://msdn.microsoft.com/en-us/library/azure/ee460782.aspx
    #>

    param (
        [parameter()]
        [switch]$Force
    )

    # if ($IsCoreCLR) {
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    # }
    # elseif (! $IsCoreCLR) {
    #     $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzProfileProvider]::Instance.Profile
    # }
    # else {
    #     throw 'Cannot acquire cached token'
    # }

    if (-not @($azureRmProfile.Accounts).Count) {
        Write-Error "Ensure you have logged in before calling this function."
    }

    if ($Force) {
        Connect-AzureAccountInteractive
    }

    # $currentAzureContext = Get-AzContext
    # $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    # Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
    # $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
    # $token.AccessToken
    $currentAzureContext = Get-AzContext
    $token = $currentAzureContext.TokenCache.ReadItems() | Sort-Object ExpiresOn -Descending | Select-Object -First 1
    $token.AccessToken
}
