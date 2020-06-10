function Test-Json {
    <#
    .SYNOPSIS
    Tests if the passed string is valid JSON; returns $true or $false
    
    .PARAMETER Json
    The string to validate; this can be multiline, for example the content of a file
    
    .EXAMPLE
    Get-Content -Path C:\temp\myfile.json | Test-Json

    True
    
    .NOTES
    General notes
    # https://stackoverflow.com/a/57092959/9335336
    #>
    [CmdletBinding()]
    param (
        [parameter(mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        $Json
    )

    $jsonString = $Json -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/' -join ' '
    Microsoft.PowerShell.Utility\Test-Json -Json $jsonString
}