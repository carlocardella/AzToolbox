function Get-AzAutomationJobInfo {
    <#
    .SYNOPSIS
    Returns text from all output streams for the given Azure Automation Job(s)

    .PARAMETER AutomationAccountName
    Automation Account hosting the runbook and job

    .PARAMETER ResourceGroupName
    Resource Group containing the Automation Account

    .PARAMETER JobId
    Job Id(s) to query

    .EXAMPLE
    $aa

    SubscriptionId        : 07de8526-5054-4ba7-9a80-c1fc7b232292
    ResourceGroupName     : myResourceGroup
    AutomationAccountName : myAutomationAccount
    Location              : South Central US
    State                 :
    Plan                  :
    CreationTime          : 2/2/2016 5:14:41 PM -08:00
    LastModifiedTime      : 1/29/2018 8:10:12 PM -08:00
    LastModifiedBy        :
    Tags                  : {}


    $aa | Get-AzAutomationJobInfo -JobId 0210697a-9752-45e4-a1f0-017eb13a62c2
    {
        "SubscriptionId":  "07de8526-5054-4ba7-9a80-c1fc7b232292",
        "ResourceName":  "myCloudService",
        "ResourceGroupName":  "myResourceGroup",
        "Mode":  "Test",
        "BuildVersion":  "7.3.43.0"
    }


    This command takes the Automation Account information from the pipeline and returns the output stream for the passed JobId
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$AutomationAccountName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string[]]$JobId
    )

    process {
        foreach ($jid in $JobId) {
            Get-AzAutomationJob -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -JobId $jid | 
                Get-AzAutomationJobOutput | Get-AzAutomationJobOutputRecord | Select-Object -ExpandProperty 'Value' | Select-Object -ExpandProperty 'Values'
        }
    }
}
