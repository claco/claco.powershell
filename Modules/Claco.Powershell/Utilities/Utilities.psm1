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
        [System.Management.Automation.ActionPreference] $ExceptionAction = 'Continue'
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
        if ($ExceptionAction -eq 'Continue') {
            $WarningPreference = 'Continue'

            Write-Warning "┈┈ Exception StackTrace $('┈┈' * 25)"
            Write-Warning "$ErrorRecord"
            Write-Warning "$($ErrorRecord.ScriptStackTrace)"
            Write-Warning "$('┈┈' * 37)"
        } elseif ($ExceptionAction -ne 'SilentlyContinue') {
            Write-Error -ErrorRecord $ErrorRecord -ErrorAction Continue
        }
    }
}

Export-ModuleMember -Function Get-DebugPreference, Test-Debug
Export-ModuleMember -Function Get-VerbosePreference, Test-Verbose
Export-ModuleMember -Function Write-DebugFunctionStart, Write-DebugFunctionEnd, Write-Exception
