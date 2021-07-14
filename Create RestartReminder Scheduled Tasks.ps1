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

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -file "C:\Support\RestartReminder\RebootReminderNotification.ps1"'

$principal = New-ScheduledTaskPrincipal -GroupID "BUILTIN\Administrators" -RunLevel Highest

Register-ScheduledTask -Action $action -Trigger $onUnlocktrigger -TaskName "RestartReminder at Unlock" -Description "Displays reminder to reboot at Workstation Unlock" -Principal $principal

Register-ScheduledTask -TaskName "RestartReminder_915AM" -Action $action -Trigger $9amtrigger -Description "Displays reminder to reboot at 9:15AM" -Principal $principal

Register-ScheduledTask -TaskName "RestartReminder_455PM" -Action $action -Trigger $455pmtrigger  -Description "Displays reminder to reboot at 4:55PM" -Principal $principal