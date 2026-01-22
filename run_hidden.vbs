Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\mic_lock.ps1", 0, False
