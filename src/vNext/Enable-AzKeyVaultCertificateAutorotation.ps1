function Enable-AzKeyVaultCertificateAutorotation {
    <#
    .SYNOPSIS
    Enable KeyVault certificate autorotation

    .PARAMETER VaultName
    KeyVault name

    .PARAMETER SecretName
    Secret Name of the certificate to enable autorotation for

    .PARAMETER IssuerName
    Issuer (CA) name

    .PARAMETER EmailAtPercentageOfLifetime
    Specifies the percentage of the lifetime after which the automatic process for the notification begins

    .PARAMETER EmailAtNumberOfDaysBeforeExpiry
    Specifies the number of days before expiration when automatic renewal should start

    .EXAMPLE
    Get-AzKeyVaultCertificate -VaultName myKV -SecretName myCertificate | Enable-AzKeyVaultCertificateAutorotation -RenewAtPercentageLifetime 75 -Verbose

    VERBOSE:

    SecretContentType               : application/x-pkcs12
    Kty                             : RSA
    KeySize                         : 2048
    Exportable                      : True
    ReuseKeyOnRenewal               : False
    SubjectName                     : CN=myCertificate.azure.com
    DnsNames                        :
    KeyUsage                        : {digitalSignature, keyEncipherment}
    Ekus                            : {1.3.6.1.5.5.7.3.1, 1.3.6.1.5.5.7.3.2}
    ValidityInMonths                : 24
    IssuerName                      : SSLAdminBasedIssuer
    CertificateType                 :
    RenewAtNumberOfDaysBeforeExpiry :
    RenewAtPercentageLifetime       : 75
    EmailAtNumberOfDaysBeforeExpiry :
    EmailAtPercentageLifetime       :
    CertificateTransparency         :
    Enabled                         : True
    Created                         : 11/10/2018 5:46:55 AM
    Updated                         : 11/10/2018 5:46:55 AM
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string]$VaultName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string[]]$SecretName,

        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IssuerName,

        [parameter()]
        [Nullable[Int16]]$RenewAtNumberOfDaysBeforeExpiry = $null,

        [parameter()]
        [Nullable[Int16]]$RenewAtPercentageLifetime = 75
    )

    process {
        foreach ($certificate in $SecretName) {
            Write-Verbose $certificate
            $certSecret = $null
            $certSecret = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $certificate

            if ($null -eq $certSecret) {
                Write-Error "Cannot find certificate $certificate in KeyVault $VaultName"
                continue
            }

            $certPolicy = $null
            $certPolicy = Get-AzKeyVaultCertificatePolicy -VaultName $VaultName -Name $certificate

            if ($null -eq $certPolicy) {
                Write-Error "Cannot retrieve Certificate Policy for certificate $certificate"
                continue
            }

            $certPolicy.IssuerName = $IssuerName
            $certPolicy.EmailAtPercentageLifetime = $null
            $certPolicy.EmailAtNumberOfDaysBeforeExpiry = $null
            $certPolicy.RenewAtNumberOfDaysBeforeExpiry = $RenewAtNumberOfDaysBeforeExpiry
            $certPolicy.RenewAtPercentageLifetime = $RenewAtPercentageLifetime

            Set-AzKeyVaultCertificatePolicy -InputObject $certPolicy -VaultName $VaultName -Name $certificate
            Write-Verbose ($certPolicy | Out-String)
        }
    }
}