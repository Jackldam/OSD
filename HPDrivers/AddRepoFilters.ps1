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

$AddDevices = Get-HPDeviceDetails -Name * | Where-Object SystemID -NotIn  $(($CurrentFilters | Select-Object platform -Unique).platform) | Out-GridView -OutputMode Multiple

if ($AddDevices) {

    $AddDevices  | ForEach-Object {
        #Add Devices to Repo list
        . {
            Get-HPDeviceDetails -Name $_.Name -OSList | Where-Object OperatingSystemRelease -EQ "2009" | Sort-Object SystemID -Unique | Select-Object SystemID, OperatingSystemRelease
            Get-HPDeviceDetails -Name $_.Name -OSList | Where-Object OperatingSystemRelease -EQ "21H2" | Sort-Object SystemID -Unique | Select-Object SystemID, OperatingSystemRelease
        } | ForEach-Object {
            Add-RepositoryFilter -Platform $_.SystemID -Os "win10" -OsVer $_.OperatingSystemRelease -Category Bios, Driver, Firmware
        }
    }
}
