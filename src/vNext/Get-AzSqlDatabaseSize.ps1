
function Get-AzSqlDatabaseSize {
    <#
    .SYNOPSIS
    Returns SKU and size information about the passed Azure Sql database

    .PARAMETER ServerName
    Server Name hosting the database(s) to retrieve the size information for

    .PARAMETER DatabaseName
    Database to retrieve the size information for

    .EXAMPLE
    Get-AzSqlDatabaseSize -ServerName gwkn284rij -ResourceGroupName Default-SQL-EastUS2 -DatabaseName scusdb_1

    ServerName    : gwkn284rij
    DatabaseName  : scusdb_1
    Sku           : P15
    CurrentSizeGb : 3511.92083740234
    MaxSizeGb     : 4096
    %-Used        : 85.74

    #>
    [CmdletBinding()]
    [OutputType('AzSqlDatabaseSize')]
    param (
        [parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$ServerName,

        [parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter(Mandatory, Position = 3, ValueFromPipelineByPropertyName)]
        [string]$DatabaseName
    )

    begin {
        class AzSqlDatabaseSize {
            [string]$ServerName
            [string]$DatabaseName
            [string]$Sku
            [string]$CurrentSizeGb
            [string]$MaxSizeGb
            [string]$PercentageUsed

            AzSqlDatabaseSize($ServerName, $DatabaseName, $Sku, $CurrentSizeGb, $MaxSizeGb, $PercentageUsed) {
                $this.ServerName = $ServerName;
                $this.DatabaseName = $DatabaseName;
                $this.Sku = $Sku;
                $this.CurrentSizeGb = $CurrentSizeGb;
                $this.MaxSizeGb = $MaxSizeGb;
                $this.PercentageUsed = $PercentageUsed
            }
        }
    }

    process {
        # $server = Get-AzSqlServer -ServerName $ServerName -ResourceGroupName $ResourceGroupName
        <#
        ResourceGroupName        : Default-SQL-AustraliaEast
        Location                 : australiaeast
        SqlAdministratorLogin    : dbadmin
        SqlAdministratorPassword :
        ServerVersion            : 12.0
        Tags                     :
        Identity                 :
        FullyQualifiedDomainName : aesqlserver.database.windows.net
        ResourceId               : /subscriptions/0d8b01bc-b3b6-4b86-ba37-acec5ac36670/resourceGroups/Default-SQL-AustraliaEast/providers/Microsoft.Sql/servers/aesqlserver
        #>

        $database = Get-AzSqlDatabase -ServerName $ServerName -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName
        <#
        ResourceGroupName             : Default-SQL-AustraliaEast
        ServerName                    : aesqlserver
        DatabaseName                  : dbaes1
        Location                      : australiaeast
        DatabaseId                    : a10629b9-ac83-47e6-9df6-39230a855e00
        Edition                       : Premium
        CollationName                 : SQL_Latin1_General_CP1_CI_AS
        CatalogCollation              :
        MaxSizeBytes                  : 536870912000
        Status                        : Online
        CreationDate                  : 11/20/18 10:40:16 PM
        CurrentServiceObjectiveId     : 00000000-0000-0000-0000-000000000000
        CurrentServiceObjectiveName   : P2
        RequestedServiceObjectiveName : P2
        RequestedServiceObjectiveId   :
        ElasticPoolName               :
        EarliestRestoreDate           : 2/3/19 12:00:00 AM
        Tags                          :
        ResourceId                    : /subscriptions/0d8b01bc-b3b6-4b86-ba37-acec5ac36670/resourceGroups/Default-SQL-AustraliaEast/providers/Microsoft.Sql/servers/aesqlserver/databas
                                        es/dbaes1
        CreateMode                    :
        ReadScale                     : Disabled
        ZoneRedundant                 : False
        Capacity                      : 250
        Family                        :
        SkuName                       : Premium
        LicenseType                   :
        #>

        $dbSize = $null
        $dbSize = $database | Get-AzMetric -MetricName 'storage' -WarningAction 'SilentlyContinue'
        # Id         : /subscriptions/0d8b01bc-b3b6-4b86-ba37-acec5ac36670/resourceGroups/Default-SQL-AustraliaEast/providers/Microsoft.Sql/servers/aesqlse
        #  rver/databases/dbaes1/providers/Microsoft.Insights/metrics/storage
        # Name       :
        #                 LocalizedValue : Total database size
        #                 Value          : storage

        # Type       : Microsoft.Insights/metrics
        # Unit       : Bytes
        # Data       : {Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricValue, Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricValue,
        #             Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricValue, Microsoft.Azure.Commands.Insights.OutputClasses.PSMetricValue...}
        # Timeseries : {Microsoft.Azure.Management.Monitor.Models.TimeSeriesElement}

        $resourceIdTokens = $dbSize.Id -split '/'

        # $outObj = [PSCustomObject]@{
        #     # SubscriptionName = $resourceIdTokens[2];
        #     ServerName    = $resourceIdTokens[8];
        #     DatabaseName  = $resourceIdTokens[10];
        #     Sku           = $database.CurrentServiceOBjectiveName;
        #     CurrentSizeGb = ($dbSize.Data[0].Maximum / 1gb).ToString("0.00");
        #     MaxSizeGb     = $database.MaxSizeBytes / 1gb;
        #     '%-Used'      = (($dbSize.Data[0].Maximum) / ($database.MaxSizeBytes) * 100).ToString("0.00")
        # }
        # $outObj.PSObject.TypeNames.Insert(0, 'AzSqlDatabaseSize')

        $ServerName = $resourceIdTokens[8]
        $DatabaseName = $resourceIdTokens[10]
        $Sku = $database.CurrentServiceOBjectiveName
        $CurrentSizeGb = ($dbSize.Data[0].Maximum / 1gb).ToString("0.00")
        $MaxSizeGb = $database.MaxSizeBytes / 1gb
        $PercentageUsed = (($dbSize.Data[0].Maximum) / ($database.MaxSizeBytes) * 100).ToString("0.00")

        $outObj = [AzSqlDatabaseSize]::new($ServerName, $DatabaseName, $Sku, $CurrentSizeGb, $MaxSizeGb, $PercentageUsed)
        # $outObj = New-Object -TypeName 'AzSqlDatabaseSize' -ArgumentList $ServerName, $DatabaseName, $Sku, $CurrentSizeGb, $MaxSizeGb, $PercentageUsed

        $outObj
    }
}