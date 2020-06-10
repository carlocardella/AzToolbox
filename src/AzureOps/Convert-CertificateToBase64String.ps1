
function Convert-CertificateToBase64String {
    <#
    .SYNOPSIS
    Converts a certificate object to a Base64 string

    .PARAMETER Thumbprint
    Thumbprint of the certificate to convert

    .PARAMETER FilePath
    Certificate file to convert to Base64 string

    .PARAMETER Password
    Password to be used for the Private Key (pfx) certificate

    .EXAMPLE
    Convert-CertificateToBase64String -Thumbprint 0B2C5E31A344F7BC85E78100B90DF95399C289FC
    
    .EXAMPLE
    Convert-CertificateToBase64String -FilePath C:\Temp\certificate.cer
    #>
    param(
        [parameter(ParameterSetName = 'thumbprint')]
        [string]$Thumbprint,

        [parameter(ParameterSetName = 'file')]
        [ValidateScript( { Test-Path $_ })]
        [string]$FilePath,

        [parameter()]
        [securestring]$Password
    )

    if ($PSCmdlet.ParameterSetName -eq 'file') {
        $Cer = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($FilePath)
        $BinCert = $Cer.GetRawCertData()
        [System.Convert]::ToBase64String($BinCert)
    }

    if ($PSCmdlet.ParameterSetName -eq 'thumbprint') {
        $cert = (Get-ChildItem cert: -Recurse | Where-Object Thumbprint -Match $Thumbprint)[0]
        $type = [System.Security.Cryptography.X509Certificates.X509ContentType]::pfx
        $bytes = $cert[0].export($type, $Password)
        [system.convert]::ToBase64String($bytes)
    }
}

