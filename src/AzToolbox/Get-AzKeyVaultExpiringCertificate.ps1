function Get-AzKeyVaultExpiringCertificate {
    <#
    .SYNOPSIS
    Reads the list of certificates on a given KeyVault and returns information about expiring certificates

    .PARAMETER VaultName
    KeyVault to query

    .PARAMETER DaysLeft
    Number of days to consider as expiration threshold
    Default: all certificates are returned

    .EXAMPLE
    Get-AzKeyVaultExpiringCertificate -VaultName cdoprodvault

    SecretName      Thumbprint                               Subject                            NotAfter               DaysLeft
    ----------      ----------                               -------                            --------               --------
    SslCertificate  A6D40090AEA739D6204F967B37C150A180F16CC6 CN=*.mydomain.com                  1/16/2021 11:00:59 AM       219
    EncryptionCert  1D5C4B14D5E3148545D92E47FD297A9F814E6DB2 CN=encryptioncert.mydomain.com     1/24/2021 4:28:28 PM        227
    SpnAuthCert     AD19FB2723ABBF53B2E0FF2622796E31C36ED416 CN=spnauthcert.mydomain.com        1/16/2021 8:47:29 AM        218
    Monitoring      90B8DC83E4F5A18E5CDC9584E26699F0ABC66855 CN=monitoring.mydomain.com         6/26/2020 7:37:57 AM         14
    s2sAuthCert     23328BACFD7F41B29BBE7B1BF001A7568E3574BF CN=s1sauthcert.mydomain.com        6/05/2020 7:36:10 AM         -7
    #>

    [CmdletBinding()]
    [OutputType('AzKeyVaultExpiringCertificate')]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string]$VaultName,

        [parameter(Position = 1)]
        [int]$DaysLeft = [int]::MaxValue
    )

    process {
        Get-AzKeyVaultCertificate -VaultName $VaultName | ForEach-Object {
            Write-Verbose "Certificate name $($_.Name)"
            Get-AzKeyVaultCertificate -VaultName $_.VaultName -Name $_.Name | Where-Object { ([datetime]($_.Certificate.NotAfter) - (Get-Date)).Days -le $DaysLeft } | ForEach-Object {
                $outObj = $null
                $outObj = $_ | Select-Object *
                $outObj.PSObject.TypeNames.Insert(0, 'AzKeyVaultExpiringCertificate')
                $outObj
            }
        }
    }
}