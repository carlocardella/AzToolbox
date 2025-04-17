<#
.SYNOPSIS
    Finds the AKS node image based on the provided image SHA.

.DESCRIPTION
    This function uses `kubectl` to retrieve information about all pods across namespaces in an AKS cluster.
    It extracts the container image and image ID, then filters the results to match the provided image SHA.

.PARAMETER ImageSha
    The SHA of the image to search for in the AKS cluster.

.EXAMPLE
    Find-AzAksNodeImage -ImageSha "sha256:abcd1234"
    Searches for the image with the specified SHA in the AKS cluster.

.NOTES
    - Requires `kubectl` to be installed and available in the system PATH.
    - Outputs an error if `kubectl` is not found.
#>
function Find-AzAksNodeImage {
    
    param(
        [parameter()]
        [string]$ImageSha
    )

    # Check if kubectl is installed and available
    & kubectl | Out-Null
    if (!$?) {
        Write-Error "kubectl not found. Please install kubectl and try again."
        return
    }

    # Retrieve pod information and filter by the provided image SHA
    & kubectl get pods --all-namespaces -o jsonpath="{range .items[*]}{.spec.containers[*].image}{'\t'}{.status.containerStatuses[*].imageID}{'\n'}{end}" | Sort-Object | Select-String $ImageSha
}