function Disable-AzKeyVaultCertificateAutorotation {
    <#
    .SYNOPSIS
    Disable KeyVault certificate autorotation

    .PARAMETER VaultName
    KeyVault name, by default CdoProdVaule

    .PARAMETER SecretName
    Secret Name of the certificate to disable autorotation for

    .PARAMETER EmailAtPercentageOfLifetime
    Specifies the percentage of the lifetime after which the automatic process for the notification begins

    .PARAMETER EmailAtNumberOfDaysBeforeExpiry
    Specifies the number of days before expiration when automatic renewal should start

    .EXAMPLE
    Get-KeyVaultCertificate mysubject | Disable-AzKeyVaultCertificateAutorotation -Verbose

    VERBOSE:

    SecretContentType               : application/x-pkcs12
    Kty                             : RSA
    KeySize                         : 2048
    Exportable                      : True
    ReuseKeyOnRenewal               : False
    SubjectName                     : CN=mysubject.azure.com
    DnsNames                        :
    KeyUsage                        : {digitalSignature, keyEncipherment}
    Ekus                            : {1.3.6.1.5.5.7.3.1, 1.3.6.1.5.5.7.3.2}
    ValidityInMonths                : 24
    IssuerName                      : SSLAdminBasedIssuer
    CertificateType                 :
    RenewAtNumberOfDaysBeforeExpiry :
    RenewAtPercentageLifetime       :
    EmailAtNumberOfDaysBeforeExpiry :
    EmailAtPercentageLifetime       : 200
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
        [Nullable[Int16]]$EmailAtPercentageOfLifetime = $null,

        [parameter()]
        [Nullable[Int16]]$emailAtNumberOfDaysBeforeExpiry = $null
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

            $certPolicy.EmailAtPercentageLifetime = $EmailAtPercentageOfLifetime
            $certPolicy.EmailAtNumberOfDaysBeforeExpiry = $emailAtNumberOfDaysBeforeExpiry
            $certPolicy.RenewAtPercentageLifetime = $null
            $certPolicy.RenewAtNumberOfDaysBeforeExpiry = $null

            Set-AzKeyVaultCertificatePolicy -InputObject $certPolicy -VaultName $VaultName -Name $certificate
            Write-Verbose ($certPolicy | Out-String)
        }
    }
}