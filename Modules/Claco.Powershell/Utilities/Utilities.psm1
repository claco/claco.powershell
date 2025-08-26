function Get-DebugPreference {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ActionPreference])]
    param (
        [System.Management.Automation.InvocationInfo] $Invocation
    )

    return $(Test-Debug -Invocation $Invocation) ? [System.Management.Automation.ActionPreference]::Continue  : [System.Management.Automation.ActionPreference]::SilentlyContinue
}

function Get-VerbosePreference {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ActionPreference])]
    param (
        [System.Management.Automation.InvocationInfo] $Invocation
    )

    return $(Test-Verbose -Invocation $Invocation) ? [System.Management.Automation.ActionPreference]::Continue  : [System.Management.Automation.ActionPreference]::SilentlyContinue
}

function Test-Debug {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [System.Management.Automation.InvocationInfo] $Invocation
    )

    if ($Invocation -and $Invocation.BoundParameters.ContainsKey('Debug')) {
        return $true
    } elseif ($env:DEBUG -eq 'True') {
        return $true
    } elseif ($DebugPreference -eq 'Continue') {
        return $true
    } else {
        return $false
    }
}

function Test-Verbose {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [System.Management.Automation.InvocationInfo] $Invocation
    )

    if ($Invocation -and $Invocation.BoundParameters.ContainsKey('Verbose')) {
        return $true
    } elseif ($env:VERBOSE -eq 'True') {
        return $true
    } elseif ($VerbosePreference -eq 'Continue') {
        return $true
    } else {
        return $false
    }
}

function Write-DebugFunctionStart {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [string] $Name = $null
    )

    $Caller = $(Get-PSCallStack)[1]

    if (-not $Name) {
        $Name = $Caller.FunctionName.Replace('<.*>', '')
    }

    if ($Caller.Arguments.Contains('Debug')) {
        Write-Debug "›››› $($Name) $('›' * (70 - $Name.Length))" -Debug
    }
}

function Write-DebugFunctionEnd {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [string] $Name = $null
    )

    $Caller = $(Get-PSCallStack)[1]

    if (-not $Name) {
        $Name = $Caller.FunctionName.Replace('<.*>', '')
    }

    if ($Caller.Arguments.Contains('Debug')) {
        Write-Debug "‹‹‹‹ $($Name) $('‹' * (70 - $Name.Length))" -Debug
    }
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
