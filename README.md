# PowerShell Custom Script

This custom PowerShell script provides useful features and shortcuts to facilitate various everyday tasks.

## Included Features

App Launchers
firefox — Opens Mozilla Firefox.

edge — Opens Microsoft Edge.

chrome — Opens Google Chrome.

vscode — Opens Visual Studio Code.

telegram — Opens Telegram Desktop.

System & Network Info
sysinfo — Displays detailed system information (OS, CPU, RAM, disk, GPU, motherboard).

myip — Shows local and public IP addresses.

wifiinfo — Displays Wi-Fi connection details and available networks.

myos — A neofetch-like system info summary with colored box output.

File & Process Management
find-file or ff — Search for files by name recursively.

fsearch — Search inside files for a text pattern recursively.

pslist — Lists running processes, sorted by CPU or filtered by name.

killproc — Kills all processes matching a name.

Directory Navigation
.. — Go up one directory.

... — Go up three directories.

.... — Go up four directories.

..... — Go up five directories.

desktop — Change directory to your Desktop folder.

bureau — Change directory to the French equivalent Desktop folder.

Utilities & Others
docs — Opens the Documents folder in Explorer.

dls — Opens the Downloads folder.

desk — Opens the Desktop folder.

admin, su, sudo — Run PowerShell as administrator.

oh-my-posh — Loads your Oh My Posh theme if installed.




## How to Use

1. Open terminal 
2. Copy paste the PowerShell script by opening a console and using the command ``notepad $PROFILE`` or ``New-Item -ItemType File -Path $PROFILE -Force``
3. If you have some error remove ohmyposh or read : https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4

## Requirements

- PowerShell 5.1 or later.
- oh-my-posh for console themes (optional).

## Notes

- Ensure you have administrator rights to run certain commands. (find-file)
- Some features may require adjustments based on your environment.


