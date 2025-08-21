# === Конфигурация ===
$DownloadUrl = "https://example.com/zenith-proxy.zip"
$InstallPath = "C:\ProgramData\SystemCache\WinUpdate"
$ZipFile = "$env:TEMP\zenith-proxy.zip"
$PythonInstallerUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
$PythonInstaller = "$env:TEMP\python310.exe"
$BatFile = Join-Path $InstallPath "zenith-service.bat"
$VbsFile = Join-Path $InstallPath "run-hidden.vbs"
$ConfigFile = Join-Path $InstallPath "config.json"
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RegName = "WinUpdateService"

# === Функция: Проверка Python 3.10 ===
function Ensure-Python310 {
    try {
        $pyver = & python --version 2>$null
        if ($pyver -like "Python 3.10*") { return $true }
    } catch {}
    return $false
}

# === Функция: Изменение имени пользователя в конфиге ===
function Change-Username {
    param([string]$NewUsername)
    
    if (-not (Test-Path $ConfigFile)) {
        Write-Host "Файл конфигурации не найден!" -ForegroundColor Red
        return $false
    }
    
    try {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        $config.authentication.username = $NewUsername
        $config | ConvertTo-Json -Depth 32 | Set-Content $ConfigFile -Encoding UTF8
        Write-Host "Имя пользователя изменено на: $NewUsername" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Ошибка при изменении конфигурации: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# === Функция: Показать меню ===
function Show-Menu {
    Clear-Host
    Write-Host "=== ZenithProxy Manager ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Изменить никнейм" -ForegroundColor Yellow
    Write-Host "2. Запустить ZenithProxy" -ForegroundColor Green
    Write-Host "3. Остановить ZenithProxy" -ForegroundColor Red
    Write-Host "4. Показать статус" -ForegroundColor White
    Write-Host "5. Переустановить" -ForegroundColor Magenta
    Write-Host "6. Удалить из автозапуска" -ForegroundColor DarkYellow
    Write-Host "7. Выход" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Выберите действие (1-7): " -NoNewline -ForegroundColor White
}

# === Функция: Запуск ZenithProxy ===
function Start-ZenithProxy {
    if (Test-Path $BatFile) {
        Write-Host "Запуск ZenithProxy..." -ForegroundColor Green
        Start-Process -WindowStyle Hidden -FilePath "wscript.exe" -ArgumentList "`"$VbsFile`" `"$BatFile`""
        Write-Host "ZenithProxy запущен в фоновом режиме" -ForegroundColor Green
    } else {
        Write-Host "Файлы ZenithProxy не найдены!" -ForegroundColor Red
    }
}

# === Функция: Остановка ZenithProxy ===
function Stop-ZenithProxy {
    try {
        $processes = Get-Process | Where-Object { $_.ProcessName -like "*java*" -or $_.ProcessName -like "*zenith*" }
        if ($processes) {
            $processes | Stop-Process -Force
            Write-Host "ZenithProxy остановлен" -ForegroundColor Green
        } else {
            Write-Host "Процессы ZenithProxy не найдены" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Ошибка при остановке: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === Функция: Показать статус ===
function Show-Status {
    Write-Host "=== Статус ZenithProxy ===" -ForegroundColor Cyan
    
    # Проверка установки
    if (Test-Path $InstallPath) {
        Write-Host "✓ Установлен в: $InstallPath" -ForegroundColor Green
    } else {
        Write-Host "✗ Не установлен" -ForegroundColor Red
    }
    
    # Проверка автозапуска
    try {
        $regValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop
        Write-Host "✓ В автозапуске" -ForegroundColor Green
    } catch {
        Write-Host "✗ Не в автозапуске" -ForegroundColor Yellow
    }
    
    # Проверка процессов
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*java*" -or $_.ProcessName -like "*zenith*" }
    if ($processes) {
        Write-Host "✓ Запущен (найдено процессов: $($processes.Count))" -ForegroundColor Green
    } else {
        Write-Host "✗ Не запущен" -ForegroundColor Yellow
    }
    
    # Показать текущий никнейм
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            Write-Host "Текущий никнейм: $($config.authentication.username)" -ForegroundColor White
        } catch {
            Write-Host "Ошибка чтения конфигурации" -ForegroundColor Red
        }
    }
}

# === Функция: Первоначальная установка ===
function Install-ZenithProxy {
    Write-Host "Установка ZenithProxy..." -ForegroundColor Yellow
    
    # === Установка Python если нужно ===
    if (-not (Ensure-Python310)) {
        Write-Host "Установка Python 3.10..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $PythonInstallerUrl -OutFile $PythonInstaller -UseBasicParsing -ErrorAction Stop
            Start-Process -FilePath $PythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait -WindowStyle Hidden
            Remove-Item $PythonInstaller -Force
            Write-Host "Python 3.10 установлен" -ForegroundColor Green
        } catch { 
            Write-Host "Ошибка установки Python: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "Python 3.10 уже установлен" -ForegroundColor Green
    }
    
    # === Скачивание архива проекта ===
    try {
        Write-Host "Скачивание ZenithProxy..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
        
        if (Test-Path $InstallPath) { 
            Remove-Item -Recurse -Force $InstallPath 
        }
        
        Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force
        Remove-Item $ZipFile -Force
        
        Write-Host "ZenithProxy распакован в $InstallPath" -ForegroundColor Green
        
        # === Создаём VBS для скрытого запуска ===
        $vbsCode = @'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run """" & WScript.Arguments(0) & """", 0, False
Set WshShell = Nothing
'@
        Set-Content -Path $VbsFile -Value $vbsCode -Encoding ASCII -Force
        
        # === Прописываем автозапуск ===
        if (Test-Path $BatFile) {
            $cmd = "wscript.exe `"$VbsFile`" `"$BatFile`""
            New-ItemProperty -Path $RegPath -Name $RegName -Value $cmd -PropertyType String -Force | Out-Null
            Write-Host "Автозапуск настроен" -ForegroundColor Green
        }
        
        Write-Host "Установка завершена успешно!" -ForegroundColor Green
        return $true
        
    } catch { 
        Write-Host "Ошибка установки: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# === Функция: Удаление из автозапуска ===
function Remove-AutoStart {
    try {
        Remove-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop
        Write-Host "Удален из автозапуска" -ForegroundColor Green
    } catch {
        Write-Host "Не найден в автозапуске" -ForegroundColor Yellow
    }
}

# === Основная логика ===

# Проверяем, установлен ли ZenithProxy
$isInstalled = Test-Path $InstallPath

if (-not $isInstalled) {
    Write-Host "ZenithProxy не установлен. Выполняем установку..." -ForegroundColor Yellow
    if (Install-ZenithProxy) {
        # Предлагаем сменить никнейм при первой установке
        Write-Host ""
        $changeNick = Read-Host "Хотите изменить никнейм? (y/N)"
        if ($changeNick -eq 'y' -or $changeNick -eq 'Y') {
            $newNick = Read-Host "Введите новый никнейм"
            if ($newNick) {
                Change-Username $newNick
            }
        }
        
        # Запуск после установки
        Start-ZenithProxy
        Write-Host ""
        Write-Host "Нажмите любую клавишу для продолжения..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "Установка не удалась!" -ForegroundColor Red
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
}

# Главное меню
do {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "=== Изменение никнейма ===" -ForegroundColor Cyan
            if (Test-Path $ConfigFile) {
                try {
                    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
                    Write-Host "Текущий никнейм: $($config.authentication.username)" -ForegroundColor White
                } catch {}
            }
            Write-Host ""
            $newNick = Read-Host "Введите новый никнейм"
            if ($newNick) {
                Change-Username $newNick
            } else {
                Write-Host "Никнейм не изменен" -ForegroundColor Yellow
            }
            Write-Host ""
            Read-Host "Нажмите Enter для продолжения"
        }
        "2" {
            Clear-Host
            Start-ZenithProxy
            Read-Host "Нажмите Enter для продолжения"
        }
        "3" {
            Clear-Host
            Stop-ZenithProxy
            Read-Host "Нажмите Enter для продолжения"
        }
        "4" {
            Clear-Host
            Show-Status
            Write-Host ""
            Read-Host "Нажмите Enter для продолжения"
        }
        "5" {
            Clear-Host
            Write-Host "Переустановка ZenithProxy..." -ForegroundColor Yellow
            Stop-ZenithProxy
            Start-Sleep 2
            Install-ZenithProxy
            Read-Host "Нажмите Enter для продолжения"
        }
        "6" {
            Clear-Host
            Remove-AutoStart
            Read-Host "Нажмите Enter для продолжения"
        }
        "7" {
            Write-Host "Выход..." -ForegroundColor Gray
            exit 0
        }
        default {
            Write-Host "Неверный выбор. Попробуйте снова." -ForegroundColor Red
            Start-Sleep 1
        }
    }
} while ($true)
