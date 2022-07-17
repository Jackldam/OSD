<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
[CmdletBinding()]
param (
)

#Region #*Load Functions
function New-Hostname {
    [CmdletBinding()]
    param (
        
    )
    try {
        switch -Wildcard ((Get-WmiObject -Class:"Win32_ComputerSystem").Model) {
            { $_ -like "*Virtual*" } { 
                #New computername for a VM
                return $("NLVE" + $(Get-Date -Format:"yyMMdd") + $( -join $((65..90) + (97..122) | Get-Random -Count 3 | ForEach-Object { [char]$_ })).ToUpper())
            }
            { $_ -like "*VMWare*" } {
                #New computername for a VM
                return $("NLVE" + $(Get-Date -Format:"yyMMdd") + $( -join $((65..90) + (97..122) | Get-Random -Count 3 | ForEach-Object { [char]$_ })).ToUpper())
            }
            Default {
                #New computername for a Physical device
                return "NL" + $((Get-WmiObject -Class Win32_Bios).Serialnumber)
            }
        }
    }
    catch {
        Write-CMTraceLog -Loglevel:3 -Message:"$_"
    }
}

#endregion

#Region #*Dynamic Variables

#TODO get current Computername if not already present.
$NewComputerName = New-Hostname

#endregion

#Region #*Customizations

#Allow showing command prompts in MDT Remote
Set-ItemProperty HKCU:\Console -Name "ForceV2" `
    -Value 0 `
    -Type DWord `
    -Force

#Set Custom Background
. "$PSScriptRoot\PreStart\BGI\BGInfo.ps1" -path "STEP_00.BGI"

#endregion

#Region #*start Remote Connection tool

#Test if RemoteRecovery.exe exists if not skip step.
if (Test-Path -Path "$env:windir\System32\RemoteRecovery.exe") {
    #To automaticly start Remote Connection tool at startup of Windows PE
    Start-Process -FilePath:"$env:windir\System32\RemoteRecovery.exe" `
        -ArgumentList:"-nomessage" `
        -WindowStyle Minimized

    #test if file is made and will wait until created
    do {
        if (Test-Path "$PSScriptRoot\inv32.xml") {
            [xml]$Import = Get-Content "$PSScriptRoot\inv32.xml"
        }
        Start-Sleep -Seconds:1
    }
    while (!($Import))

    #Store info in Variable
    $Dart = [ordered]@{
        Ticket   = $($Import.E.A.ID)
        IPAdress = $($Import.E.C.T.L.N[1])
        Port     = $($Import.E.C.T.L.P[1])
    }

    #TODO copy to fileshare 
    #$Dart | ConvertTo-Json | Out-File -FilePath "$PSScriptRoot\$NewComputerName.json"

}


#endregion