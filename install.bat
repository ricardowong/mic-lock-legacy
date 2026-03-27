@echo off
setlocal EnableDelayedExpansion

:: Check for Administrative Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [MicLock Legacy Installer] Requesting administrative privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~dp0install.bat\"\"' -Verb RunAs"
    exit /b
)

echo ===================================================
echo   Installing Legacy MicLock (PowerShell + Task)
echo ===================================================

set "SCRIPT_DIR=%~dp0"
set "TARGET_DIR=C:\Scripts"

:: 1. Ensure target directory exists
if not exist "%TARGET_DIR%" (
    echo [*] Creating directory %TARGET_DIR%...
    mkdir "%TARGET_DIR%"
)

:: 2. Copy script files to C:\Scripts
echo [*] Copying mic_lock.ps1 and run_hidden.vbs to %TARGET_DIR%...
copy /Y "%SCRIPT_DIR%mic_lock.ps1" "%TARGET_DIR%\mic_lock.ps1" >nul
copy /Y "%SCRIPT_DIR%run_hidden.vbs" "%TARGET_DIR%\run_hidden.vbs" >nul

:: 3. Check and install AudioDeviceCmdlets PowerShell module
echo [*] Verifying AudioDeviceCmdlets module...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-Module -ListAvailable AudioDeviceCmdlets)) { Write-Host 'Installing AudioDeviceCmdlets module...'; Install-Module -Name AudioDeviceCmdlets -Scope AllUsers -Force -SkipPublisherCheck }"

:: 4. Register Scheduled Task
echo [*] Registering Windows Scheduled Task 'MicLock'...
schtasks /create /tn "MicLock" /tr "wscript.exe \"%TARGET_DIR%\run_hidden.vbs\"" /sc onlogon /rl highest /f

:: 5. Start the task immediately
echo [*] Starting task 'MicLock'...
schtasks /run /tn "MicLock"

echo.
echo [OK] Legacy MicLock has been successfully provisioned and started!
echo      Logs will be written to %TARGET_DIR%\mic_lock.log
echo.
pause
