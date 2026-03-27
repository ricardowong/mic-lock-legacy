<#
.SYNOPSIS
    Provisions and registers the legacy PowerShell MicLock background task.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Administrator rights required to register a system task with 'RunLevel Highest'."
    Write-Host "Elevating prompt..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetDir = "C:\Scripts"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "Copying scripts to $targetDir..." -ForegroundColor Cyan
Copy-Item "$scriptDir\mic_lock.ps1" "$targetDir\mic_lock.ps1" -Force
Copy-Item "$scriptDir\run_hidden.vbs" "$targetDir\run_hidden.vbs" -Force

# Verify AudioDeviceCmdlets
if (-not (Get-Module -ListAvailable AudioDeviceCmdlets)) {
    Write-Host "Installing AudioDeviceCmdlets module..." -ForegroundColor Yellow
    Install-Module -Name AudioDeviceCmdlets -Scope AllUsers -Force -SkipPublisherCheck
}

# Register Scheduled Task
Write-Host "Registering Scheduled Task 'MicLock'..." -ForegroundColor Cyan
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$targetDir\run_hidden.vbs`"" -WorkingDirectory $targetDir
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -Hidden -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "MicLock" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force | Out-Null

Write-Host "Starting task 'MicLock'..." -ForegroundColor Cyan
Start-ScheduledTask -TaskName "MicLock"

Write-Host "`n[SUCCESS] Legacy MicLock provisioned and running!" -ForegroundColor Green
Write-Host "Log file: $targetDir\mic_lock.log"
