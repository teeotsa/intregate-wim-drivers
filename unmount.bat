@echo off

>nul 2>&1 REG QUERY HKEY_USERS\S-1-5-20 || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

@powershell -nop -exec bypass -command "Dismount-WindowsImage -Path \"$env:TEMP\mount\" -Discard"