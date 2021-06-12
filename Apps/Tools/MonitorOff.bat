@echo off
start "" "%SystemRoot%\System32\nircmdc.exe" monitor off
start "" rundll32.exe user32.dll,LockWorkStation
exit