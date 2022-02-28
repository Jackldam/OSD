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
    2022/02/26 Created by Jack den Ouden <jack@ldam.nl>
    Revisions:
        1.0.0 - Created script
#>
[CmdletBinding()]
param (
    # Parameter help description
    [Parameter()]
    [string]
    $ConfigFile = "$PSScriptRoot\Example_Config.xml", #* Configuration url created at https://config.office.com/officeSettings/configurations

    # Desired version test
    [Parameter()]
    [string]
    $Version = "16.0.14326.20784",

    # Parameter help description
    [Parameter()]
    [string]
    $ApplicationName = "Microsoft 365 Apps for enterprise - en-us"
)

#region Preperations

#download link O365 Click to run
$Downloadurl = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=O365BusinessRetail&platform=X64&language=en-us"

#Temp storage location
$C2RDownloadfolder = "$env:TEMP\Provisioning\$ApplicationName"

#Test Application & version
$TestCodeBlock = { Get-CimInstance -ClassName "Win32_InstalledWin32Program" -Filter "Name = `"$ApplicationName`"" }
$Installcheck = Invoke-Command -ScriptBlock $TestCodeBlock

#endregion

Write-Host "Application:[$ApplicationName] Version:[$($Installcheck.version)] Test if already installed"
if (-not($Installcheck.Version -ge $Version)) {
    #region installation

    Write-Host "Application not found or version was lower then $Version"
    Write-Host "Start installing $ApplicationName"

    #Create folder if it doesn't exist
    Write-Host "Testing if $C2RDownloadfolder exists"
    if (-not (Test-Path $C2RDownloadfolder)) {
        
        Write-Host "$C2RDownloadfolder doesn't exist creating folder"

        #Create folder don't show output
        New-Item -Path $C2RDownloadfolder `
            -ItemType Directory | Out-Null

    }

    Write-Host "Downloading Setup.exe from $Downloadurl"

    #Download setup file
    Invoke-WebRequest -Uri $Downloadurl `
        -OutFile "$C2RDownloadfolder\Setup.exe"
    
    
    Write-Host "Installing $ApplicationName"
    #Install O365 C2R
    Start-Process -FilePath "$C2RDownloadfolder\Setup.exe" `
        -ArgumentList "/configure $ConfigFile" `
        -Wait `
        -NoNewWindow

    #endregion

    #region Test if installation successfull

    $Installcheck = Invoke-Command -ScriptBlock $TestCodeBlock

    if (-not($Installcheck.Version -ge $Version)) {
        Write-Host "Application:[$ApplicationName] Version:[$Version] installation succesfull"
    }
    else {
        throw "Application:[$ApplicationName] Version:[$Version] installation failed!"
    }

    #endregion

}
else {
    Write-Host "Application:[$ApplicationName] Version:[$($Installcheck.version)] Already installed"
}


if (Test-Path $C2RDownloadfolder) {
    
    Write-Host "Cleanup tempfiles $C2RDownloadfolder"
    #Cleanup all temp files
    Remove-Item $C2RDownloadfolder -Recurse -Force
}

