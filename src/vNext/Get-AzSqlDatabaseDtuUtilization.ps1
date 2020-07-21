function Get-AzSqlDatabaseDtuUtilization {
    <#
    .SYNOPSIS
    Returns the DTU utilization as read from a Sql Azure database
    
    .PARAMETER Server
    Sql Server to query; must be a Fully Qualified Domain Name (e.g. myserver.database.windows.net)
    
    .PARAMETER Database
    Database to query for DTU details
    
    .PARAMETER Username
    Username to connect to the database
    
    .PARAMETER Password
    Password for Username
    
    .PARAMETER ConnectionString
    Full Sql connection string to the Sql Database
    
    .EXAMPLE
    Get-AzSqlDatabaseDtuUtilization -Server myserver.database.windows.net -Database MyDatabase -Username DbAdmin -Password (Read-Host -AsSecureString)

    .EXAMPLE
    $conn = "Server=tcp:{yourserverhere}.database.windows.net,1433;Database={database};User ID={account}@{yourserverhere};Password={your_password_here};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
    Get-AzSqlDatabaseDtuUtilization -ConnectionString $conn
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'params')]
    param(
        [parameter(mandatory = $true, ParameterSetName = 'params')]
        ## Sql Server to connect to
        [string]$Server,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        ## Database to query
        [string]$Database,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        ## Username to authenticate to the database
        [string]$Username,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        ## Password to use with $Username
        [System.Security.SecureString]$Password,

        [parameter(mandatory = $true, ParameterSetName = 'connectionString')]
        ## Connection string to connect to the desired database
        [System.Security.SecureString]$ConnectionString
    )

    Import-Module -Name 'LSEFunctions' -ErrorAction 'Stop'

    $sqlCommand = "SELECT end_time, (SELECT Max(v) FROM (VALUES (avg_cpu_percent), (avg_data_io_percent), (avg_log_write_percent)) AS value(v)) AS [avg_DTU_percent] FROM sys.dm_db_resource_stats"
    
    $params = @{ }
    if ($PSCmdlet.ParameterSetName -eq 'params') {
        $params = @{
            'Server'     = $Server;
            'Database'   = $Database;
            'Username'   = $Username;
            'Password'   = $Password
            'SqlCommand' = $sqlCommand
        }
    }
    else {
        $params = @{
            'ConnectionString' = $ConnectionString;
            'SqlCommand'       = $sqlCommand
        }
    }

    Set-SqlQuery @params
}