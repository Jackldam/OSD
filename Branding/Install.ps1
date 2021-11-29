<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Changelog:
        2021-11-28 || Script created by Jack den Ouden <jack@ldam.nl>
#>
[CmdletBinding()]
param (

)

$ConfigFile = Get-Content "$PSScriptRoot\ConfigFile.json" | ConvertFrom-Json

$ConfigFile | fl

<#
. "$PSScriptRoot\Sollutions\Wallpaper.ps1"

. "$PSScriptRoot\Sollutions\LockScreen.ps1"

. "$PSScriptRoot\Sollutions\ScreenSaver.ps1"

. "$PSScriptRoot\Sollutions\StartMenu.ps1"

. "$PSScriptRoot\Sollutions\RegionSettings.ps1"

#>