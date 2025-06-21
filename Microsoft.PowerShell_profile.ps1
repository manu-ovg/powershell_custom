# --- Helper for colored output (must be defined early) ---
function Write-Color {
    param ($Text, $Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

# --- Load Oh My Posh if available ---
if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomicBit.omp.json" | Invoke-Expression
} else {
    Write-Color "Oh My Posh not found. Skipping theme setup..." Yellow
}

# --- System Info ---
function sysinfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $mem = Get-CimInstance Win32_ComputerSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $gpu = Get-CimInstance Win32_VideoController
    $mb = Get-CimInstance Win32_BaseBoard

    Write-Color "=== System Information ===" Cyan
    Write-Color "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" Green
    Write-Host "OS          : $($os.Caption) $($os.Version)"
    Write-Host "CPU         : $($cpu.Name)"
    Write-Host "Memory (GB) : $([math]::Round($mem.TotalPhysicalMemory / 1GB, 2))"
    Write-Host "Disk Total  : $([math]::Round($disk.Size / 1GB, 2)) GB"
    Write-Host "Disk Free   : $([math]::Round($disk.FreeSpace / 1GB, 2)) GB"
    Write-Host "GPU         : $(($gpu | Select-Object -ExpandProperty Name) -join ', ')"
    Write-Host "Motherboard : $($mb.Manufacturer) $($mb.Product)"
    Write-Color "=========================" Cyan
}

# --- IP Info ---
function myip {
    $local = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notmatch "Loopback"} | Select-Object -First 1).IPAddress
    try {
        $public = Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 5
    } catch {
        $public = "Unable to retrieve"
    }

    Write-Color "=== IP Information ===" Cyan
    Write-Color "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" Green
    Write-Host "Local IP  : $local"
    Write-Host "Public IP : $public"
    Write-Color "=======================" Cyan
}

# --- Wi-Fi Info ---
function wifiinfo {
    Write-Color "=== Wi-Fi Info ===" Cyan
    Write-Color "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" Green

    $wifi = netsh wlan show interfaces
    $props = @{}
    foreach ($line in $wifi) {
        if ($line -match "^\s*(.+?)\s*:\s*(.+)$") {
            $props[$matches[1].Trim()] = $matches[2].Trim()
        }
    }

    if ($props['State'] -eq 'connected') {
        Write-Host "Connected SSID : $($props['SSID'])"
        Write-Host "Signal         : $($props['Signal'])"
        Write-Host "Profile        : $($props['Profile'])"
    } else {
        Write-Color "Not connected to any Wi-Fi." Red
    }

    Write-Color "`nAvailable Networks:" Green
    netsh wlan show networks mode=bssid
    Write-Color "======================" Cyan
}

# --- File Search ---
function find-file {
    param (
        [string]$Name,
        [string]$Path = "."
    )
    Write-Color "Searching for files named '*$Name*' in '$Path'..." Cyan
    $results = Get-ChildItem -Path $Path -Recurse -Filter "*$Name*" -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer }

    if ($results.Count -eq 0) {
        Write-Color "No files found." Red
    } else {
        foreach ($file in $results) {
            Write-Host $file.FullName -ForegroundColor Yellow
        }
    }
}
Set-Alias ff find-file

# --- Process List ---
function pslist {
    param (
        [string]$Name
    )

    Write-Color "=== Running Processes ===" Cyan

    $processes = if ($Name) {
        Get-Process | Where-Object { $_.Name -like "*$Name*" }
    } else {
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 15
    }

    $processes | Select-Object Name, Id, CPU, WorkingSet | Format-Table -AutoSize
    Write-Color "=========================" Cyan
}

# --- Text Search in Files ---
function fsearch {
    param(
        [string]$pattern,
        [string]$path = "."
    )
    Write-Host "Searching for '$pattern' in files under $path"

    $results = @()
    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        try {
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction Stop
            $matches = Select-String -InputObject $content -Pattern $pattern

            if ($matches) {
                foreach ($match in $matches) {
                    $results += [PSCustomObject]@{
                        Filename   = $file.FullName
                        LineNumber = $match.LineNumber
                        Line       = $match.Line.Trim()
                    }
                }
            }
        } catch { }
    }

    if ($results.Count -gt 0) {
        $results | Format-Table -AutoSize
    } else {
        Write-Host "No matches found." -ForegroundColor Yellow
    }
}

# --- Kill Process ---
function killproc {
    param([string]$name)
    Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Killed all processes named $name"
}

# --- OS Info (Fancy Box) ---
function Write-ColorLine {
    param(
        [string]$label,
        [string]$value,
        [ConsoleColor]$labelColor = 'Cyan',
        [ConsoleColor]$valueColor = 'White',
        [int]$padLength = 10
    )
    $labelText = $label.PadRight($padLength)
    Write-Host "│ " -NoNewline
    Write-Host "$labelText" -ForegroundColor $labelColor -NoNewline
    Write-Host ": $value" -ForegroundColor $valueColor
}

