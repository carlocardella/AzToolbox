param (
    [parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$ClusterName,

    [parameter(Mandatory, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [parameter(Mandatory, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId
)

# Select-AzureSubscription -SubscriptionId $SubscriptionId
# if ($? -eq $false) {
#     throw
# }
# az account set -s $SubscriptionId
# if ($? -eq $false) {
#     throw
# }

$aksCluster = Get-AzAksCluster -Name $ClusterName -ResourceGroupName $ResourceGroupName
Import-AzAksCredential -Name $aksCluster.Name -ResourceGroupName $aksCluster.ResourceGroupName -Admin -Force

$ubuntuNodePools = $aksCluster.AgentPoolProfiles | Where-Object { $_.OsSKU -eq 'Ubuntu' }

if ($aksCluster.AgentPoolProfiles.Count -ne $ubuntuNodePools.Count) {
    foreach ($nodePool in $ubuntuNodePools) {
        Write-Host -ForegroundColor Yellow "Removing nodepool $($nodePool.Name)"
        Remove-AzAksNodePool -ClusterName $aksCluster.Name -ResourceGroupName $aksCluster.ResourceGroupName -Name $nodePool.Name -Force
    }
}
else {
    Write-Host -ForegroundColor Yellow "All nodepools are Ubuntu. Terminating script."
}