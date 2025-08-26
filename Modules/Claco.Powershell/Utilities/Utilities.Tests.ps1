BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1') -Force
}

Describe 'Get-DebugPreference' {
    It 'Returns SilentlyContinue by default' {
        Get-DebugPreference | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Debug is passed' {
        Get-DebugPreference -Debug | Should -Be Continue
    }
}

Describe 'Get-VerbosePreference' {
    It 'Returns SilentlyContinue by default' {
        Get-VerbosePreference | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Verbose is passed' {
        Get-VerbosePreference -Verbose | Should -Be Continue
    }
}

Describe 'Test-Debug' {
    It 'Returns $false by default' {
        Test-Debug | Should -BeFalse
    }

    It 'Returns $true when -Debug is passed' {
        Test-Debug -Debug | Should -BeTrue
    }

    It 'Returns $true when $env:DEBUG is set to True' {
        $debug = $env:DEBUG

        try {
            $env:DEBUG = $true

            Test-Debug | Should -BeTrue
        } finally {
            $env:DEBUG = $debug
        }
    }

    It 'Returns $true when BoundParameters contains Debug' {
        $MyInvocation.BoundParameters.Add('Debug', '')

        Test-Debug -Invocation $MyInvocation | Should -BeTrue
    }
}

Describe 'Test-Verbose' {
    It 'Returns $false by default' {
        Test-Verbose | Should -BeFalse
    }

    It 'Returns $true when -Verbose is passed' {
        Test-Verbose -Verbose | Should -BeTrue
    }

    It 'Returns $true when $env:VERBOSE is set to True' {
        $verbose = $env:VERBOSE

        try {
            $env:VERBOSE = $true

            Test-Verbose | Should -BeTrue
        } finally {
            $env:VERBOSE = $verbose
        }
    }

    It 'Returns $true when BoundParameters contains Verbose' {
        $MyInvocation.BoundParameters.Add('Verbose', '')

        Test-Verbose -Invocation $MyInvocation | Should -BeTrue
    }
}
Describe 'Write-DebugFunctionStart' {
    It 'Writes no debug message by default' {
        function TestFunction {
            Write-DebugFunctionStart 5>&1 | Should -BeNullOrEmpty
        }

        TestFunction
    }

    It 'Writes debug message when -Debug is set' {
        function TestFunction {
            Write-DebugFunctionStart 5>&1 | Out-String | Should -BeLike '*› TestFunction *'
        }

        TestFunction -Debug
    }
}

Describe 'Write-DebugFunctionEnd' {
    It 'Writes no debug message by default' {
        function TestFunction {
            Write-DebugFunctionEnd 5>&1 | Should -BeNullOrEmpty
        }

        TestFunction
    }

    It 'Writes debug message when -Debug is set' {
        function TestFunction {
            Write-DebugFunctionEnd 5>&1 | Out-String | Should -BeLike '*‹ TestFunction *'
        }

        TestFunction -Debug
    }
}
Describe 'Write-Exception' {
    It 'Writes warning message by default' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception -ErrorRecord $_ 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*'
        }
    }

    It 'Writes warning message when $ExceptionAction is set to Continue' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception -ErrorRecord $_ -ExceptionAction Continue 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*TestException*'
        }
    }

    It 'Writes error message when $ExceptionAction is not Continue or SilentlyContinue' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception $_ -ExceptionAction Ignore 2>&1 | Out-String | Should -BeLike '*TestException*'
        }
    }

    It 'Writes no error or warning messages when $ExceptionAction is SilentlyContinue' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception $_ -ExceptionAction SilentlyContinue 2>&1 | Out-String | Should -BeNullOrEmpty
        }
    }

    It 'Loads -ErrorRecord from positional arguments' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception $_ 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*'
        }
    }

    It 'Loads -ErrorRecord from caller when -ErrorRecord is null' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*'
        }
    }

    It 'Loads -ErrorRecord from pipeline input' {
        try {
            throw 'TestException'
        } catch {
            $_ | Write-Exception 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*'
        }
    }

    It 'Loads -ErrorRecord from -Exception' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception -Exception $_.Exception 3>&1 | Out-String | Should -BeLike '*Exception StackTrace*'
        }
    }
}
