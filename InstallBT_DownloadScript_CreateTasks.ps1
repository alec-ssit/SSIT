# import BurntToast module
#Create directories. Download Script and Logo.
if (-not (Test-Path "C:\Support")) {
try {
    New-Item -Path "C:\Support" -ItemType Directory -ErrorAction Stop }
    catch {
    throw "Could not create path C:\Support"
    }
    }
if (-not (Test-Path "C:\Support\RestartReminder")) {
    try {
    New-Item -Path "C:\Support\RestartReminder" -ItemType Directory -ErrorAction Stop }
    catch {
    throw "Could not create path C:\Support\RestartReminder"
    }
    }
if (-not (Test-Path "C:\Support\RestartReminder\Images")) {
    try {
    New-Item -Path "C:\Support\RestartReminder\Images" -ItemType Directory -ErrorAction Stop }
    catch {
    throw "Could not create path C:\Support\RestartReminder\Images" 
    }
    }

$RepositoryURL = "https://raw.githubusercontent.com/alec-ssit/SSIT/main/RebootReminderNotification.ps1"
$LogoURL = "https://raw.githubusercontent.com/alec-ssit/SSIT/main/logo.png"

wget $RepositoryURL -outfile "C:\Support\RestartReminder\RebootReminderNotification.ps1"
wget $LogoURL -outfile "C:\Support\RestartReminder\Images\logo.png"

#Create Scheduled Tasks
$stateChangeTrigger = Get-CimClass `
    -Namespace ROOT\Microsoft\Windows\TaskScheduler `
    -ClassName MSFT_TaskSessionStateChangeTrigger

$onUnlockTrigger = New-CimInstance `
    -CimClass $stateChangeTrigger `
    -Property @{
        StateChange = 8  # TASK_SESSION_STATE_CHANGE_TYPE.TASK_SESSION_UNLOCK (taskschd.h)
    } `
    -ClientOnly
$9amtrigger = New-ScheduledTaskTrigger -Daily -At 9AM
$455pmtrigger = New-ScheduledTaskTrigger -Daily -At 4:55PM

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-ex bypass -NoProfile -WindowStyle Hidden -file "C:\Support\RestartReminder\RebootReminderNotification.ps1"'

$principal = New-ScheduledTaskPrincipal -GroupID "BUILTIN\Users" -RunLevel Highest

Register-ScheduledTask -Action $action -Trigger $onUnlocktrigger -TaskName "RestartReminder at Unlock" -Description "Displays reminder to reboot at Workstation Unlock" -Principal $principal

Register-ScheduledTask -TaskName "RestartReminder_915AM" -Action $action -Trigger $9amtrigger -Description "Displays reminder to reboot at 9:00AM" -Principal $principal

Register-ScheduledTask -TaskName "RestartReminder_455PM" -Action $action -Trigger $455pmtrigger  -Description "Displays reminder to reboot at 4:55PM" -Principal $principal
