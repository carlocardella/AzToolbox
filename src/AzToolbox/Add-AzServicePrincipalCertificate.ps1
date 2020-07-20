function Add-AzServicePrincipalCertificate {
    <#
    .SYNOPSIS
    Add a new Certificate to the specified Azure AD Application

    .PARAMETER ApplicationId
    The application id of the application to add the credentials to
    
    .PARAMETER CertificatePath

    .EXAMPLE
    Add-AzServicePrincipalCertificate -ApplicationId 05f3227b-09d1-4bc6-85c8-8db6b349af67 -CertificatePath C:\Temp\MyNewCert.cer
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
