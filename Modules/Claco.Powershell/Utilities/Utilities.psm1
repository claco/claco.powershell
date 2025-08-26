
<#
.SYNOPSIS
    Gets the current debug preference for the calling context.

.DESCRIPTION
    Determines if debug output should be written based on invocation parameters, environment variables, or call stack.

.PARAMETER Invocation
    The invocation information for the calling cmdlet or function.

.OUTPUTS
    System.Management.Automation.ActionPreference

.EXAMPLE
    Get-DebugPreference

.NOTES
    Used internally to control debug output.
#>
function Get-DebugPreference {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ActionPreference])]
    param (
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo] $Invocation = $null
    )

    try {
        Write-DebugFunctionStart

        if ($Invocation -and $Invocation.BoundParameters['Debug']) {
            return [System.Management.Automation.ActionPreference]::Continue
        } elseif ($env:DEBUG -eq $true) {
            return [System.Management.Automation.ActionPreference]::Continue
        } elseif ($DebugPreference -eq 'Continue') {
            return [System.Management.Automation.ActionPreference]::Continue
        } else {
            $Caller = $(Get-PSCallStack)[1]
            $UnboundArguments = $Caller.InvocationInfo.UnboundArguments

            if ($Caller.InvocationInfo.BoundParameters['Debug']) {
                return [System.Management.Automation.ActionPreference]::Continue
            } elseif ($UnboundArguments -contains '-Debug') {
                return [System.Management.Automation.ActionPreference]::Continue
            }
        }

        return [System.Management.Automation.ActionPreference]::SilentlyContinue
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

<#
.SYNOPSIS
    Gets the current verbose preference for the calling context.

.DESCRIPTION
    Determines if verbose output should be written based on invocation parameters, environment variables, or call stack.

.PARAMETER Invocation
    The invocation information for the calling cmdlet or function.

.OUTPUTS
    System.Management.Automation.ActionPreference

.EXAMPLE
    Get-VerbosePreference

.NOTES
    Used internally to control verbose output.
#>
function Get-VerbosePreference {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ActionPreference])]
    param (
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo] $Invocation = $null
    )

    try {
        Write-DebugFunctionStart

        if ($Invocation -and $Invocation.BoundParameters['Verbose']) {
            return [System.Management.Automation.ActionPreference]::Continue
        } elseif ($env:VERBOSE -eq $true) {
            return [System.Management.Automation.ActionPreference]::Continue
        } elseif ($VerbosePreference -eq 'Continue') {
            return [System.Management.Automation.ActionPreference]::Continue
        } else {
            $Caller = $(Get-PSCallStack)[1]
            $UnboundArguments = $Caller.InvocationInfo.UnboundArguments

            if ($Caller.InvocationInfo.BoundParameters['Verbose']) {
                return [System.Management.Automation.ActionPreference]::Continue
            } elseif ($UnboundArguments -contains '-Verbose') {
                return [System.Management.Automation.ActionPreference]::Continue
            }
        }

        return [System.Management.Automation.ActionPreference]::SilentlyContinue
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

<#
.SYNOPSIS
    Determines if debug output should be written for the calling context.

.DESCRIPTION
    Returns $true if debug output should be written based on invocation parameters, environment variables, or call stack.

.PARAMETER Invocation
    The invocation information for the calling cmdlet or function.

.OUTPUTS
    System.Boolean

.EXAMPLE
    Test-Debug

.NOTES
    Used internally to check debug output state.
#>
function Test-Debug {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo] $Invocation = $null
    )

    try {
        Write-DebugFunctionStart

        if ($Invocation -and $Invocation.BoundParameters['Debug']) {
            return $true
        } elseif ($env:DEBUG -eq $true) {
            return $true
        } elseif ($DebugPreference -eq 'Continue') {
            return $true
        } else {
            $Caller = $(Get-PSCallStack)[1]
            $UnboundArguments = $Caller.InvocationInfo.UnboundArguments

            if ($Caller.InvocationInfo.BoundParameters['Debug']) {
                return $true
            } elseif ($UnboundArguments -contains '-Debug') {
                return $true
            }
        }

        return $false
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

<#
.SYNOPSIS
    Determines if verbose output should be written for the calling context.

.DESCRIPTION
    Returns $true if verbose output should be written based on invocation parameters, environment variables, or call stack.

.PARAMETER Invocation
    The invocation information for the calling cmdlet or function.

.OUTPUTS
    System.Boolean

.EXAMPLE
    Test-Verbose

.NOTES
    Used internally to check verbose output state.
#>
function Test-Verbose {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo] $Invocation = $null
    )

    try {
        Write-DebugFunctionStart

        if ($Invocation -and $Invocation.BoundParameters['Verbose']) {
            return $true
        } elseif ($env:VERBOSE -eq $true) {
            return $true
        } elseif ($VerbosePreference -eq 'Continue') {
            return $true
        } else {
            $Caller = $(Get-PSCallStack)[1]
            $UnboundArguments = $Caller.InvocationInfo.UnboundArguments

            if ($Caller.InvocationInfo.BoundParameters['Verbose']) {
                return $true
            } elseif ($UnboundArguments -contains '-Verbose') {
                return $true
            }
        }

        return $false
    } catch {
        Write-Exception
    } finally {
        Write-DebugFunctionEnd
    }
}

