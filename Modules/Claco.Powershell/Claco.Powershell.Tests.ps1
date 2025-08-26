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
        BeforeEach {
            $Global:ConfirmPreference = 'None'
            $Global:ProgressPreference = 'SilentlyContinue'

            $RepositoryFolderName = [System.IO.Path]::GetRandomFileName()

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Linter is a bit unaware of Pester scopes')]
            $RepositoryName = "ws.$RepositoryFolderName"

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Linter is a bit unaware of Pester scopes')]
            $RepositoryPath = Join-Path -Path $TestDrive -ChildPath $RepositoryFolderName
        }

        AfterEach {
            Unregister-PSRepository -Name $RepositoryName *>$null

            Get-PSRepository -Name $RepositoryName -OutVariable Repository *>$null

            $Repository | Should -BeNullOrEmpty
        }

        It "Creates a repository in '`$PWD/.PSWorkspaceRepository' by default" {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Intentional here for testing')]
            $PWD = $RepositoryPath

            Test-Path -Path $RepositoryPath | Should -Not -BeTrue

            Initialize-WorkspaceRepository *>$null

            $Repository = Get-PSRepository -Name $RepositoryName
            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $(Join-Path -Path $PWD -ChildPath '.PSWorkspaceRepository')
            $Repository.SourceLocation | Test-Path | Should -BeTrue
        }

        It 'Creates a repository with -Name in -Path' {
            Test-Path -Path $RepositoryPath | Should -Not -BeTrue

            Initialize-WorkspaceRepository -Name $RepositoryName -Path $RepositoryPath *>$null

            $Repository = Get-PSRepository -Name $RepositoryName
            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $RepositoryPath
            $Repository.SourceLocation | Test-Path | Should -BeTrue
        }

        It 'Creates a repository with -Path if it already exists' {
            $RepositoryDirectory = New-Item -Path $RepositoryPath -ItemType Directory
            $RepositoryFile = New-Item -Path $(Join-Path -Path $RepositoryDirectory -ChildPath '.gitkeep') -ItemType File

            Initialize-WorkspaceRepository -Name $RepositoryName -Path $RepositoryPath *>$null

            $Repository = Get-PSRepository -Name $RepositoryName
            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $RepositoryPath
            $Repository.SourceLocation | Test-Path | Should -BeTrue
            $RepositoryFile.Exists | Should -BeTrue
        }

        It 'Recreates repository path when -Force is set' {
            $RepositoryDirectory = New-Item -Path $RepositoryPath -ItemType Directory
            $RepositoryFile = New-Item -Path $(Join-Path -Path $RepositoryDirectory -ChildPath '.gitkeep') -ItemType File

            Initialize-WorkspaceRepository -Name $RepositoryName -Path $RepositoryPath -Force *>$null

            $Repository = Get-PSRepository -Name $RepositoryName
            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $RepositoryPath
            $Repository.SourceLocation | Test-Path | Should -BeTrue
            $RepositoryFile.Exists | Should -BeFalse
            $RepositoryDirectory.GetFiles().Count | Should -Be 0
        }

        It 'Recreates repository when -Force is set' {
            $InitialRepositoryPath = "$RepositoryPath.original"
            $UpdatedRepositoryPath = "$RepositoryPath.updated"

            Initialize-WorkspaceRepository -Name $RepositoryName -Path $InitialRepositoryPath *>$null
            Initialize-WorkspaceRepository -Name $RepositoryName -Path $UpdatedRepositoryPath -Force *>$null

            $Repository = Get-PSRepository -Name $RepositoryName
            $Repository | Should -Not -BeNullOrEmpty
            $Repository.Name | Should -BeExactly $RepositoryName
            $Repository.SourceLocation | Should -BeExactly $UpdatedRepositoryPath
            $Repository.SourceLocation | Test-Path | Should -BeTrue
        }
    }
}

Describe 'Publish-WorkspaceModule' {
    BeforeEach {
        $Global:ProgressPreference = 'SilentlyContinue'

        $RepositoryName = "pester.$([System.IO.Path]::GetRandomFileName())"
        $RepositoryPath = Join-Path -Path $TestDrive -ChildPath $RepositoryName

        Initialize-WorkspaceRepository -Name $RepositoryName -Path $RepositoryPath *>$null
    }

    AfterEach {
        Unregister-PSRepository -Name $RepositoryName
    }

    It 'Publishes module to -Repository' {
        $Module = Publish-WorkspaceModule -Repository $RepositoryName 6>$null
        $Repository = Get-PSRepository -Name $RepositoryName

        $PackageName = "$($Module.Name).$($Module.Version).nupkg"
        $PackageFile = Join-Path -Path $Repository.PublishLocation -ChildPath $PackageName

        $Module | Should -Not -BeNullOrEmpty
        $PackageFile | Test-Path | Should -BeTrue
    }

    It 'Published module can be installed' {
        $Module = Publish-WorkspaceModule -Repository $RepositoryName 6>$null
        $ModulePath = Join-Path -Path $TestDrive -ChildPath $Module.Name -AdditionalChildPath $Module.Version

        $Module | Save-Module -Path $TestDrive

        $ModulePath | Test-Path | Should -BeTrue
    }
}
