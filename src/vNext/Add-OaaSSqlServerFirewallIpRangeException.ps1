function Add-SqlServerFirewallIpRangeException {
    <#
    .SYNOPSIS
    Add a Firewall rule to the given Azure Sql Server.
    This function uses the passed ip address (IPv4 format) and creates a firewall exception using the ip range instead:
    e.g. passing 131.107.120.23 will create a firewall rule with
        - StartIpAddress: 131.107.120.0
        - EndIpAddress: 131.107.120.255

    The rule name will be "ms_proxy_xxxxxx" where xxxxxx is Ticks returned by (Get-Date).Ticks, this is to guarantee
    the rule will have a unique name

    .PARAMETER ServerName
    Sql Server name to add the firewall exception to

    .PARAMETER IpAddress
    IpAddress (IPv4 format) to allow through Sql Firewall

    .EXAMPLE
    Get-AzSqlServer | Add-SqlServerFirewallIpRangeException -StartIpAddress @('167.220.148.0', '131.107.147.0', '131.107.159.0', '131.107.160.0')

    ResourceGroupName : acsqlserverbackend
    ServerName        : acsqlserverbackend
    StartIpAddress    : 167.220.148.0
    EndIpAddress      : 167.220.148.255
    FirewallRuleName  : ms_proxy_636850438716646608

    ResourceGroupName : acsqlserverbackend
    ServerName        : acsqlserverbackend
    StartIpAddress    : 131.107.147.0
    EndIpAddress      : 131.107.147.255
    FirewallRuleName  : ms_proxy_636850439758653757

    ResourceGroupName : acsqlserverbackend
    ServerName        : acsqlserverbackend
    StartIpAddress    : 131.107.159.0
    EndIpAddress      : 131.107.159.255
    FirewallRuleName  : ms_proxy_636850439806076602

    [...]
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ServerName,

        [parameter(Mandatory)]
        [ValidatePattern( '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')]
        [string[]]$IpAddress
    )

    process {
        foreach ($server in $ServerName) {
            foreach ($ip in $IpAddress) {
                $startIP = ([regex]::Matches($ip, "([0-9]{1,3}\.)").value -join '') + '0'
                $endIP = ([regex]::Matches($ip, "([0-9]{1,3}\.)").value -join '') + '255'
                Get-AzSqlServer | Where-Object ServerName -eq $server | New-AzSqlServerFirewallRule -ServerName $server -FirewallRuleName "ms_proxy_$((Get-Date).Ticks)" -StartIpAddress $startIP -EndIpAddress $endIP -ErrorAction 'Inquire'
            }
        }
    }
}