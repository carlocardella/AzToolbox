<#+
.SYNOPSIS
Retrieves Cosmos DB SQL role assignment details for a given account and resource group.

.DESCRIPTION
Queries Cosmos DB SQL role assignments for the specified account and resource group, enriches the results with service principal metadata, and emits a PSCustomObject for each assignment.

.PARAMETER AccountName
Cosmos DB account name hosting the SQL database.

.PARAMETER ResourceGroupName
Resource group containing the Cosmos DB account.

.EXAMPLE
Get-AzCosmosDBSqlRoleAssignmentDetail -AccountName 'mycosmos' -ResourceGroupName 'rg-cosmos'

Retrieves all SQL role assignments for the account named "mycosmos" in resource group "rg-cosmos" and returns the details, including principal display name and application ID when available.
#>
function Get-AzCosmosDBSqlRoleAssignmentDetail {
    param(
        [parameter(Mandatory)]
        [string]$AccountName,

        [parameter(Mandatory)]
        [string]$ResourceGroupName
    )

    Get-AzCosmosDBSqlRoleAssignment -AccountName $AccountName -ResourceGroupName $ResourceGroupName  -pv 'ra' | ForEach-Object {
        $servicePrincipal = Get-AzADServicePrincipal -ObjectId $_.PrincipalId -ErrorAction SilentlyContinue 

        [PSCustomObject]@{
            ResourceName      = $ResourceName
            ResourceGroupName = $ResourceGroupName
            ResourceType      = $ResourceType
            DisplayName       = ${servicePrincipal}?.DisplayName ?? 'unavailable'
            ApplicationId     = ${servicePrincipal}?.AppId ?? 'unavailable'
            ObjectId          = ${servicePrincipal}?.Id ?? 'unavailable'
            Scope             = $ra.Scope
            RoleAssignment    = $ra.RoleDefinitionId.Split('/')[-1] -eq '1' ? 'Data Reader' : 'Data Contributor'
            RoleDefinitionId  = $ra.RoleDefinitionId
        }
    }
}