<#+
.SYNOPSIS
Retrieves Azure role assignment details for a specific resource.

.DESCRIPTION
Queries role assignments scoped to the specified resource and enriches each result with service principal metadata when available. Outputs a PSCustomObject per assignment.

.PARAMETER ResourceName
Name of the Azure resource whose role assignments you want to list.

.PARAMETER ResourceGroupName
Resource group containing the target resource.

.PARAMETER ResourceType
Fully qualified resource type (for example: Microsoft.KeyVault/vaults, Microsoft.Compute/virtualMachines).

.EXAMPLE
Get-AzRoleAssignmentDetails -ResourceName 'myvault' -ResourceGroupName 'rg-secure' -ResourceType 'Microsoft.KeyVault/vaults'

Returns all role assignments for the Key Vault named "myvault" in resource group "rg-secure" along with principal display name and IDs when resolvable.
#>
function Get-AzRoleAssignmentDetails {
    param(
        [parameter(Mandatory)]
        [string]$ResourceName,

        [parameter(Mandatory)]
        [string]$ResourceGroupName,

        [parameter(Mandatory)]
        [string]$ResourceType
    )

    Get-AzRoleAssignment -ResourceName $ResourceName -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -PipelineVariable 'ra' | ForEach-Object {
        $servicePrincipal = Get-AzADServicePrincipal -ObjectId $_.ObjectId -ErrorAction 'SilentlyContinue'
        
        [PSCustomObject]@{
            ResourceName       = $ResourceName
            ResourceGroupName  = $ResourceGroupName
            ResourceType       = $ResourceType
            ObjectType         = $ra.ObjectType
            DisplayName        = ${servicePrincipal}?.DisplayName ?? 'unavailable'
            ApplicationId      = ${servicePrincipal}?.AppId ?? 'unavailable'
            ObjectId           = ${servicePrincipal}?.Id ?? 'unavailable'
            RoleDefinitionName = $ra.RoleDefinitionName
            RoleAssignmentId   = $ra.RoleAssignmentId
            RoleAssignmentName = $ra.RoleAssignmentName
            Condition          = $ra.Condition
        }
    }
}