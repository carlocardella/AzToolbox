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


# cordon nodes
$nodes = (& kubectl get nodes -o json | ConvertFrom-Json -Depth 100).items | Where-Object { $_.metadata.labels.'kubernetes.azure.com/node-image-version' -Match 'Ubuntu' }

# Write-Host -ForegroundColor Yellow "kubectl cordon $nodes"
& kubectl cordon $nodes.metadata.name
