[CmdletBinding(DefaultParameterSetName = 'patch')]
param (
    [parameter(ParameterSetName = 'major')]
    [switch]$Major,

    [parameter(ParameterSetName = 'minor')]
    [switch]$Minor,

    [parameter(ParameterSetName = 'patch')]
    [switch]$Patch
)

if ((Get-Module -ListAvailable 'Pester').Version.Major -notcontains 5) {
    Install-Module -Name 'Pester' -Force -AcceptLicense -AllowClobber -SkipPublisherCheck -Repository 'PSGallery' -Verbose -MinimumVersion '5.0.0.0' -ErrorAction 'Stop'
}

Import-Module -Name 'Pester' -MinimumVersion $([System.Version]::new(5, 0)) -ErrorAction 'Stop'

Invoke-Pester -Path "$PSScriptRoot/Tests/" -Output Detailed -CI -PassThru
