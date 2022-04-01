# Train a Monkey to do the boring stuff - The Workshop

## Introduction

This repository is intended for instructor led training purposes. I is created to facilitate a VMUG workshop in Denmark held in May 2022.

The workshop is intended to be executed in a VMware Hands On Lab environment. Details will follow this short introduction.

## HOL Lab
[HOL-2201-06-CMP](https://pathfinder.vmware.com/v3/activity/vmware_vrealize_automation8_hol)

vRO URL - https://vr-automation.corp.local/vco/



### Logins

| Resource                  | Username                    | Password |
| ------------------------- | --------------------------- | -------- |
| vSphere Client            | administrator@vsphere.local | VMware1! |
| vRO Control Panel         | root                        | VMware1! |
| vRO Client                | holadmin                    | VMware1! |
| Windows VM (windows-0602) | administrator               | VMware1! |



```powershell
# Clone Git repository
mkdir C:\Users\Administrator\Documents\Github
cd C:\Users\Administrator\Documents\Github
git clone https://github.com/KnutssonDevelopment/Train-a-Monkey-to-do-the-boring-stuff/
cd Train-a-Monkey-to-do-the-boring-stuff
```



## TODO

### Setup script

* Create bookmarks for relevant URLs
* Delete irrelevant URLs
* Snapshot Windows VM
  * Shutdown windows-0602
  * Take a base snapshot
  * PowerOn windows-0602
* Enable Windows Update Service
  * Revert WU GPO
  * Set Service to Manuel
  * Reboot VM
* Prepare Windows for scripting
  * Install-Module PSWindowsUpdate -Confirm:$false

```powershell
# Install PSWindowsUpdate from GIT Repo
net use Z: \\windows-0602\c$
xcopy PSModules\PSWindowsUpdate 'Z:\Program Files\WindowsPowershell\Modules\'
```



## Notes

```powershell
# Save PS module for offline install
Save-module -Name PSWindowsUpdate -Path .
```

