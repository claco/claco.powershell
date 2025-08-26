# See: https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/using-scriptanalyzer?view=ps-modules#settings-support-in-scriptanalyzer
#
# PSAvoidUsingWriteHost:
#
#     Starting in Windows PowerShell 5.0, Write-Host is a wrapper for Write-Information. Rather than reimplementing
#     incomplete forms of Write-Information to avoid all the -InformationAction Continue passing, just use
#     Write-Host and be on modern PowerShell versions. You also retain the use of colors in Write-Host not
#     supported by Write-Information.
#
# PSUseBOMForUnicodeEncodedFile:
#
#     Caused by characters in debug output for smaller footprint. Not critical at this time unless you are using a
#     text editor that requires BOM or need BOM in additional xml/xslt files in this project.
#
@{
    Severity     = @('Error', 'Warning', 'Information')
    ExcludeRules = @('PSUseBOMForUnicodeEncodedFile', 'PSAvoidUsingWriteHost')
    Rules        = @{
        PSProvideCommentHelp = @{
            Enable                  = $true
            ExportedOnly            = $true
            BlockComment            = $true
            VSCodeSnippetCorrection = $true
            Placement               = 'before'
        }
    }
}
