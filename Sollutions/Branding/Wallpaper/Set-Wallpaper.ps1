<#
.SYNOPSIS
    Script that will try to Set the default wall paper for Windws 10/11
.DESCRIPTION
    Script that will try to Set the default wall paper for Windws 10/11
.EXAMPLE
    PS C:\> Set-Wallpaper.ps1 -Path ".\OSD\Branding\Wallpapers\img0.jpg"
    Explanation of what the example does
.INPUTS
    .jpg file
.OUTPUTS
    n/a
.NOTES
    2021-11-28 Created by Jack den Ouden <jack@ldam.nl>
    Revisions:
        1.0.0 - Created script and added Example_img0.jpg
#>
[CmdletBinding()]
param (
    # Path to jpg file that will be set to default Company background
    [Parameter()]
    [ValidateScript({
            if (-Not ($_ | Test-Path) ) {
                throw "File or folder does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if ($_ -notmatch "(\.jpg)") {
                throw "The file specified in the path argument must be .jpg"
            }
            return $true 
        })]
    [System.IO.FileInfo]$Path = ".\Branding\Wallpaper\img0.jpg"
)

$ErrorActionPreference = "stop"


try {

    #Windows wallpaper paths
    @(
        "c:\windows\WEB\wallpaper\Windows\img0.jpg",
        "c:\windows\WEB\wallpaper\Windows\img19.jpg",
        "C:\Windows\Web\4K\Wallpaper\Windows\*.*"
    ) | ForEach-Object {
        
        #Test if file found if not skip steps
        if (Test-Path -Path $_ ) {
            #take ownership and apply required rights to manipulate files
            . takeown.exe /F $_ | Out-Null

            . icacls.exe $_ `
                /Grant "$($env:USERNAME):(F)" | Out-Null

            #Remove old files
            Remove-Item -Path $_ `
                -Force
        }
    }
    
    #Copy light theme wallpaper
    Copy-Item -Path "$Path" `
        -Destination "c:\windows\WEB\wallpaper\Windows\img0.jpg" `
        -Force

    #Copy Dark theme wallpaper 
    Copy-Item -Path "$Path" `
        -Destination "c:\windows\WEB\wallpaper\Windows\img19.jpg" `
        -Force

    #Copy img file for different resolutions
    Copy-Item -Path "$Path" `
        -Destination "C:\Windows\Web\4K\Wallpaper\Windows\img0_1920x1080.jpg" `
        -Force
}
catch {
    $($_.Exception.message)
}

