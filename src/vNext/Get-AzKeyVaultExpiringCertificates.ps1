function Get-AzKeyVaultExpiringCertificates {
    <#
    .SYNOPSIS
    Reads the list of certificates on a given KeyVault and returns information about expiring certificates

    .PARAMETER VaultName
    KeyVault to query

    .PARAMETER DaysLeft
    Number of days to consider as expiration threshold
    Default: all certificates are returned

    .EXAMPLE
    Get-AzKeyVaultExpiringCertificates -VaultName cdoprodvault

    SecretName           Thumbprint                               Subject                                  NotAfter               DaysLeft
    ----------           ----------                               -------                                  --------               --------
    agentsvc-prod-ac     A6D40090AEA739D6204F967B37C150A180F16CC6 CN=agentsvc-prod-ac.azure-automation.net 1/16/2021 11:00:59 AM  519
    agentsvc-prod-ae     1D5C4B14D5E3148545D92E47FD297A9F814E6DB2 CN=agentsvc-prod-ae.azure-automation.net 1/24/2021 4:28:28 PM   527
    agentsvc-prod-brs    AD19FB2723ABBF53B2E0FF2622796E31C36ED416 CN=agentsvc-prod-brs.azure-automation.n… 1/16/2021 8:47:29 AM   518
    agentsvc-prod-ccan   90B8DC83E4F5A18E5CDC9584E26699F0ABC66855 CN=agentsvc-prod-ccan.azure-automation.… 6/26/2020 7:37:57 AM   314
    agentsvc-prod-cid    23328BACFD7F41B29BBE7B1BF001A7568E3574BF CN=agentsvc-prod-cid.azure-automation.n… 6/26/2020 7:36:10 AM   314
    agentsvc-prod-cus    9C708E64C7650D061DE3CDEEC25EA8136BCA9A03 CN=agentsvc-prod-cus.azure-automation.n… 1/16/2021 8:53:11 AM   518
    agentsvc-prod-ea     B3EC381CCF237A643B217A2F2EE286F65D20DCB7 CN=agentsvc-prod-ea.azure-automation.net 1/16/2021 8:51:44 AM   518
    agentsvc-prod-ejp    D4E716FAA8908112CC49D401C8E375E961D8AD75 CN=agentsvc-prod-ejp.azure-automation.n… 6/26/2020 7:32:37 AM   314
    agentsvc-prod-eus    902DB1B588EB84E4A2B65A24F63A8DA66E1B78EE CN=agentsvc-prod-eus.azure-automation.n… 6/26/2020 7:22:02 AM   314
    agentsvc-prod-eus2   7415FAD477D354EA5EB5E4C6E15F9D7C43FE08FB CN=agentsvc-prod-eus2.azure-automation.… 1/18/2021 8:10:59 AM   520
    agentsvc-prod-eus2p  6330751D6C74FDD803C2F51A960FE000B95EF6A8 CN=agentsvc-prod-eus2p.azure-automation… 6/26/2020 7:39:28 AM   314
    #>

    [CmdletBinding()]
    [OutputType('AzKeyVaultExpiringCertificates')]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string]$VaultName,

        [parameter(Position = 1)]
        [int]$DaysLeft = [int]::MaxValue
    )

    begin {
        Connect-AzureAccountInteractive -TenantId (Get-Subscription -MGMT).TenantId | Out-Null
    }

    process {
        Get-AzKeyVaultCertificate -VaultName $VaultName | ForEach-Object {
            Write-Verbose "Certificate name $($_.Name)"
            Get-AzKeyVaultCertificate -VaultName $_.VaultName -Name $_.Name | Where-Object { ([datetime]($_.Certificate.NotAfter) - (Get-Date)).Days -le $DaysLeft } | ForEach-Object {
                $outObj = $null
                $outObj = $_ | Select-Object *
                $outObj.PSObject.TypeNames.Insert(0, 'AzKeyVaultExpiringCertificates')
                $outObj
            }
        }
    }
}