function myos {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $uptimeSpan = (Get-Date) - $os.LastBootUpTime

    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi','Ethernet' -ErrorAction SilentlyContinue |
           Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' } |
           Select-Object -First 1).IPAddress

    Write-Host ("╭" + ("─" * 31) + "╮") -ForegroundColor Green
    Write-Host ("│" + " System Info".PadRight(31) + "│") -ForegroundColor Green
    Write-Host ("├" + ("─" * 31) + "┤") -ForegroundColor Green
    Write-ColorLine "User" "$user@$computer"
    Write-ColorLine "OS" "$($os.Caption) ($($os.Version))"
    Write-ColorLine "CPU" $cpu.Name.Trim()
    Write-ColorLine "GPU" $gpu.Name.Trim()
    Write-ColorLine "RAM" ("{0} GB" -f [math]::Round($ramBytes / 1GB, 2))
    Write-ColorLine "Disk (C:)" ("{0} free / {1} total GB" -f [math]::Round($disk.FreeSpace / 1GB, 2), [math]::Round($disk.Size / 1GB, 2))
    Write-ColorLine "Uptime" ("{0}d {1}h {2}m" -f $uptimeSpan.Days, $uptimeSpan.Hours, $uptimeSpan.Minutes)
    Write-ColorLine "IP" $ip
    Write-Host ("╰" + ("─" * 31) + "╯") -ForegroundColor Green
}

# --- Aliases & App Launchers ---
Set-Alias .. 'Set-Location ..'
function ... { Set-Location ../../.. }
function .... { Set-Location ../../../.. }
function ..... { Set-Location ../../../../.. }

Set-Alias c Clear-Host
Set-Alias curl Invoke-WebRequest
Set-Alias wget Invoke-WebRequest
Set-Alias ff find-file

function desktop { Set-Location "$HOME\Desktop" }
function bureau { Set-Location "$HOME\Bureau" }
function docs { explorer "$HOME\Documents" }
function dls { explorer "$HOME\Downloads" }
function desk { explorer "$HOME\Desktop" }

function firefox { Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe" }
function edge { Start-Process "msedge.exe" }
function chrome { Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" }
function vscode { Start-Process "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code\Code.exe" }
function telegram {
    $path = "$env:USERPROFILE\AppData\Roaming\Telegram Desktop\Telegram.exe"
    if (Test-Path $path) {
        Start-Process $path
    } else {
        Write-Host "Telegram not found at $path" -ForegroundColor Yellow
    }
}
function obs {
    Start-Process -FilePath "C:\Program Files\obs-studio\bin\64bit\obs64.exe" -WorkingDirectory "C:\Program Files\obs-studio\bin\64bit"
}

# --- Misc ---
function np {
    param(
        [string]$filename,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$textParts
    )

    if (-not $filename) {
        Write-Host "Usage: np <filename> [text]" -ForegroundColor Yellow
        return
    }

    $text = $textParts -join ' '
    Set-Content -Path $filename -Value $text -Encoding UTF8
    Start-Process notepad.exe $filename
}

function reload {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Green
}

function proj {
    $path = "C:\Users\$env:USERNAME\Projects"
    if (Test-Path $path) {
        Set-Location $path
    } else {
        Write-Host "Folder '$path' does not exist." -ForegroundColor Yellow
    }
}

function web {
    $path = "C:\Users\$env:USERNAME\Websites"
    if (Test-Path $path) {
        Set-Location $path
    } else {
        Write-Host "Folder '$path' does not exist." -ForegroundColor Yellow
    }
}

function yt { Start-Process "https://www.youtube.com" }
function fb { Start-Process "https://www.facebook.com" }
function insta { Start-Process "https://www.instagram.com" }

function google {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$query
    )

    if ($query.Count -eq 0) {
        Start-Process "https://www.google.com"
    } else {
        $searchTerm = [uri]::EscapeDataString(($query -join ' '))
        Start-Process "https://www.google.com/search?q=$searchTerm"
    }
}

function codeproj {
    param(
        [string]$projectName
    )

    if (-not $projectName) {
        Write-Host "Usage: codeproj <projectName>" -ForegroundColor Yellow
        return
    }

    if ($projectName -match '\.[^\\/:*?"<>|]+$') {
        Write-Host "Warning: Project names should not have file extensions. Removing extension." -ForegroundColor Yellow
        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectName)
    }

    $projectPath = "C:\Users\$env:USERNAME\Projects\$projectName"

    if (-not (Test-Path $projectPath)) {
        $create = Read-Host "Project '$projectName' does not exist. Create it? (Y/N)"
        if ($create -match '^[Yy]') {
            try {
                New-Item -ItemType Directory -Path $projectPath -ErrorAction Stop | Out-Null
                Write-Host "Project folder created at '$projectPath'" -ForegroundColor Green
            } catch {
                Write-Host "Failed to create project folder: $_" -ForegroundColor Red
                return
            }
        } else {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }
    }

    code $projectPath
}

function sudo {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Command
    )

    $joined = $Command -join ' '
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& { . `$PROFILE; $joined; pause }" -Verb RunAs
}
