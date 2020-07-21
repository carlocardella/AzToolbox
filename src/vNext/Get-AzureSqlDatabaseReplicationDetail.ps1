function Get-AzureSqlDatabaseReplicationDetail {
    <#
    .SYNOPSIS
        Queries all databases in the given Azure Subscription and returns information about the Primary database
        and its copies.
        The function will skip databases without Sql replication (Azure Copy) enabled
        
    .EXAMPLE
        Get-AzureSqlDatabaseReplicationDetail -SubscriptionName MySubscription

        SourceServerName            : o4u9svmno6
        SourceDatabaseName          : dbncuss1
        SourceServerLocation        : North Central US
        SourceServiceObjective      : P1
        DestinationServerName       : l9ymqzwze2
        DestinationDatabaseName     : dbncuss1
        DestinationServerLocation   : South Central US
        IsLocal                     : False
        IsContinuous                : True
        PercentComplete             : 100
        IsOfflineSecondary          : False
        DestinationServiceObjective : P1

        SourceServerName            : o4u9svmno6
        SourceDatabaseName          : dbncuss1
        SourceServerLocation        : North Central US
        SourceServiceObjective      : P1
        DestinationServerName       : y9chephoe8
        DestinationDatabaseName     : dbncuss1
        DestinationServerLocation   : North Central US
        IsLocal                     : True
        IsContinuous                : True
        PercentComplete             : 100
        IsOfflineSecondary          : False
        DestinationServiceObjective : P1
    #>

    [OutputType('Microsoft.Azure.AzureSqlDatabaseReplicationDetail')]
    param (
    )

    throw [System.NotImplementedException]::new("This function is not supported in Powershell Core yet, please update it")

    # process {

    # Get-AzureSqlDatabaseServer -pv srv | Get-AzureSqlDatabaseCopy | Where-Object IsLocalDatabaseReplicationTarget -eq False |
    #     Select-Object SourceServerName, SourceDatabaseName, @{l = 'SourceServerLocation'; e = {$(Get-AzureSqlDatabaseServer $_.SourceServerName).Location}}, `
    # @{l = 'SourceServiceObjective'; e = {$(Get-AzureSqlDatabase -ServerName $_.SourceServerName -DatabaseName $_.SourceDatabaseName).ServiceObjectiveName}}, `
    #     DestinationServerName, DestinationDatabaseName, @{l = 'DestinationServerLocation'; e = {$(Get-AzureSqlDatabaseServer $_.DestinationServerName).Location}}, `
    # @{l = 'IsLocal'; e = {($((Get-AzureSqlDatabaseServer $_.SourceServerName).Location) -eq $((Get-AzureSqlDatabaseServer $_.DestinationServerName).Location))}}, `
    #     IsContinuous, PercentComplete, IsOfflineSecondary, `
    # @{l = 'DestinationServiceObjective'; e = {$(Get-AzureSqlDatabase -ServerName $_.DestinationServerName -DatabaseName $_.DestinationDatabaseName).ServiceObjectiveName}}
    $sqlServer = Get-AzSqlServer
    $sqlDatabase = $sqlServer | Get-AzSqlDatabase | Where-Object 'DatabaseName' -ne 'master'

    Get-AzSqlDatabaseReplicationLink -ServerName $sqlDatabase[0].ServerName -ResourceGroupName $sqlDatabase[0].ResourceGroupName -DatabaseName $sqlDatabase[0].DatabaseName -PartnerResourceGroupName $sqlDatabase[0].ResourceGroupName

    # }
}
