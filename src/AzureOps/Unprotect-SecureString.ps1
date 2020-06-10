function Unprotect-SecureString {
    <#
    .SYNOPSIS
    Converts a SecureString object to its original, unencrypted value. 

    .PARAMETER SecureString
    The SecureString object to unencrypt

    .EXAMPLE
    Unprotect-SecureString -SecureString $encryptedString
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [SecureString]$SecureString
    )

    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
}
