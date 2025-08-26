Import-Module $(Join-Path -Path $PSScriptRoot -ChildPath '..\Utilities\Utilities.psm1')

<#
    .SYNOPSIS
    A simple example function demonstrating the use of common parameters like -WhatIf, -Force, and -Confirm.

    .DESCRIPTION
    The Invoke-SimpleExample function is a basic example that showcases how to implement common parameters such
    as -WhatIf, -Force, and -Confirm in a PowerShell functions that may perform destructive actions or require user
    confirmation. It includes error handling and debug messages to illustrate best practices.

    .PARAMETER Force
    A switch parameter that, when specified, forces the operation to proceed without prompting for confirmation
    irrespective of the current $ConfirmPreference.

    .INPUTS
    None. You cannot pipe objects to Invoke-SimpleExample.

    .OUTPUTS
    None. This function does not generate any output.

    .EXAMPLE
    Invoke-SimpleExample
    Invoke-SimpleExample -Confirm
    Invoke-SimpleExample -Debug
    Invoke-SimpleExample -Force
    Invoke-SimpleExample -Verbose
    Invoke-SimpleExample -WhatIf

    .NOTES
    This cmdlet has its ConfirmImpact set to 'Low'.

    If $ConfirmPreference is set to 'None', no confirmation prompt will be shown by default, unless -Confirm is set.
    If $ConfirmPreference is set to 'Low', a confirmation prompt will be shown by default, unless -Confirm:$false or -Force is set.
    if $ConfirmPreference is set to 'Medium', no confirmation prompt will be shown by default, unless -Confirm is set.
    if $ConfirmPreference is set to 'High', no confirmation prompt will be shown by default, unless -Confirm is set.
#>
function Invoke-SimpleExample {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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

        if ($PSCmdlet.ShouldProcess('Invoke-SimpleExample', 'Process')) {
            Write-Host 'Running Invoke-SimpleExample...' -ForegroundColor DarkGreen
        }
    } catch {
        Write-Exception -ExceptionAction Stop
    } finally {
        Write-DebugFunctionEnd
    }

    return
}

<#
    .SYNOPSIS
    A simple example function demonstrating the use of pipeline processing.

    .DESCRIPTION
    The Invoke-PipelineExample function is a basic example that showcases how to implement pipeline processing in
    a PowerShell function. It includes error handling and debug messages to illustrate best practices.

    .PARAMETER Path
    A path, or list of paths to process. Defaults to `$PWD`

    .INPUTS
    String (Path)
    Property of type Object (Path)

    .OUTPUTS
    String

    .EXAMPLE
    Invoke-PipelineExample
    Invoke-PipelineExample -Path $PWD
    Invoke-PipelineExample -Path Modules,Tests
    @('Modules', 'Tests') | Invoke-PipelineExample
#>
function Invoke-PipelineExample {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'None')]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [ValidateScript({ $_.Count -gt 0 })]
        [string[]] $Path = $PWD
    )

    begin {
        Write-DebugFunctionStart

        Write-Host 'Running Invoke-PipelineExample...' -ForegroundColor DarkGreen

        [PSCustomObject[]] $Results = @()
    }

    process {
        try {
            foreach ($ProcessingPath in $Path) {
                if ($PSCmdlet.ShouldProcess($ProcessingPath, 'Process')) {

                    Write-Host "Processing '$ProcessingPath'..." -ForegroundColor Magenta -NoNewline

                    $Result = [PSCustomObject]@{
                        Input  = $ProcessingPath
                        Path   = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ProcessingPath)
                        Exists = Test-Path -Path $ProcessingPath
                    }

                    if ($Result.Exists) {
                        Write-Host 'Exists!' -ForegroundColor Green
                    } else {
                        Write-Host 'Not Found!' -ForegroundColor Yellow
                    }

                    $Results += $Result
                }
            }
        } catch {
            Write-Host 'Processing failed unexpectedly!' -ForegroundColor Red

            Write-Exception
        }
    }

    end {
        Write-DebugFunctionEnd

        return [PSCustomObject[]] $Results
    }
}

Export-ModuleMember -Function Invoke-SimpleExample, Invoke-PipelineExample
