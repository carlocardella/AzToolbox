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

# ensure AllowedDisruptions is set at least to 1 for all nodes
$ubuntuNodes = (& kubectl get nodes -o json | ConvertFrom-Json -Depth 100).items | Where-Object { $_.metadata.labels.'kubernetes.azure.com/node-image-version' -Match 'Ubuntu' }
$marinerNodes = (& kubectl get nodes -o json | ConvertFrom-Json -Depth 100).items | Where-Object { $_.metadata.labels.'kubernetes.azure.com/node-image-version' -Match 'Mariner' }
$allowedDisruptions = (& kubectl get pdb -A -o json | convertfrom-json -d 100).items.status.disruptionsAllowed | ForEach-Object { $_ -ge 1 } | Where-Object { $_ -eq $false }

if ($allowedDisruptions.Count -eq 0) {
    foreach ($node in $ubuntuNodes) {
        Write-Host -ForegroundColor Yellow "Draining node $($node.metadata.name)"
        & kubectl drain $node.metadata.name --ignore-daemonsets --delete-emptydir-data
    
        $pods = (& kubectl get pods -A -o json | ConvertFrom-Json -Depth 100).items | Where-Object { $_.spec.nodeName -in $marinerNodes.metadata.name }
        $allPodsRunning = $false
    
        while (-not $allPodsRunning) {
            Start-Sleep 10
            $notReady = $pods.status.containerStatuses | Where-Object 'phase' -NotIn ('Completed', 'Succeeded') | Where-Object 'ready' -eq $false
            if ($notReady.Count -eq 0) {
                Write-Host -ForegroundColor Green "$(Get-Date) - Pods and containers ready"
                $allPodsRunning = $true
                break
            }

            Write-Host -ForegroundColor Yellow "$(Get-Date) - Waiting for pods to be ready"
        }
    }
}
else {
    throw "AllowedDisruptions must be at least 1 for every node"
}