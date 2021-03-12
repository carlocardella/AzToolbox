Remove-Module 'ClusterConfig' -Force -ErrorAction 'SilentlyContinue'
Import-Module "$PSScriptRoot/../src/ClusterConfig" -Force -ErrorAction 'Stop'
$PesterPreference = [PesterConfiguration]::Default
$PesterPreference.Should.ErrorAction = 'Continue'
$PesterPreference.CodeCoverage.Enabled = $true
$PesterPreference.Output.Verbosity = 'Detailed'


Describe "ScriptAnalysis" -Tag 'ScriptAnalysis' {
    Context "ScriptAnalysis" -Tag 'ScriptAnalysis' {
        $functionFiles = Get-ChildItem -Path "$PSScriptRoot/../src/ClusterConfig/*.ps1"
        
        It "<functionName> passesScript Analyzer rules" -TestCases @(
            $functionFiles | ForEach-Object {
                @{'functionName' = $_.BaseName; 'filePath' = $_.FullName }
            }
        ) -Test {
            Invoke-ScriptAnalyzer -Path $filePath | Should -BeNullOrEmpty
        }

        It 'Checks <functionName> PS version compatibility'  -TestCases @(
            $functionFiles | ForEach-Object {
                @{'functionName' = $_.BaseName; 'filePath' = $_.FullName }
            }
        ) -Test {
            $settings = @{
                Rules = @{
                    PSUseCompatibleSyntax = @{
                        # This turns the rule on (setting it to false will turn it off)
                        Enable         = $true

                        # List the targeted versions of PowerShell here
                        TargetVersions = @(
                            '5.1',
                            '6.0',
                            '6.1',
                            '6.2',
                            '7.0',
                            '7.0.3',
                            '7.1',
                            '7.2'
                        )
                    }
                }
            }

            Invoke-ScriptAnalyzer -Path $filePath | Should -BeNullOrEmpty
        }

        It 'Checks if <functionName> uses Compatible Commands' -TestCases @(
            $functionFiles | ForEach-Object {
                @{'functionName' = $_.BaseName; 'filePath' = $_.FullName }
            }
        ) -Test {
            $settings = @{
                Rules = @{
                    PSUseCompatibleCommands = @{
                        # Turns the rule on
                        Enable         = $true

                        # Lists the PowerShell platforms we want to check compatibility with
                        TargetProfiles = @(
                            'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',
                            'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                            'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                            'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                            'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework',
                            'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                            'win-8_x64_10.0.14393.0_6.1.3_x64_4.0.30319.42000_core',
                            'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                            'win-48_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                            'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core',
                            'win-8_x64_6.3.9600.0_6.1.3_x64_4.0.30319.42000_core',
                            'rhel_x64_7.6_6.1.3_x64_4.0.30319.42000_core',
                            'macos_x64_18.2.0.0_6.2.0_x64_4.0.30319.42000_core',
                            'debian_x64_9_6.1.3_x64_4.0.30319.42000_core',
                            'azurefunctions',
                            'azureautomation'
                        )
                    }
                }
            }

            Invoke-ScriptAnalyzer -Path $filePath | Should -BeNullOrEmpty
        }
    }
}