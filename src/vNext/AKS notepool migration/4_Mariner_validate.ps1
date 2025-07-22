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

$pods = (& kubectl get pods -A -o json | ConvertFrom-Json -Depth 100).items

foreach ($pod in $pods) {
    [pscustomobject]@{
        'PodName'   = $pod.metadata.name;
        'PodStatus' = $pod.status.phase;
        'NodeName'  = $pod.spec.nodeName
    }
}