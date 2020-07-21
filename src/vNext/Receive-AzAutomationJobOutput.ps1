<#
.SYNOPSIS
    Short description

.PARAMETER AutomationAccountName
    Automation Account Name owning the job to query

.PARAMETER ResourceGroupName
    Resource Group Name containing the Automation Account

.PARAMETER JobId
    Automation Job Id to query

.EXAMPLE
    Receive-AzAutomationJobOutput -AutomationAccountName $aa -ResourceGroupName $rg -JobId 25c6bd75-14e8-4e72-a1b4-0969dac7080a
    [
        {
            "ProfileName":  "MyTrafficManagerProfile",
            "ProfileStatus":  "Enabled",
            "ResourceGroupName":  "Default-TrafficManager",
            "Endpoint":  "myCloudService.cloudapp.net",
            "Priority":  1,
            "Weight":  1,
            "EndpointStatus":  "Disabled",
            "EndpointMonitorStatus":  "Disabled",
            "BuildVersion":  "7.2.2974.0",
            "ApiType":  "ARM"
        },
        {
            "ProfileName":  "MyTrafficManagerProfile",
            "ProfileStatus":  "Enabled",
            "ResourceGroupName":  "Default-TrafficManager",
            "Endpoint":  "myCloudService.cloudapp.net",
            "Priority":  2,
            "Weight":  1,
            "EndpointStatus":  "Enabled",
            "EndpointMonitorStatus":  "Degraded",
            "BuildVersion":  "7.2.2578.0",
            "ApiType":  "ARM"
        }
    ]
#>
function Receive-AzAutomationJobOutput {
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AutomationAccountName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [parameter(Mandatory)]
        [ValidateScript( { [guid]::Parse($_) })]
        [string]$JobId
    )

    Get-AzAutomationJobOutput -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -Id $JobId | Get-AzAutomationJobOutputRecord | Select-Object -ExpandProperty 'Value' | Select-Object -ExpandProperty 'Values'
}
