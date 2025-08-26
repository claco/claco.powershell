# PSAvoidUsingWriteHost:
#
#     Starting in Windows PowerShell 5.0, Write-Host is a wrapper for Write-Information. Rather
#     than reimplementing incomplete forms of Write-Info to avoid all the -InformationAction Continue passing, just use
#     Write-Host and be on modern powershell versions. You also retain the use of colors in Write-Host not in
#     Write-Information.
#
# PSUseBOMForUnicodeEncodedFile:
#
#     Cause by characters in debug output for smaller footprint. Not critical.
@{
    Severity     = @('Error', 'Warning', 'Information')
    ExcludeRules = @('PSUseBOMForUnicodeEncodedFile', 'PSAvoidUsingWriteHost')
}
