<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

# Parameter help description
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path = "C:\HPDriverRepo"
)

#Test if folder exits and if not create it.
if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
}

Set-Location -Path $Path
Set-HPCMSLLogFormat -Format CMTrace

try { Get-RepositoryInfo } catch { 
    Initialize-Repository
    Set-RepositoryConfiguration -Setting OfflineCacheMode -CacheValue Enable
    Set-RepositoryConfiguration OnRemoteFileNotFound -Value LogAndContinue
}




