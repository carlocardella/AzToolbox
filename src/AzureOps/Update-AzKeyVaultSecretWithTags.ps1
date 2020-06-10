function Update-AzKeyVaultSecretWithTags {
    <#
    .SYNOPSIS
    Updates an existing KeyVault secret maintaining the Tag list

    .PARAMETER VaultName
    KeyVault containing the secret to update

    .PARAMETER SecretName
    Secret to update

    .PARAMETER SecretValue
    New secret

    .EXAMPLE
    $secret = Read-Host -AsSecureString
    Update-AzKeyVaultSecretWithTags -VaultName myKV -SecretName mySecret -SecretValue $secret

    Vault Name   : myKV
    Name         : mySecret
    Version      : 9b8d41c6316e4e7f98b2a89b5a7745bf
    Id           : https://myKV.vault.azure.net:443/secrets/mySecret/9b8d41c6316e4e7f98b2a89b5a7745bf
    Enabled      : True
    Expires      :
    Not Before   :
    Created      : 7/5/2017 8:22:38 PM
    Updated      : 7/5/2017 8:22:38 PM
    Content Type :
    Tags         : Name                Value
                   Notes
                   Username            mySecret
                   SecretStorePath
                   SecretType          Password
                   Resource
    #>
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$VaultName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName,

        [parameter(Mandatory)]
        [securestring]$SecretValue
    )

    $kvSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -ErrorAction 'Inquire'

    Set-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -SecretValue $SecretValue -Tag $kvSecret.Attributes.Tags -ErrorAction 'Inquire'
}