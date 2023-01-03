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
Set-Location -Path $Path
Set-HPCMSLLogFormat -Format CMTrace

$CurrentFilters = (Get-RepositoryInfo).filters

$RemoveDeviceFilter = Get-HPDeviceDetails -Name * | Where-Object SystemID -In  $(($CurrentFilters | Select-Object platform -Unique).platform) | Out-GridView -OutputMode Single

if ($RemoveDeviceFilter) {
    $title = 'Remove Device filters from Repository'
    $question = "$((Get-HPDeviceDetails -Platform $RemoveDeviceFilter.SystemID).Name | Out-String)"
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {

        #Remove from filter
    (Get-RepositoryInfo).filters | Where-Object platform -EQ $RemoveDeviceFilter.SystemID | ForEach-Object {
            Remove-RepositoryFilter -Platform $_.platform -Yes
        }
    }
    else {
        Write-Host 'cancelled'
    }
}