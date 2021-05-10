function Add-AzServicePrincipalCertificate {
    <#
    .SYNOPSIS
    Add a new Certificate to the specified Azure AD Application

    .PARAMETER ApplicationId
    The application id of the application to add the credentials to
    
    .PARAMETER CertificatePath
    Path to the .cer file to add

    .EXAMPLE
    Add-AzServicePrincipalCertificate -ApplicationId 84f121e6-bb47-568f-912f-410c1824ebe1 -CertificatePath C:\Temp\MyNewCert.cer
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationId,

        [parameter(Mandatory, Position = 1)]
        [ValidateScript( {
                if (Test-Path -Path $_) { $true }
                else { throw "Invalid certificate path: $_" }
            })
        ]
        [string]$CertificatePath
    )

    $CertificatePath = Resolve-Path $CertificatePath
    $Cer = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath)
    $BinCert = $Cer.GetRawCertData()
    $CredValue = [System.Convert]::ToBase64String($BinCert)

    New-AzADAppCredential -ApplicationId $ApplicationId -CertValue $CredValue -StartDate $Cer.NotBefore -EndDate $Cer.NotAfter
}
