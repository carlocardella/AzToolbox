if (Get-Module 'AzureOps') { Remove-Module 'AzureOps' -Force }
Import-Module "$PSScriptRoot/../src/AzureOps/"
$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Should.ErrorAction = 'Continue'
$pesterPreference.CodeCoverage.Enabled = $true


Describe 'AzureOps' {
    Context -Name 'Test-IsGuid' -Tag 'TestIsGuid' {
        BeforeAll {
            $guid = 1..5 | ForEach-Object { [Guid]::NewGuid() }
            $notGuid = @('teststring', '234gd', 'asddfghhjk234567.', '123345456568', 'a1b2c3')
        }

        It 'Can validate a GUID' {
            # parameter
            { Test-Guid -Guid $guid } | Should -Not -Throw
            { Test-Guid -Guid $notGuid } | Should -Not -Throw
            
            Test-Guid -Guid $guid | Should -BeTrue
            Test-Guid -Guid $notGuid | Should -BeFalse
            
            # pipeline
            { $guid | Test-Guid } | Should -Not -Throw
            { $notGuid | Test-Guid } | Should -Not -Throw
            
            $guid | Test-Guid | Should -BeTrue
            $notGuid | Test-Guid | Should -BeFalse
        }
    }

    Context -Name 'Unprotect-SecureString' -Tag 'UnprotectSecureString' {
        BeforeAll {
            $secureString = ConvertTo-SecureString -AsPlainText -Force 'this is a secure string'
            $plainTextString = 'this is a plain text string'
        }

        It 'Can return a SecreString as plain text' {
            { Unprotect-SecureString -SecureString $secureString } | Should -Not -Throw
            { Unprotect-SecureString -SecureString $plainTextString } | Should -Throw
            
            Unprotect-SecureString -SecureString $secureString | Should -BeExactly 'this is a secure string' -Because 'strings match'
            { Unprotect-SecureString -SecureString $plainTextString } | Should -Throw 'Cannot process argument transformation on parameter ''SecureString''. Cannot convert the "this is a plain text string" value of type "System.String" to type "System.Security.SecureString".'
        }
    }

    Context -Name 'Test-IsHexadecimal' -Tag 'TestIsHexadecimal' {
        BeforeAll {
            $hexadecimal = @('10FA', 'ab45', 'cc45fd')
            $notHex = @('10ZZ', 'xf5', 'test')
        }

        It 'Validates an hexadecimal string' {
            # parameter
            { Test-IsHexadecimal -String $hexadecimal } | Should -Not -Throw
            { Test-IsHexadecimal -String $notHex } | Should -Not -Throw
            Test-IsHexadecimal -String $hexadecimal | Should -BeTrue
            Test-IsHexadecimal -String $notHex | Should -BeFalse
            
            # pipeline
            { $hexadecimal | Test-IsHexadecimal } | Should -Not -Throw
            { $notHex  | Test-IsHexadecimal } | Should -Not -Throw
            $hexadecimal | Test-IsHexadecimal  | Should -BeTrue
            $notHex | Test-IsHexadecimal | Should -BeFalse
        }
    }
}