<#
.SYNOPSIS
    A script to remove all bloatware from Windows.
.DESCRIPTION
    A script to remove all bloatware from Windows.
.NOTES
    2023-06-18 Jack den Ouden <Jack@Ldam.nl>
        Script created
.LINK
    
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $RegistryKeyCSV = "C:\repo\OSD\Sollutions\DefaultRegistrySettings\RegistryTemplate.csv",
    [Parameter()]
    [switch][bool]
    $DryRun,
    [Parameter()]
    [bool]
    $Confirm = $true
)

Write-Host "Script start finished" -ForegroundColor Yellow
try {
    #* Variables
    #region
    Write-Host "Loading variables" -ForegroundColor Yellow

    $ErrorActionPreference = "stop"

    #endregion

    #* Functions
    #region
    Write-Host "Loading functions" -ForegroundColor Yellow

    #endregion

    #* Script
    #region
    Write-Host "Starting script" -ForegroundColor Yellow

    Import-Csv -Path $RegistryKeyCSV -Delimiter ";" | ForEach-Object {
        
        Write-Host "Test if $($_.Key) exists"
        if (!(Test-Path "registry::$($_.Key)")) {
            Write-Host "$($_.Key) not found" -ForegroundColor Red
            Write-Host "Creating $($_.Key)" -ForegroundColor Green
            New-Item "registry::$($_.Key)" -Force | Out-Null
        }
        else {
            Write-Host "$($_.Key) exists" -ForegroundColor Green
        }

        New-ItemProperty -Path "registry::$($_.Key)" -Name ($_.Name) -Value ($_.Value) -PropertyType ($_.Type) -Force


    }


    Write-Host "Script finished" -ForegroundColor Yellow

    #endregion

}
catch {
    Write-Host $_ -ForegroundColor Red
}

