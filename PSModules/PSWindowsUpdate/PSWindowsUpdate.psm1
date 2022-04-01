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
        $module = [pscustomobject]@{
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
           
    .EXAMPLE
        C:\PS>
        Set-HostCompliance -VMHosts <Array of ESXi Hosts> -Action:<SCAN or FIX> -IncludeWitnessHosts:<TRUE or FALSE>
    
        # Command to Scan some hosts
        Set-HostCompliance -VMHosts $VMHosts -Action:SCAN -IncludeWitnessHosts:$true -IncludePending:$false
    
        # Command to Fix compliance issues on some hosts
        Set-HostCompliance -VMHosts $VMHosts -Action:FIX -IncludeWitnessHosts:$true -IncludePending:$false
        
    .NOTES
        Author: Brian F. Knutsson - CRIT Solutions
        Date Created: April 1, 2022
        Version: 1.0
    #>
    param( 
        [switch]$AcceptAll=$false,
        [switch]$Install=$false,
        [switch]$AutoReboot=$false
    )
    
    $packages = Get-Packages
    if ($Install) {
        $task = '1'
        if ($AcceptAll) {
            $result = 'Accepted'
            $reboot = $true
        } else {
            $result = 'Rejected'
            $reboot = $false
        }

        foreach ($package in $packages) {
            $package | Add-Member -NotePropertyName 'X' -NotePropertyValue $task
            $package | Add-Member -NotePropertyName 'Result' -NotePropertyValue $result
        }
        
        if ($AcceptAll) {
            $result = 'Downloaded'
            $task = '2'

            foreach ($package in $packages) {
                $downloaded_package = $package.PsObject.Copy()
                $downloaded_package.Result = $result
                $downloaded_package.X = $task
                $packages += $downloaded_package
            }

            $result = 'Installed'
            $task = '3'

            foreach ($package in $packages) {
                if ($package.X -like '1') {
                    $downloaded_package = $package.PsObject.Copy()
                    $downloaded_package.Result = $result
                    $downloaded_package.X = $task
                    $packages += $downloaded_package
                }
            }

            if ($AutoReboot) {
                Restart-Computer
            }
        }
        
        return $packages | ft X,ComputerName,Result,KB,Size,Title -AutoSize

    } else {
        $reboot = $false
        $packages | ft -AutoSize
    }
}