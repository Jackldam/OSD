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
    General notes
#>
[CmdletBinding()]
param (
)

$ErrorActionPreference = "Stop"
$SettingsBackupTempDestination = "$env:TEMP\SettingsBackup"

#region Functions

#region Get-OneDrivePath

Function Get-OneDrivePath {
    $ODrivetest = (Get-ChildItem -Path $env:USERPROFILE -Filter "*OneDrive*").FullName
    
    Write-Verbose "Folders found $($ODrivetest.count)"
    switch ($ODrivetest.count) {
        1 { }
        2 { $ODrivetest = $ODrivetest -match "Onedrive -" }
        { $_ -gt 2 } { Throw "To many options stopping script" }
    }
    
    Write-Verbose "Selecting `"$ODrivetest`""
    
    return $ODrivetest
    
}

#endregion

#region Sync-Folder

function Sync-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [string]
        $Destination,
        [Parameter()]
        [array]
        $Exclude
    )
    
    $Params = @(
        , "/mir"
        #, "/e"
        #, "/purge"
        , "/sl"
        , "/r:5"
        , "/w:5"
        , "/ns"
        , "/nc"
        , "/nfl"
        , "/ndl"
        , "/np"
        , "/njh"
        , "/njs"
    )

    $Exclude | ForEach-Object {
        $Params += @(
            "/xd"
            "`"$_`""
        )
    }
    . Robocopy.exe "`"$Source`"" "`"$Destination`"" @Params | Out-Null

}

#endregion

#endregion

#region Create TempFolder

#Test if temp folder exists and if not then create it
if (!(Test-Path -Path $SettingsBackupTempDestination)) {
        
    Write-Verbose "Creating folder `"$SettingsBackupTempDestination`""
    #Create directory if not already present
    New-Item -Path "$SettingsBackupTempDestination" `
        -ItemType Directory `
        -Force | Out-Null
}

#endregion

#region Backup Appdata

Sync-Folder -Source "$env:APPDATA" `
    -Destination "$SettingsBackupTempDestination\Roaming" `
    -Exclude @("Teams")

#endregion

#region backup Wifi Settings

#get all wlan profiles
$list = . netsh.exe wlan show profiles

#Use regex to get the profile names
$regex = "\s{2,}:.(?'Profile'.*)"
$List = $list | ForEach-Object {
    $i = [regex]::Matches($_, $regex)
    $i.Groups | Where-Object Name -EQ Profile
}

#Test if folder exists
$WLanTemp = "$SettingsBackupTempDestination\WlanProfiles"
if (!(Test-Path -Path $WLanTemp)) { New-Item -Path $WLanTemp -ItemType Directory -Force }

#export each profile to xml to desired backup location
$List.value | ForEach-Object {
    $Params = @(
        , "wlan"
        , "export"
        , "profile"
        , "$_"
        , "key=clear"
        , "Folder=`"$WLanTemp`""
    )
    . netsh.exe @Params | Out-Null
}

#endregion

#region Save all installed applications in CSV list

Get-CimInstance -Namespace "root\cimv2" -ClassName "Win32_InstalledWin32Program" | Sort-Object Name | Select-Object Name, Version |
Export-Csv -Path "$SettingsBackupTempDestination\InstalledApplications.csv" `
    -Delimiter ";" `
    -NoTypeInformation `
    -Force

#endregion

#region #TODO Backup Office Settings

#endregion

#region Compress tempfolder backup to 7z

if (Test-Path -Path "$env:TEMP\SettingsBackup.7z") {
    Remove-Item "$env:TEMP\SettingsBackup.7z" -Force
}

. $PSScriptRoot\7zip\7za.exe a -t7z -mx=9 "$env:TEMP\SettingsBackup.7z" "$SettingsBackupTempDestination\*"

#endregion

#region Copy local backup to Cloud
$i = "$(Get-OneDrivePath)\SettingsBackup"
if (!(Test-Path -Path $i)) {
    New-Item -Path $i -ItemType Directory -Force
}

Copy-Item -Path "$env:TEMP\SettingsBackup.7z" `
    -Destination "$i\$env:ComputerName.7z" `
    -Force
#endregion