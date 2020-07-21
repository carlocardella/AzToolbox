function Get-AzAutomationJobOutputStream {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$AutomationAccountName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$JobId
    )

    $aa = $null
    $aa = Get-AzAutomationAccount -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName

    if ($aa) {
        $aa | Get-AzAutomationJob -Id $JobId | Get-AzAutomationJobOutput | Get-AzAutomationJobOutputRecord | Select-Object -ExpandProperty 'Value'
    }
}