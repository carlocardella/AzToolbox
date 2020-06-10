function Update-StringInFile {
    <#
    .SYNOPSIS
    Updates (replaces) all occurrences of a given string in a file with a new value; the file is overwritten in place

    .PARAMETER FilePath
    Path to the file to update

    .PARAMETER OldString
    String to replace with $NewString

    .PARAMETER NewString
    New string to use as replacement for $OldString

    .PARAMETER MatchCase
    Treat $OldString as case sensitive

    .PARAMETER Force
    Suppress confirmation prompt

    .EXAMPLE
    Update-StringInFile -FilePath c:\temp\myfile.txt -OldString 'replace me!' -NewString 'new value'

    This command replaces all occurrences of OldString with NewString in c:\temp\myfile.txt

    .EXAMPLE
    dir c:\temp\*.txt | Update-StringInFile -OldString 'replace me!' -NewString 'new value'

    This command replaces OldString with NewString in all files received from the pipeline
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'outputfolder')]
    param(
        [parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Fullname', 'Path')]
        [ValidateScript( { if (!(Test-Path -Path $_)) { throw "Invalid path: $_" } })]
        [ValidateScript( { if (!(Test-Path -Path $_ -PathType 'Leaf')) { throw "FilePath must be a file: $_" } })]
        [string[]]$FilePath,

        [parameter(Mandatory, Position = 1)]
        [string]$OldString,

        [parameter(Mandatory, Position = 2)]
        [string]$NewString,

        [parameter()]
        [switch]$MatchCase,

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($file in $FilePath) {
            Write-Verbose -Message "Working on $file"
            [bool]$updateFile = $false

            if (Select-String -Path $file -Pattern $OldString -CaseSensitive:$MatchCase -SimpleMatch) {
                Write-Verbose "Match found"
                $updateFile = $true
            }
            else {
                Write-Verbose "No match found, skipping"
                continue
            }

            $newContent = $null
            $oldContent = Get-Content -Path $file

            if ($MatchCase) {
                $newContent = $oldContent.Replace($OldString, $NewString)
            }
            else {
                $newContent = $oldContent | ForEach-Object { $_.replace($OldString, $NewString) }
            }

            if ($updateFile -and $PSCmdlet.ShouldProcess("$file", "Overwrite file")) {
                if ($updateFile -and ($Force -or ($PSCmdlet.ShouldContinue("Overwrite $file?", "Overwriting $file")))) {
                    Write-Verbose -Message "Updating $file"
                    Set-Content -Path $file -Value $newContent -Force
                }
                else {
                    $newContent
                }
            }
        }
    }
}
