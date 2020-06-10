<#
.SYNOPSIS
Tests if the passed string is a valid GUID; returns $true or $false

.PARAMETER Guid
The string to validate

.EXAMPLE
Test-Guid -Guid '3845035f-a303-4e21-b2a5-f9218764a0e1'

Tests the passed string (a valid GUID in this example) and returns $true or $false accordingly

.EXAMPLE
'string1','test','3845035f-a303-4e21-b2a5-f9218764a0e1' | Test-Guid
False
False
True

Tests the strings passed down the pipeline and returns $true or $false accordingly
#>
function Test-Guid {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true, position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Guid
    )

    process {
        foreach ($g in $Guid) {
            Write-Verbose $g
            try {
                [System.Guid]::Parse($g) | Out-Null
                $true
            }
            catch {
                $false
            }
        }
    }
}


