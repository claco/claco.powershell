#Requires -Modules Pester, PSScriptAnalyzer

function Invoke-Lint {
    [CmdletBinding()]
    [OutputType([void])]
    param (
    )

    try {
        Write-DebugFunctionStart

        Invoke-ScriptAnalyzer -Path $PWD -Recurse -Settings $PSScriptRoot/PSScriptAnalyzerSettings.psd1
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }

}

function Invoke-Test {
    # [ExcludeFromCodeCoverageAttribute()] #coming in Pester 6 https://pester.dev/docs/v6/usage/code-coverage#excluding-functions-from-coverage
    [CmdletBinding(DefaultParameterSetName = 'File')]
    [OutputType([void])]
    param (
        [Parameter(ParameterSetName = 'File')]
        [string] $Configuration = "$PSScriptRoot\PesterConfiguration.psd1",

        [switch] $Cover,
        [switch] $Report
    )

    $Debug = Test-Debug -Invocation $MyInvocation

    Import-Module Pester

    $PesterConfiguration = [PesterConfiguration]::Default

    if ($PSCmdlet.ParameterSetName -eq 'File') {
        if (Test-Path -Path $Configuration) {
            Write-Verbose "Loading PesterConfiguration file '$Configuration'..."

            $PesterConfiguration = [PesterConfiguration]$(Import-PowerShellDataFile -Path $Configuration)
        } else {
            Write-Warning "PesterConfiguration file '$Configuration' not found."
        }
    }

    if ($Cover) {
        $PesterConfiguration.CodeCoverage.Enabled = $true
    }

    if ($Debug) {
        $PesterConfiguration.Debug.WriteDebugMessages = $true
        $PesterConfiguration.Output.Verbosity = 'Diagnostic'
    }

    if ($Report) {
        $PesterConfiguration.TestResult.Enabled = $True
        $PesterConfiguration.TestResult.OutputFormat = 'JUnitXml'
    }

    Invoke-Pester -Configuration $PesterConfiguration
}

function Invoke-TestFunction {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
    )

    try {
        Write-DebugFunctionStart
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

Export-ModuleMember

function Invoke-Example {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'None')]
    [OutputType([void])]
    param (
        [switch] $Force
    )

    try {
        Write-DebugFunctionStart

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        Write-Debug "ConfirmPreference=$ConfirmPreference"
        Write-Debug "WhatIfPreference=$WhatIfPreference"

        if ($PSCmdlet.ShouldProcess('Invoke-Example', 'Call')) {
            Write-Host 'Running example...' -ForegroundColor DarkGreen
        }
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }

    return
}
