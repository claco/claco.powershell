BeforeAll {
    Import-Module $PSCommandPath.Replace('.Tests.ps1', '.psm1') -Force

    Import-Module $PSCommandPath\..\..\Testing\Testing.psm1 -Force
}

Describe 'Get-DebugPreference' {
    It 'Returns SilentlyContinue by default' {
        Get-DebugPreference | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Debug parameter is set' {
        Get-DebugPreference -Debug 5>$null | Should -Be Continue
    }

    It 'Returns Continue when $env:DEBUG is set to True' {
        $debug = $env:DEBUG

        try {
            $env:DEBUG = $true

            Get-DebugPreference | Should -Be Continue
        } finally {
            $env:DEBUG = $debug
        }
    }

    It 'Returns Continue when -Debug is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Get-DebugPreference
        }

        TestFunction -Debug | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Debug:$false is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Get-DebugPreference
        }

        TestFunction -Debug:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Debug is passed to calling function and parameter is not defined' {
        function TestFunction {
            param (
            )

            return Get-DebugPreference
        }

        TestFunction -Debug | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Debug:$false is passed to calling function and no parameter is not defined' {
        function TestFunction {
            param (
            )

            return Get-DebugPreference
        }

        TestFunction -Debug:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Debug is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Debug
            )

            return Get-DebugPreference
        }

        TestFunction -Debug | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Debug:$false is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Debug
            )

            return Get-DebugPreference
        }

        TestFunction -Debug:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Invocation.BoundParameters contains Debug' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return $MyInvocation
        }

        Get-DebugPreference -Invocation $(TestFunction -Debug) | Should -Be Continue
    }
}

Describe 'Get-VerbosePreference' {
    It 'Returns SilentlyContinue by default' {
        Get-VerbosePreference | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Verbose parameter is set' {
        Get-VerbosePreference -Verbose 4>$null | Should -Be Continue
    }

    It 'Returns Continue when $env:VERBOSE is set to True' {
        $verbose = $env:VERBOSE

        try {
            $env:VERBOSE = $true

            Get-VerbosePreference | Should -Be Continue
        } finally {
            $env:VERBOSE = $verbose
        }
    }

    It 'Returns Continue when -Verbose is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Get-VerbosePreference
        }

        TestFunction -Verbose | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Verbose:$false is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Get-VerbosePreference
        }

        TestFunction -Verbose:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Verbose is passed to calling function and parameter is not defined' {
        function TestFunction {
            param (
            )

            return Get-VerbosePreference
        }

        TestFunction -Verbose | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Verbose:$false is passed to calling function and no parameter is not defined' {
        function TestFunction {
            param (
            )

            return Get-VerbosePreference
        }

        TestFunction -Verbose:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Verbose is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Verbose
            )

            return Get-VerbosePreference
        }

        TestFunction -Verbose | Should -Be Continue
    }

    It 'Returns SilentlyContinue when -Verbose:$false is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Verbose
            )

            return Get-VerbosePreference
        }

        TestFunction -Verbose:$false | Should -Be SilentlyContinue
    }

    It 'Returns Continue when -Invocation.BoundParameters contains Debug' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return $MyInvocation
        }

        Get-VerbosePreference -Invocation $(TestFunction -Verbose) | Should -Be Continue
    }
}

Describe 'Test-Debug' {
    It 'Returns $false by default' {
        Test-Debug | Should -BeFalse
    }

    It 'Returns $true when -Debug parameter is set' {
        Test-Debug -Debug 5>$null | Should -BeTrue
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

    It 'Returns $true when -Debug is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Test-Debug
        }

        TestFunction -Debug | Should -BeTrue
    }

    It 'Returns $false when -Debug:$false is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Test-Debug
        }

        TestFunction -Debug:$false | Should -BeFalse
    }

    It 'Returns $true when -Debug is passed to calling function and parameter is not defined' {
        function TestFunction {
            param (
            )

            return Test-Debug
        }

        TestFunction -Debug | Should -BeTrue
    }

    It 'Returns $false when -Debug:$false is passed to calling function and no parameter is not defined' {
        function TestFunction {
            param (
            )

            return Test-Debug
        }

        TestFunction -Debug:$false | Should -BeFalse
    }

    It 'Returns $true when -Debug is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Debug
            )

            return Test-Debug
        }

        TestFunction -Debug | Should -BeTrue
    }

    It 'Returns $false when -Debug:$false is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Debug
            )

            return Test-Debug
        }

        TestFunction -Debug:$false | Should -BeFalse
    }

    It 'Returns $true when -Invocation.BoundParameters contains Debug' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return $MyInvocation
        }

        Test-Debug -Invocation $(TestFunction -Debug) | Should -BeTrue
    }
}