<#
.SYNOPSIS
    Writes a debug message indicating the start of a function.

.DESCRIPTION
    Outputs a formatted debug message to indicate the entry point of a function, using the function name and debug preference.

.PARAMETER Name
    The name of the function to display in the debug message. If not specified, the caller's function name is used.

.OUTPUTS
    None

.EXAMPLE
    Write-DebugFunctionStart -Name 'MyFunction'

.NOTES
    Used internally for consistent debug output formatting.
#>
function Write-DebugFunctionStart {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Position = 0)]
        [string] $Name
    )

    try {
        $Caller = $(Get-PSCallStack)[1]
        $BoundParameters = $Caller.InvocationInfo.BoundParameters

        if (-not $Name) {
            $Name = $Caller.FunctionName.Replace('<.*>', '')
        }

        if ($BoundParameters['Debug'] -or $DebugPreference -eq 'Continue') {
            Write-Debug "›››› $($Name) $('›' * (70 - $Name.Length))" -Debug
        }
    } catch {
        Write-Exception
    }

    return
}

<#
.SYNOPSIS
    Writes a debug message indicating the end of a function.

.DESCRIPTION
    Outputs a formatted debug message to indicate the exit point of a function, using the function name and debug preference.

.PARAMETER Name
    The name of the function to display in the debug message. If not specified, the caller's function name is used.

.OUTPUTS
    None

.EXAMPLE
    Write-DebugFunctionEnd -Name 'MyFunction'

.NOTES
    Used internally for consistent debug output formatting.
#>
function Write-DebugFunctionEnd {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Position = 0)]
        [string] $Name = $null
    )

    try {
        $Caller = $(Get-PSCallStack)[1]
        $BoundParameters = $Caller.InvocationInfo.BoundParameters

        if (-not $Name) {
            $Name = $Caller.FunctionName.Replace('<.*>', '')
        }

        if ($BoundParameters['Debug'] -or $DebugPreference -eq 'Continue') {
            Write-Debug "‹‹‹‹ $($Name) $('‹' * (70 - $Name.Length))" -Debug
        }
    } catch {
        Write-Exception
    }

    return
}

<#
.SYNOPSIS
    Writes detailed information about an exception or error record.

.DESCRIPTION
    Outputs warning messages with stack trace and error details, or writes an error record, depending on the specified action.

.PARAMETER ErrorRecord
    The error record to process and display.

.PARAMETER Exception
    The exception to process and display.

.PARAMETER ExceptionAction
    Specifies how to handle the exception output. Defaults to 'Continue'.

.EXAMPLE
    Write-Exception -ErrorRecord $error[0]

.EXAMPLE
    Write-Exception -Exception $_.Exception

.NOTES
    Used internally for consistent exception handling and output.
#>
function Write-Exception {
    [CmdletBinding(DefaultParameterSetName = 'ErrorRecord')]
    [OutputType([void])]
    param (
        [Parameter(Position = 0, ParameterSetName = 'ErrorRecord', ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord] $ErrorRecord = $null,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Exception')]
        [ValidateNotNull()]
        [exception] $Exception,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ActionPreference] $ExceptionAction = $PSCmdlet.SessionState.PSVariable.GetValue('ExceptionActionPreference') ?? 'Continue'
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ErrorRecord') {
            if (-not $ErrorRecord) {
                $Caller = $(Get-PSCallStack)[1]
                $CallerVariables = $Caller.GetFrameVariables()

                if ($CallerVariables.Keys.Contains('PSItem')) {
                    $PSItemValue = $CallerVariables['PSItem'].Value

                    if ($PSItemValue -is [System.Management.Automation.ErrorRecord]) {
                        $ErrorRecord = $PSItemValue
                        $Exception = $ErrorRecord.Exception
                    }
                }
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'Exception') {
            $ErrorRecord = $Exception.ErrorRecord
        }
    }

    process {
        Write-Debug "ExceptionAction=$ExceptionAction"
        Write-Debug "ExceptionActionPreference=$ExceptionActionPreference"

        if ($ExceptionAction -eq 'Continue') {
            $WarningPreference = 'Continue'

            Write-Warning "┈┈ Exception StackTrace $('┈┈' * 25)"
            Write-Warning "$ErrorRecord"
            Write-Warning "$($ErrorRecord.ScriptStackTrace)"
            Write-Warning "$('┈┈' * 37)"
        } elseif ($ExceptionAction -ne 'SilentlyContinue') {
            Write-Error -ErrorRecord $ErrorRecord -ErrorAction $ExceptionAction
        }
    }
}

Export-ModuleMember -Function Get-DebugPreference, Test-Debug
Export-ModuleMember -Function Get-VerbosePreference, Test-Verbose
Export-ModuleMember -Function Write-DebugFunctionStart, Write-DebugFunctionEnd, Write-Exception
