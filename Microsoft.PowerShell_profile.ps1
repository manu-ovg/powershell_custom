function firefox {
    Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe"
}


function vip {
    Start-Process "C:\VIP.CETRAINER"
}



function ip {
    Invoke-RestMethod -Uri "https://ifconfig.me" 
    Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).InterfaceAlias | Select-Object IPAddress

}



function sysinfo {
    Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model
    Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, NumberOfCores
}

function wifi {
    Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*Wireless*' } | Select-Object Name, InterfaceDescription, MacAddress
}

function installed {
    Get-WmiObject -Class Win32_Product | Select-Object Name, Version
}


function sysinfo {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $processor = Get-CimInstance -ClassName Win32_Processor
    $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
    $networkAdapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -eq 2 }

    Write-Host "### System Information ###"
    Write-Host "Manufacturer: $($computerSystem.Manufacturer)"
    Write-Host "Model: $($computerSystem.Model)"
    Write-Host "OS: $($operatingSystem.Caption) $($operatingSystem.Version)"
    Write-Host "BIOS Version: $($bios.Version)"
    Write-Host "Processor: $($processor.Name)"

    # Calculer la capacité totale de la mémoire
    $totalMemoryGB = ($memory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    Write-Host "Memory: $totalMemoryGB GB"

    Write-Host "Network Adapter: $($networkAdapter.Description)"
}


function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$($args[0])'"
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    } else {
        Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}

Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

function find-file($name) {
    ls -Recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
        $place_path = $_.directory
        echo "${place_path}\${_}"
    }

}
Set-Alias -Name ff -Value find-file

function pslist {
    Get-Process
}


oh-my-posh init pwsh | Invoke-Expression


# HELP

function hh {
    @"
Usage: hh [command]

Description:
This script provides custom functions and aliases for convenience.

Available Commands:
- firefox : Open Mozilla Firefox.
- vip : Open VIP.CETRAINER.
- ip : Get your public IP address.
- sysinfo : Display system information.
- admin : Run PowerShell as administrator.
- su, sudo : Aliases for admin.
- find-file : Search for files with a given name.
- pslist : List running processes
- installed : List of installed programs
- wifi : To view Wi-Fi information

Examples:
- hh firefox : Display help for the firefox command.
- hh sysinfo : Display help for the sysinfo command.
"@
}


