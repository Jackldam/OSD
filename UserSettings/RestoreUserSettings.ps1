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

#region Sync-ToTempFolder

function Sync-ToTempFolder {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Source,
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Destination
    )

    try {
        
        #Get source folder name
        $SFoldername = Split-Path -Path $Source -Leaf

        #Declare destination with source folder name
        $Destination = "$Destination\$SFoldername"

        #* create destination folder
        #Region
        
        #Test Destination
        if (!(Test-Path -Path "$Destination")) {
        
            Write-Verbose "Creating folder `"$Destination`""
            #Create directory if not already present
            New-Item -Path "$Destination" `
                -ItemType Directory `
                -Force | Out-Null
        }

        #endregion

        #Region mirror data to temp folder

        $Params = @(
            , "`"$Source`""
            , "`"$Destination`""
            , "/mir"
            , "/sl"
            , "/r:100"
            , "/w:1"
            , "/ns"
            , "/nc"
            , "/nfl"
            , "/ndl"
            , "/np"
            , "/njh"
            , "/njs"
        )

        . Robocopy.exe $Params

        $Source | Out-File -FilePath "$Destination\SourcePath.txt" -Encoding utf8 -Force | Out-Null

        #endregion
        
    }
    catch {
        throw $_.exception.message
    }
}

#endregion

#region Restore-Backup

function Restore-Backup {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Source,
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Destination
    )

    try {
        
        #Get source folder name
        $SFoldername = Split-Path -Path $Source -Leaf

        #Declare destination with source folder name
        $Destination = "$Destination"

        #* create destination folder
        #Region
        
        #Test Destination
        if (!(Test-Path -Path "$Destination")) {
        
            Write-Verbose "Creating folder `"$Destination`""
            #Create directory if not already present
            New-Item -Path "$Destination" `
                -ItemType Directory `
                -Force | Out-Null
        }

        #endregion

        #Region mirror data to temp folder

        $Params = @(
            , "`"$Source`""
            , "`"$Destination`""
            , "/mir"
            , "/sl"
            , "/r:100"
            , "/w:1"
            , "/ns"
            , "/nc"
            , "/nfl"
            , "/ndl"
            , "/np"
            , "/njh"
            , "/njs"
        )

        . Robocopy.exe $Params

        $Source | Out-File -FilePath "$Destination\SourcePath.txt" -Encoding utf8 -Force | Out-Null

        #endregion
        
    }
    catch {
        throw $_.exception.message
    }
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

#endregion

#Region Restore backup

$BackupFile.fullname | ForEach-Object {

    Expand-Archive -Path $_ `
        -DestinationPath $Source `
        -Force
}

(Get-ChildItem -Path $Source -Directory).FullName | ForEach-Object {
    $Path = $_ 
    
    $Destination = Get-ChildItem $_ -Filter "OriginalPath.txt" | Get-Content
    
    Restore-Backup -Source "$Path" `
        -Destination $Destination | Out-Null
        $LASTEXITCODE
}

#endregion
