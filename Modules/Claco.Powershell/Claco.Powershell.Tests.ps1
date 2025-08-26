BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1')
}

InModuleScope Claco.Powershell {
    Describe 'Invoke-Lint' {
        It 'Loads PSScriptAnalyzerSettings.psd1 if it exists' {
            Mock -CommandName Invoke-ScriptAnalyzer `
                -ParameterFilter { $Settings -like '*PSScriptAnalyzerSettings.psd1' }

            Invoke-Lint *>$null | Should -Invoke -CommandName Invoke-ScriptAnalyzer -Times 1 -Exactly
        }

        It 'Does not throw exceptions by default' {
            Mock -CommandName Invoke-ScriptAnalyzer -MockWith { throw 'TestException' }

            { Invoke-Lint *>$null  } | Should -Not -Throw
        }

        It 'Writes exception to Warning stream by default' {
            Mock -CommandName Invoke-ScriptAnalyzer -MockWith { throw 'TestException' }

            Invoke-Lint -WarningVariable Warnings *>$null

            $Warnings | Out-String | Should -BeStackTrace
        }
    }
}
