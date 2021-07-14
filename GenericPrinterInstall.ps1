# This script works on Windows 8 or newer since the add-printer cmdlets are't available on Windows 7.
#  Download the HP Univeral Printing PCL 6 driver.

# To find\extract the .inf file, run 7-zip on the print driver .exe and go to the folder in Powershell and run this command: get-childitem *.inf* |copy-item -destination "C:\examplefolder" Otherwise it's hard to find the .inf files.

#Define a "shortName" variable and load all driver files into a [shortname].zip folder. Put driver zip file into same folder as this script

$shortName="easytotypenamehere"
$driver = "Full Name of the Driver Here"
$address = "0.0.0.0"
$name = "Printer Name as it Appears in Devices & Printers Here"
$sleep = "3"
$infFile = "driverfilehere.inf"

Get-Location
Expand-Archive -Path "$($PSScriptRoot)\$($shortName).zip" -DestinationPath "C:\Support\$($shortName)_Drivers"

# The invoke command can be added to specify a remote computer by adding -computername. You would need to copy the .inf file to the remote computer first though. 
# This script has it configured to run on the local computer that needs the printer.
# The pnputil command imports the .inf file into the Windows driverstore. 
# The .inf driver file has to be physically on the local or remote computer that the printer is being installed on.

Invoke-Command {pnputil.exe -a "C:\Support\$($shortname)_Drivers\$($infFile)" }


Add-PrinterDriver -Name $driver

Start-Sleep $sleep

# This creates the TCP\IP printer port. It also will not use the annoying WSD port type that can cause problems. 
# WSD can be used by using a different command syntax though if needed.

Add-PrinterPort -Name $address -PrinterHostAddress $address

start-sleep $sleep

Add-Printer -DriverName $driver -Name $name -PortName $address


Start-Sleep $sleep 