function Test-AzKeyVaultCertificateAutorotation {
    <#
    .SYNOPSIS
    Check the KeyVaultCertificatePolicy to verify if autorotation is enabled.
    RenewAtNumberOfDaysBeforeExpiry or RenewAtPercentageLifetime must be greater than 1

    .PARAMETER VaultName
    KeyVault name

    .PARAMETER SecretName
    Secret Name of the certificate to enable autorotation for

    .PARAMETER ExtendedDetails

    .EXAMPLE
    Test-AzKeyVaultCertificateAutorotation -VaultName myKV -SecretName myCertificate

    True

    .EXAMPLE
    Get-AzKeyVaultCertificate -VaultName myKV | Test-AzKeyVaultCertificateAutorotation -ExtendedDetails | Format-Table -AutoSize

    SecretName                 Enabled RenewAtPercentageLifetime RenewAtNumberOfDaysBeforeExpiry
    ----------                 ------- ------------------------- -------------------------------
    SslCertificate             True                           80
    EncryptionCertificate      True                           75
    AuthenticationCertificate  True                           75
    RDPEncryptionCertificate   True                           80
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [OutputType('AzKeyVaultCertificateAutorotationStatus')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$VaultName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string[]]$SecretName,

        [parameter()]
        [switch]$ExtendedDetails
    )

    process {
        foreach ($certificate in $SecretName) {
            $certPolicy = $null
            $certPolicy = Get-AzKeyVaultCertificatePolicy -VaultName $VaultName -Name $certificate

            if ($null -eq $certPolicy) {
                Write-Error "Cannot retrieve Certificate Policy for certificate $certificate"
                continue
            }

            if ($ExtendedDetails) {
                $ht = $null
                $ht = [ordered]@{
                    'SecretName'                      = $certificate;
                    'Enabled'                         = $(
                        if (($certPolicy.RenewAtNumberOfDaysBeforeExpiry -gt 1) -or ($certPolicy.RenewAtPercentageLifetime -gt 1)) {
                            $true
                        }
                        else {
                            $false
                        }
                    );
                    'RenewAtPercentageLifetime'       = $certPolicy.RenewAtPercentageLifetime;
                    'RenewAtNumberOfDaysBeforeExpiry' = $certPolicy.RenewAtNumberOfDaysBeforeExpiry
                }
                $outObj = [pscustomobject]$ht
                $outObj.PSObject.TypeNames.Insert(0, 'AzKeyVaultCertificateAutorotationStatus')
                $outObj
            }
            else {
                if (($certPolicy.RenewAtNumberOfDaysBeforeExpiry -gt 1) -or ($certPolicy.RenewAtPercentageLifetime -gt 1)) {
                    $true
                }
                else {
                    $false
                }
            }
        }
    }
}