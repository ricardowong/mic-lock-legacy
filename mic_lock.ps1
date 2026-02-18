
# Verified compatibility with Windows 10 & 11 CoreAudio stack
# https://github.com/Abeelha/windows-mic-lock/tree/869533af4e9ca6856710d63db95f522feb8019e1
Import-Module AudioDeviceCmdlets -ErrorAction SilentlyContinue

$logFile = "C:\Scripts\mic_lock.log"
"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] MicLock started (User: $env:USERNAME, Session: $((Get-Process -Id $PID).SessionId))" | Out-File -FilePath $logFile -Append

while ($true) {
    try {
        $raw = Get-AudioDevice -RecordingVolume
        if ($raw) {
            $vol = [float]($raw.Replace('%', '').Trim())
            if ($vol -lt 100) {
                Set-AudioDevice -RecordingVolume 100
                "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Volume was $vol%, reset to 100%" | Out-File -FilePath $logFile -Append
            }
        }
    } catch {
        "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error: $_" | Out-File -FilePath $logFile -Append
    }
    Start-Sleep -Seconds 2
}

