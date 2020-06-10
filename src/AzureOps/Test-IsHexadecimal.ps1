function Test-IsHexadecimal {
    <#
    .SYNOPSIS
    Tests is the input string is valid hexadecimal
    
    .PARAMETER String
    The string to be validated
    
    .EXAMPLE
    Test-IsHexadecimal -String 12d87f5
    True

    .EXAMPLE
    'ad3','56g' | Test-IsHexadecimal
    True
    False
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Alias('Input')]
        [string[]]$String
    )

    process {
        foreach ($s in $String) {
            Write-Verbose $s
            $s -match "\A\b[0-9a-fA-F]+\b\Z"
        }
    }
}