Function Get-Packages {
    $computer_name = [System.Net.Dns]::GetHostName()

    $fake_modules = @(
        @("Windows Server Service Pack 4", '', '204TB'),
        @("Windows .NET Framework 8.9", '', '104MB'),
        @("Windows Millennium Edition Autoinstaller", 'KB42534F44', '99MB'),
        @("Solitare 5.0 Dark Mode", '', '8KB'),
        @("Windows Pretender Self-Destruct Sequence Countdown Timer - Rollup Update 4", '', '509MB'),
        @("OSD ...---... Keyboard", 'KB534F53', '2MB'),
        @("Mouse Driver Dragclick enabler", 'KB001337', '234MB')
    )

    $packages = @()
    foreach ($m in $fake_modules) {
        $module = [PSCustomObject]@{
            ComputerName = $computer_name
            Status = '-------'
            KB = $m[1]
            Size = $m[2]
            Title = $m[0]
        }
        $packages += $module        
    }

    return $packages
}

Function Update-Package {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)][PSCustomObject]$Package,
        [Parameter(Mandatory)][ValidateSet("Rejected", "Accepted", "Downloaded", "Installed")]$Result,
        [Parameter(Mandatory)][int]$Task,
        [int[]]$lengths
    )
    begin {
        Write-Host "X ComputerName" -NoNewline
        Write-Host "$(' ' * (($lengths[0]) - 12 + 1))" -NoNewline
        Write-Host "Result" -NoNewline
        Write-Host "$(' ' * (10 - 6 + 1))" -NoNewline
        Write-Host "KB" -NoNewline
        Write-Host "$(' ' * (($lengths[1]) - 2 + 1))" -NoNewline
        Write-Host "Size" -NoNewline
        Write-Host "$(' ' * (($lengths[2]) - 4 + 1))" -NoNewline
        Write-Host "Title"
        Write-Host "- " -NoNewline
        Write-Host "------------" -NoNewline
        Write-Host "$(' ' * (($lengths[0]) - 12 + 1))" -NoNewline
        Write-Host "------" -NoNewline
        Write-Host "$(' ' * (10 - 6 + 1))" -NoNewline
        Write-Host "--" -NoNewline
        Write-Host "$(' ' * (($lengths[1]) - 2 + 1))" -NoNewline
        Write-Host "----" -NoNewline
        Write-Host "$(' ' * (($lengths[2]) - 4 + 1))" -NoNewline
        Write-Host "-----"

        $first_loop = $true
    }

    process{
        $package | Add-Member -NotePropertyName 'X' -NotePropertyValue $task -Force
        $package | Add-Member -NotePropertyName 'Result' -NotePropertyValue $Result -Force

        if (($first_loop) -And (($Result -Like "Rejected") -Or ($Result -Like "Accepted"))) {
            Start-Sleep -s 5
            $first_loop = $false
        } elseif (($Result -NotLike "Rejected") -And ($Result -NotLike "Accepted")) {
            Start-Sleep -s 1
        }

        Write-Host "$($Package.X)" -NoNewline
        Write-Host "$(' ' * 1)" -NoNewline
        Write-Host "$($Package.ComputerName)" -NoNewline
        Write-Host "$(' ' * (($lengths[0]) - $Package.ComputerName.Length + 1))" -NoNewline
        Write-Host "$($package.Result)" -NoNewline
        Write-Host "$(' ' * (10 - $Package.Result.Length + 1))" -NoNewline
        Write-Host "$($Package.KB)" -NoNewline
        Write-Host "$(' ' * (($lengths[1]) - $Package.KB.Length + 1))" -NoNewline
        Write-Host "$($Package.Size)" -NoNewline
        Write-Host "$(' ' * (($lengths[2]) - $Package.Size.Length + 1))" -NoNewline
        Write-Host "$($Package.Title)"
    }

    end {
        Write-Host ""
    }
}


Function Get-WindowsUpdate {
    <#
    .SYNOPSIS
        This function does absolutely nothing. It intention is to pretend to install some fake updated.
    
    .DESCRIPTION
        This function was build as part of a VMware vRO training session. It's purpose is to simulate download and installation of windows updates.
        
        The reson for this simulation is that the environment which the training was held in did not have internet connection, and 
        that made it impossible to use the real modules, so this was build to replace them, as the installation and download of updates was not essential to
        the goal of the course.
    
    .PARAMETER AcceptAll
        This parameter will let you accept all the fake updates. Nothing will happend of course.

    .PARAMETER Install
        This parameter will let you autoinstall the fake updates. Again .. Nothing will change except the screen output

    .PARAMETER AutoReboot
        This parameter will let choose to autoreboot the machine after the installation.

        BEWARE: THIS WILL ACCTUARLLY REBOOT THE MACHINE IF YOU SET IT

    .PARAMETER Crash
        This parameter will deliberately make this function crash. It will teach the class to handle errors.
           
    .EXAMPLE
        C:\PS>
        
        Get-WindowsUpdate -AcceptAll:$true -Install:$true -AutoReboot:$false -Crash:$true
        
    .NOTES
        Author: Brian F. Knutsson - CRIT Solutions
        Date Created: April 1, 2022
        Version: 1.0
    #>

    [CmdletBinding()]
    param( 
        [switch]$AcceptAll=$false,
        [switch]$Install=$false,
        [switch]$AutoReboot=$false,
        [switch]$Crash=$false
    )
    
    $packages = Get-Packages

    $task = '1'
    if ($AcceptAll) {
        $result = 'Accepted'
    } else {
        $result = 'Rejected'
    }

    $lengths = @(
        (($packages.ComputerName, ("-" * 12)).Split(' ') | Where-Object { $_.length -gt 1 } | Measure-Object -Maximum -Property Length).Maximum,
        (($packages.KB, ("-" * 2)).Split(' ') | Where-Object { $_.length -gt 1 } | Measure-Object -Maximum -Property Length).Maximum,
        (($packages.Size, ("-" * 4)).Split(' ') | Where-Object { $_.length -gt 1 } | Measure-Object -Maximum -Property Length).Maximum,
        ($packages.Title | Measure-Object -Maximum -Property Length).Maximum
    )

    if ($Crash) {
        throw("ERROR: There was a really weird deliberate error made by the developer.... Odd. I wonder why he did that...")
    }

    if ($Install) {
        if ($AcceptAll) {
            $packages | Update-Package -Task $task -Result $result -Lengths $lengths | Format-Table X,ComputerName,Result,KB,Size,Title -AutoSize

            $result = 'Downloaded'
            $task = '2'
            $packages | Update-Package -Task $task -Result $result -Lengths $lengths | Format-Table X,ComputerName,Result,KB,Size,Title -AutoSize

            $result = 'Installed'
            $task = '3'
            $packages | Update-Package -Task $task -Result $result -Lengths $lengths | Format-Table X,ComputerName,Result,KB,Size,Title -AutoSize

            if ($AutoReboot) {
                Write-Host "Rebooting Computer"
                #Restart-Computer
            } else {
                Write-Host "The computer needs to reboot..."
            }
        } else {
            $result = 'Rejected'
            $task = '1'
            $packages | Update-Package -Task 2 -Result $result -Lengths $lengths | Format-Table X,ComputerName,Result,KB,Size,Title -AutoSize
        }
    } else {
        $task = '1'
        $packages | Update-Package -Task 2 -Result $result -Lengths $lengths | Format-Table X,ComputerName,Result,KB,Size,Title -AutoSize
    }
}