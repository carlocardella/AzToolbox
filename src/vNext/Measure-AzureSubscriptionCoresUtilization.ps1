function Measure-AzureSubscriptionCoresUtilization {
    <#
    .SYNOPSIS
    Returns the number of cores used, available, and the max quota available for the given subscription(s)
    Note: this is based on RDFE

    .PARAMETER SubscriptionName
    Name of the subscription to measure. If this is empty, the current subscription is measured

    .EXAMPLE
    Get-Subscription -Public | Measure-AzureSubscriptionCoresUtilization | sort AvailableCoreCount

    SubscriptionName        CurrentCoreCount MaxCoreCount AvailableCoreCount
    ----------------        ---------------- ------------ ------------------
    NE-PROD-1                           1408         1500                 92
    JPE-PROD-1                           688          800                112
    WCUS-PROD-1                          234          350                116
    WE-PROD-1                            124          350                226
    EUS2-PROD-1                          124          350                226
    UKS-PROD-1                           488          800                312
    WUS2-PROD-1                          340         3000               2660
    EUS2-PROD-1                         4576         8000               3424
    #>
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)]
        [Alias('Name')]
        [string[]]$SubscriptionName
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($SubscriptionName)) {
            $SubscriptionName = Get-AzureSubscription -Current | Select-Object -ExpandProperty 'SubscriptionName'
        }
        else {
            $initialSubscription = Get-AzureSubscription -Current
        }
    }

    process {
        foreach ($sub in $SubscriptionName) {
            Write-Verbose $sub
            Select-AzureSubscription -SubscriptionName $sub | Out-Null

            if ($?) {
                Get-AzureSubscription -Current -ExtendedDetails -ErrorAction SilentlyContinue |
                    Select-Object @{l = 'SubscriptionName'; e = { $_.SubscriptionName } }, CurrentCoreCount, MaxCoreCount, @{l = 'AvailableCoreCount'; e = { $_.MaxCoreCount - $_.CurrentCoreCount } }
            }
        }
    }

    end {
        Select-AzureSubscription -SubscriptionId $initialSubscription.SubscriptionId | Out-Null
    }
}