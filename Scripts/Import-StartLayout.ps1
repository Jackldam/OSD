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
    [Parameter()]
    [TypeName]
    $ParameterName
)

Export-StartLayout -Path 

Import-StartLayout -LayoutPath ".\Branding\Startmenu\LayoutModification.json" -MountPath "C:\"