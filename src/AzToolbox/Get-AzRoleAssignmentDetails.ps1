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
        [parameter(ParameterSetName = 'ResourceName', Mandatory)]
        [string]$ResourceName,

        [parameter(ParameterSetName = 'ResourceName', Mandatory)]
        [string]$ResourceGroupName,

        [parameter(ParameterSetName = 'ResourceName', Mandatory)]
        [string]$ResourceType,

        [parameter(ParameterSetName = 'Scope', Mandatory)]
        [string]$Scope
    )

    # Get-AzRoleAssignment -Scope /subscriptions/1ac856a9-c735-423d-b4cf-9a6b06185a06 -ObjectId 2fa3c00e-3290-49ad-9158-d1aecf225ea9

    if ($PSCmdlet.ParameterSetName -eq 'ResourceName') {
        $params = @{
            ResourceName       = $ResourceName
            ResourceGroupName  = $ResourceGroupName
            ResourceType       = $ResourceType
        }
    }
    else {
        $params = @{
            Scope = $Scope
        }
    }

    Get-AzRoleAssignment @params -PipelineVariable 'ra' | ForEach-Object {
        $servicePrincipal = Get-AzADServicePrincipal -ObjectId $_.ObjectId -ErrorAction 'SilentlyContinue'

        if ($ExecutionContext.SessionState.LanguageMode -eq 'ConstrainedLanguage') {
            $_ | Select-Object @{N = 'ResourceName'; E = { $ResourceName } },
            @{N = 'ResourceGroupName'; E = { $ResourceGroupName } },
            @{N = 'ResourceType'; E = { $ResourceType } },
            @{N = 'ObjectType'; E = { $_.ObjectType } },
            @{N = 'DisplayName'; E = { if ($servicePrincipal.DisplayName) { $servicePrincipal.DisplayName }else { 'unavailable' } } },
            @{N = 'ApplicationId'; E = { if ($servicePrincipal.AppId) { $servicePrincipal.AppId }else { 'unavailable' } } },
            @{N = 'ObjectId'; E = { if ($servicePrincipal.Id) { $servicePrincipal.Id }else { 'unavailable' } } },
            RoleDefinitionName,
            RoleAssignmentId,
            RoleAssignmentName,
            Condition
        }
        else {
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
}