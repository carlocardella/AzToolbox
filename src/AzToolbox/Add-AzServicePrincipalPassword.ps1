function Add-AzServicePrincipalPassword {
    <#
    .SYNOPSIS
    Add a new password to the specified Azure AD Application

    .PARAMETER ApplicationId
    The application id of the application to add the credentials to

    .PARAMETER Password
    The password to be associated with the application

    .PARAMETER StartDate
    The effective start date of the credential usage. The default start date value is today

    .PARAMETER EndDate
    The effective end date of the credential usage. The default end date value is one year from today

    .EXAMPLE
    Add-AzServicePrincipalPassword -ApplicationId 05f3227b-09d1-4bc6-85c8-8db6b349af67 -Password (ReadHost -AsSecureString)
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationId,

        [parameter(Mandatory, Position = 1)]
        [securestring]$Password,

        [parameter()]
        [datetime]$StartDate = $(Get-Date),

        [parameter()]
        [datetime]$EndDate = $(Get-Date).AddYears(1)
    )

    if ($EndDate -lt $StartDate) { throw [System.FormatException]::new("EndDate cannot be before StartDate") } 
    New-AzADAppCredential -ApplicationId $ApplicationId -Password $Password -StartDate $StartDate -EndDate $EndDate
}