Describe 'Test-Verbose' {
    It 'Returns $false by default' {
        Test-Verbose | Should -BeFalse
    }

    It 'Returns $true when -Verbose parameter is set' {
        Test-Verbose -Verbose 5>$null | Should -BeTrue
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

    It 'Returns $true when -Verbose is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Test-Verbose
        }

        TestFunction -Verbose | Should -BeTrue
    }

    It 'Returns $false when -Verbose:$false is passed to calling cmdlet' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return Test-Verbose
        }

        TestFunction -Verbose:$false | Should -BeFalse
    }

    It 'Returns $true when -Verbose is passed to calling function and parameter is not defined' {
        function TestFunction {
            param (
            )

            return Test-Verbose
        }

        TestFunction -Verbose | Should -BeTrue
    }

    It 'Returns $false when -Verbose:$false is passed to calling function and no parameter is not defined' {
        function TestFunction {
            param (
            )

            return Test-Verbose
        }

        TestFunction -Verbose:$false | Should -BeFalse
    }

    It 'Returns $true when -Verbose is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Verbose
            )

            return Test-Verbose
        }

        TestFunction -Verbose | Should -BeTrue
    }

    It 'Returns $false when -Verbose:$false is passed to calling function' {
        function TestFunction {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param (
                [switch] $Verbose
            )

            return Test-Verbose
        }

        TestFunction -Verbose:$false | Should -BeFalse
    }

    It 'Returns $true when -Invocation.BoundParameters contains Verbose' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            return $MyInvocation
        }

        Test-Verbose -Invocation $(TestFunction -Verbose) | Should -BeTrue
    }
}

Describe 'Write-DebugFunctionStart' {
    It 'Writes no debug message by default' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            Write-DebugFunctionStart 5>&1 | Should -BeNullOrEmpty
        }

        TestFunction
    }

    It 'Writes debug message when -Debug is set' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            Write-DebugFunctionStart 5>&1 | Out-String | Should -BeLike '*› TestFunction *'
        }

        TestFunction -Debug
    }
}

Describe 'Write-DebugFunctionEnd' {
    It 'Writes no debug message by default' {
        function TestFunction {
            [CmdletBinding()]
            param ()

            Write-DebugFunctionEnd 5>&1 | Should -BeNullOrEmpty
        }

        TestFunction
    }

    It 'Writes debug message when -Debug is set' {
        function TestFunction {
            [CmdletBinding()]
            param ()

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
            Write-Exception -ErrorRecord $_ 3>&1 | Should -BeStackTrace
        }
    }

    It 'Writes warning message when $ExceptionAction is set to Continue' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception -ErrorRecord $_ -ExceptionAction Continue 3>&1 | Should -BeStackTrace
        }
    }

    It 'Writes error message when $ExceptionAction is not Continue or SilentlyContinue' {
        try {
            throw 'TestException'
        } catch {
            { Write-Exception $_ -ExceptionAction Stop 2>&1 | Out-String } | Should -Throw 'TestException'
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
            Write-Exception $_ 3>&1 | Should -BeStackTrace
        }
    }

    It 'Loads -ErrorRecord from caller when -ErrorRecord is null' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception 3>&1 | Should -BeStackTrace
        }
    }

    It 'Loads -ErrorRecord from pipeline input' {
        try {
            throw 'TestException'
        } catch {
            $_ | Write-Exception 3>&1 | Should -BeStackTrace
        }
    }

    It 'Loads -ErrorRecord from -Exception' {
        try {
            throw 'TestException'
        } catch {
            Write-Exception -Exception $_.Exception 3>&1 | Should -BeStackTrace
        }
    }
}
