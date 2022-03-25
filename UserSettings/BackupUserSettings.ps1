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
            , "/r:5"
            , "/w:1"
            , "/ns"
            , "/nc"
            , "/nfl"
            , "/ndl"
            , "/np"
            , "/njh"
            , "/njs"
        )

        . Robocopy.exe $Params | Out-Null

        $Source | Out-File -FilePath "$Destination\OriginalPath.txt" -Encoding utf8 -Force

        #endregion
        
    }
    catch {
        throw $_.exception.message
    }
}

#endregion

#endregion

#region Variables

#Destination of the backup
$DestinationPath = "$(Get-OneDrivePath)\SettingsBackup"

#Temporary local location prior to compression & copy to OneDrive
$TempDestinationPath = "$env:TEMP\SettingsBackup"

#Folders to backup excluding Microsoft folder
$FoldersToBackup = @((Get-ChildItem -Path $env:APPDATA -Exclude "Microsoft").FullName)

#Adding Outlook signatures
$FoldersToBackup += @(
    , "C:\Users\jdenouden\AppData\Roaming\Microsoft\Signatures"
)

#endregion

#Region create hidden destination folder
        
#Test Destination
if (!(Test-Path -Path "$DestinationPath")) {
        
    Write-Verbose "Creating folder `"$DestinationPath`""
    #Create directory if not already present
    $Directory = New-Item -Path "$DestinationPath" `
        -ItemType Directory `
        -Force

    $Directory.Attributes = "Hidden"
}

#endregion

#Region Backup

$Results = $FoldersToBackup | ForEach-Object {
    
    $Path = $_
    #Test if folder exists and if not skip it.
    if (Test-Path -Path $Path) {
        Sync-ToTempFolder -Source $Path `
            -Destination $TempDestinationPath
            
        [PSCustomObject]@{
            SourcePath = $Path
            ExitCode   = $LASTEXITCODE
        }

    }
}


#$Results | Out-String
$Results = $Results | Where-Object {
    ($_.ExitCode -ne 0) -and
    ($_.ExitCode -ne 1) -and
    ($_.ExitCode -ne 2)
}

if ($Results){
    throw "Nobackup made `n$($Results | Out-String)"
}

#endregion

#Region CompressBackup

#create backup
Compress-Archive -Path "$TempDestinationPath\*" `
    -DestinationPath "$DestinationPath\$env:COMPUTERNAME.zip" `
    -CompressionLevel Optimal `
    -Force

#endregion