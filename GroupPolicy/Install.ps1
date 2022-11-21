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

[CmdletBinding()]
param (
)

#* Variables
#region
$VerbosePreference = "Continue"
#endregion

#* Create template folder if not exists
#region
$Path = "$PSScriptRoot\Template\PolicyDefinitions"
if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType Directory -Force
}
#endregion

#* Import templates to local Machine
#Region

Get-ChildItem -Path $PSScriptRoot -Filter "PolicyDefinitions" -Recurse | ForEach-Object {
    Write-Verbose "Importing $($_.FullName)"
    Copy-Item -Path $_.fullname `
        -Destination "$env:windir" `
        -Recurse `
        -Force
}

#endregion