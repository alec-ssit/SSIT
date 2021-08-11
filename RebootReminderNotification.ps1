# determine days since last reboot
$os = Get-WmiObject -Namespace 'root\cimv2' -Class 'win32_OperatingSystem'
$LastBoot = $os.converttodatetime($os.lastbootuptime)
$days = ((get-date)-$lastboot).Days

# display reminder if 7+ days since last reboot
if ($days -ge 7) {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("It has been over 7 days since your PC was last restarted. Weekly Restarts are needed to ensure Business Critical Security Updates can process. Please Restart your PC ASAP.",0,"Windows Security",0)
        }
return $true
