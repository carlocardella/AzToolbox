function Set-SqlQuery {
    <#
    .SYNOPSIS
    Executes change statements to a Sql database

    .DESCRIPTION
    Executes change statements (Insert, Update, Drop etc...) to a Sql database. This cmdlet internally uses the .NET ExecuteNonQuery method
    The function returns any output returned from the ExecuteNonQuery statement (tipically the number of records affected by the command)

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

    .PARAMETER SqlCommand
    Query to execute

    .EXAMPLE
    $query = "insert into MyTable (Col1, Col2, Col3) values ('val1', 'val2', 'val3)"
    Set-SqlQuery -Server myserver.database.windows.net -Database MyDatabase -Username DbAdmin -Password (Read-Host -AsSecureString) -SqlCommand $query

    This command connects to a Sql Database on Azure, prompts the user to enter the password, executes the "insert" statement and returns the number of records affected by the change

    .EXAMPLE
    $conn = "Server=tcp:{yourserverhere}.database.windows.net,1433;Database={database};User ID={account}@{yourserverhere};Password={your_password_here};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
    $query = @('insert into MyTable (Col1, Col2, Col3) values ('val1', 'val2', 'val3)', 'insert into MyOtherTable (Col11, Col22, Col33) values ('val11', 'val22', 'val33)')
    $query | Set-SqlQuery -ConnectionString $conn

    This command pipes the queries in $query to Set-SqlQuery, uses the connection string in $conn to connect to the database,
    executes the "insert" statements and returns the number of records affected by the change
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
        [System.Security.SecureString]$ConnectionString,

        [parameter(mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$SqlCommand
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
            Write-Verbose -Message "Building the connection string"
            $pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            $connString = "Server=$Server;Database=$Database;User Id=$Username;Password=$pwd;Trusted_Connection=False;Encrypt=True"

        }
        else {
            Write-Verbose -Message "Using the connection string"
            $connString = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConnectionString))
        }

        $connection = New-Object System.Data.SqlClient.SqlConnection $connString
        $connection.Open()
    }

    process {
        foreach ($cmd in $SqlCommand) {
            $command = $connection.CreateCommand()
            $command.CommandText = $cmd
            $command.CommandTimeout = $Timeout

            Write-Verbose -Message "`n Executing `n ********* `n $cmd `n ********* `n "
            $command.ExecuteNonQuery()
        }
    }

    end {
        Write-Verbose -Message "Closing the Sql connection"
        $connection.Close() | Out-Null
    }
}
