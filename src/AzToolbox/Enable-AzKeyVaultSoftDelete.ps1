function Enable-AzKeyVaultSoftDelete {
    <#
    .SYNOPSIS
    Enable Soft Delete in the given KeyVault

    .PARAMETER VaultName
    KeyVault to enable Soft Delete for
    
    .PARAMETER Force
    Suppress confirmation prompts

    .EXAMPLE
    Enable-AzKeyVaultSoftDelete -VaultName 'myKeyvault' -Force
    
    .NOTES
    https://blogs.technet.microsoft.com/kv/2017/05/10/azure-key-vault-recovery-options/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$VaultName,

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($vault in $VaultName) {
            Write-Verbose $vault
            $kv = $null
            $kv = Get-AzKeyVault -VaultName $vault

            if (! $kv) {
                Write-Error "Could not find KeyVault $vault in the current Subscription. Please select the proper Azure Subscription or make sure the KeyVault name is correct and the KeyVault is available"
                continue
            }

            ($resource = Get-AzResource -ResourceId (Get-AzKeyVault -VaultName $vault).ResourceId).Properties | Add-Member -MemberType NoteProperty -Name enableSoftDelete -Value 'True'

            if ($Force -or ($PScmdlet.ShouldProcess($vault, 'Enable Soft Delete'))) {
                if ($Force -or ($PScmdlet.ShouldContinue("Enable Soft Delete on KeyVault $vault?", 'Enable Soft Delete'))) {
                    Set-AzResource -resourceid $resource.ResourceId -Properties $resource.Properties -Force
                }
            }
        }
    }
}