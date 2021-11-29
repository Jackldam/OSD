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
    # Parameter help description
    [Parameter()]
    [string]
    $Uri = "https://github.com/Jackldam/OSD/raw/main/Branding/Wallpaper/Example_img0.jpg"
)

#Define variables
$MDMRootPath = "C:\MDM"
$LockScreenImagePath = "C:\MDM\LockScreen.jpg"

if (-not (Test-Path -Path $MDMRootPath)) {
    New-Item -Path $MDMRootPath `
        -ItemType "Directory" `
        -Force
}

Invoke-WebRequest -UseBasicParsing `
    -Uri $Uri `
    -OutFile $LockScreenImagePath

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

#$LockScreenImageValue = "C:\REPO\OSD\Branding\Wallpaper\Example_img0.jpg"
$LockScreenImageValue = 

if (!(Test-Path $RegKeyPath)) {
    Write-Host "Creating registry path $($RegKeyPath)."
    New-Item -Path $RegKeyPath -Force | Out-Null
}

New-ItemProperty -Path $RegKeyPath `
    -Name "LockScreenImageStatus" `
    -Value "1" `
    -PropertyType "DWORD" `
    -Force | Out-Null


New-ItemProperty -Path $RegKeyPath `
    -Name "LockScreenImagePath" `
    -Value $LockScreenImagePath `
    -PropertyType STRING `
    -Force | Out-Null

New-ItemProperty -Path $RegKeyPath `
    -Name "LockScreenImageUrl" `
    -Value $LockScreenImagePath `
    -PropertyType STRING `
    -Force | Out-Null

RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True