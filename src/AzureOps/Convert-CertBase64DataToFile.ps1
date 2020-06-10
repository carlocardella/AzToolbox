function Convert-CertBase64DataToFile {
    <#
    .SYNOPSIS
    Converts the Base64 string representation of a certificate to a Certificate object and optionally
    saves the certificate to disk

    .PARAMETER CertBase64Data
    Base64 String certificate representation

    .PARAMETER OutputFile
    Full path to the certificate to save to disk

    .PARAMETER Password
    Password to protect the private key certificate (.pfx)

    .EXAMPLE
    Convert-CertBase64DataToFile -CertBase64Data (Get-AzKeyVaultSecret myCertificateSecret).SecretValueText -OutputFile C:\LocalTemp\myCertificateSecret.pfx -Password (Read-Host -AsSecureString p)
    p: *************
    #>

    param(
        [parameter(Mandatory, Position = 1, ValueFromPipeline)]
        ## Base64String representation of the certificate object
        [Alias('Data')]
        [string]$CertBase64Data,

        [parameter(Position = 2)]
        ## Full file path where to save the converted certificate
        [string]$OutputFile,

        [parameter(Position = 3)]
        ## password to use to save a Private Key file
        [securestring]$Password
    )

    process {
        [byte[]]$certData = [System.Convert]::FromBase64String($CertBase64Data)
        $certObject = [System.Security.Cryptography.X509Certificates.X509Certificate2] $certData

        if (! [string]::IsNullOrWhiteSpace($OutputFile)) {
            if (! [string]::IsNullOrWhiteSpace($Password)) {
                if (! $certObject.HasPrivateKey) {
                    Write-Warning "Saving a .cer file in .pfx format with password may result in a corrupted file"
                }
                $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                $certCollection.Import($certData, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
                [System.IO.File]::WriteAllBytes($OutputFile, $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $Password))
            }
            else {
                [System.IO.File]::WriteAllBytes($OutputFile, $certObject.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
            }
        }
        else {
            $certObject
        }
    }
}