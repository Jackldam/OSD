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

#region Remove-PathToLongDirectory

function Remove-PathToLongDirectory {
    Param(
        [string]$directory
    )

    # create a temporary (empty) directory
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    $tempDirectory = New-Item -ItemType Directory -Path (Join-Path $parent $name)

    robocopy /MIR $tempDirectory.FullName $directory | Out-Null
    Remove-Item $directory -Force | Out-Null
    Remove-Item $tempDirectory -Force | Out-Null
}

#endregion

#endregion

#region Variables

$Source = "$env:TEMP\SettingsBackup"

#Destination of the backup
$DestinationPath = $env:APPDATA

#endregion

#region get backup's

if (!(Test-Path "$(Get-OneDrivePath)\SettingsBackup")) {
    throw "SettingsBackup folder not found"
    break
}

$BackupFile = Get-ChildItem  -Path "$(Get-OneDrivePath)\SettingsBackup" | Select-Object Name, LastWriteTime, fullname | Out-GridView -OutputMode Single

if (!($BackupFile)) {
    throw "No backups found or selected"
    exit
}

if (Test-Path -Path $Source) {
    Remove-PathToLongDirectory -directory $Source
}

. "$PSScriptRoot\7zip\7za.exe" x "$($BackupFile.FullName)" -o"$Source" -r

#endregion

#Region Restore Appdata backup

Sync-Folder -Source "$Source\Roaming"  `
    -Destination $env:APPDATA

#endregion

#region recover Wifi networks

(Get-ChildItem "$Source\WlanProfiles").FullName | ForEach-Object {
    $i = @(
        , "wlan"
        , "add"
        , "profile"
        , "filename=`"$_`""
        , "user=all"
    )
    
    netsh.exe @i
}

#endregion