#Requires -Modules Pester, PSScriptAnalyzer

function Invoke-Lint {
    [CmdletBinding()]
    [OutputType([void])]
    param (
    )

    Write-DebugFunctionStart

    try {
        Write-Debug "PWD=$($PWD)"

        Invoke-ScriptAnalyzer -Path $PWD -Recurse -Settings $PSScriptRoot/PSScriptAnalyzerSettings.psd1
    } catch {
        # these are all the same
        # $_ | Write-Exception
        # Write-Exception
        # Write-Exception $_
        # Write-Exception -ErrorRecord $_
        # Write-Exception -Exception $_.Exception

        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }

}

function Invoke-Test {
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

Export-ModuleMember
