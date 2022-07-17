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

#* Install Microsoft ADK 
. '.\Tools\Microsoft ADK 10.1.19041.1\Deploy-Application.ps1' -DeploymentType Install -DeployMode Interactive

#* Install Microsoft ADK PE Add-ons
. '.\Tools\Microsoft ADK PE 10.1.19041.1\Deploy-Application.ps1' -DeploymentType Install -DeployMode Interactive

#* Install Microsoft MDT
. '.\Tools\Microsoft MDT 6.3.8456.100\Deploy-Application.ps1' -DeploymentType Install -DeployMode Interactive