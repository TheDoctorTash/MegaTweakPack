@echo off
cd /d %~dp0
reg add "HKCU\Console" /v "WindowAlpha" /t REG_DWORD /d "206" /f >nul 2>&1
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f >nul 2>&1
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowSize" /t REG_DWORD /d "2228361" /f >nul 2>&1
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowPosition" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f >nul 2>&1
reg add "HKCU\Console\%%SystemRoot%%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f >nul 2>&1
%~dp0Apps\Resources\MegaTweaksPack.cmd
cls
exit /b 0