function Get-AzClientCertificate {
    <#
.SYNOPSIS
    Returns the ARM client authentication certificate for the selected environment
    The response can list one or two certificates: if two are presented, both certificates
    should be trusted to permit the certificate rolling use case.

    The "certificate" field is a Base64 encoded cer file, if RP want to read and validate more fields.

.EXAMPLE
    Get-AzClientCertificate.ps1 -Environment Public

    thumbprint                               notBefore            notAfter             certificate
    ----------                               ---------            --------             -----------
    6510AFE49C4FE1ADB0CCC0B65BAB07C298E6609A 2015-08-18T22:16:02Z 2017-08-17T22:16:02Z MIIGaTCCBFGgAwIBAgITWgABpmv9...

    Returns the available ARM client certificate(s) from the Public generic ARM endpoint

.EXAMPLE
    Get-AzClientCertificate.ps1 -Environment Public -RegionalEndpoint centralus

    thumbprint                               notBefore            notAfter             certificate
    ----------                               ---------            --------             -----------
    6510AFE49C4FE1ADB0CCC0B65BAB07C298E6609A 2015-08-18T22:16:02Z 2017-08-17T22:16:02Z MIIGaTCCBFGgAwIBAgITWgABpmv9...

    Returns the available ARM client certificate(s) from the specified ARM regional endpoint


.OUTPUTS
    TypeName: System.Management.Automation.PSCustomObject

.NOTES
    Sparta sharepoint page: http://sharepoint/sites/AzureUX/Sparta/SpartaWiki/Authentication%20between%20ARM%20and%20RP.aspx
    Yammer discussion: https://www.yammer.com/microsoft.com/threads/578119330
#>
    [CmdletBinding()]
    [OutputType('Microsoft.Azure.AzureArmClientCertificate')]
    param (
        [parameter(Position = 1)]
        [ValidateSet('Public', 'Dogfood', 'Mooncake', 'Fairfax', 'Blackforest')]
        [string]$Environment = 'Public'
    )

    DynamicParam {
        if (![string]::IsNullOrWhiteSpace($Environment)) {
            $ParameterName = 'RegionalEndpoint'
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $AttributeCollection.Add($ParameterAttribute)
            [System.Management.Automation.PSCustomObject]$response = $null

            switch ($Environment) {
                'Public' {
                    $arrSet = @(
                        'eastasia',
                        'southeastasia',
                        'centralus',
                        'eastus',
                        'eastus2',
                        'westus',
                        'northcentralus',
                        'southcentralus',
                        'northeurope',
                        'westeurope',
                        'japanwest',
                        'japaneast',
                        'brazilsouth',
                        'australiaeast',
                        'australiasoutheast',
                        'southindia',
                        'centralindia',
                        'westindia',
                        'canadacentral',
                        'canadaeast',
                        'uksouth',
                        'ukwest',
                        'westcentralus',
                        'westus2',
                        'koreacentral',
                        'koreasouth'
                    )
                }
                'Dogfood' {
                    $arrSet = @(
                        'eastasia',
                        'southeastasia',
                        'centralus',
                        'eastus',
                        'eastus2',
                        'westus',
                        'northcentralus',
                        'southcentralus',
                        'northeurope',
                        'westeurope',
                        'japanwest',
                        'japaneast',
                        'brazilsouth',
                        'australiaeast',
                        'australiasoutheast',
                        'southindia',
                        'centralindia',
                        'westindia',
                        'canadacentral',
                        'canadaeast',
                        'uksouth',
                        'ukwest',
                        'westcentralus',
                        'westus2',
                        'koreacentral',
                        'koreasouth'
                    )
                }
                'Fairfax' {
                    $arrSet = @(
                        'usgoveast',
                        'usgovcentral',
                        'usgovsc',
                        'usgovsw'
                    )
                }
                'Mooncake' {
                    $arrSet = @(
                        'chinacentral',
                        'chinaeast'
                    )
                }
                'Blackforest' {
                    $arrSet = @(
                        'germanycentral',
                        'germanynortheast'
                    )
                }
            }

            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $AttributeCollection.Add($ValidateSetAttribute)

            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)

            return $RuntimeParameterDictionary
        }
    }

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
            'Public' {
                $uri = "https://$($re)management.azure.com:24582/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty clientCertificates
            }

            'Dogfood' {
                $uri = "https://$($re)api-dogfood.resources.windows-int.net:24582/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty clientCertificates
            }

            'Mooncake' {
                $uri = "https://$($re)management.chinacloudapi.cn:24582/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty clientCertificates
            }

            'Fairfax' {
                $uri = "https://$($re)management.usgovcloudapi.net:24582/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -Method 'Get'
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty clientCertificates
            }

            'Blackforest' {
                $uri = "https://$($re)management.microsoftazure.de:24582/metadata/authentication?api-version=2015-01-01"
                $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials
                $outObj = $response | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty clientCertificates
            }

            Default {
                Write-Error -Message "Invalid envorinment: $Environment"
            }
        }

        if ($outObj) {
            $outObj.PSObject.TypeNames.Insert(0, "Microsoft.Azure.AzureArmClientCertificate")
            $outObj
        }
    }
}
