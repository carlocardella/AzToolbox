Remove-Module 'AzToolbox' -Force -ErrorAction 'SilentlyContinue'
Import-Module $PSScriptRoot/../src/AzToolbox -Force -ErrorAction 'Stop'
$PesterPreference = [PesterConfiguration]::Default
$PesterPreference.Should.ErrorAction = 'Continue'
$PesterPreference.CodeCoverage.Enabled = $true
$PesterPreference.Output.Verbosity = 'Detailed'


Describe 'CheckHelp' {
    Context "Help" -Tag 'CheckHelp' {
        # this initialization must be at the Context level, otherwise $functionNames will be out of scope for -TestCases
        $functionsList = (Get-Command -Module 'AzToolbox' | Where-Object -FilterScript { $_.CommandType -eq 'Function' }).Name
        $functionNames = $functionsList | ForEach-Object {
            @{'functionName' = $_ }
        }

        It "Checks if <functionName> has proper help" -TestCases $functionNames -Test {
            $help = Get-Help -Name $functionName -Full
            $ast = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content function:\$functionName), [ref]$null, [ref]$null)
            $astParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath

            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Examples.Count | Should -BeGreaterThan 0
            ($help.parameters.parameter | Where-Object 'Name' -NotIn @('WhatIf', 'Confirm')).Count | Should -Be $astParameters.Count
        }

        It "Checks if each parameter in <functionName> has a .PARAMETER block" -TestCases $functionNames -Test {
            $help = Get-Help -Name $functionName -Full
            $parameters = $help.Parameters.parameter | Where-Object 'Name' -NotIn @('WhatIf', 'Confirm')

            foreach ($parameter in $parameters) {
                $parameter.description | Should -Not -BeNullOrEmpty
            }
        }

        It 'Checks if <functionName> has tests available' -TestCases $functionNames -Test {
            $testFiles = (Get-ChildItem -Path "$PSScriptRoot/../Tests" -Filter '*.Tests.ps1').Name -replace '.tests.ps1', ''

            $functionName -in $testFiles | Should -BeTrue
        }
    }
}