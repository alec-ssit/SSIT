# import BurntToast module
if (Get-Module -ListAvailable -Name 'BurntToast') {
    Import-Module -Name 'BurntToast'
} else {
    Install-Module BurntToast -Force
}

# determine days since last reboot
$os = Get-WmiObject -Namespace 'root\cimv2' -Class 'win32_OperatingSystem'
$LastBoot = $os.converttodatetime($os.lastbootuptime)
$days = ((get-date)-$lastboot).Days

# display reminder if 7+ days since last reboot
if ($days -ge 7) {
    # create text objects for the message content
    $text1 = New-BTText -Content 'Restart your PC ASAP'
    $text2 = New-BTText -Content "It has been $days days since your PC was last restarted. Please restart your PC ASAP to ensure Security Updates can process."

    # reference the company logo.png file (rename your logo to logo.png) that I prestaged in the C:\support\restartreminder\images\ folder
    $path = "C:\Support\RestartReminder"
    $image1 = New-BTImage -Source "$path\Images\logo.png" -AppLogoOverride -Crop Circle

      # assemble the notification object
    $binding1 = New-BTBinding -Children $text1, $text2 -AppLogoOverride $image1
    $visual1 = New-BTVisual -BindingGeneric $binding1
    $content1 = New-BTContent -Visual $visual1 -Scenario Reminder

    # submit the notification object to be displayed
    Submit-BTNotification -Content $content1 -UniqueIdentifier "SinglesourceITRestart"
}

return $true