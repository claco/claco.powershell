#Requires -Modules Pester, PSScriptAnalyzer

<#
.SYNOPSIS
Invokes PSScriptAnalyzer for the current project.

.DESCRIPTION
The Invoke-Lint function runs a linting process, typically used to analyze code for potential errors, stylistic issues, or best practices violations.

.PARAMETER Path
Specifies the path to the directory or file to be analyzed. Defaults to the current working directory ($PWD).
If a directory is specified, the function will recursively analyze all files within that directory.

.PARAMETER Settings
Specifies the path to the PSScriptAnalyzer settings file. Defaults to "$PSScriptRoot/PSScriptAnalyzerSettings.psd1".
This file contains configuration settings for the linting process.

.INPUTS
String (Path)
Property of type Object (Path)

.OUTPUTS
[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.SuppressedRecord]

.EXAMPLE
Invoke-Lint

.EXAMPLE
Invoke-Lint -Path "C:\MyProject" -Settings "C:\MySettings.psd1"

'C:\MyProject' | Invoke-Lint

.EXAMPLE
Invoke-Lint -Path ".\Modules\Claco.Powershell\Claco.Powershell.psm1"
#>
function Invoke-Lint {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord], [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.SuppressedRecord])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]] $Path = $PWD,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string] $Settings = $(Join-Path -Path $PSScriptRoot -ChildPath 'PSScriptAnalyzerSettings.psd1')
    )

    begin {
        $Results = @()
    }

    process {
        try {
            Write-DebugFunctionStart

            $Debug = Test-Debug

            foreach ($LintingPath in $Path) {
                $LintingPath = Resolve-Path -Path $LintingPath -Relative

                if (Test-Path -Path $Settings) {
                    $Settings = Resolve-Path -Path $Settings -Relative

                    Write-Host "Linting '$LintingPath' with settings '$Settings'." -ForegroundColor Magenta

                    $Result = Invoke-ScriptAnalyzer -Path $LintingPath -Recurse -Settings $Settings -Verbose:$Debug -Debug:$Debug -Confirm:$false
                } else {
                    Write-Warning "Linting settings file '$Settings' not found."

                    $Result = Invoke-ScriptAnalyzer -Path $LintingPath -Recurse -Verbose:$Debug -Debug:$Debug -Confirm:$false
                }

                if ($Result.Count -gt 0) {
                    Write-Host "$($Result.Count) issue(s) detected." -ForegroundColor Yellow

                    $Results += $Result
                } else {
                    Write-Host 'No issues detected.' -ForegroundColor Green
                }
            }
        } catch {
            Write-Host 'Linting failed unexpectedly!' -ForegroundColor Red

            Write-Exception
        } finally {
            Write-DebugFunctionEnd
        }
    }

    end {
        return $Results
    }
}

<#
.SYNOPSIS
Invokes Pester tests for the current project.

.PARAMETER Configuration
Specifies the path to the Pester configuration file. Defaults to "$PSScriptRoot\PesterConfiguration.psd1".
This file contains configuration settings for the Pester testing process.

.PARAMETER Cover
When specified, enables code coverage analysis during the Pester test run.

.PARAMETER Report
When specified, enables test result reporting in JUnit XML format.

.INPUTS
None. You cannot pipe objects to Invoke-Test.

.OUTPUTS
None. This function does not generate any output.

.EXAMPLE
Invoke-Test

.EXAMPLE
Invoke-Test -Configuration "C:\MyPesterConfig.psd1" -Cover -Report
#>
function Invoke-Test {
    # [ExcludeFromCodeCoverageAttribute()] #coming in Pester 6 https://pester.dev/docs/v6/usage/code-coverage#excluding-functions-from-coverage
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string] $Configuration = $(Join-Path -Path $PSScriptRoot -ChildPath 'PesterConfiguration.psd1'),

        [switch] $Cover,
        [switch] $Report
    )

    try {
        Write-DebugFunctionStart

        Import-Module Pester

        $Debug = Test-Debug
        $PesterConfiguration = [PesterConfiguration]::Default

        if (Test-Path -Path $Configuration) {
            Write-Verbose "Loading PesterConfiguration file '$Configuration'..."

            $PesterConfiguration = [PesterConfiguration]$(Import-PowerShellDataFile -Path $Configuration)
        } else {
            Write-Warning "PesterConfiguration file '$Configuration' not found."
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
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

Export-ModuleMember -Function Invoke-Lint, Invoke-Test
