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
    $LocalPath = "C:\HPDriverRepo",
    [Parameter()]
    [string]
    $FileSharePath = "\\10.2.10.2\public\HPDriverRepo"
)

Set-Location -Path $LocalPath
Set-HPCMSLLogFormat -Format CMTrace

Remove-Item -Path "$LocalPath\.repository\activity.log" -Force

do {
    $Retry = $false
    try { Invoke-RepositorySync }catch { $Retry = $true }
}
while($Retry)

Invoke-RepositoryCleanup

Robocopy.exe $LocalPath $FileSharePath /MIR 