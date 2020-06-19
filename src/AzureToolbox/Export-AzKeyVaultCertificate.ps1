function Export-AzKeyVaultCertificate {
    <#
    .SYNOPSIS
    Exports a certificate from KeyVault to a file.

    .PARAMETER SecretName
    Secret name to retrieve the certificate from KeyVault

    .PARAMETER ExportPrivateKey
    If available, exports the private key (.pfx file)

    .PARAMETER Password
    Password to use to protect the exported private key; does not have any effect
    if only the public key is exported

    .PARAMETER KeyVaultName
    KeyVault to export the certificate from

    .PARAMETER Version
    Specifies the secret version. This cmdlet constructs the FQDN of a secret based on the key vault name, your currently selected environment, the secret name, and the secret version

    .PARAMETER OutputFolder
    Folder to save the exported certificate to

    .EXAMPLE
    $password = Read-Host -AsSecureString
    Export-AzKeyVaultCertificate -SecretName mySecretName -Password $password -KeyVaultName 'myKeyVault' -OutputFolder C:\Temp\Certs -ExportPrivateKey

    .NOTES
    The exported certificate file uses the Subject Name (CN) as name of the file; the proper file extension (.pfx or .cer) is used
    depending on the type of certificate exported
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Azure.Commands.KeyVault.Models.PSKeyVaultCertificate])]
    [OutputType([Microsoft.Azure.Commands.KeyVault.Models.PSKeyVaultCertificateIdentityItem])]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string]$VaultName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string]$SecretName,

        [parameter()]
        [switch]$ExportPrivateKey,

        [parameter()]
        [securestring]$Password,

        [parameter()]
        [switch]$InRemovedState,

        [parameter()]
        [string]$Version,

        [parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType 'Container' })]
        [string]$OutputFolder
    )

    process {
        $params = @{
            'VaultName'  = $VaultName;
            'SecretName' = (Convert-SecretStoreSecretNameToKeyVault -SecretName $SecretName)
        }
        if ($InRemovedState) { $params.InRemovedState = $true }
        if (![string]::IsNullOrWhiteSpace($Version)) { $params.Version = $Version }

        $kvSecret = $null
        $kvSecret = Get-AzKeyVaultSecret @params
        if ($null -eq $kvSecret) {
            Write-Error "Could not retrieve certificate $($params.SecretName) from KeyVault $($params.VaultName)"
            return
        }
        $kvSecretBytes = [System.Convert]::FromBase64String($kvSecret.SecretValueText)

        if ($ExportPrivateKey) {
            $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            $certCollection.Import($kvSecretBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
            $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $(Unprotect-SecureString -SecureString $Password))
            $pfxFileName = "$($certCollection[0].Subject)`.pfx" -replace '\*', '_'
            $pfxPath = Join-Path -Path $OutputFolder -ChildPath $pfxFileName
            Write-Verbose "Exported private key to $pfxPath"
            [System.IO.File]::WriteAllBytes($pfxPath, $protectedCertificateBytes)

            Get-Item -Path $pfxPath
        }
        else {
            $certObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($kvSecretBytes)
            $cerFileName = "$($certObject.Subject)`.cer" -replace '\*', '_'
            $cerPath = Join-Path -Path $OutputFolder -ChildPath $cerFileName
            Write-Verbose "Exported public key to $cerPath"
            $certBytes = $certObject.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
            [System.IO.File]::WriteAllBytes($cerPath, $certBytes)

            Get-Item -Path $cerPath
        }
    }
}
