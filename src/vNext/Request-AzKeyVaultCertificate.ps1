function Request-AzKeyVaultCertificate {
    <#
    .SYNOPSIS
    Request a new SSL certificate from KeyVault

    .PARAMETER SecretName
    Name of the secret in KeyVault

    .PARAMETER VaultName
    The KeyVault to use to request and store the certificate

    .PARAMETER SubjectName
    Subject (Common Name) of the certificate to be provisioned

    .PARAMETER ValidityInMonths
    Certificate validity: default is 365 days

    .PARAMETER IssuerName
    Issuer (CA) name

    .PARAMETER SubjectAlternativeNames
    Array of Subject Alternative Names to add to this certificate

    .PARAMETER Tag
    ARM Tag to add to this certificate

    .PARAMETER KeyNotExportable
    If present, the primate key for this certificate will not be exportable from KeyVault

    .PARAMETER DisableAutorotation
    Disable Certificate autorotation/autorenewal: autorotation happens when the certificate
    reaches 75% of its lifetime

    .PARAMETER Renew
    Renew the certificate maintaining the existing CertificatePolicy

    .EXAMPLE
    Request-AzKeyVaultCertificate -SecretName MySiteSSLCert -SubjectName mysite.azure.com -Verbose

    .NOTES
    Validation rules:

    1.	Certificate's CN must be FQDN and not an IP address
    2.	Certificate's CN cannot contain an underscore
    3.	A certificate with a SAN (multiple CNs) cannot have duplicate entries
    4.	A certificate cannot contain text encoded using Teletex
    5.	No part of the Certificate's CN can start or end  with a dash (for example, server-.encryption.cloudapp.net cannot be used)
    6.	The FQDN cannot be longer than 64 characters
    7.	No part of the CN can contain white spaces
    #>
    [CmdletBinding(DefaultParameterSetName = 'provision')]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [string]$VaultName,

        [parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('CertificateName', 'Name')]
        [string]$SecretName,
        
        [parameter(Mandatory, ParameterSetName = 'provision')]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 64)]
        [ValidateScript( {
                # no ip address
                if ($_ -match '\d+\.\d+\.\d+\.\d+') {
                    throw 'The Subject Name cannot contain an ip address'
                }

                # no underscore
                if ($_ -match '_') {
                    throw "The Subject Name cannot contain an underscore (_). SubjectName $_"
                }

                # No part of the Certificate's CN can start or end  with a dash
                $parts = $_ -split '\.'
                foreach ($part in $parts) {
                    if ( $part.StartsWith("-") -or $part.EndsWith("-") ) {
                        throw "No part of the Subject Name can start or end with a dash (-). Part: $part"
                    }
                }

                # no white spaces
                if ($_ -match ' ') {
                    throw "The Subject Name cannot contain white spaces. SubjectName $_"
                }

                $true
            })]
        [string]$SubjectName,

        [parameter(ParameterSetName = 'provision')]
        [int]$ValidityInMonths = 12,

        [parameter(ParameterSetName = 'provision')]
        [string]$IssuerName,

        [parameter(ParameterSetName = 'provision')]
        [string[]]$SubjectAlternativeNames,

        [parameter(ParameterSetName = 'provision')]
        [hashtable]$Tag,

        [parameter(ParameterSetName = 'provision')]
        [switch]$KeyNotExportable,

        [parameter(ParameterSetName = 'provision')]
        [switch]$DisableAutorotation,

        [parameter(ParameterSetName = 'renew')]
        [switch]$Renew
    )

    # check for duplicate domain names
    $subjects = @()
    $subjects = $SubjectAlternativeNames
    $subjects += $SubjectName
    if ($subjects.Count -ne @($subjects | Select-Object -Unique).Count) {
        throw "Duplicates in Subject Alternative Name are not allowed"
    }

    # set the renewal date
    $maxLifetimeDays = 365
    $renewAtNumberOfDaysBeforeExpiry = $maxLifetimeDays

    # if the user selected a lifetime shorter than $maxLifetimeDays, renew 2 days before expiration
    $expirationDay = (Get-Date).AddMonths($ValidityInMonths)
    $validityInDays = (Get-Date $expirationDay) - (Get-Date).AddDays($maxLifetimeDays)
    if ($validityInDays.Days -lt $maxLifetimeDays) {
        $renewAtNumberOfDaysBeforeExpiry = 2
    }

    # validate the certificate expiration and autorotation
    $certificateLifetimeInDays = $((Get-Date).AddMonths($ValidityInMonths) - (Get-Date)).TotalDays
    if ($certificateLifetimeInDays -le $renewAtNumberOfDaysBeforeExpiry) {
        throw "Certificate lifetime must be greater than $renewAtNumberOfDaysBeforeExpiry days"
    }

    Write-Verbose "Subscription: $((Get-AzContext).Subscription.SubscriptionId), KeyVaultName: $VaultName"

    $azureKeyVaultCertificate = @{
        'VaultName' = $VaultName;
        'Name'      = $SecretName;
        'Tags'      = $Tag
    }

    if (! $Renew) {
        $CN = "CN=$SubjectName"
        $policyHT = @{
            'SecretContentType' = 'application/x-pkcs12';
            'SubjectName'       = $CN;
            'IssuerName'        = $IssuerName;
            'ValidityInMonths'  = $ValidityInMonths;
            'KeyNotExportable'  = $KeyNotExportable;
        }
        if (! [string]::IsNullOrWhiteSpace($SubjectAlternativeNames)) {
            $policyHT.DnsNames = $SubjectAlternativeNames
        }
        if (! $DisableAutorotation) {
            $policyHT.EmailAtPercentageLifetime = $null
            $policyHT.RenewAtNumberOfDaysBeforeExpiry = $renewAtNumberOfDaysBeforeExpiry
        }
        else {
            $policyHT.EmailAtNumberOfDaysBeforeExpiry = $renewAtNumberOfDaysBeforeExpiry
        }
        $policy = New-AzKeyVaultCertificatePolicy @policyHT
        Write-Verbose ($policy | Out-String)
        $azureKeyVaultCertificate.CertificatePolicy = $policy
    }
    else {
        $policy = Get-AzKeyVaultCertificatePolicy -VaultName $VaultName -Name $SecretName
        $azureKeyVaultCertificate.CertificatePolicy = $policy
    }
    Add-AzKeyVaultCertificate @azureKeyVaultCertificate | Out-Null


    while ((Get-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $SecretName).Status -eq 'InProgress') {
        Write-Verbose "$SecretName provisioning in progress, please wait"
        Start-Sleep -Seconds 10
    }

    if ((Get-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $SecretName).Status -eq 'Completed') {
        Get-AzKeyVaultCertificate -VaultName $VaultName -Name $SecretName
    }
    else {
        $op = Get-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $SecretName
        throw "Failed to request certificate $secretName with error: $($op.ErrorMessage)"
    }
}