function Invoke-SqlQuery {
    <#
    .SYNOPSIS
    Queries a Sql database. This cmdlet internally uses the .NET ExecuteReader method
    If you pass in one query the cmdlet returns the result in a DataTable.
    If you pass in multiple queries the cmdlet returns a DataSet with multiple DataTables, one for each query executed

    .PARAMETER Server
    Sql Server to connect to

    .PARAMETER Database
    Database to query

    .PARAMETER Username
    Username to authenticate to the database

    .PARAMETER Password
    Password to use with $Username

    .PARAMETER Timeout
    Command timeout in seconds

    .PARAMETER ConnectionString
    Connection string to connect to the desired database

    .PARAMETER Query
    Query to execute

    .EXAMPLE
    $query = "select top 10 * from customers"
    Invoke-SqlQuery -Server myserver.database.windows.net -Database MyDatabase -Username DbAdmin -Password (Read-Host -AsSecureString) -Query $query

    This command connects to a Sql Database on Azure, prompts the user to enter the password, executes the query in $query and returns the result as DataTable

    .EXAMPLE
    $conn = "Server=tcp:{yourserverhere}.database.windows.net,1433;Database={database};User ID={account}@{yourserverhere};Password={your_password_here};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
    $query = @('select top 10 * from orders', 'selet count (*) from customers')
    $query | Invoke-SqlQuery -ConnectionString $conn

    This command pipes the queries in $query to Invoke-SqlQuery, uses the connection string in $conn to connect to the database and returns the result as DataSet

    .OUTPUTS
    System.Data.DataTable
    System.Data.DataSet
    #>
    [CmdletBinding(DefaultParameterSetName = 'params')]
    [OutputType([System.Data.DataTable])]
    param(
        [parameter(mandatory = $true, ParameterSetName = 'params')]
        [string]$Server,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        [string]$Database,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        [string]$Username,

        [parameter(mandatory = $true, ParameterSetName = 'params')]
        [System.Security.SecureString]$Password,

        [parameter(mandatory = $false, ParameterSetName = 'params')]
        [string]$Timeout = 60,

        [parameter(mandatory = $true, ParameterSetName = 'connectionString')]
        [string]$ConnectionString,

        [parameter(mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Query
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
            Write-Verbose -Message "Building the connection string"
            $ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$(Unprotect-SecureString -SecureString $Password);Trusted_Connection=False;Encrypt=True"
        }

        $connection = New-SqlConnectionObject -ConnectionString $ConnectionString
    }

    process {
        foreach ($cmd in $Query) {
            $command = $connection.CreateCommand()
            $command.CommandText = $cmd
            $command.CommandTimeout = $Timeout

            Write-Verbose -Message "Executing the query"
            $sqlReader = $command.ExecuteReader()
            $dataTable = New-Object -TypeName System.Data.DataTable
            $dataTable.Load($sqlReader)
            $sqlReader.Close()

            if ($Query.Count -gt 1) {
                if ($null -eq $dataset) { $dataset = New-Object -TypeName System.Data.Dataset }
                $dataset.Tables.Add($dataTable)
            }
        }
    }

    end {
        if ($null -ne $dataset) { $dataset.Tables } else { $dataTable }
        Write-Verbose -Message "Cloding the Sql connection"
        $connection.Close() | Out-Null
    }
}
