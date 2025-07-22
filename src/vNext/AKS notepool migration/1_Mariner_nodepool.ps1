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


foreach ($agentPool in $aksCluster.AgentPoolProfiles) {
    $params = @(
        '--cluster-name', $($aksCluster.Name),
        '--resource-group', $($aksCluster.ResourceGroupName),
        '--name', $($agentPool.Name + 'm'),
        '--os-sku', 'Mariner',
        '--mode', $($agentPool.Mode),
        '--enable-cluster-autoscaler',
        '--min-count', $($agentPool.MinCount ?? 3),
        '--max-count', $($agentPool.MaxCount ?? 10),
        '--node-count', $($agentPool.Count)
    )

    if ($agentPool.NodeTaints) {
        if ($agentPool.Mode -eq 'System') {
            throw "System node pools cannot have taints: $($agentPool.Name)"
        }

        $params += '--node-taints'
        $params += $agentPool.NodeTaints
    }

    if ($agentPool.NodeLabels) {
        $params += '--labels'
        $params += "$($agentPool.NodeLabels.Keys)=$($agentPool.NodeLabels.Values)"
    }

    Write-Host -ForegroundColor Yellow "az aks nodepool add $params"

    & az aks nodepool add $params
}
