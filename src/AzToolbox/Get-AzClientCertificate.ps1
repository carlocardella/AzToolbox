function Get-AzClientCertificate {
    <#
    .SYNOPSIS
    Returns the Azure Resource Manager client authentication certificate for the selected environment
    The response can list one or two certificates: if two are presented, both certificates
    should be trusted to permit the certificate rolling use case.

    The "certificate" field is a Base64 encoded cer file, if RP want to read and validate more fields.

    .PARAMETER Environment
    The Azure Cloud environment name to query

    .EXAMPLE
    Get-AzClientCertificate -Environment Public

    thumbprint                               notBefore            notAfter             certificate
    ----------                               ---------            --------             -----------
    6510AFE49C4FE1ADB0CCC0B65BAB07C298E6609A 2015-08-18T22:16:02Z 2017-08-17T22:16:02Z MIIGaTCCBFGgAwIBAgITWgABpmv9...

    Returns the available ARM client certificate(s) from the Public generic ARM endpoint

    .OUTPUTS
    Microsoft.Azure.AzureArmClientCertificate
    #>
    [CmdletBinding()]
    [OutputType('AzureArmClientCertificate')]
    param (
        [parameter(Position = 0)]
        [ArgumentCompleter( {
                param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-AzEnvironment | Select-Object -ExpandProperty 'Name'
            })]
        [string]$Environment = 'AzureCloud'
    )

    process {
        if (![string]::IsNullOrWhiteSpace($PSCmdlet.MyInvocation.BoundParameters.RegionalEndpoint)) {
            $re = "{0}." -f $PSCmdlet.MyInvocation.BoundParameters.RegionalEndpoint
        }

        $uri = $null
        $outObj = $null
        if ($IsCoreCLR) {
            [Microsoft.Powershell.Commands.BasicHtmlWebResponseObject]$response = $null
        }
        else {
            [Microsoft.PowerShell.Commands.HtmlWebResponseObject]$response = $null
        }
        switch ($Environment) {
            'AzureCloud' {
                $uri = "https://admin.management.azure.com/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty 'clientCertificates'
            }

            'AzureChinaCloud' {
                $uri = "https://admin.management.chinacloudapi.cn/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty 'clientCertificates'
            }

            'AzureUSGovernment' {
                $uri = "https://admin.management.usgovcloudapi.net/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -Method 'Get'
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty 'clientCertificates'
            }

            'AzureGermanCloud' {
                $uri = "https://admin.management.microsoftazure.de/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty 'clientCertificates'
            }

            Default {
                Write-Error -Message "Invalid envorinment: $Environment"
            }
        }

        if ($outObj) {
            foreach ($certificate in $outObj) {
                $certificate.PSObject.TypeNames.Insert(0, "AzureArmClientCertificate")
                $certificate
            }
        }
    }
}
