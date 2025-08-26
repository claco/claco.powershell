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

    Describe 'Initialize-WorkspaceRepository' {
        BeforeAll {
            $RepositoryName = [System.IO.Path]::GetRandomFileName()

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            $RepositoryPath = Join-Path -Path $TestDrive -ChildPath $RepositoryName
        }

        It 'Creates a workspace repository in -Path' {
            Initialize-WorkspaceRepository -Name $RepositoryName -Path $RepositoryPath

            $Repository = Get-PSRepository -Name $RepositoryName

            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $RepositoryPath
        }

        AfterAll {
            Unregister-PSRepository -Name $RepositoryName *>&1 | Out-Null

            Get-PSRepository -Name $RepositoryName -OutVariable Repository *>&1 | Out-Null

            $Repository | Should -BeNullOrEmpty
        }
    }
}
