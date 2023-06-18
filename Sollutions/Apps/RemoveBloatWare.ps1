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

    $AppxPackagesToRemove = @(
        , "Clipchamp.Clipchamp"
        , "Microsoft.BingNews"
        , "Microsoft.BingWeather"
        , "Microsoft.Getstarted"
        , "Microsoft.MicrosoftOfficeHub"
        , "Microsoft.MicrosoftSolitaireCollection"
        , "Microsoft.MicrosoftStickyNotes"
        , "Microsoft.People"
        , "Microsoft.PowerAutomateDesktop"
        , "Microsoft.WindowsFeedbackHub"
        , "Microsoft.WindowsMaps"
        , "Microsoft.Xbox.TCUI"
        , "Microsoft.XboxGameOverlay"
        , "Microsoft.XboxGamingOverlay"
        , "Microsoft.XboxIdentityProvider"
        , "Microsoft.XboxSpeechToTextOverlay"
        , "Microsoft.YourPhone"
        , "Microsoft.ZuneMusic"
        , "Microsoft.ZuneVideo"
    )

    #endregion

    #* Functions
    #region
    Write-Host "Loading functions" -ForegroundColor Yellow

    #endregion

    #* Script
    #region
    Write-Host "Starting script" -ForegroundColor Yellow

    $AppxPackagesToRemove | ForEach-Object { 
        Write-Host "Test if app $_ is found"
        if (!($DryRun)) {
            
            if (Get-AppxPackage -Name $_) {
                Write-Host "$_ Found" -ForegroundColor Red

                Write-Host "Try removing $_"
                try {
                    Remove-AppxPackage -Package (Get-AppxPackage -Name $_).PackageFullName -AllUsers -Confirm:$Confirm
                }
                catch {
                    Write-Host $_ -ForegroundColor Red
                }
            }
        }
        else {
            if (Get-AppxPackage -Name $_) {
                Write-Host "$_ Found" -ForegroundColor Red

                Write-Host "DryRun enabled skip removing $_" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "Script finished" -ForegroundColor Yellow

    #endregion

}
catch {
    Write-Host $_ -ForegroundColor Red
}