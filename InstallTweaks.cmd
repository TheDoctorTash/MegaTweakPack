@echo off
cd /d %~dp0
reg add "HKCU\Console" /v "WindowAlpha" /t REG_DWORD /d "206" /f
%~dp0Apps\Resources\MegaTweaksPack.cmd
cls
exit /b 0