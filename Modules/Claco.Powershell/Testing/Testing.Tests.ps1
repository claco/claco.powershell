BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1') -Force

    $script:StackTraceOutput = @(
        '┈┈ Exception StackTrace ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈'
        'at TestException, /workspaces/claco.powershell/Modules/Claco.Powershell/Testing/Testing.Tests.ps1:13'
        'at Assert-ContainsStackTrace $StackTraceOutput | Should -Be, /workspaces/claco.powershell/Modules/Claco.Powershell/Testing/Testing.Tests.ps1:13'
        'at /workspaces/claco.powershell/Modules/Claco.Powershell/Testing/Testing.Tests.ps1:13'
        '┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈'
    )
}

Describe 'Assert-ContainsStackTrace' {
    It "Succeeds when message contains 'Exception StackTrace' and function 'TestException'" {
        (Assert-ContainsStackTrace $script:StackTraceOutput).Succeeded | Should -BeTrue
    }

    It "Succeeds when message contains 'Exception StackTrace' and -WithFunctionName" {
        (Assert-ContainsStackTrace $script:StackTraceOutput -WithFunctionName Assert-ContainsStackTrace).Succeeded | Should -BeTrue
    }

    It 'Supports -Negate to verify message does not contain stack trace' {
        (Assert-ContainsStackTrace $script:StackTraceOutput -WithFunctionName Invoke-NonExistingFunction -Negate).Succeeded | Should -BeTrue
    }

    It 'Accepts scalar input in addition to array input' {
        $ScalarInput = $script:StackTraceOutput | Out-String
        (Assert-ContainsStackTrace $ScalarInput).Succeeded | Should -BeTrue
    }

    It 'Fails when message does not contain stack trace' {
        $AssertResult = Assert-ContainsStackTrace $script:StackTraceOutput -WithFunctionName Invoke-NonExistingFunction

        $AssertResult.Succeeded | Should -BeFalse
        $AssertResult.FailureMessage | Should -BeLike "Expected message to contain 'Exception StackTrace' header and 'Invoke-NonExistingFunction', but got*"
    }
}
