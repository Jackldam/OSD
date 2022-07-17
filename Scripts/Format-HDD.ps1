<#
.SYNOPSIS
    Put this script at the top of a OSD Task Sequence to clean and format the Harddisk.
.DESCRIPTION
    Put this script at the top of a OSD Task Sequence to clean and format the Harddisk.
.EXAMPLE
    n/a
.INPUTS
    n/a
.OUTPUTS
    n/a
.NOTES
    2021-03-12 Jack den Ouden Script file stored at new location.
#>
[CmdletBinding()]
param (
)

#Region load functions
Function Format-PrimaryDrive {
    <#
    .SYNOPSIS
    Formats the harddrive with the partitions needed for Windows 10 to be installed

    .DESCRIPTION
    Formats the harddrive with the partitions needed for Windows 10 to be installed
    System 512MB
    MSR 128MB
    Windows <Max Size>
    Recovery 499MB

    .EXAMPLE
    PS C:\> Format-PrimaryDrive

    .EXAMPLE
    PS C:\> New-ComputerName
    NLVE190819NZJZV

    .LINK
    PowerShell Module DictionaryFile
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $DriveLetter = "C"
    )
    try {

        function Test-VirtualMachine {
            [CmdletBinding()]
            param (
                
            )
            try {
                switch ($((Get-WmiObject -Class:"Win32_ComputerSystem").Model)) {
                    { $_ -like "*Virtual*" } { return $true }
                    { $_ -like "*VMWare*" } { return $true }
                    Default { return $false }
                }
            }
            catch {
                Write-Host "An error occurred:"
                Write-Host $_
            }
            
        }
        

        # Identify SSD after shich the Largest size
        If ($null -ne $(Get-PhysicalDisk | Where-Object MediaType -EQ "SSD")) {
            $UID = $((Get-PhysicalDisk | Where-Object MediaType -EQ "SSD").UniqueId)
        }
        else {
            $UID = $((Get-PhysicalDisk | Sort-Object Size -Descending)[0].UniqueId)
        }

        $Disk = $((Get-Disk -UniqueId:$UID).Number)
        If ($((Get-Disk -UniqueId:$UID).PartitionStyle) -eq "RAW") {
            Initialize-Disk -UniqueId:$UID -PartitionStyle GPT 
        }
        else {
            Clear-Disk -UniqueId:$UID -RemoveData -RemoveOEM -Confirm:$false 
            Initialize-Disk -UniqueId:$UID -PartitionStyle GPT 
        }

        #if VM create Recovery at begining
        if (Test-VirtualMachine) {
            #Creating Recovery Partition at the end of the drive
            New-Partition -DiskNumber:$Disk -Size:499MB -GptType:"{de94bba4-06d1-4d40-a16a-bfd50179d6ac}" -DriveLetter:"R"
            Format-Volume -DriveLetter:"R" -FileSystem:NTFS -NewFileSystemLabel:"Recovery tools"
        }
        
        #Creating System partition
        New-Partition -DiskNumber:$Disk -Size:512MB -GptType:"{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -DriveLetter:"S"
        Format-Volume -DriveLetter:"S" -FileSystem:FAT32 -NewFileSystemLabel:"System"

        #Creating Microsoft reserved partition
        New-Partition -DiskNumber:$Disk -Size:128MB -GptType:"{e3c9e316-0b5c-4db8-817d-f92df00215ae}"

        #Creating Windows Partition Format it and Label it Windows
        New-Partition -DiskNumber:$Disk -UseMaximumSize -DriveLetter:$DriveLetter
        Format-Volume -DriveLetter:$DriveLetter -FileSystem NTFS -NewFileSystemLabel:"Windows"

        #if VM create Recovery at begining
        if (-Not (Test-VirtualMachine)) {
        
            #Resize Windows Volume to leave 500MB free space at the end of the Drive
            Resize-Partition -Size:$((Get-Volume -DriveLetter:$DriveLetter).Size - 499MB) -PartitionNumber:$(Get-Partition -DriveLetter:$DriveLetter).PartitionNumber -DiskNumber:$Disk 

            #Creating Recovery Partition at the end of the drive
            New-Partition -DiskNumber:$Disk -Size:499MB -GptType:"{de94bba4-06d1-4d40-a16a-bfd50179d6ac}" -DriveLetter:"R"
            Format-Volume -DriveLetter:"R" -FileSystem:NTFS -NewFileSystemLabel:"Recovery tools"
        }

        Write-Verbose "$((Get-PhysicalDisk -UniqueId:$UID).FriendlyName) an $((Get-PhysicalDisk -UniqueId:$UID).MediaType) Drive with a size of $(((Get-PhysicalDisk -UniqueId:$UID).Size/1GB).tostring("00"))GB has been Formatted "
    
    }
    catch {
        $($Error[0].exception.gettype().fullname)
        Write-Host "An error occurred:"
        Write-Host $_ 
    }
}
#endRegion

#Formatting Disk.
try {
    Format-PrimaryDrive -ErrorAction:Stop
}
catch {

    $ButtonType = [System.Windows.Forms.MessageBoxButtons]::AbortRetryIgnore
    $MessageIcon = [System.Windows.Forms.MessageBoxIcon]::Error
    $MessageTitle = "Formatting error"
    $MessageBody = "$($_.exception.message)"
    $Result = [System.Windows.Forms.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)

    switch ($Result) {
        "Abort" { Stop-Computer -Force }
        "Retry" { Format-PrimaryDrive }
        "Ignore" {}
    }

}