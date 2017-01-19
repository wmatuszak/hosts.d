# Install-Managed-Hosts-File.ps1

$sHostsScript = "Update-HostsFile.ps1"
$pathRoot = $PSScriptRoot + "\"
$pathInstallScript = $pathRoot + $sHostsScript
$pathHostsRoot = $env:SystemDrive + "\Windows\System32\drivers\etc\"
$pathHostsD = $pathHostsRoot + "hosts.d\"
$pathInstalledScript = $pathHostsRoot + $sHostsScript

# Create hosts.d folder
if(-not (Test-Path $pathHostsD)) { New-Item -ItemType Directory -Path $pathHostsD -Force } 

# Install script
Copy-Item -Path $pathInstallScript -Destination $pathInstalledScript -Force

# Create base hosts file
Copy-Item -Path ($pathHostsRoot + "hosts") -Destination ($pathHostsRoot + "base.hosts") -Force

# Create the schedule tasks for the script batches
$stTaskName = "Managed Hosts File - Update hosts.d"
$stTaskDescription = "Update hosts.d - This task executes the Update-HostsFile.ps1 script that will process and update the system hosts file."
$stAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$pathInstalledScript`""
$stRepInterval = New-TimeSpan -Hours 1
$stRepDuration = New-TimeSpan -Days 10000
$stTrigger =  New-ScheduledTaskTrigger -Once -At "12:00am" -RepetitionInterval $stRepInterval -RepetitionDuration $stRepDuration
$stSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $stAction -Trigger $stTrigger -TaskName $stTaskName -Description $stTaskDescription -Settings $stSettings -User "System" -RunLevel Highest
