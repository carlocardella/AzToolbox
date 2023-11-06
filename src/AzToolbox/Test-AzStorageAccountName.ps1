function Test-AzStorageAccountName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [Alias('Name')]
        [string]$StorageAccountName,

        [parameter()]
        [switch]$CheckIfExists,

        [parameter()]
        [switch]$IsValid
    )

    if ($IsValid) {
        [psobject]@{
            'StorageAccountName' = $StorageAccountName
            'IsValid' = $StorageAccountName -match '^[a-z0-9]{3,24}$'
        }
    }

    if ($CheckIfExists) {
        [psobject]@{
            'StorageAccountName' = $StorageAccountName
            'Exists' = (Resolve-DnsName -Name "$StorageAccountName.blob.core.windows.net" -Type A -ErrorAction SilentlyContinue) ? $true : $false
        }
    }
}