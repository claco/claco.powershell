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

    return
}

<#
    .SYNOPSIS
    Publishes the current workspace module to the workspace repository created by Initialize-WorkspaceRepository.

    .DESCRIPTION
    The Publish-WorkspaceModule cmdlet packages and publishes the current PowerShell module to the workspace
    repository created by Initialize-WorkspaceRepository. Publish-Module is used to upload the module package to
    the repository and the results of Publish-Module are returned.

    .PARAMETER Repository
    Specifies the name of the PowerShell repository to which the module will be published. Defaults to
    'ws.<CurrentDirectoryName>'. For example, if the current directory is 'MyProject', the default repository name
    will be 'ws.MyProject'.

    .PARAMETER Force
    If specified, forces the publication by deleting any existing package with the same name and version in
    the repository before publishing the new package. This is useful for local file share repositories where
    overwriting existing packages is not allowed.

    .INPUTS
    None. You cannot pipe objects to Publish-WorkspaceModule.

    .OUTPUTS
    [PSCustomObject] The module object returned by Find-Module after publishing.

    .EXAMPLE
    Publish-WorkspaceModule
    Publish-WorkspaceModule -Repository $(InitializedRepository).Name

    .NOTES
    You may publish to any NuGet repository using the -Repository parameter. However, the use of -Force assumes
    the repository is a local file share and will attempt to delete any existing package with the same name and
    version using Remove-Item before publishing the new package.
#>
function Publish-WorkspaceModule {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0)]
        [string] $Repository = "ws.$(Split-Path -Path $PWD -Leaf)",

        [switch] $Force
    )

    try {
        Write-DebugFunctionStart

        $Module = $null
        $ModuleName = $MyInvocation.MyCommand.ModuleName
        $ModuleVersion = $MyInvocation.MyCommand.Module.Version
        $PackageName = "$($ModuleName).$($ModuleVersion).nupkg"

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        Write-Debug "ModuleName=$ModuleName"
        Write-Debug "ModuleVersion=$ModuleVersion"
        Write-Debug "PackageName=$PackageName"
        Write-Debug "ConfirmPreference=$ConfirmPreference"
        Write-Debug "WhatIfPreference=$WhatIfPreference"

        if ($PSCmdlet.ShouldProcess($Repository, $PackageName)) {
            Write-Host "Publishing module '$PackageName' to repository '$Repository'..." -ForegroundColor DarkGreen

            if ($Force) {
                $RepositorySourceLocation = $(Get-PSRepository -Name $Repository).SourceLocation
                $PackagePath = Join-Path -Path $RepositorySourceLocation -ChildPath $PackageName

                Write-Debug "RepositorySourceLocation=$RepositorySourceLocation"
                Write-Debug "PackagePath=$PackagePath"

                if (Test-Path -Path $PackagePath) {
                    Write-Verbose "-Force is set. Deleting repository package '$PackagePath'."

                    Remove-Item -Path $PackagePath -Force:$Force
                }
            }

            Publish-Module -Path $PSScriptRoot -Repository $Repository

            $Module = Find-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository $Repository
        }
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }

    return $Module
}

<#
    .SYNOPSIS
    Initializes a local PowerShell module repository in the current working directory.

    .DESCRIPTION
    The Initialize-WorkspaceRepository cmdlet creates a local PowerShell module repository in the current working
    directory. This repository can be used to store and manage PowerShell modules for development and testing
    purposes, allowing you to easily publish and retrieve modules within your workspace.

    .PARAMETER Name
    Specifies the name of the PowerShell repository to create. Defaults to 'ws.<CurrentDirectoryName>'.
    For example, if the current directory is 'MyProject', the default repository name will be 'ws.MyProject'.

    .PARAMETER Path
    Specifies the path where the repository will be created. Defaults to a hidden directory named after the
    repository (e.g., '.PSWorkspaceRepository') in the current working directory.

    .PARAMETER Force
    If specified, forces the recreation of the repository if it already exists.

    .PARAMETER Trusted
    If specified, sets the repository's installation policy to 'Trusted'. By default, the installation policy is
    set to 'UnTrusted'.

    .INPUTS
    None. You cannot pipe objects to Initialize-WorkspaceRepository.

    .OUTPUTS
    [PSCustomObject] The repository object returned by Get-PSRepository after creation.

    .EXAMPLE
    $Repository = Initialize-WorkspaceRepository
    Publish-WorkspaceModule -Repository $Repository.Name

    .EXAMPLE
    Initialize-WorkspaceRepository -Name 'MyRepo' -Path 'C:\MyRepo' -Force
#>
function Initialize-WorkspaceRepository {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0)]
        [string] $Name = "ws.$(Split-Path -Path $PWD -Leaf)",

        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 1)]
        [string] $Path = $(Join-Path -Path $PWD -ChildPath '.PSWorkspaceRepository'),

        [switch] $Force,

        [switch] $Trusted
    )

    try {
        Write-DebugFunctionStart

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        Write-Debug "ConfirmPreference=$ConfirmPreference"
        Write-Debug "WhatIfPreference=$WhatIfPreference"
        Write-Debug "Name=$Name"
        Write-Debug "Path=$Path"
        Write-Debug "Force=$Force"
        Write-Debug "PassThru=$PassThru"
        Write-Debug "Trusted=$Trusted"

        if ($PSCmdlet.ShouldProcess($Path)) {
            Write-Host "Initializing workspace repository '$Name' in '$Path'..." -ForegroundColor DarkGreen

            if (Test-Path -Path $Path) {
                Write-Verbose "Workspace repository path '$Path' exists."

                if ($Force) {
                    Write-Verbose "-Force is set. Recreating repository path '$Path'."

                    Remove-Item -Path $Path -Recurse -Force -ProgressAction SilentlyContinue | Out-Null
                    New-Item -Path $Path -ItemType Directory | Out-Null
                }
            } else {
                Write-Verbose "Creating repository path '$Path'."

                New-Item -Path $Path -ItemType Directory | Out-Null
            }

            $InstallationPolicy = $Trusted ? 'Trusted' : 'UnTrusted'

            Get-PSRepository -Name $Name -OutVariable Repository *>&1 | Out-Null
            if ($Repository) {
                Write-Verbose "Workspace repository '$Name' exists."

                if ($Force) {
                    Write-Verbose "-Force is set. Recreating repository '$Name' with path '$Path'."

                    Unregister-PSRepository -Name $Name
                    Write-Host $(Register-PSRepository -Name $Name -SourceLocation $Path -ScriptSourceLocation $Path -InstallationPolicy $InstallationPolicy) -Verbose
                }
            } else {
                Write-Verbose "Creating repository '$Name' with path '$Path'."

                Register-PSRepository -Name $Name -SourceLocation $Path -ScriptSourceLocation $Path -InstallationPolicy $InstallationPolicy
            }

            return Get-PSRepository -Name $Name
        }
    } catch {
        Write-Exception -ExceptionAction Stop
    } finally {
        Write-DebugFunctionEnd
    }

    return
}

Export-ModuleMember -Function Initialize-WorkspaceRepository
Export-ModuleMember -Function Invoke-Lint, Invoke-Test
Export-ModuleMember -Function Publish-WorkspaceModule

$script:ExceptionAction = 'Continue'
