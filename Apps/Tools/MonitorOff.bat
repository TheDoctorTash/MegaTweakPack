@echo off
start "" "%WinDir%\nircmd.exe" monitor off
start "" rundll32.exe user32.dll,LockWorkStation
