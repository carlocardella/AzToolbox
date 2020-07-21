<#
.SYNOPSIS
    Returns the RDFE client authentication certificate for the selected environment
    The response can list one or two certificates: if two are presented, both certificates
    should be trusted to permit the certificate rolling use case.

    The "certificate" field is a Base64 encoded cer file

.EXAMPLE
    Get-AzureRDFEClientCertificate -Environment Public

    Thumbprint                               NotBefore            NotAfter             Certificate
    ----------                               ---------            --------             -----------
    6510AFE49C4FE1ADB0CCC0B65BAB07C298E6609A 2015-08-18T22:16:02Z 2017-08-17T22:16:02Z MIIGaTCCBFGgAwIBAgITWgABpmv9...

    Returns the available RDFE client certificate(s) from the Public Global RDFE endpoint

.OUTPUTS
    TypeName: System.Management.Automation.PSCustomObject
#>
function Get-AzureRDFEClientCertificate {
    [CmdletBinding()]
    [OutputType('Microsoft.Azure.AzureRDFEClientCertificate')]
    param (
        [parameter(Position = 1)]
        [ValidateSet('Public', 'Mooncake', 'Fairfax', 'Blackforest')]
        [string]$Environment = 'Public'
    )

    process {
        $uri = $null
        $response = $null
        $outObj = $null
        switch ($Environment) {
            'Public' {
                $uri = 'https://management.core.windows.net/public/certificates'
            }

            'Mooncake' {
                $uri = 'https://management.core.chinacloudapi.cn/public/certificates'
            }

            'Fairfax' {
                $uri = 'https://management.core.usgovcloudapi.net/public/certificates'
            }

            'Blackforest' {
                $uri = 'https://management.core.cloudapi.de/public/certificates'
            }

            Default {
                Write-Error -Message "Invalid envorinment: $Environment"
                throw
            }
        }

        $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
        [xml]$outObj = $response | Select-Object -ExpandProperty 'Content'

        if ($outObj) {
            foreach ($certificate in $outObj.PublicSettings.Certificates.ServiceCertificate) {
                [System.Security.Cryptography.X509Certificates.X509Certificate2]$certObj = $null
                $certObj = [Convert]::FromBase64String($certificate.Pfx)

                New-Object -TypeName 'PSCustomObject' -Property (
                    [ordered]@{
                        'Thumbprint'  = $certObj.Thumbprint;
                        'NotBefore'   = $certObj.NotBefore;
                        'NotAfter'    = $certObj.NotAfter;
                        'Certificate' = $certificate.Pfx;
                    }
                )
            }
        }
    }
}
