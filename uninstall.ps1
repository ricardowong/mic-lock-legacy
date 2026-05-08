<#
.SYNOPSIS
    Uninstalls and de-provisions the legacy PowerShell MicLock background task.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Administrator rights required to delete a task with 'RunLevel Highest'."
    Write-Host "Elevating prompt..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Terminating background mic_lock processes..." -ForegroundColor Cyan
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*mic_lock*" } | ForEach-Object {
    Write-Host "Stopping process PID $($_.ProcessId)..."
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
}

Write-Host "Stopping and deleting Scheduled Task 'MicLock'..." -ForegroundColor Cyan
try {
    Stop-ScheduledTask -TaskName "MicLock" -ErrorAction SilentlyContinue
} catch {}

try {
    Unregister-ScheduledTask -TaskName "MicLock" -Confirm:$false -ErrorAction Stop
    Write-Host "Task 'MicLock' successfully removed." -ForegroundColor Green
} catch {
    Write-Warning "Task 'MicLock' was not found or failed to unregister: $_"
}

# Clean active scripts in C:\Scripts
if (Test-Path "C:\Scripts\mic_lock.ps1") {
    Remove-Item "C:\Scripts\mic_lock.ps1" -Force -ErrorAction SilentlyContinue
    Write-Host "Removed C:\Scripts\mic_lock.ps1"
}
if (Test-Path "C:\Scripts\run_hidden.vbs") {
    Remove-Item "C:\Scripts\run_hidden.vbs" -Force -ErrorAction SilentlyContinue
    Write-Host "Removed C:\Scripts\run_hidden.vbs"
}

Write-Host "`n[SUCCESS] Legacy MicLock completely removed!" -ForegroundColor Green
