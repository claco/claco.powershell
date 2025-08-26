#Requires -Module Pester

function Assert-ContainsStackTrace {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [object[]] $ActualValue,
        [switch] $Negate,
        [object] $CallerSessionState,
        [string] $WithFunctionName = 'TestException'

    )

    $FunctionName = $WithFunctionName
    $StackTraceHeader = 'Exception StackTrace'
    $StringValue = $($ActualValue | Out-String)

    $Succeeded = $false

    if ($Negate) {
        $Succeeded = $StringValue -notlike "*$($StackTraceHeader)*$($FunctionName)*"
    } else {
        $Succeeded = $StringValue -like "*$($StackTraceHeader)*$($FunctionName)*"
    }

    return [PSCustomObject]@{
        Succeeded      = $Succeeded
        FailureMessage = "Expected message to contain '$StackTraceHeader' header and '$FunctionName', but got $StringValue."
    }
}

Add-ShouldOperator -Name BeStackTrace `
    -InternalName 'Assert-ContainsStackTrace' `
    -Test ${function:Assert-ContainsStackTrace} `
    -SupportsArrayInput
