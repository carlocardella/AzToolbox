<#
.SYNOPSYS
Creates a failover group for a database in the given region. 

For Db database:
NOTE: failovergroupname format:'db"regionname"failovergroup'
For Db database:
NOTE: failovergroupname format: '"regionname"agentservicesql1failovergroup'


.EXAMPLE
Add-SqlFailoverGroup -geo BRS -failovergroupname dbbrsfailovergroup
Add-SqlFailoverGroup -geo BRS -DSC -failovergroupname brsagentservicesql1failovergroup
#>

function Add-SqlFailoverGroup {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, Position = 1, ParameterSetName = 'geo')]
        [ValidateSet(
            'NCUS', 'SCUS', 'WCUS', 'EUS2', 'EUS', 'WUS2', 'CC', 'BRS', 'CUS', 'CE',
            'WE', 'NE', 'UKS', 'FC', 'UKW',
            'SEA', 'CID', 'JPE', 'ASE', 'KC', 'AE', 'EA', 'JPW'
        )]
        [Alias('ShortName')]
        [string]$Geo,

        [parameter(ParameterSetName = 'geo')]
        [switch]$DSC,

        [parameter(Mandatory)]
        [validatescript( { $_ -match "^[a-z0-9-]*$" })]
        [string]$FailoverGroupName
    )

    $sqlserver = Get-AzureSqlDatabaseReplicationDetail -SubscriptionName $subscriptionName | where-object IsLocal -eq $false
    $primaryServerName = $sqlserver.sourceservername
    $partnerServerName = $sqlserver.DestinationServerName
    $database = $sqlserver.SourceDatabaseName
    $primaryServerResourceGroupName = (Get-AzResource | where-object name -like $primaryServerName).ResourceGroupName
    $PartnerResourceGroupName = (Get-AzResource | where-object name -like $partnerServerName).ResourceGroupName
    if (((Get-AzSqlDatabaseFailoverGroup -ResourceGroupName $primaryServerResourceGroupName -ServerName $primaryServerName).FailoverGroupName) -eq $failoverGroupName) {
        throw "failovergroup exists"
    }
    else { 
        if (((Get-AzSqlDatabaseFailoverGroup -ResourceGroupName $primaryServerResourceGroupName -ServerName $primaryServerName).DatabaseNames -eq $database)) {
            throw "$database failovergroup exists"
        }
        write-host "Creating Failovergroup for $database"
        $failoverGroupName = new-azSqlDatabaseFailoverGroup -ResourceGroupName $primaryServerResourceGroupName -ServerName $primaryServerName -PartnerResourceGroupName $PartnerResourceGroupName -PartnerServerName $partnerServerName -FailoverGroupName $failoverGroupName -FailoverPolicy Manual
        Get-AzSqlDatabase -ResourceGroupName $primaryServerResourceGroupName -ServerName $primaryServerName -DatabaseName $database | Add-AzSqlDatabaseToFailoverGroup -ResourceGroupName $primaryServerResourceGroupName -ServerName $primaryServerName -FailoverGroupName $failoverGroupName
    }

}