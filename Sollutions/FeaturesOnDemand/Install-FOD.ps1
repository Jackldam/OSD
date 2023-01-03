<#
.SYNOPSIS
    This script makes it so you can install the RSAT features on any Windows device even when WSUS server is used.
.DESCRIPTION
    This script makes it so you can install the RSAT features on any Windows device even when WSUS server is used.
    To do this we disable the WSUS enforcement install RSAT and then enable the WSUS enforcement again.
.NOTES
    2022-07-01 Jack den Ouden <jack@ldam.nl>
        Script created.
.EXAMPLE
    .\ Install-RSAT.ps1
.EXAMPLE
.\ Install-RSAT.ps1 -Uninstall
#>
[CmdletBinding()]
param (
    # Parameter help description
    [Parameter()]
    [switch][bool]
    $Uninstall
)

#region Disable usage of wsus server.

if (test-path -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"){
#Set registry key to disable wsus server usage
Write-Host "Setting registrykey UseWUServer to 0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -Name "UseWUServer" `
    -Value 0 `
    -Force

#restart Windows update service
Write-Host "Restarting wuauserv service"
Get-Service -Name "wuauserv" | Restart-Service -Force
}
#endregion

if (-not $Uninstall) {
    #region install RSAT
    Write-Host "Installing RSAT"
    Get-WindowsOptionalFeature -Online | Where-Object State -eq "Disabled" | Out-GridView -OutputMode Multiple | ForEach-Object {
        Write-Host "Installing $($_.DisplayName)"
        $_ | Enable-WindowsOptionalFeature -Online -NoRestart
    }

    #endregion
}
else {
    #region Uninstall RSAT
    Write-Host "Removing RSAT"
    Get-WindowsOptionalFeature -Online | Where-Object State -eq "Enabled" | Out-GridView -OutputMode Multiple | ForEach-Object {
        Write-Host "Removing $($_.DisplayName)"
        $_ | Disable-WindowsOptionalFeature -Online -NoRestart
    }

    #endregion
}

#region Enable usage of wsus server.
if (test-path -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"){

#Set registry key to enable wsus server usage
Write-Host "Setting registrykey UseWUServer to 1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -Name "UseWUServer" `
    -Value 1 `
    -Force

#restart Windows update service
Write-Host "Restarting wuauserv service"
Get-Service -Name "wuauserv" | Restart-Service -Force
}
#endregion
