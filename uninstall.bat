@echo off
setlocal EnableDelayedExpansion

:: Check for Administrative Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [MicLock Legacy Uninstaller] Requesting administrative privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~dp0uninstall.bat\"\"' -Verb RunAs"
    exit /b
)

echo ===================================================
echo   Uninstalling Legacy MicLock (PowerShell + Task)
echo ===================================================

:: 1. Stop any currently running background process
echo [*] Terminating running mic_lock.ps1 background processes...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*mic_lock*' } | ForEach-Object { Write-Host \"Killing PID $($_.ProcessId)...\"; Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"

:: 2. Stop and delete the Scheduled Task
echo [*] Removing 'MicLock' from Windows Task Scheduler...
schtasks /end /tn "MicLock" >nul 2>&1
schtasks /delete /tn "MicLock" /f

:: 3. Clean up active scripts from C:\Scripts
if exist "C:\Scripts\mic_lock.ps1" (
    echo [*] Removing active C:\Scripts\mic_lock.ps1...
    del /f /q "C:\Scripts\mic_lock.ps1" >nul 2>&1
)

if exist "C:\Scripts\run_hidden.vbs" (
    echo [*] Removing active C:\Scripts\run_hidden.vbs...
    del /f /q "C:\Scripts\run_hidden.vbs" >nul 2>&1
)

echo.
echo [OK] Legacy MicLock script and Scheduled Task have been completely removed!
echo.
pause
