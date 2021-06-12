@echo off
echo off
chcp 1251 | break
setlocal enableextensions enabledelayedexpansion
if defined SAFEBOOT_OPTION (
	echo  *** Вы находитесь в безопасном режиме^! Данный скрипт предназначен только для запуска в обычном режиме. ***
	timeout /t 10 /nobreak | break
	goto :eof
)
ver | findstr /i "10.0." | break
if %errorLevel% neq 0 (
	echo  *** Ваша ОС не поддерживается^! Данный скрипт предназначен только для применения в ОС Windows 10. ***
	timeout /t 10 /nobreak | break
	goto :eof
)
reg query "HKU\S-1-5-19\Environment" & cls
if %errorlevel% neq 0 (
	echo: Set UAC = CreateObject^("Shell.Application"^) > "%~dp0..\..\Logs\getadmin.vbs"
	echo: UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%~dp0..\..\Logs\getadmin.vbs"
	"%~dp0..\..\Logs\getadmin.vbs" goto :eof )
if exist "%~dp0..\..\Logs\getadmin.vbs" ( del /f /q "%~dp0..\..\Logs\getadmin.vbs" ) & goto :eof
rem #########################################################################################################################################################################################################################
call :clr
chcp 1251 | break
pushd "%cd%"
cd /d "%~dp0"
if /i not "%cd%\"=="%~dp0" cd /d "%~dp0"
set tmpfile=%~dp0..\..\Logs\timer.dat
time /t > %tmpfile%
set /p ftime= < %tmpfile%
set daytime=%date:~6%%date:~3,2%%date:~0,2%_%ftime:~0,2%%ftime:~3,2%
set logfile=%~dp0..\..\Logs\MegaTweakPack_%daytime%.txt
set arch=x64&(if "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 set arch=x86)
set SystemUser=%~dp0superUser_%arch%.exe -w -c
powershell "Set-ExecutionPolicy Unrestricted" | break
set autoChoose=30
set keySelY="Задача будет запущена автоматически через %autoChoose% секунд. [Y:Запуск / N:Отмена]"
set keySelN="Задача будет пропущена автоматически через %autoChoose% секунд. [Y:Запуск / N:Отмена]"
cls
rem #########################################################################################################################################################################################################################
set title=MegaTweaksPack for Highest Performance %version%
set version=v0.8 by TheDoctor
title %title%
@echo %clr%[42m %title% %clr%[0m
@echo *** %title% *** 1>> %logfile%
echo. 1>> %logfile%
timeout /t 5 /nobreak | break
%~dp0ExitExplorer.exe
call :kill "explorer.exe"
echo.
rem #########################################################################################################################################################################################################################
@echo %clr%[36mСоздание точки восстановления. Пожалуйста, подождите...%clr%[92m
@echo Создание точки восстановления. Пожалуйста, подождите... 1>> %logfile%
set timerStart=!time!
%SystemUser% reg.exe load "HKU\.DEFAULT" "%HomeDrive%\Users\Default\NTUSER.DAT" 1>> %logfile% 2>>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "DisableConfig" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "DisableSR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableConfig" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
sc config srservice start=auto 1>> %logfile% 2>>&1
powershell "$SysDrive = $env:SystemDrive; Enable-ComputerRestore $SysDrive" 1>> %logfile% 2>>&1
cmd.exe /c "vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10GB" 1>> %logfile% 2>>&1
::powershell "Checkpoint-Computer -Description 'Установлен MegaTweakPack - %date%' -RestorePointType 'MODIFY_SETTINGS'" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo.
rem #########################################################################################################################################################################################################################
@echo %clr%[36mВыполнить обслуживание ОС? ^(это может занять ~40 минут^)%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo.
	@echo %clr%[36mВыполнение обслуживания ОС. Пожалуйста, подождите...%clr%[92m
	@echo Выполнение обслуживания ОС. Пожалуйста, подождите... 1>> %logfile%
	set timerStart=!time!
	powershell -ExecutionPolicy Bypass -file "%~dp0OutdatedDrivers.ps1" -wa SilentlyContinue 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\ngen.exe update /force /queue 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\ngen.exe update /force /queue 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\ngen.exe executequeueditems 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\ngen.exe executequeueditems 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /force /queue 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe update /force /queue 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\ngen.exe executequeueditems 1>> %logfile% 2>>&1
	::%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe executequeueditems 1>> %logfile% 2>>&1
	::dism /online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth 1>> %logfile% 2>>&1
	sfc /scannow 1>> %logfile% 2>>&1
	del /f /q /s "%HomeDrive%\$Recycle.Bin\S-1-5*\*" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\Microsoft\Network\Downloader\*" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\Microsoft\SmsRouter\MessageStore\*" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\Microsoft\Windows\Containers\Dumps\*" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\Microsoft\Windows\WER\*" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\NVIDIA\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\NVIDIA\*.log_backup1" 1>> %logfile% 2>>&1
	del /f /q /s "%ProgramData%\NVIDIA Corporation\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\CLR_v2.0\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\CLR_v4.0\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\CLR_v4.0_32\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\config\systemprofile\AppData\Local\Microsoft\Windows\WebCache\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Internet Explorer\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Internet Explorer\CacheStorage\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Internet Explorer\Indexed DB\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Terminal Server Client\Cache\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Windows\INetCache\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Windows\WebCache\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Microsoft\Windows\History\desktop.ini" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\SquirrelTemp\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Temp\*" 1>> %logfile% 2>>&1
	del /f /q /s "%LocalAppdata%\Windows\WebCache\*" 1>> %logfile% 2>>&1
	del /f /q /s "%Appdata%\Macromedia\Flash Player\macromedia.com\support\flashplayer\sys\settings.sol" 1>> %logfile% 2>>&1
	del /f /q /s "%Appdata%\Microsoft\Windows\Recent\*" 1>> %logfile% 2>>&1
	del /f /q /s "%UserProfile%\MicrosoftEdgeBackups" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Installer\$PatchCache$\Managed\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\debug\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\INF\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Logs\*" 1>> %logfile% 2>>&1
	call :acl_folders "%SystemRoot%\Logs\waasmedic"
	%SystemUser% del /f /q /s "%SystemRoot%\Logs\waasmedic\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Panther\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\Temp\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\security\logs\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\Temp\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Temp\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\SoftwareDistribution\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\catroot2\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\catroot2\*.chk" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\GroupPolicy\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\LogFiles\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\MsDtc\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\sru\*.log" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\sru\*.chk" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*" 1>> %logfile% 2>>&1
	del /f /q /s "%SystemRoot%\System32\config\systemprofile\AppData\Local\Microsoft\Windows\WebCache\*" 1>> %logfile% 2>>&1
	reg delete "HKCR\DesktopBackground\Shell\UWTSettings" /f 1>> %logfile% 2>>&1
	powershell "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' -Name * -Force -wa SilentlyContinue" 1>> %logfile% 2>>&1
	for /f "tokens=* delims=" %%l in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /s /v "StateFlags0001"^|FindStr HKEY_') do (reg add "%%l" /v "StateFlags0001" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\DownloadsFolder" /v "StateFlags0001" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	cleanmgr sagerun:1 1>> %logfile% 2>>&1
	%~dp0\..\Cleanmgr+\Cleanmgr+.exe /nowindow 1>> %logfile% 2>>&1
	for /f "tokens=* delims=" %%i in ('wevtutil el') do (wevtutil cl "%%i" 1>> %logfile% 2>>&1)
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
	timeout /t 3 /nobreak | break
)
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Загрузка %clr%[0m
@echo Загрузка 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Время ожидания выбора ОС.%clr%[92m
@echo Время ожидания выбора ОС. 1>> %logfile%
set timerStart=!time!
bcdedit /timeout 2 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Включить NumLock при загрузке.%clr%[92m
@echo Включить NumLock при загрузке. 1>> %logfile%
set timerStart=!time!
bcdedit /set numlock Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Отключить режим автоматического восстановления во время загрузки, если система не завершила предыдущую загрузку или завершение работы.%clr%[92m
@echo Отключить режим автоматического восстановления во время загрузки, если система не завершила предыдущую загрузку или завершение работы. 1>> %logfile%
set timerStart=!time!
bcdedit /set bootstatuspolicy IgnoreAllFailures 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Отключить использование сторонней оболочки при загрузке в безопасном режиме.%clr%[92m
@echo Отключить использование сторонней оболочки при загрузке в безопасном режиме. 1>> %logfile%
set timerStart=!time!
bcdedit /set safebootalternateshell No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Память %clr%[0m
@echo Память 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Избегать использования памяти ниже указанного физического адреса в загрузчике.%clr%[92m
@echo Избегать использования памяти ниже указанного физического адреса в загрузчике.>> %logfile%
set timerStart=!time!
bcdedit /set avoidlowmemory 0x8000000 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Контролирует включение и выключение пятиуровневой подкачки для приложений (возможные значения: default, optout, optin).%clr%[92m
@echo Контролирует включение и выключение пятиуровневой подкачки для приложений (возможные значения: default, optout, optin).>> %logfile%
set timerStart=!time!
bcdedit /set linearaddress57 optout 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Использовать полный объем оперативной памяти.%clr%[92m
@echo Использовать полный объем оперативной памяти.>> %logfile%
set timerStart=!time!
bcdedit /set removememory 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Отключить режим PAE (расширение физического адреса). Позволяет использовать более 4 ГБ оперативной памяти в 32-битной ОС (возможные значения: Default, ForceEnable, ForceDisable).%clr%[92m
@echo Отключить режим PAE (расширение физического адреса). Позволяет использовать более 4 ГБ оперативной памяти в 32-битной ОС (возможные значения: Default, ForceEnable, ForceDisable).>> %logfile%
set timerStart=!time!
bcdedit /set pae ForceDisable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Отключить DEP (предотвращение выполнения данных). Параметр доступен только в 32-битных ОС при работе на процессорах, поддерживающих память без выполнения, и только тогда, когда включен PAE. (возможные значения: OptIn, OptOut, AlwaysOff, AlwaysOn).%clr%[92m
@echo Отключить DEP (предотвращение выполнения данных). Параметр доступен только в 32-битных ОС при работе на процессорах, поддерживающих память без выполнения, и только тогда, когда включен PAE. (возможные значения: OptIn, OptOut, AlwaysOff, AlwaysOn). 1>> %logfile%
set timerStart=!time!
bcdedit /set nx AlwaysOff 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Предотвратить системе выделять приложениям до 3 ГБ виртуального адресного пространства. Данный параметр удаляется из BCD в связи с проблемами с памятью пула страниц.%clr%[92m
@echo Предотвратить системе выделять приложениям до 3 ГБ виртуального адресного пространства. Данный параметр удаляется из BCD в связи с проблемами с памятью пула страниц.>> %logfile%
set timerStart=!time!
bcdedit /deletevalue increaseuserva 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Запретить загрузку системных файлов и драйверов в область памяти за пределы 4 ГБ.%clr%[92m
@echo Запретить загрузку системных файлов и драйверов в область памяти за пределы 4 ГБ.>> %logfile%
set timerStart=!time!
bcdedit /set nolowmem No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Устройства и оборудование %clr%[0m
@echo Устройства и оборудование 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить запуск RTOS (операционная система реального времени) для разгрузки ядер процессора.%clr%[92m
@echo Отключить запуск RTOS (операционная система реального времени) для разгрузки ядер процессора. 1>> %logfile%
set timerStart=!time!
bcdedit /deletevalue firstmegabytepolicy 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Использовать поддержку BIOS загрузочным приложениям для расширенного ввода с консоли.%clr%[92m
@echo Использовать поддержку BIOS загрузочным приложениям для расширенного ввода с консоли. 1>> %logfile%
set timerStart=!time!
bcdedit /set extendedinput Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Устранить проблему с нехваткой ресурсов для устройств в диспетчере устройств.%clr%[92m
@echo Устранить проблему с нехваткой ресурсов для устройств в диспетчере устройств. 1>> %logfile%
set timerStart=!time!
bcdedit /set configaccesspolicy DisallowMmConfig 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Процессоры и контроллеры APIC %clr%[0m
@echo Процессоры и контроллеры APIC 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Удалить используемый поток процессора для RTOS.%clr%[92m
@echo Удалить используемый поток процессора для RTOS. 1>> %logfile%
set timerStart=!time!
bcdedit /deletevalue numproc 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Использовать максимальное число потоков процессора в ОС.%clr%[92m
@echo Использовать максимальное число потоков процессора в ОС. 1>> %logfile%
set timerStart=!time!
bcdedit /set maxproc Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Использовать все логические ядра процессора.%clr%[92m
@echo Использовать все логические ядра процессора. 1>> %logfile%
set timerStart=!time!
bcdedit /set onecpu No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Отключить физическое использование улучшенного программируемого контроллера прерываний (APIC).%clr%[92m
@echo Отключить физическое использование улучшенного программируемого контроллера прерываний (APIC). 1>> %logfile%
set timerStart=!time!
bcdedit /set usephysicaldestination No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Отключить использование устаревшего режима улучшенного программируемого контроллера прерываний (APIC).%clr%[92m
@echo Отключить использование устаревшего режима улучшенного программируемого контроллера прерываний (APIC). 1>> %logfile%
set timerStart=!time!
bcdedit /set uselegacyapicmode No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Включить использование расширенного режима APIC.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m предварительно включите x2APIC в BIOS после перезагрузки.
@echo Включить использование расширенного режима APIC. Предупреждение: предварительно включите x2APIC в BIOS после перезагрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set x2apicpolicy Enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 7)%clr%[36m Включить расширение системы команд x86 для микропроцессоров Intel и AMD инструкции в ОС (AVX).%clr%[92m
@echo Включить расширение системы команд x86 для микропроцессоров Intel и AMD инструкции в ОС (AVX). 1>> %logfile%
set timerStart=!time!
bcdedit /set xsavedisable 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 8)%clr%[36m Отключить ограничения памяти ядра для запуска BitLocker.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m вызывает сбои/циклы загрузки, если включен Intel Software Guard Extensions.%clr%[92m
@echo Отключить ограничения памяти ядра для запуска BitLocker. Предупреждение:вызывает сбои/циклы загрузки, если включен Intel Software Guard Extensions. 1>> %logfile%
set timerStart=!time!
bcdedit /set allowedinmemorysettings 0x0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 9)%clr%[36m Отключить принудительное шифрование федеральных стандартов обработки информации (FIPS).%clr%[92m
@echo Отключить принудительное шифрование федеральных стандартов обработки информации (FIPS). 1>> %logfile%
set timerStart=!time!
bcdedit /set forcefipscrypto No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 10)%clr%[36m Задать флаги конфигурации, специфические для процессора.%clr%[92m
@echo Задать флаги конфигурации, специфические для процессора. 1>> %logfile%
set timerStart=!time!
bcdedit /set configflags 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Слой абстрагирования оборудования (HAL) и ядра (KERNEL) %clr%[0m
@echo Слой абстрагирования оборудования (HAL) и ядра (KERNEL) 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить специальную точку останова слоя абстрагирования оборудования (HAL).%clr%[92m
@echo Отключить специальную точку останова слоя абстрагирования оборудования (HAL). 1>> %logfile%
set timerStart=!time!
bcdedit /set halbreakpoint No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Отключить таймер событий высокой точности (High Precision Event Timer).%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m предварительно включите HPET в BIOS после перезагрузки.
@echo Отключить таймер событий высокой точности (High Precision Event Timer). Предупреждение: предварительно включите HPET в BIOS после перезагрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /deletevalue useplatformclock 1>> %logfile% 2>>&1
bcdedit /set useplatformclock No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Запретить поддержку устаревших устройств (CMOS, контроллер клавиатуры и т.д).%clr%[92m
@echo Запретить поддержку устаревших устройств (CMOS, контроллер клавиатуры и т.д). 1>> %logfile%
set timerStart=!time!
bcdedit /set forcelegacyplatform No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Включить расширенную временную синхронизацию (возможные значения: Legacy, Enhanced).%clr%[92m
@echo Включить расширенную временную синхронизацию (возможные значения: Legacy, Enhanced). 1>> %logfile%
set timerStart=!time!
bcdedit /set tscsyncpolicy Enhanced 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Использовать таймеры платформы в качестве счетчика производительности системы.%clr%[92m
@echo Использовать таймеры платформы в качестве счетчика производительности системы. 1>> %logfile%
set timerStart=!time!
bcdedit /set useplatformtick Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Отключить динамические процессорные такты.%clr%[92m
@echo Отключить динамические процессорные такты. 1>> %logfile%
set timerStart=!time!
bcdedit /deletevalue disabledynamictick 1>> %logfile% 2>>&1
bcdedit /set disabledynamictick Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m VESA, PCI, VGA и TPM %clr%[0m
@echo VESA, PCI, VGA и TPM 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Запретить PCI-устройствам выполнение динамического назначения IRQ и других ресурсов ввода-вывода (блокировка PCI).%clr%[92m
@echo Запретить PCI-устройствам выполнение динамического назначения IRQ и других ресурсов ввода-вывода (блокировка PCI). 1>> %logfile%
set timerStart=!time!
bcdedit /set usefirmwarepcisettings No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 2)%clr%[36m Включить прерывания, инициируемые сообщениями от PCI, PCI-X, PCI Express (MSI).%clr%[92m
@echo Включить прерывания, инициируемые сообщениями от PCI, PCI-X, PCI Express (MSI). 1>> %logfile%
set timerStart=!time!
bcdedit /set MSI Default 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 3)%clr%[36m Включить политику энтропии загрузки TPM и передать ее ядру (TPM заполняет генератор случайных чисел (RNG) ядра данными).%clr%[92m
@echo Включить политику энтропии загрузки TPM и передать ее ядру (при использовании энтропии загрузки TPM заполняет генератор случайных чисел (RNG) ядра данными). 1>> %logfile%
set timerStart=!time!
bcdedit /set tpmbootentropy ForceEnable 1>> %logfile% 2>>&1
call :demand_svc_sudo TPM
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 4)%clr%[36m Отключить режим VGA (исправляет черный экран при загрузке на некоторых видеокартах).%clr%[92m
@echo Отключить режим VGA (исправляет черный экран при загрузке на некоторых видеокартах). 1>> %logfile%
set timerStart=!time!
bcdedit /set novesa yes 1>> %logfile% 2>>&1
bcdedit /set novga yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 5)%clr%[36m Отключить встроенный контроль PCI Express (возможные значения: default, forcedisable).%clr%[92m
@echo Отключить встроенный контроль PCI Express (возможные значения: default, forcedisable). 1>> %logfile%
set timerStart=!time!
bcdedit /set pciexpress forcedisable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Драйверы %clr%[0m
@echo Драйверы 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить службы аварийного управления для операционной системы.%clr%[92m
@echo Отключить службы аварийного управления для операционной системы. 1>> %logfile%
set timerStart=!time!
bcdedit /ems Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 2)%clr%[36m Отключить службы аварийного управления для приложений загрузки.%clr%[92m
@echo Отключить службы аварийного управления для приложений загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /bootems Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 3)%clr%[36m Отключить тестовый режим.%clr%[92m
@echo Отключить тестовый режим. 1>> %logfile%
set timerStart=!time!
bcdedit /set testsigning No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo %clr%[91m 4)%clr%[36m Отключить проверку цифровой подписи драйверов.%clr%[92m
@echo Отключить проверку цифровой подписи драйверов. 1>> %logfile%
set timerStart=!time!
bcdedit /set nointegritychecks Yes 1>> %logfile% 2>>&1
bcdedit /set loadoptions DDISABLE_INTEGRITY_CHECKS 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Отключить отображение имен драйверов в процессе загрузки.%clr%[92m
@echo Отключить отображение имен драйверов в процессе загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set sos No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Экраны ошибок %clr%[0m
@echo Экраны ошибок 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить завершение работы после отображения экрана ошибки.%clr%[92m
@echo Отключить завершение работы после отображения экрана ошибки. 1>> %logfile%
set timerStart=!time!
bcdedit /set bootshutdowndisabled Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Задать тип графического интерфейса при ошибках загрузки.%clr%[92m
@echo Задать тип графического интерфейса при ошибках загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set booterrorux Simple 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Отладка и логирование %clr%[0m
@echo Отладка и логирование 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить журнал загрузки.%clr%[92m
@echo Отключить журнал загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set bootlog No 1>> %logfile% 2>>&1
bcdedit /event Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Формат журнала загрузки (возможные значения: Default, Sha1).%clr%[92m
@echo Формат журнала загрузки (возможные значения: Default, Sha1). 1>> %logfile%
set timerStart=!time!
bcdedit /set measuredbootlogformat Default 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Отключить отладку.%clr%[92m
@echo Отключить отладку. 1>> %logfile%
set timerStart=!time!
bcdedit /dbgsettings LOCAL /start Disable 1>> %logfile% 2>>&1
bcdedit /dbgsettings USB /start Disable 1>> %logfile% 2>>&1
bcdedit /dbgsettings SERIAL /start Disable 1>> %logfile% 2>>&1
bcdedit /bootdebug Off 1>> %logfile% 2>>&1
bcdedit /debug Off 1>> %logfile% 2>>&1
bcdedit /set debug No 1>> %logfile% 2>>&1
bcdedit /set debugstart Disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Отключить выделение памяти для тестирования производительности.%clr%[92m
@echo Отключить выделение памяти для тестирования производительности. 1>> %logfile%
set timerStart=!time!
bcdedit /set perfmem 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Исправить зависание при загрузке при включеном режиме отладки.%clr%[92m
@echo Исправить зависание при загрузке при включеном режиме отладки. 1>> %logfile%
set timerStart=!time!
bcdedit /set noumex Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Настройки низкоуровневой оболочки %clr%[0m
@echo Настройки низкоуровневой оболочки 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить отладку гипервизора.%clr%[92m
@echo Отключить отладку гипервизора. 1>> %logfile%
set timerStart=!time!
bcdedit /set hypervisordebug No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Включить защиту от CVE-2018-3646 для виртуальных машин.%clr%[92m
@echo Включить защиту от CVE-2018-3646 для виртуальных машин. 1>> %logfile%
set timerStart=!time!
bcdedit /set hypervisorschedulertype Core 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Включить загрузку гипервизора в системе для Hyper-V.%clr%[92m
@echo Включить загрузку гипервизора в системе для Hyper-V. 1>> %logfile%
set timerStart=!time!
bcdedit /set hypervisorlaunchtype Auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Включить политику IOMMU (блок управления памятью для операций ввода-вывода) низкоуровневой оболочки (возможные значения: default, enable, disable).%clr%[92m
@echo Включить политику IOMMU (блок управления памятью для операций ввода-вывода) низкоуровневой оболочки (возможные значения: default, enable, disable). 1>> %logfile%
set timerStart=!time!
bcdedit /set hypervisoriommupolicy Enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Использовать гипервизору большее количество записей виртуального TLB (буфер ассоциативной трансляции).%clr%[92m
@echo Использовать гипервизору большее количество записей виртуального TLB (буфер ассоциативной трансляции). 1>> %logfile%
set timerStart=!time!
bcdedit /set hypervisoruselargevtlb Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Отключить безопасный режим памяти DMA и изоляцию ядер для машин Hyper-V.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m включение режима может привести к сбою старых приложений и драйверов или даже к BSOD.
@echo Отключить безопасный режим памяти DMA и изоляцию ядер для машин Hyper-V. Предупреждение: включение режима может привести к сбою старых приложений и драйверов или даже к BSOD. 1>> %logfile%
set timerStart=!time!
bcdedit /set vsmlaunchtype Off 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Отключить изоляцию процессов через защитник Windows в виртуальном окружении.%clr%[92m
@echo Отключить изоляцию процессов через защитник Windows в виртуальном окружении. 1>> %logfile%
set timerStart=!time!
bcdedit /set isolatedcontext No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Отображение %clr%[0m
@echo Отображение 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[36m Скрыть экран приветствия при входе в систему.%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m работает только в редакциях Education и Enterprise.
@echo Скрыть экран приветствия при входе в систему. Примечание: работает только в редакциях Education и Enterprise. 1>> %logfile%
set timerStart=!time!
xcopy %~dp0Rexplorer.exe %SystemRoot% /c /q /h /r /y 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\BrandingNeutral" /v "HideAutoLogonUI" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v "HideAutoLogonUI" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v "HideFirstLogonAnimation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f 1>> %logfile% 2>>&1
for /f "tokens=2" %%i in ('whoami /user /fo table /nh') do set SID=%%i
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\Shell Launcher\%SID%" /v "Shell" /t REG_SZ /d "explorer.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\Shell Launcher\%SID%" /v "DefaultReturnCodeAction" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\Shell Launcher\S-1-5-32-544" /v "Shell" /t REG_SZ /d "explorer.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Embedded\Shell Launcher\S-1-5-32-544" /v "DefaultReturnCodeAction" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo. 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить использование анимации при запуске.%clr%[92m
@echo Отключить использование анимации при запуске. 1>> %logfile%
set timerStart=!time!
bcdedit /set bootux Disabled 1>> %logfile% 2>>&1
bcdedit /set {globalsettings} bootuxdisabled Yes 1>> %logfile% 2>>&1
bcdedit /set {globalsettings} nobootuxtext Yes 1>> %logfile% 2>>&1
bcdedit /set {globalsettings} nobootuxprogress Yes 1>> %logfile% 2>>&1
bcdedit /set {globalsettings} nobootuxfade Yes 1>> %logfile% 2>>&1
bcdedit /set {bootmgr} noerrordisplay Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 7)%clr%[36m Отключить логотип загрузки.%clr%[92m
@echo Отключить логотип загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000067 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 8)%clr%[36m Отключить круг анимации загрузки.%clr%[92m
@echo Отключить круг анимации загрузки. 1>> %logfile%
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000069 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 9)%clr%[36m Отключить загрузочные сообщения.%clr%[92m
@echo Отключить загрузочные сообщения. 1>> %logfile%
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000068 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
@echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Время перехода анимации при возобновлении.%clr%[92m
@echo Время перехода анимации при возобновлении. 1>> %logfile%
set timerStart=!time!
bcdedit /set bootuxtransitiontime 1 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Включить отображение растрового изображения с высоким разрешением вместо отображения экрана загрузки Windows и анимации.%clr%[92m
@echo Включить отображение растрового изображения с высоким разрешением вместо отображения экрана загрузки Windows и анимации. 1>> %logfile%
set timerStart=!time!
bcdedit /set quietboot Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Включить текстовый режим загрузки через клавишу F8 (возможные значения: Legacy, Standard).%clr%[92m
@echo Включить текстовый режим загрузки через клавишу F8 (возможные значения: Legacy, Standard). 1>> %logfile%
set timerStart=!time!
bcdedit /set bootmenupolicy Legacy 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Отключить графический режим для загрузочных приложений.%clr%[92m
@echo Отключить графический режим для загрузочных приложений. 1>> %logfile%
set timerStart=!time!
bcdedit /set graphicsmodedisabled Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Разрешить приложениям загрузки использовать максимальный графический режим, предоставляемый встроенным ПО.%clr%[92m
@echo Разрешить приложениям загрузки использовать максимальный графический режим, предоставляемый встроенным ПО. 1>> %logfile%
set timerStart=!time!
bcdedit /set highestmode Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
timeout /t 3 /nobreak | break
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Windows Defender, SmartScreen и Edge %clr%[0m
@echo Windows Defender, SmartScreen и Edge 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить Windows Defender Antivirus?%clr%[92m
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
	echo Отключение Windows Defender Antivirus. Пожалуйста подождите...
	@echo Отключение Windows Defender Antivirus. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	powershell "Set-MpPreference -EnableControlledFolderAccess Disabled -wa SilentlyContinue" 1>> %logfile% 2>>&1
	powershell "Set-MpPreference -EnableNetworkProtection Disabled -wa SilentlyContinue" 1>> %logfile% 2>>&1
	powershell "Set-MpPreference -PUAProtection Disabled -wa SilentlyContinue" 1>> %logfile% 2>>&1
	setx /m MP_FORCE_USE_SANDBOX 0 1>> %logfile% 2>>&1
	bcdedit /set disableelamdrivers Yes 1>> %logfile% 2>>&1
	%SystemUser% net stop WinDefend 1>> %logfile% 2>>&1
	%SystemUser% net stop WdNisSvc 1>> %logfile% 2>>&1
	powershell "Disable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
	powershell "Disable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-Default-Definitions -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
	call :acl_registry "SOFTWARE\Microsoft\Windows Defender"
	call :acl_registry "SOFTWARE\Microsoft\Windows Defender\Features"
	call :acl_registry "SOFTWARE\Microsoft\Windows Defender\Real-Time Protection"
	call :acl_registry "SOFTWARE\Microsoft\Windows Defender\Scan"
	call :acl_registry "SOFTWARE\Microsoft\Windows Defender\UX Configuration"
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "AllowNonAdminFunctionality" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	if "%arch%"=="x64" (
	call :acl_registry "SOFTWARE\Wow6432Node\Microsoft\Windows Defender"
	call :acl_registry "SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Real-Time Protection"
	call :acl_registry "SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Scan"
	call :acl_registry "SOFTWARE\Wow6432Node\Microsoft\Windows Defender\UX Configuration"
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\UX Configuration" /v "AllowNonAdminFunctionality" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\TypeLib\{8C389764-F036-48F2-9AE2-88C260DCF43B}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{13F6A0B6-57AF-4BA7-ACAA-614BC89CA9D8}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{94F35585-C5D7-4D95-BA71-A745AE76E2E2}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{FDA74D11-C4A6-4577-9F73-D7CA8586E10D}" /f 1>> %logfile% 2>>&1
	)
	call :acl_registry "SOFTWARE\Policies\Microsoft\Windows Defender"
	call :acl_registry "SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
	call :acl_registry "SOFTWARE\Policies\Microsoft\Windows Defender\Reporting"
	call :acl_registry "SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	call :disable_svc_hard WinDefend
	call :disable_svc_hard WdBoot
	call :disable_svc_hard WdFilter
	call :disable_svc_hard WdNisDrv
	call :disable_svc_hard WdNisSvc
	call :disable_svc_hard Wdnsfltr
	call :disable_svc_hard wscsvc
	call :disable_svc_hard Sense
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /v "" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{13F6A0B6-57AF-4BA7-ACAA-614BC89CA9D8}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg delete "HKLM\SOFTWARE\Classes\TypeLib\{8C389764-F036-48F2-9AE2-88C260DCF43B}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{13F6A0B6-57AF-4BA7-ACAA-614BC89CA9D8}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{94F35585-C5D7-4D95-BA71-A745AE76E2E2}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Classes\CLSID\{FDA74D11-C4A6-4577-9F73-D7CA8586E10D}" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f 1>> %logfile% 2>>&1
	call :disable_svc Sense
	call :disable_task "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
	call :disable_task "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
	call :disable_task "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
	call :disable_task "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
	call :acl_folders "%ProgramData%\Microsoft\Windows Defender"
	rmdir /s /q "%ProgramData%\Microsoft\Windows Defender" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramData%\Microsoft\Windows Defender Advanced Threat Protection"
	rmdir /s /q "%ProgramData%\Microsoft\Windows Defender Advanced Threat Protection" 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	@echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[91m 2)%clr%[36m Отключить SmartScreen?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Отключение SmartScreen. Пожалуйста подождите...
	@echo Отключение SmartScreen. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	reg add "HKCU\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows Security Health\State" /v "AppAndBrowser_EdgeSmartScreenOff" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableHHDEP" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecHealthUI.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
	call :kill "SecurityHealthSystray.exe"
	call :disable_svc_sudo SecurityHealthService
	call :acl_folders "%ProgramData%\Microsoft\Windows Security Health"
	rmdir /s /q "%ProgramData%\Microsoft\Windows Security Health" 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	@echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[91m 2)%clr%[36m Удалить Microsoft Edge?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Удаление Microsoft Edge. Пожалуйста подождите...
	@echo Удаление Microsoft Edge. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	call :disable_svc edgeupdatem
	call :kill "browser_broker.exe"
	call :kill "RuntimeBroker.exe"
	call :kill "MicrosoftEdge.exe"
	call :kill "MicrosoftEdgeCP.exe"
	call :kill "MicrosoftEdgeSH.exe"
	reg add "HKLM\SOFTWARE\Microsoft" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKCU\SOFTWARE\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	if "%arch%"=="x64" ( powershell "Start-Process -FilePath ${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe -ArgumentList '-uninstall -system-level -verbose-logging -force-uninstall' -NoNewWindow" 1>> %logfile% 2>>&1 )
	if "%arch%"=="x86" ( powershell "Start-Process -FilePath ${env:ProgramFiles}\Microsoft\Edge\Application\*\Installer\setup.exe -ArgumentList '-uninstall -system-level -verbose-logging -force-uninstall' -NoNewWindow" 1>> %logfile% 2>>&1 )
	call :acl_folders "%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
	rmdir /s /q "%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramFiles%\Microsoft\Edge"
	rmdir /s /q "%ProgramFiles%\Microsoft\Edge" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramFiles%\Microsoft\EdgeUpdate"
	rmdir /s /q "%ProgramFiles%\Microsoft\EdgeUpdate" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramFiles%\Microsoft\Temp"
	rmdir /s /q "%ProgramFiles%\Microsoft\Temp" 1>> %logfile% 2>>&1
	if "%arch%"=="x64" (
	call :acl_folders "%ProgramFiles(x86)%\Microsoft\Edge"
	rmdir /s /q "%ProgramFiles(x86)%\Microsoft\Edge" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramFiles(x86)%\Microsoft\EdgeUpdate"
	rmdir /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" 1>> %logfile% 2>>&1
	call :acl_folders "%ProgramFiles(x86)%\Microsoft\Temp"
	rmdir /s /q "%ProgramFiles(x86)%\Microsoft\Temp" 1>> %logfile% 2>>&1
	)
	call :acl_folders "%ProgramData%\Microsoft\EdgeUpdate"
	rmdir /s /q "%ProgramData%\Microsoft\EdgeUpdate" 1>> %logfile% 2>>&1
	rmdir /s /q "%AppData%\Microsoft\Edge" 1>> %logfile% 2>>&1
	del /f /q "%AppData%\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" 1>> %logfile% 2>>&1
	del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" 1>> %logfile% 2>>&1
	del /f /q "%HomePath%\Desktop\Microsoft Edge.lnk" 1>> %logfile% 2>>&1
	del /f /q "%Public%\Desktop\Microsoft Edge.lnk" 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /t REG_BINARY /d "320300004c0000000114020000000000c00000000000004683008000200000007a93da2ef73cd7012858df2ef73cd701d353b05b0eded401970100000000000001000000000000000000000000000000a0013a001f80c827341f105c1042aa032ee45287d668260001002600efbe120000004c43b521f73cd7016845cc2ef73cd701cff5dc2ef73cd701140056003100000000009d52296711005461736b42617200400009000400efbe9d5229679d5229672e000000d6050200000001000000000000000000000000000000311581005400610073006b00420061007200000016000e01320097010000734e7c25200046494c4545587e312e4c4e4b00007c0009000400efbe9d5229679d5229672e000000d70502000000010000000000000000005200000000002dfa9b00460069006c00650020004500780070006c006f007200650072002e006c006e006b00000040007300680065006c006c00330032002e0064006c006c002c002d003200320030003600370000001c00220000001e00efbe02005500730065007200500069006e006e006500640000001c00120000002b00efbe2858df2ef73cd7011c00420000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f00770073002e004500780070006c006f0072006500720000001c0000009b0000001c000000010000001c0000002d000000000000009a0000001100000003000000e06219521000000000433a5c55736572735c746573745c417070446174615c526f616d696e675c4d6963726f736f66745c496e7465726e6574204578706c6f7265725c517569636b204c61756e63685c557365722050696e6e65645c5461736b4261725c46696c65204578706c6f7265722e6c6e6b000060000000030000a058000000000000006465736b746f702d3668747071376600cc9e61a2a4954f42ac398d38cb60e68887f9b542e9a8eb11a0e000155d125200cc9e61a2a4954f42ac398d38cb60e68887f9b542e9a8eb11a0e000155d12520045000000090000a03900000031535053b1166d44ad8d7048a748402ea43d788c1d00000068000000004800000030462c212f54464e88b6c5eb1d5292d00000000000000000000000009d0600004c0000000114020000000000c00000000000004681008000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000004b0614001f809bd434424502f34db7803893943456e1350600009d05415050538b0508000300000000000000520200003153505355284c9f799f394ba8d0e1d42de1d5f35d00000011000000001f000000250000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b0079006200330064003800620062007700650000000000110000000e0000000013000000010000008500000015000000001f0000003a0000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f00310031003800310031002e0031003000300031002e00310038002e0030005f007800360034005f005f003800770065006b0079006200330064003800620062007700650000006500000005000000001f000000290000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b00790062003300640038006200620077006500210041007000700000000000c10000000f000000001f0000005700000043003a005c00500072006f006700720061006d002000460069006c00650073005c00570069006e0064006f007700730041007000700073005c004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f00310031003800310031002e0031003000300031002e00310038002e0030005f007800360034005f005f003800770065006b00790062003300640038006200620077006500000000001d00000020000000004800000078d85872f8786e42a43f34253f188061000000008a020000315350534d0bd48669903c44819a2a54090dccec550000000c000000001f000000210000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004d0065006400540069006c0065002e0070006e006700000000005500000002000000001f000000210000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004100700070004c006900730074002e0070006e00670000000000590000000f000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f0072006500420061006400670065004c006f0067006f002e0070006e00670000000000550000000d000000001f000000220000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065005700690064006500540069006c0065002e0070006e0067000000110000000400000000130000000078d7ff5900000013000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004c006100720067006500540069006c0065002e0070006e0067000000000011000000050000000013000000ffffffff110000000e0000000013000000a5040000310000000b000000001f000000100000004d006900630072006f0073006f00660074002000530074006f007200650000005900000014000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f007200650053006d0061006c006c00540069006c0065002e0070006e00670000000000000000003100000031535053b1166d44ad8d7048a748402ea43d788c150000006400000000150000004200000000000000000000004d0000003153505330f125b7ef471a10a5f102608c9eebac310000000a000000001f000000100000004d006900630072006f0073006f00660074002000530074006f00720065000000000000002d00000031535053b377ed0d14c66c45ae5b285b38d7b01b110000000700000000130000000000000000000000000000000000220000001e00efbe02005500730065007200500069006e006e00650064000000a305120000002b00efbee21ce42ef73cd701a3055e0000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b0079006200330064003800620062007700650021004100700070000000a305000000000000" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /t REG_BINARY /d "00a40100003a001f80c827341f105c1042aa032ee45287d668260001002600efbe120000004c43b521f73cd7016845cc2ef73cd701cff5dc2ef73cd701140056003100000000009d52296711005461736b42617200400009000400efbe9d5229679d5229672e000000d6050200000001000000000000000000000000000000311581005400610073006b00420061007200000016001201320097010000734e7c25200046494c4545587e312e4c4e4b00007c0009000400efbe9d5229679d5229672e000000d70502000000010000000000000000005200000000002dfa9b00460069006c00650020004500780070006c006f007200650072002e006c006e006b00000040007300680065006c006c00330032002e0064006c006c002c002d003200320030003600370000001c00120000002b00efbe2858df2ef73cd7011c00420000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f00770073002e004500780070006c006f0072006500720000001c00260000001e00efbe0200530079007300740065006d00500069006e006e006500640000001c000000004f06000014001f809bd434424502f34db7803893943456e1390600009d05415050538b0508000300000000000000520200003153505355284c9f799f394ba8d0e1d42de1d5f35d00000011000000001f000000250000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b0079006200330064003800620062007700650000000000110000000e0000000013000000010000008500000015000000001f0000003a0000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f00310031003800310031002e0031003000300031002e00310038002e0030005f007800360034005f005f003800770065006b0079006200330064003800620062007700650000006500000005000000001f000000290000004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b00790062003300640038006200620077006500210041007000700000000000c10000000f000000001f0000005700000043003a005c00500072006f006700720061006d002000460069006c00650073005c00570069006e0064006f007700730041007000700073005c004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f00310031003800310031002e0031003000300031002e00310038002e0030005f007800360034005f005f003800770065006b00790062003300640038006200620077006500000000001d00000020000000004800000078d85872f8786e42a43f34253f188061000000008a020000315350534d0bd48669903c44819a2a54090dccec550000000c000000001f000000210000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004d0065006400540069006c0065002e0070006e006700000000005500000002000000001f000000210000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004100700070004c006900730074002e0070006e00670000000000590000000f000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f0072006500420061006400670065004c006f0067006f002e0070006e00670000000000550000000d000000001f000000220000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065005700690064006500540069006c0065002e0070006e0067000000110000000400000000130000000078d7ff5900000013000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f00720065004c006100720067006500540069006c0065002e0070006e0067000000000011000000050000000013000000ffffffff110000000e0000000013000000a5040000310000000b000000001f000000100000004d006900630072006f0073006f00660074002000530074006f007200650000005900000014000000001f000000230000004100730073006500740073005c00410070007000540069006c00650073005c00530074006f007200650053006d0061006c006c00540069006c0065002e0070006e00670000000000000000003100000031535053b1166d44ad8d7048a748402ea43d788c150000006400000000150000004200000000000000000000004d0000003153505330f125b7ef471a10a5f102608c9eebac310000000a000000001f000000100000004d006900630072006f0073006f00660074002000530074006f00720065000000000000002d00000031535053b377ed0d14c66c45ae5b285b38d7b01b110000000700000000130000000000000000000000000000000000120000002b00efbee21ce42ef73cd701a3055e0000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f0077007300530074006f00720065005f003800770065006b0079006200330064003800620062007700650021004100700070000000a305260000001e00efbe0200530079007300740065006d00500069006e006e00650064000000a3050000ff" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MicrosoftEdge.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	timeout /t 3 /nobreak | break
	@echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить Центр обновления Windows?%clr%[92m
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
	echo Отключение Центра обновления Windows. Пожалуйста подождите...
	@echo Отключение Центра обновления Windows. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	call :disable_svc wuauserv
	call :disable_svc_sudo UsoSvc
	call :disable_svc_sudo_hard WaaSMedicSvc
	call :disable_task "\Microsoft\Windows\WaaSMedic\PerformRemediation"
	call :disable_task "\Microsoft\Windows\WindowsUpdate\sihpostreboot"
	call :disable_task "\Microsoft\Windows\WindowsUpdate\Scheduled Start"
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f 1>> %logfile%
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f 1>> %logfile%
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DetectionFrequencyEnabled" /t REG_DWORD /d "0" /f 1>> %logfile%
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownLoadMode" /t REG_DWORD /d "100" /f 1>> %logfile%
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	@echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить службы печати и сканирования?%clr%[92m
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
	echo Отключение служб печати и сканирования. Пожалуйста подождите...
	@echo Отключение служб печати и сканирования. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	call :disable_svc_sudo PrintWorkflowUserSvc
	call :disable_svc Spooler
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	@echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo. 1>> %logfile%
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Отчеты и реклама %clr%[0m
@echo Отчеты и реклама 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Отключить отчеты об ошибках Windows.%clr%[92m
@echo Отключить отчеты об ошибках Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "AutoApproveOSDumps" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Отключить очередь сообщений об ошибках.%clr%[92m
@echo Отключить очередь сообщений об ошибках. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Отключить советы Windows.%clr%[92m
@echo Отключить советы Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableTelemetryOptInChangeNotification" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" /v "AllowSuggestedAppsInWindowsInkWorkspace" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Отключить отображение рекламы, предложения приложений и их автоматическую установку.%clr%[92m
@echo Отключить отображение рекламы, предложения приложений и их автоматическую установку. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310091Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310092Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338380Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338381Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "Set-ItemProperty -Path (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current').PSPath -Name 'Data' -Type Binary -Value (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current').Data[0..15] -wa SilentlyContinue" 1>> %logfile% 2>>&1
sc stop ShellExperienceHost 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Запретить приложениям использовать рекламный идентификатор.%clr%[92m
@echo Запретить приложениям использовать рекламный идентификатор. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Отключить доступ приложений AppStore к списку языков.%clr%[92m
@echo Отключить доступ приложений AppStore к списку языков. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Сетевая оптимизация %clr%[0m
@echo Сетевая оптимизация 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1)%clr%[36m Применение настроек сетевой оптимизации.%clr%[92m
@echo Применение настроек сетевой оптимизации. 1>> %logfile%
set timerStart=!time!
netsh winsock reset 1>> %logfile% 2>>&1
ipconfig /flushdns 1>> %logfile% 2>>&1
netsh interface ip delete arpcache 1>> %logfile% 2>>&1
del /f /q /s "%Appdata%\Macromedia\*">> %logfile% 2>>&1
rmdir /q /s "%Appdata%\Macromedia\*">> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultReceiveWindow" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastCopyReceiveThreshold" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastSendDatagramThreshold" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /t REG_DWORD /d "15" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "FastCopyReceiveThreshold" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "FastSendDatagramThreshold" /t REG_DWORD /d "16384" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "KeepAliveTime" /t REG_DWORD /d "7200000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "QualifyingDestinationThreshold" /t REG_DWORD /d 3 /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "SynAttackProtect" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "TcpCreateAndConnectTcbRateLimitDepth" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d "5" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "GlobalMaxTcpWindowSize" /t REG_DWORD /d "5840" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpWindowSize" /t REG_DWORD /d "5840" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxConnectionsPerServer" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUBHDetect" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "UseDelayedAcceptance" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MaxSockAddrLength" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MinSockAddrLength" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters" /v "DisabledComponents" /t REG_DWORD /d "4294967295" /f 1>> %logfile% 2>>&1
call :disable_svc iphlpsvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinSock2\Parameters" /v "Ws2_32NumHandleBuckets" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{D6277990-4C6A-11CF-8D87-00AA0060F5BF}" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f 1>> %logfile% 2>>&1
netsh int ip set global neighborcachelimit=4096 1>> %logfile% 2>>&1
netsh int ip set global taskoffload=disabled 1>> %logfile% 2>>&1
netsh int tcp set global autotuninglevel=normal 1>> %logfile% 2>>&1
netsh int tcp set global netdma=disabled 1>> %logfile% 2>>&1
netsh int tcp set global timestamps=disabled 1>> %logfile% 2>>&1
netsh int isatap set state disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2)%clr%[36m Отключить эвристику масштабирования, чтобы предотвратить изменение уровня автонастройки окна.%clr%[92m
@echo Отключить эвристику масштабирования, чтобы предотвратить изменение уровня автонастройки окна. 1>> %logfile%
set timerStart=!time!
netsh int tcp set heuristics disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3)%clr%[36m Установить 2 попытки для восстановления соединения.%clr%[92m
@echo Установить 2 попытки для восстановления соединения. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global maxsynretransmissions=2 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4)%clr%[36m Включить прямой доступ к кешу.%clr%[92m
@echo Включить прямой доступ к кешу. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global dca=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5)%clr%[36m Включить отказоустойчивость без SACK RTT.%clr%[92m
@echo Включить отказоустойчивость без SACK RTT. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global nonsackrttresiliency=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6)%clr%[36m Установить начальное окно перегрузки на 10.%clr%[92m
@echo Установить начальное окно перегрузки на 10. 1>> %logfile%
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName InternetCustom -InitialCongestionWindow 10" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 7)%clr%[36m Отключить защиту от давления памяти.%clr%[92m
@echo Отключить защиту от давления памяти. 1>> %logfile%
set timerStart=!time!
netsh int tcp set security mpp=disabled 1>> %logfile% 2>>&1
netsh int tcp set security profiles=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 8)%clr%[36m Установить максимальный блок передачи (MTU) до 1492.%clr%[92m
@echo Установить максимальный блок передачи (MTU) до 1492. 1>> %logfile%
set timerStart=!time!
powershell "foreach ($adp in (Get-NetAdapter | Where {$_.Name -Match 'Ethernet'}).Name){netsh interface ipv4 set interface Ethernet mtu=1492 store=persistent}" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 9)%clr%[36m Установить TTL на 64.%clr%[92m
@echo Установить TTL на 64. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d "64" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 10)%clr%[36m Установить поддержку пользовательских портов до 65534.%clr%[92m
@echo Установить поддержку пользовательских портов до 65534. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d "65534" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 11)%clr%[36m Установить время ожидания TCP до 30.%clr%[92m
@echo Установить время ожидания TCP до 30. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 12)%clr%[36m Установить приоритеты разрешения хоста.%clr%[92m
@echo Установить приоритеты разрешения хоста. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d "5" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d "6" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d "7" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 13)%clr%[36m Отключить зарезервированную пропускную способность QoS.%clr%[92m
@echo Отключить зарезервированную пропускную способность QoS. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 14)%clr%[36m Отключить эвристику масштабирования.%clr%[92m
@echo Отключить эвристику масштабирования. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableHeuristics" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 15)%clr%[36m Включить масштабирование окна RFC 1323.%clr%[92m
@echo Включить масштабирование окна RFC 1323. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 16)%clr%[36m Установить размер пакета UDP на 1280.%clr%[92m
@echo Установить размер пакета UDP на 1280. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "MaximumUdpPacketSize" /t REG_DWORD /d "1280" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 17)%clr%[36m Задать параметры времени кэширования DNS.%clr%[92m
@echo Задать параметры времени кэширования DNS. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 18)%clr%[36m Настройка параметров оптимизации для сетевых адаптеров.%clr%[92m
@echo Настройка параметров оптимизации для сетевых адаптеров. 1>> %logfile%
set timerStart=!time!
for /f "delims=" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /s /v ProviderName 2^>nul') do call :adapters "%%i"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 19)%clr%[36m Установить алгоритмы Nagle для сетевых интерфейсов.%clr%[92m
@echo Установить алгоритмы Nagle для сетевых интерфейсов. 1>> %logfile%
set timerStart=!time!
for /f "tokens=3 delims=_ " %%i in ('net config rdr ^| find /i "tcpip"') do (
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 20)%clr%[36m Запретить весь NTLM траффик?%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m блокировка запросов NTLM нарушает работу RDP и Samba.
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
	echo Запрет NTLM траффика применен.
	@echo Запрет NTLM траффика применен. 1>> %logfile%
	set timerStart=!time!
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[91m 21)%clr%[36m Запретить доступ в интернет для DRM Windows Media.%clr%[92m
@echo Запретить доступ в интернет для DRM Windows Media. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 22)%clr%[36m Отключить общий доступ к проигрывателю Windows Media.%clr%[92m
@echo Отключить общий доступ к проигрывателю Windows Media. 1>> %logfile%
set timerStart=!time!
call :disable_svc WMPNetworkSvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 22)%clr%[36m Отключить немедленные подключения Windows для Windows Connect Now (настраивает параметры точки доступа или Wi-Fi).%clr%[92m
@echo Отключить немедленные подключения Windows для Windows Connect Now (настраивает параметры точки доступа или Wi-Fi). 1>> %logfile%
set timerStart=!time!
call :disable_svc wcncsvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 22)%clr%[36m Отключить наблюдение за датчиками (кооректировка яркости дисплея, поворота экрана и т.д.).%clr%[92m
@echo Отключить наблюдение за датчиками (кооректировка яркости дисплея, поворота экрана и т.д.). 1>> %logfile%
set timerStart=!time!
call :disable_svc SensrSvc
call :disable_svc SensorService
call :disable_svc SensorDataService
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить функцию определения местоположения и скрипты для функции определения местоположения.%clr%[92m
@echo Отключить функцию определения местоположения и скрипты для функции определения местоположения. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
call :disable_svc lfsvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 23)%clr%[36m Не ждать наличия сети при запуске компьютера и входе в сеть для рабочих групп.%clr%[92m
@echo Не ждать наличия сети при запуске компьютера и входе в сеть для рабочих групп. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "SyncForegroundPolicy" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 24)%clr%[36m Отключить тестирование сетевого подключения.%clr%[92m
@echo Отключить тестирование сетевого подключения. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" /v "NoActiveProbe" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" /v "DisablePassivePolling" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 25)%clr%[36m Отключить одноранговую сеть.%clr%[92m
@echo Отключить одноранговую сеть. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Peernet" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 26)%clr%[36m Отключить лимитное подключение и использование данных сети.%clr%[92m
@echo Отключить лимитное подключение и использование данных сети. 1>> %logfile%
set timerStart=!time!
call :acl_registry "SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "3G" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "4G" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Default" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
powershell "Get-ChildItem 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DusmSvc\Profiles\*\*' | Set-ItemProperty -Name UserCost -Value 0" 1>> %logfile% 2>>&1
call :disable_svc DusmSvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 27)%clr%[36m Исправить настройки для VPN канала.%clr%[92m
@echo Исправить настройки для VPN канала. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters" /v "DisableIKENameEkuCheck" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters" /v "NegotiateDH2048_AES256" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 28)%clr%[36m Отключить привязку QoS.%clr%[92m
@echo Отключить привязку QoS. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_pacer" -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 29)%clr%[36m Отключить использование пакетов QoS.%clr%[92m
@echo Отключить использование пакетов QoS. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterQos -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
call :disable_svc Psched
call :disable_svc QWAVEdrv
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 30)%clr%[36m Включить маркировку DSCP пакетов QoS.%clr%[92m
@echo Включить маркировку DSCP пакетов QoS. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Application DSCP Marking Request" /t REG_SZ /d "Allowed" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Do not use NLA" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
netsh winsock set autotuning on 1>> %logfile% 2>>&1
echo. 1>> %logfile%
@echo %clr%[91m 31)%clr%[36m Отключить захват NDIS.%clr%[92m
@echo Отключить захват NDIS. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_ndiscap" -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 32)%clr%[36m Отключить протокол обнаружения локальных каналов (LLDP).%clr%[92m
@echo Отключить протокол обнаружения локальных каналов (LLDP). 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_lldp" -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 33)%clr%[36m Отключить обнаружение топологии локального канала (LLTD).%clr%[92m
@echo Отключить обнаружение топологии локального канала (LLTD). 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_lltdio" -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_rspndr" -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 34)%clr%[36m Отключить сетевой стек IPv6.%clr%[92m
@echo Отключить сетевой стек IPv6. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_tcpip6" -wa SilentlyContinue" 1>> %logfile% 2>>&1
call :disable_svc Tcpip6
call :disable_svc wanarpv6
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 35)%clr%[36m Отключить механизм, позволяющий передавать IPv6-пакеты через IPv4-сети.%clr%[92m
@echo Отключить механизм, позволяющий передавать IPv6-пакеты через IPv4-сети. 1>> %logfile%
set timerStart=!time!
powershell "Set-Net6to4Configuration -State Disabled -AutoSharing Disabled -RelayState Disabled -RelayName '6to4.ipv6.microsoft.com' -wa SilentlyContinue" 1>> %logfile% 2>>&1
netsh int 6to4 set state state=disabled undoonstop=disabled 1>> %logfile% 2>>&1
netsh int 6to4 set routing routing=disabled sitelocals=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 36)%clr%[36m Отключить Teredo и протокол 6to4.%clr%[92m
@echo Отключить Teredo и протокол 6to4. 1>> %logfile%
set timerStart=!time!
netsh int ipv6 delete route ::/0 Teredo 1>> %logfile% 2>>&1
netsh int ipv6 isatap set state disabled 1>> %logfile% 2>>&1
netsh int teredo set state disabled 1>> %logfile% 2>>&1
netsh int ipv6 6to4 set state state=disabled undoonstop=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 37)%clr%[36m Включить экспериментальную автонастройку и провайдер перегрузки CTCP (для стабильных сетей рекомендуется выставить cubic).%clr%[92m
@echo Включить экспериментальную автонастройку и провайдер перегрузки CTCP (для стабильных сетей рекомендуется выставить cubic). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Experimental" /f 1>> %logfile% 2>>&1
netsh int tcp set global autotuning=experimental 1>> %logfile% 2>>&1
%SystemUser% powershell "Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider CTCP" 1>> %logfile% 2>>&1
%SystemUser% powershell "Set-NetTCPSetting -SettingName Internet -CongestionProvider CTCP" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 38)%clr%[36m Настроить медленный старт TCP для отправки 10 кадров.%clr%[92m
@echo Настроить медленный старт TCP для отправки 10 кадров. 1>> %logfile%
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName Internet -InitialCongestionWindow 10" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 39)%clr%[36m Отключить разгрузку TCP Chimney.%clr%[92m
@echo Отключить разгрузку TCP Chimney. 1>> %logfile%
set timerStart=!time!
powershell "Set-NetOffloadGlobalSetting -Chimney Disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 40)%clr%[36m Отключить объединение пакетов. Полезно для игр и Wi-Fi.%clr%[92m
@echo Отключить объединение пакетов. Полезно для игр и Wi-Fi. 1>> %logfile%
set timerStart=!time!
powershell "Set-NetOffloadGlobalSetting -PacketCoalescingFilter disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 41)%clr%[36m Отключить объединение сегментов приема.%clr%[92m
@echo Отключить объединение сегментов приема. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global rsc=disabled 1>> %logfile% 2>>&1
powershell "Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 42)%clr%[36m Включить отправку и получение Weak Host и настройка IP политик.%clr%[92m
@echo Включить отправку и получение Weak Host и настройка IP политик. 1>> %logfile%
set timerStart=!time!
powershell "Get-NetAdapter -Name * -IncludeHidden | Set-NetIPInterface -WeakHostSend Enabled -WeakHostReceive Enabled -RetransmitTimeMs 0 -Forwarding Disabled -EcnMarking Disabled -AdvertiseDefaultRoute Disabled -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 43)%clr%[36m Включить явное уведомление о перегрузке.%clr%[92m
@echo Включить явное уведомление о перегрузке. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global ecncapability=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 44)%clr%[36m Включить отметку времени RFC.%clr%[92m
@echo Включить отметку времени RFC. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global timestamps=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 45)%clr%[36m Выставить RTO в 2.5 секунды.%clr%[92m
@echo Выставить RTO в 2.5 секунды. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global initialRto=2500 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 46)%clr%[36m Выставить минимальное RTO.%clr%[92m
@echo Выставить минимальное RTO. 1>> %logfile%
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName InternetCustom -MinRto 300" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 47)%clr%[36m Включить Fastopen.%clr%[92m
@echo Включить Fastopen. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global fastopen=enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 48)%clr%[36m Отключить HyStart.%clr%[92m
@echo Отключить HyStart. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global hystart=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 49)%clr%[36m Отключить TCP Pacing.%clr%[92m
@echo Отключить TCP Pacing. 1>> %logfile%
set timerStart=!time!
netsh int tcp set global pacingprofile=off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 50)%clr%[36m Выставить минимальное MTU на 576.%clr%[92m
@echo Выставить минимальное MTU на 576. 1>> %logfile%
set timerStart=!time!
netsh int ip set global minmtu=576 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 51)%clr%[36m Отключить метку IP-потока.%clr%[92m
@echo Отключить метку IP-потока. 1>> %logfile%
set timerStart=!time!
netsh int ip set global flowlabel=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 52)%clr%[36m Отключить перезапуск окна TCP.%clr%[92m
@echo Отключить перезапуск окна TCP. 1>> %logfile%
set timerStart=!time!
netsh int tcp set supplemental InternetCustom enablecwndrestart=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 53)%clr%[36m Отключить перенаправления ICMP.%clr%[92m
@echo Отключить перенаправления ICMP. 1>> %logfile%
set timerStart=!time!
netsh int ip set global icmpredirects=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 54)%clr%[36m Отключить многоадресную пересылку.%clr%[92m
@echo Отключить многоадресную пересылку. 1>> %logfile%
set timerStart=!time!
netsh int ip set global multicastforwarding=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 55)%clr%[36m Отключить групповые перенаправленные фрагменты.%clr%[92m
@echo Отключить групповые перенаправленные фрагменты. 1>> %logfile%
set timerStart=!time!
netsh int ip set global groupforwardedfragments=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 56)%clr%[36m Отключить раздувание TCP.%clr%[92m
@echo Отключить раздувание TCP. 1>> %logfile%
set timerStart=!time!
netsh int tcp set security mpp=disabled profiles=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 57)%clr%[36m Отключить эвристику TCP.%clr%[92m
@echo Отключить эвристику TCP. 1>> %logfile%
set timerStart=!time!
netsh int tcp set heur forcews=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 58)%clr%[36m Отключить управление питанием сетевого адаптера.%clr%[92m
@echo Отключить управление питанием сетевого адаптера. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterPowerManagement -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 59)%clr%[36m Включить разгрузку контрольной суммы.%clr%[92m
@echo Включить разгрузку контрольной суммы. 1>> %logfile%
set timerStart=!time!
powershell "Enable-NetAdapterChecksumOffload -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 60)%clr%[36m Отключить разгрузку задачи инкапсулированного пакета.%clr%[92m
@echo Отключить разгрузку задачи инкапсулированного пакета. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterEncapsulatedPacketTaskOffload -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 61)%clr%[36m Включить разгрузку IPsec.%clr%[92m
@echo Включить разгрузку IPsec. 1>> %logfile%
set timerStart=!time!
powershell "Enable-NetAdapterIPsecOffload -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile% 2>>&1
@echo %clr%[91m 62)%clr%[36m Отключить разгрузку большой отправки.%clr%[92m
@echo Отключить разгрузку большой отправки. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterLso -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 63)%clr%[36m Включить PacketDirect для снижения джиттера.%clr%[92m
@echo Включить PacketDirect для снижения джиттера. 1>> %logfile%
set timerStart=!time!
powershell "Enable-NetAdapterPacketDirect -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 64)%clr%[36m Отключить объединение сегментов приема.%clr%[92m
@echo Отключить объединение сегментов приема. 1>> %logfile%
set timerStart=!time!
powershell "Disable-NetAdapterRsc -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 65)%clr%[36m Включить масштабирование сегментов приема.%clr%[92m
@echo Включить масштабирование сегментов приема. 1>> %logfile%
set timerStart=!time!
powershell "Enable-NetAdapterRss -Name * -wa SilentlyContinue" 1>> %logfile% 2>>&1
netsh interface tcp set heuristics wsh=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 66)%clr%[36m Выполнить оптимизацию интернет браузеров.%clr%[92m
@echo Выполнить оптимизацию интернет браузеров. 1>> %logfile%
set timerStart=!time!
call :browsers
if /i %browsersFound%==1 (
	echo %clr%[91mПрограмма оптимизации обнаружила наличие в системе запущенного экземпляра браузера.%clr%[92m
	echo %clr%[91mЧтобы продолжить, вы должны закрыть свой браузер и подтвердить применение настроек.%clr%[92m
	echo.
	choice /c yn /n /t %autoChoose% /d y /m %keySelY%
	if !errorlevel!==1 (
		call :kill "chrome.exe"
		call :kill "firefox.exe"
		call :kill "opera.exe"
		call :kill "msedge.exe"
		call :kill "vivaldi.exe"
		call :kill "thunderbird.exe"
		::start "" rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351 (очистка истории и кэша паролей браузера)
		regsvr32 /s actxprxy 1>> %logfile% 2>>&1
		del /f /q /s "%LocalAppdata%\Microsoft\Windows\WebCache\*" 1>> %logfile% 2>>&1
		del /f /q /s "%LocalAppData%\Microsoft\Intern*" 1>> %logfile% 2>>&1
		rmdir /q /s "%LocalAppData%\Microsoft\Intern*" 1>> %logfile% 2>>&1
		del /f /q /s "%LocalAppData%\Microsoft\Windows\History" 1>> %logfile% 2>>&1
		rmdir /q /s "%LocalAppData%\Microsoft\Windows\History" 1>> %logfile% 2>>&1
		del /f /q /s "%LocalAppData%\Microsoft\Windows\Tempor*" 1>> %logfile% 2>>&1
		rmdir /q /s "%LocalAppData%\Microsoft\Windows\Tempor*" 1>> %logfile% 2>>&1
		cmd.exe /c "%~dp0\..\Tools\speedyfox.exe "/Firefox:all" "/Chrome:all" "/Chromium:all" "/Microsoft Edge:all" "/Skype:all" "/Thunderbird:all" "/Opera:all" "/Vivaldi:all" "/Yandex Browser:all" "/Epic Privacy Browser:all" "/Cyberfox:all" "/FossaMail:all" "/Viber ^for Windows:all" "/Slimjet Browser:all" "/Pale Moon:all" "/SeaMonkey:all"" 1>> %logfile% 2>>&1
		set browsersFound=0
	)
)
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v "explorer.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v "iexplore.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v "explorer.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v "iexplore.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
)
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main" /v "DNSPreresolution" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main" /v "Use_Async_DNS" /t REG_SZ /d "yes" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "EnablePreBinding" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableInPrivateBlocking" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /v "StartMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "DnsCacheEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "DnsCacheEntries" /t REG_DWORD /d "200" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "DnsCacheTimeout" /t REG_DWORD /d "15180" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext" /v "DisableAddonLoadTimePerformanceNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext" /v "NoFirsttimeprompt" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\firefox.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\chrome.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Настройка уведомлений %clr%[0m
@echo Настройка уведомлений 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1) %clr%[36m Отключить уведомления Центра действий.%clr%[92m
@echo Отключить уведомления Центра действий. 1>> %logfile%
set timerStart=!time!
::reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotification" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotificationOnLockScreen" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BioEnrollment_cw5n1h2txyewy!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.LockApp_cw5n1h2txyewy!WindowsDefaultLockScreen" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!RemindersShareTargetApp" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.LanguageComponentsInstaller" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.ParentalControls" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.ParentalControls_cw5n1h2txyewy!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy!App" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy!SecHealthUI" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.Defender.SecurityCenter" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Calling" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Calling.SystemAlertNotification" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Compat" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.FodHelper" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.LocationManager" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.MobilityExperience" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityCenter" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WindowsTip" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WindowsUpdate.Notification" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2) %clr%[36m Отключить уведомления поставщика синхронизации.%clr%[92m
@echo Отключить уведомления поставщика синхронизации. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3) %clr%[36m Отключить значок и уведомления Центра поддержки.%clr%[92m
@echo Отключить значок и уведомления Центра поддержки. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "UseActionCenterExperience" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAHealth" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4) %clr%[36m Отключить уведомления службы поддержки.%clr%[92m
@echo Отключить уведомления службы поддержки. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5) %clr%[36m Отключить уведомления фокусировки внимания.%clr%[92m
@echo Отключить уведомления фокусировки внимания. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\QuietHours" /v "Enabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\QuietHours" /v "AllowCalls" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Notifications\Data" /v "0D83063EA3BF1C75" /t REG_BINARY /d "3F00000000000000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6) %clr%[36m Отключить уведомления Windows Defender, файервола и Центра обновлений.%clr%[92m
@echo Отключить уведомления Windows Defender, файервола и Центра обновлений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "AntiVirusDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
call :acl_registry "SOFTWARE\Microsoft\Security Center\Svc"
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "AntiVirusOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "FirewallDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "FirewallOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "AntiSpywareDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%SystemUser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "AntiSpywareOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "UpdatesDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 7) %clr%[36m Отключить историю уведомлений.%clr%[92m
@echo Отключить историю уведомлений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ClearTilesOnExit" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Настройка обновления Windows%clr%[0m
@echo Настройка обновления Windows 1>> %logfile%
echo ••••••••••••
echo •••••••••••• 1>> %logfile%
@echo %clr%[91m 1) %clr%[36m Отключить обновление драйверов через Центр обновлений Windows.%clr%[92m
@echo Отключить обновление драйверов через Центр обновлений Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "AllSigningEqual" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSendRequestAdditionalSoftwareToWER" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate" /v "Value" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
rmdir /s /q "%SystemRoot%\SoftwareDistribution" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 2) %clr%[36m Разрешить получение обновлений для других продуктов Microsoft через Центр обновления Windows.%clr%[92m
@echo Разрешить получение обновлений для других продуктов Microsoft через Центр обновления Windows. 1>> %logfile%
set timerStart=!time!
powershell "(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '')" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 3) %clr%[36m Отключить автоматическую загрузку с Центра обновления Windows.%clr%[92m
@echo Отключить автоматическую загрузку с Центра обновления Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 4) %clr%[36m Отключить автоматическую загрузку обновлений приложений из Магазина.%clr%[92m
@echo Отключить автоматическую загрузку обновлений приложений из Магазина. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 5) %clr%[36m Отключить автоматическое обновление карт.%clr%[92m
@echo Отключить автоматическое обновление карт. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\Maps" /v "AutoUpdateEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_svc MapsBroker
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 6) %clr%[36m Отключить автоматическую перезагрузку и уведомление после завершения обновления.%clr%[92m
@echo Отключить автоматическую перезагрузку и уведомление после завершения обновления. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "RestartNotificationsAllowed2" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 7) %clr%[36m Отключить ночное пробуждение для автоматического обслуживания и обновлений Windows.%clr%[92m
@echo Отключить ночное пробуждение для автоматического обслуживания и обновлений Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUPowerManagement" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[91m 8) %clr%[36m Отключить автоматический перезапуск после входа в систему при установке обновлений.%clr%[92m
@echo Отключить автоматический перезапуск после входа в систему при установке обновлений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableAutomaticRestartSignOn" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
echo.%clr%[7m%clr%[0m
@echo %clr%[7m Разное %clr%[0m
@echo Разное 1>> %logfile%
echo ••••••••••••
@echo •••••••••••• 1>> %logfile%
@echo %clr%[36m Применение параметров для отключения высоких задержек DPC/ISR.%clr%[92m
@echo Применение параметров для отключения высоких задержек DPC/ISR. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "ExitLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "ExitLatencyCheckEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "Latency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceDefault" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceFSVP" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyTolerancePerfOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceScreenOffIR" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceVSyncEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "RtlCapabilityCheckLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchedMode" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "UseGpuTimer" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PowerSavingTweaks" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "EnableRuntimePowerManagement" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PrimaryPushBufferSize" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "FlTransitionLatency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "D3PCLatency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RMDeepLlEntryLatencyUsec" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PciLatencyTimerControl" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "Node3DLowLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "LOWLATENCY" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RmDisableRegistryCaching" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RMDisablePostL2Compression" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "UseGpuTimer" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "PowerSavingTweaks" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableRuntimePowerManagement" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "PrimaryPushBufferSize" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "FlTransitionLatency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "D3PCLatency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "RMDeepLlEntryLatencyUsec" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "PciLatencyTimerControl" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "Node3DLowLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "LOWLATENCY" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "RmDisableRegistryCaching" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "RMDisablePostL2Compression" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyActivelyUsed" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyIdleLongTime" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyIdleMonitorOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyIdleNoContext" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyIdleShortTime" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultD3TransitionLatencyIdleVeryLongTime" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceIdle0" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceIdle0MonitorOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceIdle1" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceIdle1MonitorOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceMemory" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceNoContext" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceNoContextMonitorOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceOther" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultLatencyToleranceTimerPeriod" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultMemoryRefreshLatencyToleranceActivelyUsed" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultMemoryRefreshLatencyToleranceMonitorOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DefaultMemoryRefreshLatencyToleranceNoContext" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "Latency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "MaxIAverageGraphicsLatencyInOneBucket" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "MiracastPerfTrackGraphicsLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "MonitorLatencyTolerance" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "MonitorRefreshLatencyTolerance" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "TransitionLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "D3PCLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "F1TransitionLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LOWLATENCY" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Node3DLowLatency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PciLatencyTimerControl" /t REG_DWORD /d "20" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMDeepL1EntryLatencyUsec" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcMaxFtuS" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcMinFtuS" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RmGspcPerioduS" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrEiIdleThresholdUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrGrIdleThresholdUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrGrRgIdleThresholdUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMLpwrMsIdleThresholdUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectFlipDPCDelayUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectFlipTimingMarginUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VRDirectJITFlipMsHybridFlipDelayUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrCursorMarginUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrDeflickerMarginUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "vrrDeflickerMaxUs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Принудительное отключение логгирования.%clr%[92m
@echo Принудительное отключение логгирования. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AppModel" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Cellcore" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Circular Kernel Context Logger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DataMarket" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\HolographicDevice" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\iclsClient" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\iclsProxy" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\LwtNetLog" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Mellanox-Kernel" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Microsoft-Windows-AssignedAccess-Trace" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Microsoft-Windows-Setup" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\NBSMBLOGGER" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\PEAuthLog" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\RdrLog" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\ReadyBoot" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SetupPlatform" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SetupPlatformTel" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SocketHeciServer" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SpoolerLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SQMLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\TCPIPLOGGER" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\TileStore" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Tpm" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\TPMProvisioningService" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\UBPM" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WdiContextLog" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WFP-IPsec Trace" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WiFiDriverIHVSession" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WiFiDriverIHVSessionRepro" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WiFiSession" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WinPhoneCritical" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::powershell "Get-AutologgerConfig | Set-AutologgerConfig -Start 0 -InitStatus 0 -Confirm:$False -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogLevel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Credssp" /v "DebugLogLevel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Применение политики для ресурсов CPU.%clr%[92m
@echo Применение политики для ресурсов CPU. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\HardCap0" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\HardCap0" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\Paused" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\Paused" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFull" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFull" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFullAboveNormal" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFullAboveNormal" /v "PriorityClass" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapFullAboveNormal" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLow" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLow" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLowBackgroundBegin" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLowBackgroundBegin" /v "PriorityClass" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\SoftCapLowBackgroundBegin" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\UnmanagedAboveNormal" /v "CapPercentage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\UnmanagedAboveNormal" /v "PriorityClass" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\CPU\UnmanagedAboveNormal" /v "SchedulingType" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\BackgroundDefault" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\Frozen" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\FrozenDNCS" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\FrozenDNK" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\FrozenPPLE" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\Paused" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\PausedDNK" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\Pausing" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\PrelaunchForeground" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Flags\ThrottleGPUInterference" /v "IsLowPriority" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Critical" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Critical" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\CriticalNoUi" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\CriticalNoUi" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\EmptyHostPPLE" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\EmptyHostPPLE" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\High" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\High" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Low" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Low" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Lowest" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Lowest" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Medium" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\Medium" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\MediumHigh" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\MediumHigh" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\StartHost" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\StartHost" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\VeryHigh" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\VeryHigh" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\VeryLow" /v "BasePriority" /t REG_DWORD /d "130" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Importance\VeryLow" /v "OverTargetPriority" /t REG_DWORD /d "80" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\IO\NoCap" /v "IOBandwidth" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Memory\NoCap" /v "CommitLimit" /t REG_DWORD /d "4294967295" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ResourcePolicyStore\ResourceSets\Policies\Memory\NoCap" /v "CommitTarget" /t REG_DWORD /d "4294967295" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Применение параметров для ускорения ОС и оптимизации 3D игр.%clr%[92m
@echo Применение параметров для ускорения ОС и оптимизации 3D игр. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\I/O System" /v "PassiveIntRealTimeWorkerPriority" /t REG_DWORD /d "24" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\KernelVelocity" /v "DisableFGBoostDecay" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoDataExecutionPrevention" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableCursorSuppression" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "MagnetismUpdateIntervalInMilliseconds" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\DirectDraw" /v "EmulationOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\DirectDraw" /v "EmulationOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\DirectDraw" /v "EmulationOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\DirectDraw" /v "EmulationOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
reg add "HKU\.DEFAULT\Microsoft\Windows\CurrentVersion\Internet Settings" /v "SyncMode5" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "SyncMode5" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "SyncMode5" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\OLE" /v "PageAllocatorUseSystemHeap" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\OLE" /v "PageAllocatorSystemHeapIsPrivate" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\OLE" /v "Tracing" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "FipsAlgorithmPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\GRE_Initialize" /v "DisableMetaFiles" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MaxDynamicTickDuration" /t REG_DWORD /d "500" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MaximumSharedReadyQueueSize" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "SerializeTimerExpiration" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableAutoBoost" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "NonPagedPoolSize" /t REG_DWORD /d "192" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagedPoolSize" /t REG_DWORD /d "192" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d "192" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v "UseOnlyMice" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v "TreatAbsolutePointerAsAbsolute" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v "TreatAbsoluteAsRelative" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\usbflags" /v "fid_D1Latency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\usbflags" /v "fid_D2Latency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\usbflags" /v "fid_D3Latency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\pci\Parameters" /v "ASPMOptOut" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\Input\Buttons" /v "HardwareButtonsAsVKeys" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_svc GraphicsPerfSvc
call :disable_svc GpuEnergyDrv
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "AlpcWakePolicy" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xusb22\Parameters" /v "IoQueueWorkItem" /t REG_DWORD /d "10" /f 1>> %logfile% 2>>&1
call :disable_svc bam
call :disable_svc dam
call :disable_svc SystemUsageReportSvc_QUEENCREEK
call :disable_svc_sudo 'Intel(R) SUR QC SAM'
call :disable_svc_sudo kdnic
call :disable_svc LMS
call :disable_svc_sudo MEIx64
call :disable_svc MMCSS
call :disable_svc Beep
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WmiPrvSE.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RuntimeBroker.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\fontdrvhost.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Применение оптимизации службы планировщика классов Multimedia для игр (MMCSS).%clr%[92m
@echo Применение оптимизации службы планировщика классов Multimedia для игр (MMCSS). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "IdleDetectionCycles" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d "2710" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "BackgroundPriority" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "20" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Применение настроек оптимизации для SSD дисков.%clr%[92m
@echo Применение настроек оптимизации для SSD дисков. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5" /v "LPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5" /v "LPMDSTATE" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\EnableBoottrace" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\I/O System" /v "CountOperations" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Применение настроек оптимизации электропитания.%clr%[92m
@echo Применение настроек оптимизации электропитания. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PerfCalculateActualUtilization" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "SleepReliabilityDetailedDiagnostics" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "QosManagesIdleProcessors" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableVsyncLatencyUpdate" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "DisableSensorWatchdog" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceDefault" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceFSVP" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceIdleResiliency" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyTolerancePerfOverride" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceScreenOffIR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "LatencyToleranceVSyncEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{BDB3AF7A-F67E-4d1e-945D-E2790352BE0A}" /ve /t REG_SZ /d "{db57eb61-1aa2-4906-9396-23e8b8024c32}" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{BDB3AF7A-F67E-4d1e-945D-E2790352BE0A}" /v "Operator" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{BDB3AF7A-F67E-4d1e-945D-E2790352BE0A}" /v "Type" /t REG_DWORD /d "4157" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{BDB3AF7A-F67E-4d1e-945D-E2790352BE0A}" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{CD9230EE-218E-44b9-8AE5-EE7AA5DAD08F}" /ve /t REG_SZ /d "{db57eb61-1aa2-4906-9396-23e8b8024c32}" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{CD9230EE-218E-44b9-8AE5-EE7AA5DAD08F}" /v "Operator" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{CD9230EE-218E-44b9-8AE5-EE7AA5DAD08F}" /v "Type" /t REG_DWORD /d "4106" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Profile\Events\{54533251-82be-4824-96c1-47b60b740d00}\{0DA965DC-8FCF-4c0b-8EFE-8DD5E7BC959A}\{7E01ADEF-81E6-4e1b-8075-56F373584694}\{F6CC25DF-6E8F-4cf8-A242-B1343F565884}\{CD9230EE-218E-44b9-8AE5-EE7AA5DAD08F}" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "SleepStudyDisabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\ModernSleep" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powercfg -change -disk-timeout-ac 0 1>> %logfile% 2>>&1
powercfg -change -standby-timeout-ac 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отобразить все скрытые пункты в схемах управления питанием?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	@echo Отобразить все скрытые пункты в схемах управления питанием. 1>> %logfile%
	set timerStart=!time!
	for /f "tokens=* delims=" %%l in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings" /s /v "Attributes"^|FindStr HKEY_') do (reg add "%%l" /v "Attributes" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1)
	@echo %clr%[36m Отображать порог снижения производительности процессора.%clr%[92m
	@echo Отображать порог снижения производительности процессора. 1>> %logfile%
	powercfg -attributes SUB_PROCESSOR 12a0ab44-fe28-4fa9-b3bd-4b64f44960a6 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать порог увеличения производительности процессора.%clr%[92m
	@echo Отображать порог увеличения производительности процессора. 1>> %logfile%
	powercfg -attributes SUB_PROCESSOR 06cadf0e-64ed-448a-8927-ce7bf90eb35d -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать политику разрешения режима отсутствия.%clr%[92m
	@echo Отображать политику разрешения режима отсутствия. 1>> %logfile%
	powercfg -attributes SUB_SLEEP 25DFA149-5DD1-4736-B5AB-E8A37B5B8187 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать совместное использование мультимедиа.%clr%[92m
	@echo Отображать совместное использование мультимедиа. 1>> %logfile%
	powercfg -attributes 9596FB26-9850-41fd-AC3E-F7C3C00AFD4B 03680956-93BC-4294-BBA6-4E0F09BB717F -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать разрешение политики, требуемой системой.%clr%[92m
	@echo Отображать разрешение политики, требуемой системой. 1>> %logfile%
	powercfg -attributes SUB_SLEEP A4B195F5-8225-47D8-8012-9D41369786E2 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать разрешение спящего режима при удаленном открытии.%clr%[92m
	@echo Отображать разрешение спящего режима при удаленном открытии. 1>> %logfile%
	powercfg -attributes SUB_SLEEP d4c1d4c8-d5cc-43d3-b83e-fc51215cb04d -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать таймаут автоматического перехода в спящий режим.%clr%[92m
	@echo Отображать таймаут автоматического перехода в спящий режим. 1>> %logfile%
	powercfg -attributes SUB_SLEEP 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать управление питанием USB 3 Link.%clr%[92m
	@echo Отображать управление питанием USB 3 Link. 1>> %logfile%
	powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать время выборочной приостановки USB-хаба.%clr%[92m
	@echo Отображать время выборочной приостановки USB-хаба. 1>> %logfile%
	powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать разрешение отображения необходимой политики.%clr%[92m
	@echo Отображать разрешение отображения необходимой политики. 1>> %logfile%
	powercfg -attributes SUB_VIDEO A9CEB8DA-CD46-44FB-A98B-02AF69DE4623 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать действие при закрытии крышки.%clr%[92m
	@echo Отображать действие при закрытии крышки. 1>> %logfile%
	powercfg -attributes SUB_BUTTONS 5ca83367-6e45-459f-a27b-476b1d01c936 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать действие при открытии крышки.%clr%[92m
	@echo Отображать действие при открытии крышки. 1>> %logfile%
	powercfg -attributes SUB_BUTTONS 99ff10e7-23b1-4c07-a9d1-5c3206d741b4 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать управление питанием AHCI Link - Адаптивная настройка.%clr%[92m
	@echo Отображать управление питанием AHCI Link - Адаптивная настройка. 1>> %logfile%
	powercfg -attributes SUB_DISK dab60367-53fe-4fbc-825e-521d069d2456 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать порог игнорирования всплеска активности диска.%clr%[92m
	@echo Отображать порог игнорирования всплеска активности диска. 1>> %logfile%
	powercfg -attributes SUB_DISK 80e3c60e-bb94-4ad8-bbe0-0d3195efc663 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать управление питанием AHCI Link - HIPM/DIPM.%clr%[92m
	@echo Отображать управление питанием AHCI Link - HIPM/DIPM. 1>> %logfile%
	powercfg -attributes SUB_DISK 0b2d69d7-a2a1-449c-9680-f91c70521c60 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать смещение качества воспроизведения видео.%clr%[92m
	@echo Отображать смещение качества воспроизведения видео. 1>> %logfile%
	powercfg -attributes 9596FB26-9850-41fd-AC3E-F7C3C00AFD4B 10778347-1370-4ee0-8bbd-33bdacaade49 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать При воспроизведении видео.%clr%[92m
	@echo Отображать При воспроизведении видео. 1>> %logfile%
	powercfg -attributes 9596FB26-9850-41fd-AC3E-F7C3C00AFD4B 34C7B99F-9A6D-4b3c-8DC7-B6693B78CEF4 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать настройки беспроводного адаптера.%clr%[92m
	@echo Отображать настройки беспроводного адаптера. 1>> %logfile%
	powercfg -attributes 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать настройку подключения к сети в режиме ожидания.%clr%[92m
	@echo Отображать настройку подключения к сети в режиме ожидания. 1>> %logfile%
	powercfg -attributes F15576E8-98B7-4186-B944-EAFA664402D9 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать адаптивную подсветку.%clr%[92m
	@echo Отображать адаптивную подсветку. 1>> %logfile%
	powercfg -attributes SUB_VIDEO aded5e82-b909-4619-9949-f5d71dac0bcc -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать тайм-аут бездействия SEC NVMe.%clr%[92m
	@echo Отображать тайм-аут бездействия SEC NVMe. 1>> %logfile%
	powercfg -attributes SUB_DISK 6b013a00-f775-4d61-9036-a62f7e7a6a5b -ATTRIB_HIDE 1>> %logfile% 2>>&1
	@echo %clr%[36m Отображать настройку яркости затемнения экрана.%clr%[92m
	@echo Отображать настройку яркости затемнения экрана. 1>> %logfile%
	powercfg -attributes SUB_VIDEO f1fbfde2-a960-4165-9f88-50667911ce96 -ATTRIB_HIDE 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[36m Выставить сбалансированную схему управления питанием.%clr%[92m
@echo Выставить сбалансированную схему управления питанием. 1>> %logfile%
set timerStart=!time!
powercfg /setactive scheme_balanced 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить Game DVR, службы Xbox, Logitech Gaming и Razer Game Scanner.%clr%[92m
@echo Отключить Game DVR, службы Xbox, Logitech Gaming и Razer Game Scanner. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SYSTEM\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\System\GameConfigStore\Children" /f 1>> %logfile% 2>>&1
reg delete "HKCU\System\GameConfigStore\Parents" /f 1>> %logfile% 2>>&1
call :disable_svc xbgm
call :disable_svc XblAuthManager
call :disable_svc XblGameSave
call :disable_svc XboxGipSvc
call :disable_svc XboxNetApiSvc
call :disable_task "\Microsoft\XblGameSave\XblGameSaveTask"
call :acl_file "%SystemRoot%\System32\GameBarPresenceWriter.exe"
call :kill "GameBarPresenceWriter.exe"
move "%SystemRoot%\System32\GameBarPresenceWriter.exe" "%SystemRoot%\System32\GameBarPresenceWriter.old" 1>> %logfile% 2>>&1
call :kill "bcastdvr.exe"
call :acl_file "%SystemRoot%\System32\bcastdvr.exe"
move "%SystemRoot%\System32\bcastdvr.exe" "%SystemRoot%\System32\bcastdvr.old" 1>> %logfile% 2>>&1
call :disable_svc LogiRegistryService
call :disable_svc 'Razer Game Scanner Service'
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить службу поиска и Cortana.%clr%[92m
@echo Отключить службу поиска и Cortana. 1>> %logfile%
set timerStart=!time!
call :kill "SearchUI.exe"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "AllowCortana" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowIndexingEncryptedStoresOrItems" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AlwaysUseAutoLangDetection" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchPrivacy" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" /v "State" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Experience" /v "AllowCortana" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :remove_uwp Microsoft.549981C3F5F10
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Cortana.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{2765E0F4-2918-4A46-B9C9-43CDD8FCBA2B}" /t REG_SZ /d "BlockCortana|Action=Block|Active=TRUE|Dir=Out|App=C:\Windows\systemapps\microsoft.windows.cortana_cw5n1h2txyewy\searchui.exe|Name=Search and Cortana application|" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{2765E0F4-2918-4A46-B9C9-43CDD8FCBA2B}" /t REG_SZ /d "BlockCortana|Action=Block|Active=TRUE|Dir=Out|App=C:\Windows\systemapps\microsoft.windows.cortana_cw5n1h2txyewy\searchui.exe|Name=Search and Cortana application|" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить Wi-Fi Sense (данный функционал позволяет делиться доступом к своим сетям Wi-Fi со своими контактами и автоматически подключаться к сетям друзей).%clr%[92m
@echo Отключить Wi-Fi Sense (данный функционал позволяет делиться доступом к своим сетям Wi-Fi со своими контактами и автоматически подключаться к сетям друзей). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "WiFISenseAllowed" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\software\microsoft\wcmsvc\wifinetworkmanager" /v "wifisensecredshared" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\software\microsoft\wcmsvc\wifinetworkmanager" /v "wifisenseopen" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
for /f "tokens=* delims=" %%l in ('reg query "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" /s ^|FindStr HKEY_') do (reg add "%%l" /v "FeatureStates" /t REG_DWORD /d "828" /f 1>> %logfile% 2>>&1)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить сжатие памяти и предзагрузку приложений в ОС.%clr%[92m
@echo Отключить сжатие памяти и предзагрузку приложений в ОС. 1>> %logfile%
set timerStart=!time!
powershell "Disable-MMAgent -MemoryCompression -ApplicationPreLaunch -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Использовать приоритет реального времени для csrss.exe%clr%[92m
@echo Использовать приоритет реального времени для csrss.exe 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "KernelSEHOPEnabled" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить средства защиты процессов и ядра.%clr%[92m
@echo Отключить средства защиты процессов и ядра. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "22222222222222222002000000200000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "20000020202022220000000000000000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "foreach ($mit in (Get-Command -Name Set-ProcessMitigation).Parameters['Disable'].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $mit.ToString().Replace(' \', '\').Replace('`n\', '\') -ErrorAction SilentlyContinue}" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить память, управляемую ядром и отключить исправления Meltdown/Spectre.%clr%[92m
@echo Включить память, управляемую ядром и отключить исправления Meltdown/Spectre. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запретить загрузку системных файлов (таких как ядро и драйверы оборудования) в виртуальную память.%clr%[92m
@echo Запретить загрузку системных файлов (таких как ядро и драйверы оборудования) в виртуальную память. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить объединение страниц памяти (таких как совместное использование страниц для изображений, копирование при записи) для страниц данных и сжатие.%clr%[92m
@echo Отключить объединение страниц памяти (таких как совместное использование страниц для изображений, копирование при записи) для страниц данных и сжатие. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingCombining" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить большой системный кэш для ОС, чтобы исправить микрофризы.%clr%[92m
@echo Отключить большой системный кэш для ОС, чтобы исправить микрофризы. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить дополнительные средства защиты NTFS/ReFS.%clr%[92m
@echo Отключить дополнительные средства защиты NTFS/ReFS. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить временную метку 0 мс. Для неоптимизированных систем рекомендуется выставить параметр 1.%clr%[92m
@echo Включить временную метку 0 мс. Для неоптимизированных систем рекомендуется выставить параметр 1. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить разделение процесса svchost.exe в диспетчере задач.%clr%[92m
@echo Отключить разделение процесса svchost.exe в диспетчере задач. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "33554432" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BrokerInfrastructure" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Browser" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BTAGService" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cbdhsvc_3c9a6" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CmService" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CoreMessagingRegistrar" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcaSvc" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvagent" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PlugPlay" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RapiMgr" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RemoteAccess" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\StateRepository" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WAS" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WcesComm" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wcmsvc" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService_3c9a6" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Предотвратить ошибки при отключении драйверов.%clr%[92m
@echo Предотвратить ошибки при отключении драйверов. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "ErrorControl" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\fvevol" /v "ErrorControl" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}" /v "UpperFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e967-e325-11ce-bfc1-08002be10318}" /v "LowerFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{6bdd1fc6-810f-11d0-bec7-08002be2092f}" /v "UpperFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{71a27cdd-812a-11d0-bec7-08002be2092f}" /v "LowerFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить службу Superfetch.%clr%[92m
@echo Отключить службу Superfetch. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\EnableSuperfetch" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_svc SysMain
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить службу индексации поиска.%clr%[92m
@echo Отключить службу индексации поиска. 1>> %logfile%
set timerStart=!time!
call :disable_svc WSearch
sc stop WSearch 1>> %logfile% 2>>&1
%SystemUser% del /f /q C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить использование корзины. Файлы будут удаляться окончательно (полезно для SSD дисков).%clr%[92m
@echo Отключить использование корзины. Файлы будут удаляться окончательно (полезно для SSD дисков). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecycleFiles" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Увеличение объема используемой памяти для файловой системы NTFS.%clr%[92m
@echo Увеличение объема используемой памяти для файловой системы NTFS. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить поставщика алгоритмов помощника оборудования.%clr%[92m
@echo Отключить поставщика алгоритмов помощника оборудования. 1>> %logfile%
set timerStart=!time!
call :disable_svc cnghwassist
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить помощника по совместимости программ.%clr%[92m
@echo Отключить помощника по совместимости программ. 1>> %logfile%
set timerStart=!time!
call :disable_svc PcaSvc
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить удаленного помощника.%clr%[92m
@echo Отключить удаленного помощника. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "Get-WindowsCapability -Online | Where-Object {$_.Name -like 'App.Support.QuickAssist*'} | Remove-WindowsCapability -Online -wa SilentlyContinue" 1>> %logfile% 2>>&1
call :disable_task "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить обновление групповой политики во время загрузки Windows.%clr%[92m
@echo Отключить обновление групповой политики во время загрузки Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousUserGroupPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousMachineGroupPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить службу отчета об ошибках.%clr%[92m
@echo Отключить службу отчета об ошибках. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить предвыборку для ускорения запуска Windows.%clr%[92m
@echo Отключить предвыборку для ускорения запуска Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить TRIM оптимизацию SSD дисков.%clr%[92m
@echo Включить TRIM оптимизацию SSD дисков. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" /v "Enable" /t REG_SZ /d "Y" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" /v "EnableAutoLayout" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
fsutil behavior set DisableDeleteNotify 0 1>> %logfile% 2>>&1
echo. 1>> %logfile%
@echo %clr%[36m Включить создание последней удачной конфигрурации загрузки.%clr%[92m
@echo Включить создание последней удачной конфигрурации загрузки. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ReportBootOk" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить проверку диска при запуске Windows.%clr%[92m
@echo Отключить проверку диска при запуске Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Автоматически завершать не отвечающие приложения.%clr%[92m
@echo Автоматически завершать не отвечающие приложения. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "5000" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowBlockingAppsAtShutdown" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить лишние апплеты в расширенном запуске.%clr%[92m
@echo Удалить лишние апплеты в расширенном запуске. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ShellServiceObjectDelayLoad" /v "WebCheck" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "VMApplet" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить обнаружение UPnP устройств в сети.%clr%[92m
@echo Отключить обнаружение UPnP устройств в сети. 1>> %logfile%
set timerStart=!time!
call :disable_svc SSDPSRV
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить контроль системных событий.%clr%[92m
@echo Отключить контроль системных событий. 1>> %logfile%
set timerStart=!time!
call :disable_svc SENS
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить отправку отчетов об ошибках.%clr%[92m
@echo Отключить отправку отчетов об ошибках. 1>> %logfile%
set timerStart=!time!
call :disable_svc WerSvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить установку компонентов языковых пакетов из интернета.%clr%[92m
@echo Отключить установку компонентов языковых пакетов из интернета. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить службы диагностики.%clr%[92m
@echo Отключить службы диагностики. 1>> %logfile%
set timerStart=!time!
call :disable_svc_sudo DPS
call :disable_svc_sudo WdiServiceHost
call :disable_svc_sudo WdiSystemHost
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkServiceTriggers\Triggers\bc90d167-9470-4139-a9ba-be0bbbf5b74d" /v "795B6BF9-97B6-4F89-BD8D-2F42BBBE996E" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkServiceTriggers\Triggers\bc90d167-9470-4139-a9ba-be0bbbf5b74d" /v "945693c4-3648-4966-b2aa-37d66e24495f" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автозапуск CD-DVD и съемных устройств.%clr%[92m
@echo Отключить автозапуск CD-DVD и съемных устройств. 1>> %logfile%
set timerStart=!time!
call :disable_svc ShellHWDetection
call :disable_svc stisvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Не отображать подробные сообщения о состоянии при запуске и завершении работы Windows.%clr%[92m
@echo Не отображать подробные сообщения о состоянии при запуске и завершении работы Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить систему авто-выравнивания звука.%clr%[92m
@echo Отключить систему авто-выравнивания звука. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio" /v "UserDuckingPreference" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выключить функцию Время последнего доступа.%clr%[92m
@echo Выключить функцию Время последнего доступа. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
fsutil behavior set DisableLastAccess 1 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить широкиие контекстные меню.%clr%[92m
@echo Отключить широкиие контекстные меню. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\FlightedFeatures" /v "ImmersiveContextMenu" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить миниатюры сетевых папок.%clr%[92m
@echo Отключить миниатюры сетевых папок. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "DisableThumbnailsOnNetworkFolders" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать буквы дисков перед именем дисков.%clr%[92m
@echo Показать буквы дисков перед именем дисков. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowDriveLettersFirst" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Увеличить максимальное количество рабочих потоков.%clr%[92m
@echo Увеличить максимальное количество рабочих потоков. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellTaskScheduler" /v "MaxWorkerThreadsPerScheduler" /t REG_DWORD /d "255" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить автозавершение в адресной строке и автоматический ввод в поле поиска.%clr%[92m
@echo Включить автозавершение в адресной строке и автоматический ввод в поле поиска. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TypeAhead" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t REG_SZ /d "Yes" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить сворачивание окон при встряхивании (Aero Shake).%clr%[92m
@echo Отключить сворачивание окон при встряхивании (Aero Shake). 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автоматическое обнаружение типа папок.%clr%[92m
@echo Отключить автоматическое обнаружение типа папок. 1>> %logfile%
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Classes\Local Settings\SOFTWARE\Microsoft\Windows\Shell\Bags" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\SOFTWARE\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Установить имя новой папки и ярлыка как _ .%clr%[92m
@echo Установить имя новой папки и ярлыка как _ . 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "RenameNameTemplate" /t REG_SZ /d "_" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "CopyNameTemplate" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "CopyNameTemplate" /t REG_SZ /d "%%s_" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Не добавлять суффикс - Ярлык к имени созданного ярлыка.%clr%[92m
@echo Не добавлять суффикс - Ярлык к имени созданного ярлыка. 1>> %logfile%
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /t REG_SZ /d "%%s.lnk" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить стрелку с ярлыков, файлов и сетевых ярлыков.%clr%[92m
@echo Удалить стрелку с ярлыков, файлов и сетевых ярлыков. 1>> %logfile%
set timerStart=!time!
xcopy %~dp0link.ico %SystemRoot% /c /q /h /r /y 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /t REG_SZ /d "%SystemRoot%\link.ico,0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "77" /t REG_SZ /d "%SystemRoot%\link.ico,0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить режим планшета.%clr%[92m
@echo Отключить режим планшета. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAppsVisibleInTabletMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "ConvertibleSlateModePromptPreference" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить живые плитки.%clr%[92m
@echo Отключить живые плитки. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить запрос Как вы хотите открыть этот файл.%clr%[92m
@echo Отключить запрос Как вы хотите открыть этот файл. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть последние добавленные приложения.%clr%[92m
@echo Скрыть последние добавленные приложения. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить создание списков последних использованных элементов (MRU), таких как меню Последние элементы в меню Пуск, списки переходов и ярлыки в нижней части меню Файл в приложениях.%clr%[92m
@echo Отключить создание списков последних использованных элементов (MRU), таких как меню Последние элементы в меню Пуск, списки переходов и ярлыки в нижней части меню Файл в приложениях. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ClearRecentDocsOnExit" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить поиск Bing в меню Пуск.%clr%[92m
@echo Отключить поиск Bing в меню Пуск. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить создание файла подкачки swapfile.sys для приложении и освободить 256 МБ дискового пространства.%clr%[92m
@echo Отключить создание файла подкачки swapfile.sys для приложении и освободить 256 МБ дискового пространства. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SwapfileControl" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить минутное ожидание при первом входе в систему.%clr%[92m
@echo Отключить минутное ожидание при первом входе в систему. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "FSIASleepTimeInMs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить несуществующие ярлыки запуска.%clr%[92m
@echo Удалить несуществующие ярлыки запуска. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "table30.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "fsquirt.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "dfshim.dll" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "setup.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "install.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "cmmgr32.exe" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить предупреждение системы безопасности при открытии файлов из интернета.%clr%[92m
@echo Отключить предупреждение системы безопасности при открытии файлов из интернета. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "Flags" /t REG_DWORD /d "219" /f 1>> %logfile% 2>>&1
reg add "HKCU\Environment" /v "SEE_MASK_NOZONECHECKS" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "SEE_MASK_NOZONECHECKS" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
setx SEE_MASK_NOZONECHECKS 1 /m 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить отображение графического пароля.%clr%[92m
@echo Отключить отображение графического пароля. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "BlockDomainPicturePassword" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить историю активности в Представлении задач.%clr%[92m
@echo Отключить историю активности в Представлении задач. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить историю недавних документов и часто используемых папок.%clr%[92m
@echo Отключить историю недавних документов и часто используемых папок. 1>> %logfile%
set timerStart=!time!
if "%arch%"=="x64" (
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" /f 1>> %logfile% 2>>&1
)
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить USB порт после безопасного отключения USB-устройства.%clr%[92m
@echo Отключить USB порт после безопасного отключения USB-устройства. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbhub\HubG" /v "DisableOnSoftRemove" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableRemovableDriveIndexing" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить Kernel из черного списка графических драйверов.%clr%[92m
@echo Удалить Kernel из черного списка графических драйверов. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\BlockList\Kernel" /va /reg:64 /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить DPC Watchdog.%clr%[92m
@echo Отключить DPC Watchdog. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcWatchdogProfileOffset" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "IdealDpcRate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MaximumDpcQueueDepth" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MinimumDpcRate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "ThreadDpcEnable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "AdjustDpcThreshold" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcWatchdogPeriod" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить экран блокировки.%clr%[92m
@echo Отключить экран блокировки. 1>> %logfile%
set timerStart=!time!
call :kill "LockApp.exe"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData" /v "AllowLockScreen" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Настроить компьютер на полное выключение.%clr%[92m
@echo Настроить компьютер на полное выключение. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /v "PowerdownAfterShutdown" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автоматическое обслуживание.%clr%[92m
@echo Отключить автоматическое обслуживание. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить фоновые приложения.%clr%[92m
@echo Отключить фоновые приложения. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запретить использование биометрии.%clr%[92m
@echo Запретить использование биометрии. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics\Credential Provider" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_svc WbioSrvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к информации об аккаунте.%clr%[92m
@echo Отключить доступ приложениям к информации об аккаунте. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessAccountInfo" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить приложениям доступ к уведомлениям.%clr%[92m
@echo Отключить приложениям доступ к уведомлениям. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessNotifications" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к календарю.%clr%[92m
@echo Отключить доступ приложениям к календарю. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCalendar" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к истории звонков.%clr%[92m
@echo Отключить доступ приложениям к истории звонков. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCallHistory" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к задачам.%clr%[92m
@echo Отключить доступ приложениям к задачам. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessTasks" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к видео.%clr%[92m
@echo Отключить доступ приложениям к видео. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к камере.%clr%[92m
@echo Отключить доступ приложениям к камере. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCamera" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к несопряженным устройствам.%clr%[92m
@echo Отключить доступ приложениям к несопряженным устройствам. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsSyncWithDevices" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к контактам.%clr%[92m
@echo Отключить доступ приложениям к контактам. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessContacts" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к диагностике.%clr%[92m
@echo Отключить доступ приложениям к диагностике. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsGetDiagnosticInfo" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к документам.%clr%[92m
@echo Отключить доступ приложениям к документам. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к изображениям.%clr%[92m
@echo Отключить доступ приложениям к изображениям. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к радио.%clr%[92m
@echo Отключить доступ приложениям к радио. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessRadios" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к почте.%clr%[92m
@echo Отключить доступ приложениям к почте. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessEmail" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к файловой системе.%clr%[92m
@echo Отключить доступ приложениям к файловой системе. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к вводу взглядом.%clr%[92m
@echo Отключить доступ приложениям к вводу взглядом. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessGazeInput" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\gazeInput" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к геолокации.%clr%[92m
@echo Отключить доступ приложениям к геолокации. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к обмену сообщениями.%clr%[92m
@echo Отключить доступ приложениям к обмену сообщениями. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMessaging" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить доступ приложениям к микрофону.%clr%[92m
@echo Отключить доступ приложениям к микрофону. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMicrophone" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить эксперименты над системой.%clr%[92m
@echo Отключить эксперименты над системой. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System\AllowExperimentation" /v "value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить историю файлов.%clr%[92m
@echo Отключить историю файлов. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\FileHistory" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить гибернацию и отключить быстрый запуск.%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m при включении быстрого запуска пропадает возможность выключения ПК и перевод в режим гибернации.
@echo Включить гибернацию и отключить быстрый запуск. Примечание: при включении быстрого запуска пропадает возможность выключения ПК и перевод в режим гибернации. 1>> %logfile%
set timerStart=!time!
powercfg hibernate size 40 1>> %logfile% 2>>&1
powercfg /h on 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HiberFileSizePercent" /t REG_DWORD /d "40" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowHibernateOption" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить спящий режим и кнопку Sleep на клавиатуре.%clr%[92m
@echo Отключить спящий режим и кнопку Sleep на клавиатуре. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powercfg /X standby-timeout-ac 0 1>> %logfile% 2>>&1
powercfg /X standby-timeout-dc 0 1>> %logfile% 2>>&1
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 1>> %logfile% 2>>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить предложение средства удаления вредоносных программ через Центр обновления Windows.%clr%[92m
@echo Отключить предложение средства удаления вредоносных программ через Центр обновления Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автоматическую перезагрузку при сбое системы (BSOD).%clr%[92m
@echo Отключить автоматическую перезагрузку при сбое системы (BSOD). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "AutoReboot" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выставить низкий уровень UAC (контроль учетных записей).%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m полное отключение приведет к поломке некоторых приложений.%clr%[92m
@echo Выставить низкий уровень UAC (контроль учетных записей). Предупреждение: полное отключение приведет к поломке некоторых приложений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить предотвращение выполнения данных (DEP) для Internet Explorer.%clr%[92m
@echo Отключить предотвращение выполнения данных (DEP) для Internet Explorer. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DEPOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить проверку отзыва сертификатов и включить их прозрачность.%clr%[92m
@echo Отключить проверку отзыва сертификатов и включить их прозрачность. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers" /v "authenticodeenabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers" /v "TransparentEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить обратную связь с пером.%clr%[92m
@echo Отключить обратную связь с пером. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\TabletPC" /v "TurnOffPenFeedback" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить задержку запуска Windows.%clr%[92m
@echo Отключить задержку запуска Windows. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Ускорить вход в систему.%clr%[92m
@echo Ускорить вход в систему. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\AppEvents\Schemes" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить отправку и синхронизацию файлов с облаком.%clr%[92m
@echo Отключить отправку и синхронизацию файлов с облаком. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableAppSyncSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableAppSyncSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableApplicationSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableApplicationSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableCredentialsSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableCredentialsSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableDesktopThemeSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableDesktopThemeSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisablePersonalizationSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisablePersonalizationSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableStartLayoutSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableStartLayoutSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSyncOnPaidNetwork" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableWebBrowserSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableWebBrowserSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableWindowsSettingSync" /t Reg_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableWindowsSettingSyncUserOverride" /t Reg_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\DesktopTheme" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t Reg_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t Reg_DWORD /d "5" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить файервол?%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m после отключения возможно не будет работать файервол в сторонней антивирусной программе.
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
	echo Отключение файервола. Пожалуйста подождите...
	@echo Отключение файервола. Предупреждение: после отключения возможно не будет работать файервол в сторонней антивирусной программе. 1>> %logfile%
	set timerStart=!time!
	reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	netsh advfirewall firewall set rule group="Network Discovery" new enable=No 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	reg delete "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f 1>> %logfile% 2>>&1
	netsh advfirewall set allprofiles state off 1>> %logfile% 2>>&1
	call :disable_svc MpsSvc
	call :disable_svc mpsdrv
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile% 2>>&1
)
@echo %clr%[36m Добавить дополнительные правила файервола для усиления защиты ОС?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
echo Добавление дополнительных правил файервола для усиления защиты ОС. Пожалуйста подождите...
@echo Добавление дополнительных правил файервола для усиления защиты ОС. 1>> %logfile%
set timerStart=!time!
	netsh advfirewall firewall add rule name="Block appvlp.exe" program="%ProgramFiles%\Microsoft Office\root\client\AppVLP.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block appvlp.exe" program="%ProgramFiles(x86)%\Microsoft Office\root\client\AppVLP.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block At.exe" program="%SystemRoot%\System32\At.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block At.exe" program="%SystemRoot%\SysWOW64\At.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Attrib.exe" program="%SystemRoot%\System32\Attrib.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Attrib.exe" program="%SystemRoot%\SysWOW64\Attrib.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Atbroker.exe" program="%SystemRoot%\System32\Atbroker.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Atbroker.exe" program="%SystemRoot%\SysWOW64\Atbroker.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block bash.exe" program="%SystemRoot%\System32\bash.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block bash.exe" program="%SystemRoot%\SysWOW64\bash.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block bitsadmin.exe" program="%SystemRoot%\System32\bitsadmin.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block bitsadmin.exe" program="%SystemRoot%\SysWOW64\bitsadmin.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block calc.exe" program="%SystemRoot%\System32\calc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block calc.exe" program="%SystemRoot%\SysWOW64\calc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block certreq.exe" program="%SystemRoot%\System32\certreq.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block certreq.exe" program="%SystemRoot%\SysWOW64\certreq.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block certutil.exe" program="%SystemRoot%\System32\certutil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block certutil.exe" program="%SystemRoot%\SysWOW64\certutil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cmdkey.exe" program="%SystemRoot%\System32\cmdkey.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cmdkey.exe" program="%SystemRoot%\SysWOW64\cmdkey.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cmstp.exe" program="%SystemRoot%\System32\cmstp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cmstp.exe" program="%SystemRoot%\SysWOW64\cmstp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block CompatTelRunner.exe" program="%SystemRoot%\System32\CompatTelRunner.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block CompatTelRunner.exe" program="%SystemRoot%\SysWOW64\CompatTelRunner.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ConfigSecurityPolicy.exe" program="%ProgramData%\Microsoft\Windows Defender\Platform\4.18.2008.9-0\ConfigSecurityPolicy.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block control.exe" program="%SystemRoot%\System32\control.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block control.exe" program="%SystemRoot%\SysWOW64\control.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Csc.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\Csc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Csc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\Csc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cscript.exe" program="%SystemRoot%\System32\cscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block cscript.exe" program="%SystemRoot%\SysWOW64\cscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ctfmon.exe" program="%SystemRoot%\System32\ctfmon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ctfmon.exe" program="%SystemRoot%\SysWOW64\ctfmon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block curl.exe" program="%SystemRoot%\System32\curl.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block curl.exe" program="%SystemRoot%\SysWOW64\curl.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block desktopimgdownldr.exe" program="%SystemRoot%\System32\desktopimgdownldr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block DeviceDisplayObjectProvider.exe" program="%SystemRoot%\System32\DeviceDisplayObjectProvider.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block DeviceDisplayObjectProvider.exe" program="%SystemRoot%\SysWOW64\DeviceDisplayObjectProvider.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Dfsvc.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\Dfsvc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Dfsvc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\Dfsvc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block diskshadow.exe" program="%SystemRoot%\SysWOW64\diskshadow.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block diskshadow.exe" program="%SystemRoot%\System32\diskshadow.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Dnscmd.exe" program="%SystemRoot%\SysWOW64\Dnscmd.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Dnscmd.exe" program="%SystemRoot%\System32\Dnscmd.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block dwm.exe" program="%SystemRoot%\SysWOW64\dwm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block dwm.exe" program="%SystemRoot%\System32\dwm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block eventvwr.exe" program="%SystemRoot%\SysWOW64\eventvwr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block eventvwr.exe" program="%SystemRoot%\System32\eventvwr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block esentutl.exe" program="%SystemRoot%\SysWOW64\esentutl.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block esentutl.exe" program="%SystemRoot%\System32\esentutl.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block eventvwr.exe" program="%SystemRoot%\SysWOW64\eventvwr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block eventvwr.exe" program="%SystemRoot%\SysWOW64\eventvwr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Expand.exe" program="%SystemRoot%\System32\Expand.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Expand.exe" program="%SystemRoot%\SysWOW64\Expand.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block explorer.exe" program="%SystemRoot%\System32\explorer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block explorer.exe" program="%SystemRoot%\SysWOW64\explorer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Extexport.exe" program="%ProgramFiles%\Internet Explorer\Extexport.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Extexport.exe" program="%ProgramFiles(x86)%\Internet Explorer\Extexport.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block extrac32.exe" program="%SystemRoot%\System32\extrac32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block extrac32.exe" program="%SystemRoot%\SysWOW64\extrac32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block findstr.exe" program="%SystemRoot%\System32\findstr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block findstr.exe" program="%SystemRoot%\SysWOW64\findstr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block forfiles.exe" program="%SystemRoot%\System32\forfiles.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block forfiles.exe" program="%SystemRoot%\SysWOW64\forfiles.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ftp.exe" program="%SystemRoot%\System32\ftp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ftp.exe" program="%SystemRoot%\SysWOW64\ftp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block gpscript.exe" program="%SystemRoot%\System32\gpscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block gpscript.exe" program="%SystemRoot%\SysWOW64\gpscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block hh.exe" program="%SystemRoot%\System32\hh.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block hh.exe" program="%SystemRoot%\SysWOW64\hh.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ie4uinit.exe" program="%SystemRoot%\System32\ie4uinit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ie4uinit.exe" program="%SystemRoot%\SysWOW64\ie4uinit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ieexec.exe" program="%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\ieexec.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ieexec.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\ieexec.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ilasm.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\ilasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ilasm.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\ilasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Infdefaultinstall.exe" program="%SystemRoot%\System32\Infdefaultinstall.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Infdefaultinstall.exe" program="%SystemRoot%\SysWOW64\Infdefaultinstall.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block InstallUtil.exe" program="%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block InstallUtil.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block InstallUtil.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block InstallUtil.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Jsc.exe" program="%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\Jsc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Jsc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\Jsc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Jsc.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\Jsc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Jsc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\Jsc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block lsass.exe" program="%SystemRoot%\System32\lsass.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block lsass.exe" program="%SystemRoot%\SysWOW64\lsass.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block makecab.exe" program="%SystemRoot%\System32\makecab.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block makecab.exe" program="%SystemRoot%\SysWOW64\makecab.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mavinject.exe" program="%SystemRoot%\System32\mavinject.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mavinject.exe" program="%SystemRoot%\SysWOW64\mavinject.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Microsoft.Workflow.Compiler.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\Microsoft.Workflow.Compiler.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mmc.exe" program="%SystemRoot%\SysWOW64\mmc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mmc.exe" program="%SystemRoot%\System32\mmc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block MpCmdRun.exe" program="%ProgramData%\Microsoft\Windows Defender\Platform\4.18.2008.4-0\MpCmdRun.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block MpCmdRun.exe" program="%ProgramData%\Microsoft\Windows Defender\Platform\4.18.2008.7-0\MpCmdRun.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block MpCmdRun.exe" program="%ProgramData%\Microsoft\Windows Defender\Platform\4.18.2008.9-0\MpCmdRun.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework\v3.5\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v3.5\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msbuild.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\Msbuild.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block msconfig.exe" program="%SystemRoot%\System32\msconfig.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msdt.exe" program="%SystemRoot%\System32\Msdt.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Msdt.exe" program="%SystemRoot%\SysWOW64\Msdt.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mshta.exe" program="%SystemRoot%\System32\mshta.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block mshta.exe" program="%SystemRoot%\SysWOW64\mshta.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block msiexec.exe" program="%SystemRoot%\System32\msiexec.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block msiexec.exe" program="%SystemRoot%\SysWOW64\msiexec.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Netsh.exe" program="%SystemRoot%\System32\Netsh.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Netsh.exe" program="%SystemRoot%\SysWOW64\Netsh.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block notepad.exe" program="%SystemRoot%\system32\notepad.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block notepad.exe " program="%SystemRoot%\SysWOW64\notepad.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block odbcconf.exe" program="%SystemRoot%\System32\odbcconf.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block odbcconf.exe" program="%SystemRoot%\SysWOW64\odbcconf.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pcalua.exe" program="%SystemRoot%\System32\pcalua.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pcalua.exe" program="%SystemRoot%\SysWOW64\pcalua.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pcwrun.exe" program="%SystemRoot%\System32\pcwrun.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pcwrun.exe" program="%SystemRoot%\SysWOW64\pcwrun.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pktmon.exe" program="%SystemRoot%\System32\pktmon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block pktmon.exe" program="%SystemRoot%\SysWOW64\pktmon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block powershell.exe" program="%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block powershell.exe" program="%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block powershell_ise.exe" program="%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell_ise.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block powershell_ise.exe" program="%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell_ise.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Presentationhost.exe" program="%SystemRoot%\System32\Presentationhost.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Presentationhost.exe" program="%SystemRoot%\SysWOW64\Presentationhost.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block print.exe" program="%SystemRoot%\System32\print.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block print.exe" program="%SystemRoot%\SysWOW64\print.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block psr.exe" program="%SystemRoot%\System32\psr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block psr.exe" program="%SystemRoot%\SysWOW64\psr.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rasautou.exe" program="%SystemRoot%\System32\rasautou.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rasautou.exe" program="%SystemRoot%\SysWOW64\rasautou.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block reg.exe" program="%SystemRoot%\System32\reg.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block reg.exe" program="%SystemRoot%\SysWOW64\reg.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regasm.exe" program="%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\regasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regasm.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\regasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regasm.exe" program="%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\regasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regasm.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\regasm.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regedit.exe" program="%SystemRoot%\System32\regedit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regedit.exe" program="%SystemRoot%\SysWOW64\regedit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regini.exe" program="%SystemRoot%\System32\regini.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regini.exe" program="%SystemRoot%\SysWOW64\regini.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Register-cimprovider.exe" program="%SystemRoot%\System32\Register-cimprovider.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block Register-cimprovider.exe" program="%SystemRoot%\SysWOW64\Register-cimprovider.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regsvcs.exe" program="%SystemRoot%\System32\regsvcs.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regsvcs.exe" program="%SystemRoot%\SysWOW64\regsvcs.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regsvr32.exe" program="%SystemRoot%\System32\regsvr32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block regsvr32.exe" program="%SystemRoot%\SysWOW64\regsvr32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block replace.exe" program="%SystemRoot%\System32\replace.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block replace.exe" program="%SystemRoot%\SysWOW64\replace.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rpcping.exe" program="%SystemRoot%\System32\rpcping.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rpcping.exe" program="%SystemRoot%\SysWOW64\rpcping.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rundll32.exe" program="%SystemRoot%\System32\rundll32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block rundll32.exe" program="%SystemRoot%\SysWOW64\rundll32.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block runonce.exe" program="%SystemRoot%\System32\runonce.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block runonce.exe" program="%SystemRoot%\SysWOW64\runonce.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block services.exe" program="%SystemRoot%\System32\services.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block services.exe" program="%SystemRoot%\SysWOW64\services.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block sc.exe" program="%SystemRoot%\System32\sc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block sc.exe" program="%SystemRoot%\SysWOW64\sc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block schtasks.exe" program="%SystemRoot%\System32\schtasks.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block schtasks.exe" program="%SystemRoot%\SysWOW64\schtasks.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block scriptrunner.exe" program="%SystemRoot%\System32\scriptrunner.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block scriptrunner.exe" program="%SystemRoot%\SysWOW64\scriptrunner.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block SyncAppvPublishingServer.exe" program="%SystemRoot%\System32\SyncAppvPublishingServer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block SyncAppvPublishingServer.exe" program="%SystemRoot%\SysWOW64\SyncAppvPublishingServer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block telnet.exe" program="%SystemRoot%\System32\telnet.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block telnet.exe" program="%SystemRoot%\SysWOW64\telnet.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block tftp.exe" program="%SystemRoot%\System32\tftp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block tftp.exe" program="%SystemRoot%\SysWOW64\tftp.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ttdinject.exe" program="%SystemRoot%\System32\ttdinject.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block ttdinject.exe" program="%SystemRoot%\SysWOW64\ttdinject.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block tttracer.exe" program="%SystemRoot%\System32\tttracer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block tttracer.exe" program="%SystemRoot%\SysWOW64\tttracer.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block vbc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\vbc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block vbc.exe" program="%SystemRoot%\Microsoft.NET\Framework64\v3.5\vbc.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block verclsid.exe" program="%SystemRoot%\System32\verclsid.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block verclsid.exe" program="%SystemRoot%\SysWOW64\verclsid.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wab.exe" program="%ProgramFiles%\Windows Mail\wab.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wab.exe" program="%ProgramFiles(x86)%\Windows Mail\wab.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block WerFault.exe" program="%SystemRoot%\SysWOW64\WerFault.exe" protocol=any dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block WerFault.exe" program="%SystemRoot%\SysWOW64\WerFault.exe" protocol=any dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wininit.exe" program="%SystemRoot%\System32\wininit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wininit.exe" program="%SystemRoot%\SysWOW64\wininit.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block winlogon.exe" program="%SystemRoot%\System32\winlogon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block winlogon.exe" program="%SystemRoot%\SysWOW64\winlogon.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wmic.exe" program="%SystemRoot%\System32\wbem\wmic.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wmic.exe" program="%SystemRoot%\SysWOW64\wbem\wmic.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wordpad.exe" program="%ProgramFiles%\windows nt\accessories\wordpad.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wordpad.exe" program="%ProgramFiles(x86)%\windows nt\accessories\wordpad.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wscript.exe" program="%SystemRoot%\System32\wscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wscript.exe" program="%SystemRoot%\SysWOW64\wscript.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wsreset.exe" program="%SystemRoot%\System32\wsreset.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block wsreset.exe" program="%SystemRoot%\SysWOW64\wsreset.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block xwizard.exe" program="%SystemRoot%\System32\xwizard.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="Block xwizard.exe" program="%SystemRoot%\SysWOW64\xwizard.exe" dir=out enable=yes action=block profile=any 1>> %logfile% 2>>&1
:: блокировка телеметрии
	netsh advfirewall firewall add rule name="telemetry_vortex.data.microsoft.com" dir=out action=block remoteip=191.232.139.254 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_telecommand.telemetry.microsoft.com" dir=out action=block remoteip=65.55.252.92 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_oca.telemetry.microsoft.com" dir=out action=block remoteip=65.55.252.63 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_sqm.telemetry.microsoft.com" dir=out action=block remoteip=65.55.252.93 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_watson.telemetry.microsoft.com" dir=out action=block remoteip=65.55.252.43,65.52.108.29 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_redir.metaservices.microsoft.com" dir=out action=block remoteip=194.44.4.200,194.44.4.208 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_choice.microsoft.com" dir=out action=block remoteip=157.56.91.77 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.7 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_reports.wes.df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.91 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_wes.df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.93 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_services.wes.df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.92 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_sqm.df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.94 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.9 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_watson.ppe.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.11 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_telemetry.appex.bing.net" dir=out action=block remoteip=168.63.108.233 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_telemetry.urs.microsoft.com" dir=out action=block remoteip=157.56.74.250 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_settings-sandbox.data.microsoft.com" dir=out action=block remoteip=111.221.29.177 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_vortex-sandbox.data.microsoft.com" dir=out action=block remoteip=64.4.54.32 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_survey.watson.microsoft.com" dir=out action=block remoteip=207.68.166.254 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_watson.live.com" dir=out action=block remoteip=207.46.223.94 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_watson.microsoft.com" dir=out action=block remoteip=65.55.252.71 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_statsfe2.ws.microsoft.com" dir=out action=block remoteip=64.4.54.22 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_corpext.msitadfs.glbdns2.microsoft.com" dir=out action=block remoteip=131.107.113.238 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_compatexchange.cloudapp.net" dir=out action=block remoteip=23.99.10.11 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_cs1.wpc.v0cdn.net" dir=out action=block remoteip=68.232.34.200 enable=no profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_a-0001.a-msedge.net" dir=out action=block remoteip=204.79.197.200 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_statsfe2.update.microsoft.com.akadns.net" dir=out action=block remoteip=64.4.54.22 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_sls.update.microsoft.com.akadns.net" dir=out action=block remoteip=157.56.77.139 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_fe2.update.microsoft.com.akadns.net" dir=out action=block remoteip=134.170.58.121,134.170.58.123,134.170.53.29,66.119.144.190,134.170.58.189,134.170.58.118,134.170.53.30,134.170.51.190 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_diagnostics.support.microsoft.com" dir=out action=block remoteip=157.56.121.89 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_corp.sts.microsoft.com" dir=out action=block remoteip=131.107.113.238 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_statsfe1.ws.microsoft.com" dir=out action=block remoteip=134.170.115.60 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_pre.footprintpredict.com" dir=out action=block remoteip=204.79.197.200 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_i1.services.social.microsoft.com" dir=out action=block remoteip=104.82.22.249 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_feedback.windows.com" dir=out action=block remoteip=134.170.185.70 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_feedback.microsoft-hohm.com" dir=out action=block remoteip=64.4.6.100,65.55.39.10 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_feedback.search.microsoft.com" dir=out action=block remoteip=157.55.129.21 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_rad.msn.com" dir=out action=block remoteip=207.46.194.25 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_preview.msn.com" dir=out action=block remoteip=23.102.21.4 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_dart.l.doubleclick.net" dir=out action=block remoteip=173.194.113.220,173.194.113.219,216.58.209.166 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_ads.msn.com" dir=out action=block remoteip=157.56.91.82,157.56.23.91,104.82.14.146,207.123.56.252,185.13.160.61,8.254.209.254 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_a.ads1.msn.com" dir=out action=block remoteip=198.78.208.254,185.13.160.61 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_global.msads.net.c.footprint.net" dir=out action=block remoteip=185.13.160.61,8.254.209.254,207.123.56.252 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_az361816.vo.msecnd.net" dir=out action=block remoteip=68.232.34.200 enable=no profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_oca.telemetry.microsoft.com.nsatc.net" dir=out action=block remoteip=65.55.252.63 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_reports.wes.df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.91 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_df.telemetry.microsoft.com" dir=out action=block remoteip=65.52.100.7 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_cs1.wpc.v0cdn.net" dir=out action=block remoteip=68.232.34.200 enable=no profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_vortex-sandbox.data.microsoft.com" dir=out action=block remoteip=64.4.54.32 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_pre.footprintpredict.com" dir=out action=block remoteip=204.79.197.200 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_i1.services.social.microsoft.com" dir=out action=block remoteip=104.82.22.249 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_ssw.live.com" dir=out action=block remoteip=207.46.101.29 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_statsfe1.ws.microsoft.com" dir=out action=block remoteip=134.170.115.60 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_msnbot-65-55-108-23.search.msn.com" dir=out action=block remoteip=65.55.108.23 enable=yes profile=any 1>> %logfile% 2>>&1
	netsh advfirewall firewall add rule name="telemetry_a23-218-212-69.deploy.static.akamaitechnologies.com" dir=out action=block remoteip=23.218.212.69 enable=yes profile=any 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[36m Установить файл Hosts от StevenBlack, блокирующий рекламу и телеметрию?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Установка файла Hosts от StevenBlack, блокирующий рекламу и телеметрию. Пожалуйста подождите...
	@echo Установка файла Hosts от StevenBlack, блокирующий рекламу и телеметрию. 1>> %logfile%
	set timerStart=!time!
	copy "%SystemRoot%\System32\drivers\etc\hosts" "%~dp0\..\..\Backup\hosts" 1>> %logfile% 2>>&1
	powershell "Invoke-WebRequest 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' -OutFile $Env:SystemRoot\System32\drivers\etc\hosts -wa SilentlyContinue" 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[36m Добавить черный список телеметрии в файл hosts и правила файервола?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Добавление черного списка телеметрии в файл hosts и правила файервола. Пожалуйста подождите...
	@echo Добавление черного списка телеметрии в файл hosts и правила файервола. 1>> %logfile%
	set timerStart=!time!
	powershell -ExecutionPolicy Bypass -file "%~dp0BlacklistTelemetry.ps1" -wa SilentlyContinue 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[36m Добавить AdGuard DoH провайдеры для фильтрации рекламы? DoH протокол обладает более высокой надёжностью по сравнению с DNSCrypt.%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Добавление AdGuard DoH провайдеров для фильтрации рекламы. Пожалуйста подождите...
	@echo Добавление AdGuard DoH провайдеров для фильтрации рекламы. DoH протокол обладает более высокой надёжностью по сравнению с DNSCrypt. 1>> %logfile%
	set timerStart=!time!
	netsh dns add encryption server=94.140.14.14 dohtemplate=https://dns.adguard.com/dns-query 1>> %logfile% 2>>&1
	netsh dns add encryption server=94.140.15.15 dohtemplate=https://dns.adguard.com/dns-query 1>> %logfile% 2>>&1
	netsh dns add encryption server=2a10:50c0::ad1:ff dohtemplate=https://dns.adguard.com/dns-query 1>> %logfile% 2>>&1
	netsh dns add encryption server=2a10:50c0::ad2:ff dohtemplate=https://dns.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=94.140.14.15 dohtemplate=https://dns-family.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=94.140.15.16 dohtemplate=https://dns-family.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=2a10:50c0::bad1:ff dohtemplate=https://dns-family.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=2a10:50c0::bad2:ff dohtemplate=https://dns-family.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=94.140.14.140 dohtemplate=https://dns-unfiltered.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=94.140.14.141 dohtemplate=https://dns-unfiltered.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=2a10:50c0::1:ff dohtemplate=https://dns-unfiltered.adguard.com/dns-query 1>> %logfile% 2>>&1
	::netsh dns add encryption server=2a10:50c0::2:ff dohtemplate=https://dns-unfiltered.adguard.com/dns-query 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Отключить формирование отзывов.%clr%[92m
@echo Отключить формирование отзывов. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_task "\Microsoft\Windows\Feedback\Siuf\DmClient"
call :disable_task "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запретить приложениям на других устройствах запускать приложения и отправлять сообщения на этом устройстве.%clr%[92m
@echo Запретить приложениям на других устройствах запускать приложения и отправлять сообщения на этом устройстве. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Не предлагать способ завершения настройки устройства.%clr%[92m
@echo Не предлагать способ завершения настройки устройства. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Не предлагать индивидуальный подход, основанный на настройках диагностических данных.%clr%[92m
@echo Не предлагать индивидуальный подход, основанный на настройках диагностических данных. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать значок «Этот компьютер» на рабочем столе.%clr%[92m
@echo Показать значок «Этот компьютер» на рабочем столе. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать расширения файлов.%clr%[92m
@echo Показать расширения файлов. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать конфликты слияния папок.%clr%[92m
@echo Показать конфликты слияния папок. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideMergeConflicts" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запретить смену регистра имен файлов в проводнике.%clr%[92m
@echo Запретить смену регистра имен файлов в проводнике. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontPrettyPath" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить «Библиотеки» из панели навигации проводника.%clr%[92m
@echo Удалить «Библиотеки» из панели навигации проводника. 1>> %logfile%
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" /v "System.IsPinnedToNameSpaceTree" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить восстановление открытых окон проводника при входе в систему.%clr%[92m
@echo Включить восстановление открытых окон проводника при входе в систему. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "PersistBrowsers" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть кнопку «Люди» на панели задач.%clr%[92m
@echo Скрыть кнопку «Люди» на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показывать секунды на часах панели задач.%clr%[92m
@echo Показывать секунды на часах панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отображать маленькие значки на панели задач.%clr%[92m
@echo Отображать маленькие значки на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Открывать проводник для «Этот компьютер».%clr%[92m
@echo Открывать проводник для «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запускать окна проводника как отдельные процессы.%clr%[92m
@echo Запускать окна проводника как отдельные процессы. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить предварительный просмотр рабочего стола на кнопке «Свернуть».%clr%[92m
@echo Включить предварительный просмотр рабочего стола на кнопке «Свернуть». 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть кнопку «Представление задач».%clr%[92m
@echo Скрыть кнопку «Представление задач». 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить прозрачность меню Пуск, панели задач.%clr%[92m
@echo Включить прозрачность меню Пуск, панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Увеличить прозрачность панели задач.%clr%[92m
@echo Увеличить прозрачность панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить прозрачность командной строки и Powershell.%clr%[92m
@echo Включить прозрачность командной строки и Powershell. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Console" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
reg add "HKCU\Console\%%%SystemRoot%%%_system32_cmd.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
reg add "HKCU\Console\%%%SystemRoot%%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
reg add "HKCU\Console\%%%SystemRoot%%%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать все папки на панели проводника.%clr%[92m
@echo Показать все папки на панели проводника. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NavPaneShowAllFolders" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Открывать последнее активное окно на панели задач.%clr%[92m
@echo Открывать последнее активное окно на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LastActiveClick" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть панель меню в проводнике.%clr%[92m
@echo Скрыть панель меню в проводнике. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AlwaysShowMenus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть последние открытые элементы в меню Пуск и панели задач.%clr%[92m
@echo Скрыть последние открытые элементы в меню Пуск и панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отображать маленькие иконки в меню Пуск.%clr%[92m
@echo Отображать маленькие иконки в меню Пуск. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_LargeMFUIcons" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Увеличить кэш памяти для вида папок.%clr%[92m
@echo Увеличить кэш памяти для вида папок. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell" /v "BagMRU Size" /t REG_DWORD /d "20000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «Видео» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Видео» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «Документы» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Документы» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «Загрузки» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Загрузки» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile
@echo %clr%[36m Скрыть папку «Изображения» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Изображения» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «Музыка» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Музыка» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «Рабочий стол» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «Рабочий стол» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть папку «3D-объекты» из «Этот компьютер».%clr%[92m
@echo Скрыть папку «3D-объекты» из «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить все папки из меню «Этот компьютер».%clr%[92m
@echo Удалить все папки из меню «Этот компьютер». 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Всегда отображать диалоговое окно передачи файлов в подробном режиме.%clr%[92m
@echo Всегда отображать диалоговое окно передачи файлов в подробном режиме. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" /v "EnthusiastMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть ленту в проводнике.%clr%[92m
@echo Скрыть ленту в проводнике. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" /v "MinimizedStateTabletModeOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть панель быстрого доступа в проводнике.%clr%[92m
@echo Скрыть панель быстрого доступа в проводнике. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть часто используемые папки и файлы в меню быстрого доступа.%clr%[92m
@echo Скрыть часто используемые папки и файлы в меню быстрого доступа. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить помощника по привязке на панели задач.%clr%[92m
@echo Отключить помощника по привязке на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SnapAssist" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть кнопку «Поиск» на панели задач.%clr%[92m
@echo Скрыть кнопку «Поиск» на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть кнопку «Windows Ink Workspace» на панели задач.%clr%[92m
@echo Скрыть кнопку «Windows Ink Workspace» на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceButtonDesiredVisibility" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть кнопку «Mail» на панели задач.%clr%[92m
@echo Скрыть кнопку «Mail» на панели задач. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins" /v "MailPin" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins" /v "MailPin" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть значок «MeetNow» в области уведомлений.%clr%[92m
@echo Скрыть значок «MeetNow» в области уведомлений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отображать значки Компьютер и Панель управления на рабочем столе для всех пользователей.%clr%[92m
@echo Отображать значки Компьютер и Панель управления на рабочем столе для всех пользователей. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выставить просмотр значков панели управления по категориям.%clr%[92m
@echo Выставить просмотр значков панели управления по категориям. 1>> %logfile%
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerStart=!time!
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть анимацию первого входа после обновления.%clr%[92m
@echo Скрыть анимацию первого входа после обновления. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableFirstLogonAnimation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "EnableFirstLogonAnimation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выставить максимальное качество обоев для рабочего стола в формате JPEG.%clr%[92m
@echo Выставить максимальное качество обоев для рабочего стола в формате JPEG. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "100" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Сделать рабочий стол отзывчивым.%clr%[92m
@echo Сделать рабочий стол отзывчивым. 1>> %logfile%
set timerStart=!time!
reg add "HKU\.DEFAULT\Control Panel\Accessibility\HighContrast" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\MouseKeys" /v "Flags" /t REG_SZ /d "186" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\MouseKeys" /v "MaximumSpeed" /t REG_SZ /d "40" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\MouseKeys" /v "TimeToMaximumSpeed" /t REG_SZ /d "3000" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\TimeOut" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Desktop" /v "ForegroundLockTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "100" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Desktop" /v "MouseWheelRouting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\Windows\DWM" /v "CompositionPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\HighContrast" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\MouseKeys" /v "Flags" /t REG_SZ /d "186" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\MouseKeys" /v "MaximumSpeed" /t REG_SZ /d "40" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\MouseKeys" /v "TimeToMaximumSpeed" /t REG_SZ /d "3000" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\TimeOut" /v "Flags" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Desktop" /v "ForegroundLockTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "100" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Desktop" /v "MouseWheelRouting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "CompositionPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Настроить запуск диспетчера задач в развернутом режиме.%clr%[92m
@echo Настроить запуск диспетчера задач в развернутом режиме. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" /v "Preferences" /t REG_BINARY /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить контроль за свободным пространством жестких дисков.%clr%[92m
@echo Отключить контроль за свободным пространством жестких дисков. 1>> %logfile%
set timerStart=!time!
call :disable_task "Microsoft\Windows\DiskFootprint\StorageSense"
powershell "Remove-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Recurse -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалять не используемые временные файлы. Будет применяться, если включен контроль за свободным пространством.%clr%[92m
@echo Удалять не используемые временные файлы. Будет применяться, если включен контроль за свободным пространством. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "04" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить пути NTFS длиной более 260 символов.%clr%[92m
@echo Включить пути NTFS длиной более 260 символов. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отображать информацию о Stop ошибках на BSOD.%clr%[92m
@echo Отображать информацию о Stop ошибках на BSOD. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить оптимизацию доставки.%clr%[92m
@echo Отключить оптимизацию доставки. 1>> %logfile%
set timerStart=!time!
reg add "HKU\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Заменить метод ввода по умолчанию на английский.%clr%[92m
@echo Заменить метод ввода по умолчанию на английский. 1>> %logfile%
set timerStart=!time!
powershell "Set-WinDefaultInputMethodOverride -InputTip '0409:00000409' -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Запрос подтверждения перед запуском средства устранения неполадок.%clr%[92m
@echo Запрос подтверждения перед запуском средства устранения неполадок. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsMitigation" /v "UserPreference" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить запуска экранного диктора и функции распознавания голоса.%clr%[92m
@echo Отключить запуска экранного диктора и функции распознавания голоса. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sapisvr.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SpeechUXWiz.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Скрыть инсайдерскую страницу.%clr%[92m
@echo Скрыть инсайдерскую страницу. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить и удалить зарезервированное хранилище (только для сборок 20H1 и выше).%clr%[92m
@echo Отключить и удалить зарезервированное хранилище (только для сборок 20H1 и выше). 1>> %logfile%
set timerStart=!time!
dism /online /Set-ReservedStorageState /State:Disabled 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить активацию устройств расширенного хранилища.%clr%[92m
@echo Отключить активацию устройств расширенного хранилища. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" /v "TCGSecurityActivationDisabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить клавишу справки F1 в проводнике и на рабочем столе.%clr%[92m
@echo Отключить клавишу справки F1 в проводнике и на рабочем столе. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" /v "(default)" /t REG_BINARY /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Показать полный путь к каталогу в строке заголовка проводника.%clr%[92m
@echo Показать полный путь к каталогу в строке заголовка проводника. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" /v "FullPath" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить Num Lock при запуске.%clr%[92m
@echo Включить Num Lock при запуске. 1>> %logfile%
set timerStart=!time!
reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить залипание клавиш после 5ти кратного нажатия клавиши Shift.%clr%[92m
@echo Отключить залипание клавиш после 5ти кратного нажатия клавиши Shift. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автозапуск для всех носителей и устройств.%clr%[92m
@echo Отключить автозапуск для всех носителей и устройств. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d "255" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить автозапуск не закрытых приложений после перезагрузки или обновления.%clr%[92m
@echo Включить автозапуск не закрытых приложений после перезагрузки или обновления. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "RestartApps" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
for /f "tokens=* skip=1" %%n in ('wmic useraccount where "name='%username%'" get SID ^| findstr "."') do (set SID=%%n)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\%SID%" /v "OptOut" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автонастройку часов активности в зависимости от ежедневного использования.%clr%[92m
@echo Отключить автонастройку часов активности в зависимости от ежедневного использования. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "SmartActiveHoursState" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить перезагрузку для установки обновления.%clr%[92m
@echo Отключить перезагрузку для установки обновления. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "IsExpedited" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Включить NET Framework 3.5 версии.%clr%[92m
@echo Включить NET Framework 3.5 версии. 1>> %logfile%
set timerStart=!time!
Dism /online /enable-feature /featurename:"NetFx3" /All /Source:"%~dp0microsoft-windows-netfx3.cab" /LimitAccess /norestart 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Windows-Identity-Foundation -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить компоненты прежних версии.%clr%[92m
@echo Включить компоненты прежних версии. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName LegacyComponents -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить подсистему Linux (WSL).%clr%[92m
@echo Включить подсистему Linux (WSL). 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить песочницу Windows.%clr%[92m
@echo Включить песочницу Windows. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить блокировку устройства.%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m работает только в редакциях Education и Enterprise.
@echo Включить блокировку устройства. Примечание: работает только в редакциях Education и Enterprise. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Client-EmbeddedExp-Package -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Client-DeviceLockdown -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Client-EmbeddedShellLauncher -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Client-EmbeddedBootExp -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Client-EmbeddedLogon -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить платформу виртуальной машины.%clr%[92m
@echo Включить платформу виртуальной машины. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить виртуальную платформу Hyper-V.%clr%[92m
@echo Включить виртуальную платформу Hyper-V. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить компоненты DirectPlay.%clr%[92m
@echo Включить компоненты DirectPlay. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить устаревший протокол SMB 1.0 и Samba сервер для поддержки старых ОС.%clr%[92m
@echo Включить устаревший протокол SMB 1.0 и Samba сервер для поддержки старых ОС. 1>> %logfile%
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -wa SilentlyContinue" 1>> %logfile% 2>>&1
sc config mrxsmb start= delayed-auto 1>> %logfile% 2>>&1
sc config Mrxsmb10 start= delayed-auto 1>> %logfile% 2>>&1
sc config Mrxsmb20 start= delayed-auto 1>> %logfile% 2>>&1
sc config srv2 start= delayed-auto 1>> %logfile% 2>>&1
powershell "Enable-NetAdapterBinding -Name * -ComponentID 'ms_server' -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить средство записи XPS документов и печать в PDF.%clr%[92m
@echo Отключить средство записи XPS документов и печать в PDF. 1>> %logfile%
set timerStart=!time!
powershell "Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features -NoRestart -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Установить кодек для воспроизведения видео в формате High Efficiency Video Coding (HEVC) или H.265 в любом видеоприложении.%clr%[92m
@echo Установить кодек для воспроизведения видео в формате High Efficiency Video Coding (HEVC) или H.265 в любом видеоприложении. 1>> %logfile%
set timerStart=!time!
powershell -ExecutionPolicy Unrestricted "Add-AppxPackage -Path '%~dp0Microsoft.HEVCVideoExtension_1.0.32762.0_x64__8wekyb3d8bbwe.Appx' -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить аудит событий, генерируемых при создании или запуска процесса.%clr%[92m
@echo Отключить аудит событий, генерируемых при создании или запуска процесса. 1>> %logfile%
set timerStart=!time!
auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Не включать командную строку в события создания процесса.%clr%[92m
@echo Не включать командную строку в события создания процесса. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_Enabled" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Удалить создание строки Создание процесса в планировщике событий.%clr%[92m
@echo Удалить создание строки Создание процесса в планировщике событий. 1>> %logfile%
set timerStart=!time!
powershell "Remove-Item -Path $env:ProgramData\'Microsoft\Event Viewer\Views\ProcessCreation.xml' -Force -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить ведение журнала для всех модулей Windows PowerShell.%clr%[92m
@echo Отключить ведение журнала для всех модулей Windows PowerShell. 1>> %logfile%
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v "EnableModuleLogging" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v "EnableScriptBlockLogging" /f 1>> %logfile% 2>>&1
powershell "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name * -Force -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить диспетчер вложений, помечающий файлы, загруженные из Интернета, как небезопасные.%clr%[92m
@echo Отключить диспетчер вложений, помечающий файлы, загруженные из Интернета, как небезопасные. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "HideZoneInfoOnProperties" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".zip;.rar;.nfo;.txt;.exe;.bat;.com;.cmd;.reg;.msi;.htm;.html;.gif;.bmp;.jpg;.avi;.mpg;.mpeg;.mov;.mp3;.m3u;.wav;" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить поддержку TLS 1.2 для старых версий .NET Framework (для 4.6 и более поздних версий по умолчанию включено).%clr%[92m
@echo Включить поддержку TLS 1.2 для старых версий .NET Framework (для 4.6 и более поздних версий по умолчанию включено). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить Магазин Windows. Необходим для поддержки некоторых игр и приложений.%clr%[92m
@echo Включить Магазин Windows. Необходим для поддержки некоторых игр и приложений. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StoreAppsOnTaskbar" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить оптимизацию доставки P2P Центра обновления Windows компьютерам в локальной сети.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m полное отключение приводит к ошибке при загрузке с магазина Windows.
@echo Отключить оптимизацию доставки P2P Центра обновления Windows компьютерам в локальной сети. Предупреждение: полное отключение приводит к ошибке при загрузке с магазина Windows). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить потребительский опыт от Microsoft.%clr%[92m
@echo Отключить потребительский опыт от Microsoft. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить автоматическое обновление драйверов (требуется для установки специфичных или устаревших драйверов для устройств).%clr%[92m
@echo Отключить автоматическое обновление драйверов (требуется для установки специфичных или устаревших драйверов для устройств). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v "DenyDeviceIDs" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v "DenyDeviceIDsRetroactive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выставить сервера pool.ntp.org для синхронизации времени.%clr%[92m
@echo Выставить сервера pool.ntp.org для синхронизации времени. 1>> %logfile%
set timerStart=!time!
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить инструмент отслеживания производительности.%clr%[92m
@echo Отключить инструмент отслеживания производительности. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Выполнить полное удаление OneDrive.%clr%[92m
@echo Выполнить полное удаление OneDrive. 1>> %logfile%
set timerStart=!time!
call :kill "OneDrive.exe"
set OneDr_x86=%SystemRoot%\System32\OneDriveSetup.exe
set OneDr_x64=%SystemRoot%\SysWOW64\OneDriveSetup.exe
if exist %OneDr_x64% (%OneDr_x64% /uninstall 1>> %logfile% 2>>&1) else (%OneDr_x86% /uninstall 1>> %logfile% 2>>&1)
if "%arch%"=="x86" (
call :acl_file "%OneDr_x86%"
del /f /q "%OneDr_x86%" 1>> %logfile% 2>>&1
)
if "%arch%"=="x64" (
call :acl_file "%OneDr_x64%"
del /f /q "%OneDr_x64%" 1>> %logfile% 2>>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\Onedrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\Onedrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\Onedrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
del /f /q "%LocalAppData%\Microsoft\OneDrive\OneDriveStandaloneUpdater.exe" 1>> %logfile% 2>>&1
rmdir /s /q "%UserProfile%\OneDrive" "%ProgramData%\Microsoft OneDrive" "%LocalAppData%\Microsoft\OneDrive" "%HomeDrive%\OneDriveTemp" 1>> %logfile% 2>>&1
del /f /q "%AppData%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" 1>> %logfile% 2>>&1
powershell "Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false" 1>> %logfile% 2>>&1
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 1>> %logfile% 2>>&1
call :acl_folders "%SystemRoot%\WinSxS\*onedrive*"
powershell "foreach ($item in (Get-ChildItem $Env:SystemRoot\WinSxS\*onedrive*)) {Remove-Item -Recurse -Force $item.FullName}" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SkyDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\OneDrive" /v "DisablePersonalSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Windows" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg delete "HKCU\Environment" /v "OneDrive" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 1>> %logfile% 2>>&1
reg delete "HKU\.DEFAULT\Environment" /v "OneDrive" /f 1>> %logfile% 2>>&1
reg delete "HKU\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f 1>> %logfile% 2>>&1
call :disable_svc CldFlt
call :disable_svc CDPUserSvc
call :disable_svc OneSyncSvc
call :disable_svc PimIndexMaintenanceSvc
call :disable_svc UnistoreSvc
call :disable_svc UserDataSvc
call :disable_svc MessagingService
::call :disable_svc WpnUserService
::call :disable_svc WpnService
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Удалить поиск Windows.%clr%[92m
@echo Удалить поиск Windows. 1>> %logfile%
set timerStart=!time!
Dism /online /Disable-Feature /FeatureName:"SearchEngine-Client-Package" /Remove /norestart 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Удалить UWP приложения.%clr%[92m
@echo Удалить UWP приложения. 1>> %logfile%
set timerStart=!time!
call :remove_uwp Microsoft.3dbuilder
call :remove_uwp Microsoft.Microsoft3DViewer
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.3ds\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.3mf\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.3mf\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.bmp\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.dae\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.dxf\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.fbx\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.gif\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.glb\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.jfif\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.jpe\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.jpeg\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.jpg\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.obj\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.obj\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.ply\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.ply\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.png\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.stl\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.stl\Shell\3D Print" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.tif\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.tiff\Shell\3D Edit" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\SystemFileAssociations\.wrl\Shell\3D Print" /f 1>> %logfile% 2>>&1
call :remove_uwp Microsoft.BingFinance
call :remove_uwp Microsoft.BingTranslator
call :remove_uwp Microsoft.BingFoodAndDrink
call :remove_uwp Microsoft.BingHealthAndFitness
call :remove_uwp Microsoft.BingTravel
call :remove_uwp feedback
call :remove_uwp Microsoft.MicrosoftPowerBIForWindows
call :remove_uwp Microsoft.Wallet
call :remove_uwp Microsoft.WindowsReadingList
call :remove_uwp Microsoft.WindowsAlarms
call :remove_uwp Microsoft.Asphalt8Airborne
call :remove_uwp Microsoft.WindowsCamera
call :remove_uwp Microsoft.DrawboardPDF
call :remove_uwp Microsoft.GetHelp
call :remove_uwp Microsoft.GetStarted
call :remove_uwp Microsoft.WindowsMaps
call :remove_uwp Microsoft.Messaging
call :remove_uwp Microsoft.Advertising.Xaml
call :remove_uwp Microsoft.BingNews
call :remove_uwp Microsoft.MicrosoftSolitaireCollection
call :remove_uwp Microsoft.People
call :remove_uwp Todos
call :remove_uwp Microsoft.Whiteboard
call :remove_uwp MinecraftUWP
call :remove_uwp Microsoft.MixedReality.Portal
call :remove_uwp Microsoft.OneConnect
call :remove_uwp Microsoft.NetworkSpeedTest
call :remove_uwp Microsoft.MicrosoftOfficeHub
call :remove_uwp Office.Lens
call :remove_uwp Office.OneNote
call :remove_uwp Office.Sway
call :remove_uwp Microsoft.Office.Todo.List
call :remove_uwp WindowsPhone
call :remove_uwp CommsPhone
call :remove_uwp Microsoft.Print3D
call :remove_uwp WindowsScan
call :remove_uwp Microsoft.SkypeApp
call :remove_uwp Microsoft.MicrosoftStickyNotes
call :remove_uwp Microsoft.Getstarted
::call :remove_uwp Microsoft.WindowsSoundRecorder
call :remove_uwp Microsoft.BingWeather
call :remove_uwp Microsoft.YourPhone
call :remove_uwp Microsoft.ZuneMusic
call :remove_uwp Microsoft.ZuneVideo
call :remove_uwp Microsoft.XboxApp
call :remove_uwp Microsoft.XboxGameOverlay
call :remove_uwp Microsoft.XboxGamingOverlay
call :remove_uwp Microsoft.XboxSpeechToTextOverlay
:: другие приложения
call :remove_uwp PicsArt-PhotoStudio
call :remove_uwp ActiproSoftwareLLC
call :remove_uwp AdobePhotoshopExpress
call :remove_uwp AutodeskSketchBook
call :remove_uwp bingsports
call :remove_uwp candycrush
call :remove_uwp DolbyAccess
call :remove_uwp empires
call :remove_uwp Facebook
call :remove_uwp FarmHeroesSaga
call :remove_uwp PandoraMediaInc
call :remove_uwp spotify
call :remove_uwp Shazam
call :remove_uwp Twitter
call :remove_uwp Yandex.Music
call :remove_uwp xing
call :remove_uwp EclipseManager
call :remove_uwp Netflix
call :remove_uwp PolarrPhotoEditorAcademicEdition
call :remove_uwp Wunderlist
call :remove_uwp LinkedInforWindows
call :remove_uwp DisneyMagicKingdoms
call :remove_uwp MarchofEmpires
call :remove_uwp Plex
call :remove_uwp iHeartRadio
call :remove_uwp FarmVille2CountryEscape
call :remove_uwp Duolingo-LearnLanguagesforFree
call :remove_uwp CyberLinkMediaSuiteEssentials
call :remove_uwp DrawboardPDF
call :remove_uwp FitbitCoach
call :remove_uwp Flipboard
call :remove_uwp Asphalt8Airborne
call :remove_uwp KeeperSecurityInc.Keeper
call :remove_uwp NORDCURRENT.COOKINGFEVER
call :remove_uwp CaesarsSlotsFreeCasino
call :remove_uwp SlingTV
call :remove_uwp SpotifyMusic
call :remove_uwp PhototasticCollage
call :remove_uwp WinZipUniversal
call :remove_uwp RoyalRevolt2
call :remove_uwp king.com
call :remove_uwp king.com.BubbleWitch3Saga
call :remove_uwp king.com.CandyCrushSaga
call :remove_uwp king.com.CandyCrushSodaSaga
:: принудительное удаление приложений
call :remove_uwp_hard InputApp
call :remove_uwp_hard People
call :remove_uwp_hard Microsoft.AAD.BrokerPlugin
call :remove_uwp_hard Microsoft.BioEnrollment
call :remove_uwp_hard Microsoft.CredDialogHost
call :remove_uwp_hard Microsoft.ECApp
call :remove_uwp_hard Microsoft.EdgeDevtoolsPlugin
call :remove_uwp_hard Microsoft.MicrosoftEdge
call :remove_uwp_hard Microsoft.MicrosoftEdgeDevToolsClient
call :remove_uwp_hard Microsoft.PPIProjection
::Microsoft.Windows.Apprep.ChxApp (Часть дефендера и Edge. Множество настроек в Параметрах и очень много в ГП.)
call :remove_uwp_hard Microsoft.Windows.AssignedAccessLockApp
call :remove_uwp_hard Microsoft.Windows.CallingShellApp
call :remove_uwp_hard Microsoft.Windows.CapturePicker
::call :remove_uwp_hard Microsoft.Windows.CloudExperienceHost (используется облачными приложениями)
call :remove_uwp_hard Microsoft-Windows-ContactSupport
call :remove_uwp_hard Microsoft.Windows.ContentDeliveryManager
call :remove_uwp_hard Microsoft.Windows.Cortana
call :remove_uwp_hard Microsoft.Windows.NarratorQuickStart
call :remove_uwp_hard Microsoft.Windows.OOBENetworkCaptivePortal
call :remove_uwp_hard Microsoft.Windows.OOBENetworkConnectionFlow
call :remove_uwp_hard Microsoft.Windows.ParentalControls
call :remove_uwp_hard Microsoft.Windows.PeopleExperienceHost
call :remove_uwp_hard Microsoft.Windows.PinningConfirmationDialog
call :remove_uwp_hard Microsoft.Windows.SecHealthUI
call :remove_uwp_hard Microsoft.Windows.SecureAssessmentBrowser
call :remove_uwp_hard Microsoft.Windows.XGpuEjectDialog
call :remove_uwp_hard Microsoft-Windows-Help
call :remove_uwp_hard Microsoft.WindowsFeedback
call :remove_uwp_hard Microsoft.WindowsFeedbackHub
call :remove_uwp_hard microsoft.windowscommunicationsapps
call :remove_uwp_hard Microsoft-Windows-Internet-Browser-Package
call :remove_uwp_hard Windows.CBSPreview
call :remove_uwp_hard Windows.ContactSupport
call :remove_uwp_hard Windows.Devices.PointOfService
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Использовать Windows Photo Viewer.%clr%[92m
@echo Использовать Windows Photo Viewer. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\.jpg" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.jpeg" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.gif" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.png" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.bmp" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.tiff" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.ico" /ve /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить мониторинг использования сетевых данных.%clr%[92m
@echo Отключить мониторинг использования сетевых данных. 1>> %logfile%
set timerStart=!time!
call :disable_svc Ndu
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить службу push-уведомлений по протоколу беспроводных приложений (WAP) для управления устройствами.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m эта служба необходима для взаимодействия с Microsoft Intune.%clr%[36m%clr%[92m
@echo Отключить службу push-уведомлений по протоколу беспроводных приложений (WAP) для управления устройствами. Предупреждение: эта служба необходима для взаимодействия с Microsoft Intune. 1>> %logfile%
set timerStart=!time!
call :disable_svc dmwappushservice
call :disable_svc dmwappushsvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить возможности подключенного пользователя и телеметрию (ранее называвшуюся службой отслеживания диагностики) и заблокировать соединение единой телеметрии через правила брандмауэра для исходящего трафика.%clr%[92m
@echo Отключить возможности подключенного пользователя и телеметрию (ранее называвшуюся службой отслеживания диагностики) и заблокировать соединение единой телеметрии через правила брандмауэра для исходящего трафика. 1>> %logfile%
set timerStart=!time!
call :disable_svc DiagTrack
call :disable_svc diagnosticshub.standardcollector.service
powershell "Get-NetFirewallRule -Group DiagTrack | Set-NetFirewallRule -Enabled False -Action Block -wa SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить совместимость оценщика.%clr%[92m
@echo Отключить совместимость оценщика. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить программу улучшения качества программного обеспечения.%clr%[92m
@echo Отключить программу улучшения качества программного обеспечения. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить сборщик дисковых данных.%clr%[92m
@echo Отключить сборщик дисковых данных. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
call :disable_task "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить обслуживание памяти во время простоя и при ошибках.%clr%[92m
@echo Отключить обслуживание памяти во время простоя и при ошибках. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents"
call :disable_task "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnostic"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить анализ энергопотребления системы.%clr%[92m
@echo Отключить анализ энергопотребления системы. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить запланированную дефгарментацию дисков.%clr%[92m
@echo Отключить запланированную дефгарментацию дисков. 1>> %logfile%
set timerStart=!time!
call :disable_task "\Microsoft\Windows\Defrag\ScheduledDefrag"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Полное отключение всех видов телеметрии.%clr%[92m
@echo Полное отключение всех видов телеметрии. 1>> %logfile%
set timerStart=!time!
if "%arch%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableConfigFlighting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableExperimentation" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CorporateSQMURL" /t REG_SZ /d "0.0.0.0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Assistance\Client\1.0\Settings" /v "ImplicitFeedback" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" /v "AllowLinguisticDataCollection" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\15.0\osm" /v "Enablelogging" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\15.0\osm" /v "EnableUpload" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "Enablelogging" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "EnableUpload" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\ClickToRun\OverRide" /v "DisableLogManagement" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v "TimerInterval" /t REG_SZ /d "900000" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::call :acl_file "%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl"
::del /f /q %ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Inventory" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Steps-Recorder" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\PerfTrack" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DisableAutomaticTelemetryKeywordReporting" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "TelemetryServiceDisabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks" /v "DisableAsimovUpLoad" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DeviceCensus.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v Debugger /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v "LastLoggedOnUserSID" 2^>nul') do (set UID=%%b)
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\%UID%" /v "FeatureStates" /t REG_SZ /d "828" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "AutoSuggest" /t REG_SZ /d "no" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" /v "NoUpdateCheck" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Geolocation" /v "PolicyDisableGeolocation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "no" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\Main" /v "FormSuggest Passwords" /t REG_SZ /d "no" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\SearchScopes" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredUI" /v "DisablePasswordReveal" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
call :disable_task "\Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask"
call :disable_task "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
call :disable_task "\Microsoft\Windows\Autochk\Proxy"
call :disable_task "\Microsoft\Windows\AppID\SmartScreenSpecific"
call :disable_task "\Microsoft\Windows\Application Experience\AitAgent"
call :disable_task "\Microsoft\Windows\Application Experience\StartupAppTask"
call :disable_task "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
call :disable_task "\Microsoft\Windows\DiskFootprint\Diagnostics"
call :disable_task "\Microsoft\Windows\Data Integrity Scan\Data Integrity Scan"
call :disable_task "\Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery"
call :disable_task "\Microsoft\Windows\FileHistory\File History (maintenance mode)"
call :disable_task "\Microsoft\Windows\Maintenance\WinSAT"
call :disable_task "\Microsoft\Windows\PI\Sqm-Tasks"
call :disable_task "\Microsoft\Windows\Shell\FamilySafetyMonitor"
call :disable_task "\Microsoft\Windows\Shell\FamilySafetyRefresh"
call :disable_task "\Microsoft\Windows\Shell\FamilySafetyUpload"
call :disable_task "\Microsoft\Windows\Shell\FamilySafetyMonitorToastTask"
call :disable_task "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
call :disable_task "\Microsoft\Windows\WindowsUpdate\Automatic App Update"
call :disable_task "\Microsoft\Windows\License Manager\TempSignedLicenseExchange"
call :disable_task "\Microsoft\Windows\Clip\License Validation"
call :disable_task "\Microsoft\Windows\ApplicationData\DsSvcCleanup"
call :disable_task "\Microsoft\Windows\PushToInstall\LoginCheck"
call :disable_task "\Microsoft\Windows\PushToInstall\Registration"
call :disable_task "\Microsoft\Windows\Subscription\EnableLicenseAcquisition"
call :disable_task "\Microsoft\Windows\Subscription\LicenseAcquisition"
call :disable_task "\Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner"
call :disable_task "\Microsoft\Windows\Diagnosis\Scheduled"
call :disable_task "\Microsoft\Windows\NetTrace\GatherNetworkInfo"
call :disable_task "\Microsoft\Windows\Maps\MapsUpdateTask"
call :disable_task "\Microsoft\Windows\Maps\MapsToastTask"
call :disable_task "\Microsoft\Windows\Chkdsk\ProactiveScan"
call :disable_task_sudo "\Microsoft\Windows\Chkdsk\SyspartRepair"
call :disable_task_sudo "\Microsoft\Windows\SettingSync\BackgroundUpLoadTask"
call :disable_task_sudo "\Microsoft\Windows\Device Setup\Metadata Refresh"
call :disable_task "\Microsoft\Windows\Flighting\OneSettings\RefreshCache"
call :disable_task "\Microsoft\Windows\SettingSync\NetworkStateChangeTask"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\HandleCommand"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange"
call :disable_task "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceConnectedToNetwork"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange"
call :disable_task "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic1"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24"
call :disable_task "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic6"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange"
call :disable_task "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceScreenOnOff"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged"
call :disable_task_sudo "\Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice"
call :disable_task "\Microsoft\Windows\HelloFace\FODCleanupTask"
call :disable_task "\Microsoft\Windows\Location\Notifications"
call :disable_task "\Microsoft\Windows\Location\WindowsActionDialog"
call :disable_task "\Microsoft\Windows\Management\Provisioning\Cellular"
call :disable_task "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"
call :disable_task "\Microsoft\Windows\RetailDemo\CleanupOfflineContent"
call :disable_task_sudo "\Microsoft\Windows\WaaSMedic\PerformRemediation"
call :disable_task "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"
call :disable_task "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization"
call :disable_task "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work"
call :disable_task "\Microsoft\Windows\WDI\ResolutionHost"
call :disable_task "\Microsoft\Windows\ApplicationData\appuriverifierinstall"
call :disable_task "\Microsoft\Windows\ApplicationData\appuriverifierdaily"
call :disable_task "\Microsoft\Windows\Device Information\Device"
call :disable_task "\Microsoft\Windows\DUSM\dusmtask"
call :disable_task "\Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate"
call :disable_task "\Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate"
call :disable_task "\Microsoft\Windows\SpacePort\SpaceAgentTask"
call :disable_task "\Microsoft\Windows\SpacePort\SpaceManagerTask"
call :disable_task "\Microsoft\Windows\Speech\SpeechModelDownloadTask"
call :disable_task "\Microsoft\Windows\media center\activateWindowssearch"
call :disable_task "\Microsoft\Windows\media center\configureinternettimeservice"
call :disable_task "\Microsoft\Windows\media center\dispatchrecoverytasks"
call :disable_task "\Microsoft\Windows\media center\ehdrminit"
call :disable_task "\Microsoft\Windows\media center\installplayready"
call :disable_task "\Microsoft\Windows\media center\mcupdate"
call :disable_task "\Microsoft\Windows\media center\mediacenterrecoverytask"
call :disable_task "\Microsoft\Windows\media center\objectstorerecoverytask"
call :disable_task "\Microsoft\Windows\media center\ocuractivate"
call :disable_task "\Microsoft\Windows\media center\ocurdiscovery"
call :disable_task "\Microsoft\Windows\media center\pbdadiscovery"
call :disable_task "\Microsoft\Windows\media center\pbdadiscoveryw1"
call :disable_task "\Microsoft\Windows\media center\pbdadiscoveryw2"
call :disable_task "\Microsoft\Windows\media center\pvrrecoverytask"
call :disable_task "\Microsoft\Windows\media center\pvrscheduletask"
call :disable_task "\Microsoft\Windows\media center\registersearch"
call :disable_task "\Microsoft\Windows\media center\reindexsearchroot"
call :disable_task "\Microsoft\Windows\media center\sqlliterecoverytask"
call :disable_task "\Microsoft\Windows\media center\updaterecordpath"
call :disable_task "\Microsoft\Office\Office ClickToRun Service Monitor"
call :disable_task "\Microsoft\Office\OfficeTelemetryAgentFallBack2016"
call :disable_task "\Microsoft\Office\OfficeTelemetryAgentLogOn2016"
call :disable_task "\Microsoft\Office\OfficeTelemetry\AgentFallBack2016"
call :disable_task "\Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016"
call :disable_task "\Microsoft\Office\Office 15 Subscription Heartbeat"
call :disable_task "\Microsoft\Office\OfficeTelemetryAgentFallBack"
call :disable_task "\Microsoft\Office\OfficeTelemetryAgentLogOn"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\System32\Winevt\Logs\AirSpaceChannel.etl" 1>> %logfile% 2>>&1
del /f /q /s "%SystemRoot%\SysNative\Tasks\Microsoft\Windows\SettingSync\*" 1>> %logfile% 2>>&1
del /f /q /s "%SystemRoot%\System32\Tasks\Microsoft\Windows\SettingSync\*" 1>> %logfile% 2>>&1
auditpol /set /subcategory:"{0CCE9226-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable 1>> %logfile% 2>>&1
call :disable_svc DcpSvc
call :disable_svc WalletService
call :disable_svc wercplsupport
call :disable_svc PcaSvc
call :disable_svc wisvc
call :disable_svc RetailDemo
call :disable_svc diagsvc
call :disable_svc shpamsvc
call :disable_svc TermService
call :disable_svc UmRdpService
call :disable_svc SessionEnv
call :disable_svc TroubleshootingSvc
call :disable_svc OneSyncSvc
call :disable_svc MessagingService
call :disable_svc PimIndexMaintenanceSvc
call :disable_svc UserDataSvc
call :disable_svc UnistoreSvc
call :disable_svc BcastDVRUserService
call :disable_svc_sudo Sgrmbroker
call :disable_svc cbdhsvc
call :disable_svc SCardSvr
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить задачи телеметрии NVIDIA.%clr%[92m
@echo Отключить задачи телеметрии NVIDIA. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\Startup\SendTelemetryData" /v "@" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
call :disable_svc NvTelemetryContainer
call :disable_task "\NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
call :disable_task "\NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
call :disable_task "\NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
call :disable_task "\NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить задачи телеметрии Intel.%clr%[92m
@echo Отключить задачи телеметрии Intel. 1>> %logfile%
set timerStart=!time!
call :disable_task "\IntelSURQC-Upgrade-86621605-2a0b-4128-8ffc-15514c247132"
call :disable_task "\IntelSURQC-Upgrade-86621605-2a0b-4128-8ffc-15514c247132-Logon"
call :disable_task "\Intel PTT EK Recertification"
call :disable_task "\USER_ESRV_SVC_QUEENCREEK"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить телеметрию Mozilla Firefox.%clr%[92m
@echo Отключить телеметрию Mozilla Firefox. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableTelemetry" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableDefaultBrowserAgent" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить Software Reporter Tool и сервис обновления Google Chrome.%clr%[92m
@echo Отключить Software Reporter Tool и сервис обновления Google Chrome. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupReportingEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe" /v "Debugger" /t REG_SZ /d "%SystemRoot%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
call :disable_task "\GoogleUpdateTaskMachineCore"
call :disable_task "\GoogleUpdateTaskMachineUA"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выставить запуск по требованию для помощника по входу в учетную запись Майкрософт.%clr%[92m
@echo Выставить запуск по требованию для помощника по входу в учетную запись Майкрософт. 1>> %logfile%
set timerStart=!time!
call :demand_svc_sudo wlidsvc
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Включить перечислитель виртуальных дисков.%clr%[92m
@echo Включить перечислитель виртуальных дисков. 1>> %logfile%
set timerStart=!time!
sc config vdrvroot start=auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить инфраструктуру виртуализации Hyper-V.%clr%[92m
@echo Включить инфраструктуру виртуализации Hyper-V. 1>> %logfile%
set timerStart=!time!
sc config Vid start= auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить перечислитель виртуальных сетевых карт.%clr%[92m
@echo Включить перечислитель виртуальных сетевых карт. 1>> %logfile%
set timerStart=!time!
sc config NdisVirtualBus start= delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить составную шину.%clr%[92m
@echo Включить составную шину. 1>> %logfile%
set timerStart=!time!
sc config CompositeBus start= auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить UMBus.%clr%[92m
@echo Включить UMBus. 1>> %logfile%
set timerStart=!time!
sc config umbus start= auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить шину RDP.%clr%[92m
@echo Включить шину RDP. 1>> %logfile%
set timerStart=!time!
sc config rdpbus start= delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить протокол Link-Local Multicast Name Resolution (LLMNR).%clr%[92m
@echo Отключить протокол Link-Local Multicast Name Resolution (LLMNR). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SOFTWARE\policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Включить восстановление системы и сброс до заводских настроек (Windows RE).%clr%[92m
@echo Включить восстановление системы и сброс до заводских настроек (Windows RE). 1>> %logfile%
set timerStart=!time!
reagentc /enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить повышенную точность указателя.%clr%[92m
@echo Отключить повышенную точность указателя. 1>> %logfile%
set timerStart=!time!
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000c0cc0c0000000000809919000000000040662600000000000033330000000000" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000a800000000000000e00000000000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Установить новые возможности от Windows 10X (только для сборок 20H1 и выше).%clr%[92m
@echo Установить новые возможности от Windows 10X (только для сборок 20H1 и выше). 1>> %logfile%
set timerStart=!time!
:: Disk Management in Settings
"%~dp0ViVeTool.exe" addconfig 23257398 2 1>> %logfile% 2>>&1
:: Windows 10X Touch Keyboard
"%~dp0ViVeTool.exe" addconfig 20438551 2 1>> %logfile% 2>>&1
:: Theme-aware Live Tiles
"%~dp0ViVeTool.exe" addconfig 23615618 2 1>> %logfile% 2>>&1
:: Media Controls in Volume Flyout
"%~dp0ViVeTool.exe" addconfig 23403403 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 23674478 2 1>> %logfile% 2>>&1
:: About Page in Settings
"%~dp0ViVeTool.exe" addconfig 25175482 2 1>> %logfile% 2>>&1
:: Theme-aware Splashscreens
"%~dp0ViVeTool.exe" addconfig 25936164 2 1>> %logfile% 2>>&1
:: Meet Now Integration
"%~dp0ViVeTool.exe" addconfig 28170999 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28582629 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28758888 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28622680 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28622690 0 1>> %logfile% 2>>&1
:: GPU Information in Settings About Page
"%~dp0ViVeTool.exe" addconfig 27974039 2 1>> %logfile% 2>>&1
:: Split Layout for Windows 10X
"%~dp0ViVeTool.exe" addconfig 23881110 2 1>> %logfile% 2>>&1
:: Profile Header in Settings
"%~dp0ViVeTool.exe" addconfig 18299130 0 1>> %logfile% 2>>&1
:: Windows 10X OOBE
"%~dp0ViVeTool.exe" addconfig 26336822 2 1>> %logfile% 2>>&1
:: App Archival
"%~dp0ViVeTool.exe" addconfig 21206371 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28384772 2 1>> %logfile% 2>>&1
:: Advanced Settings for Colour
"%~dp0ViVeTool.exe" addconfig 10834416 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 12259052 2 1>> %logfile% 2>>&1
:: New UI for the Battery Settings Page
"%~dp0ViVeTool.exe" addconfig 27296756 2 1>> %logfile% 2>>&1
:: New UI for the Touch Keyboard
"%~dp0ViVeTool.exe" addconfig 23324166 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30024318 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 27154708 2 1>> %logfile% 2>>&1
:: Acrylic Blur on the Input Switcher
"%~dp0ViVeTool.exe" addconfig 13140185 2 1>> %logfile% 2>>&1
:: Settings Enhancements and Rejuvenation
"%~dp0ViVeTool.exe" addconfig 30206630 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31010280 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30204574 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29449858 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30204206 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31197890 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29643556 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30381770 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29734477 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30580687 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30380766 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30030725 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29896902 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31291312 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29739067 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29029980 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30331247 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30832672 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 25977668 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31198568 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31199967 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31401318 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31065128 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30095024 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29241208 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29241309 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 25810627 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 29673992 2 1>> %logfile% 2>>&1
:: Acrylic Task View in Timeline
"%~dp0ViVeTool.exe" addconfig 12520383 2 1>> %logfile% 2>>&1
:: Device Health Improvements
"%~dp0ViVeTool.exe" addconfig 30091733 2 1>> %logfile% 2>>&1
:: Modern Animations for Input View
"%~dp0ViVeTool.exe" addconfig 29650567 2 1>> %logfile% 2>>&1
:: TLS 1.3 for EAP
"%~dp0ViVeTool.exe" addconfig 31308504 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31308502 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 31308506 2 1>> %logfile% 2>>&1
:: New Bluetooh Inbound Pairing UI
"%~dp0ViVeTool.exe" addconfig 23402385 2 1>> %logfile% 2>>&1
:: Bluetooth Flyout
"%~dp0ViVeTool.exe" addconfig 23673487 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 19919111 2 1>> %logfile% 2>>&1
:: Display Sleep Power Settings
"%~dp0ViVeTool.exe" addconfig 31026792 2 1>> %logfile% 2>>&1
:: FIDO 2.1
"%~dp0ViVeTool.exe" addconfig 27870272 2 1>> %logfile% 2>>&1
:: Modern Search
"%~dp0ViVeTool.exe" addconfig 20383964 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 21206249 2 1>> %logfile% 2>>&1
:: New Devices Flow Connect UI
"%~dp0ViVeTool.exe" addconfig 23673473 2 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 20447509 2 1>> %logfile% 2>>&1
:: Optimised Window Position and Size Updates
"%~dp0ViVeTool.exe" addconfig 30134375 2 1>> %logfile% 2>>&1
:: Redirect Programs and Features to UWP Settings
"%~dp0ViVeTool.exe" addconfig 26003950 2 1>> %logfile% 2>>&1
:: Thumbnail Cache Updates
"%~dp0ViVeTool.exe" addconfig 19173096 2 1>> %logfile% 2>>&1
:: New Search and Cortana
"%~dp0ViVeTool.exe" addconfig 19263623 0 1>> %logfile% 2>>&1
:: Modern UX for Voice Typing
"%~dp0ViVeTool.exe" addconfig 24781215 2 1>> %logfile% 2>>&1
:: Expand Voice Typing Supported Language
"%~dp0ViVeTool.exe" addconfig 29609459 2 1>> %logfile% 2>>&1
:: Windows Spotlight v3
"%~dp0ViVeTool.exe" addconfig 11024039 2 1>> %logfile% 2>>&1
:: Device Usage Settings Page
"%~dp0ViVeTool.exe" addconfig 25810627 2 1>> %logfile% 2>>&1
:: Deferred Contexts for D3D11on12
"%~dp0ViVeTool.exe" 13815251 2 1>> %logfile% 2>>&1
:: DirectX Core System File Mappings
"%~dp0ViVeTool.exe" 22765950 2 1>> %logfile% 2>>&1
:: DXGI Buffer Upgrades
"%~dp0ViVeTool.exe" 25957903 2 1>> %logfile% 2>>&1
:: DXGI Windowed Swap Effect Upgrades
"%~dp0ViVeTool.exe" 23990563 2 1>> %logfile% 2>>&1
:: News and Interests
"%~dp0ViVeTool.exe" addconfig 29947361 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 27833282 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 27368843 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 28247353 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 27371092 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 27371152 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30803283 0 1>> %logfile% 2>>&1
"%~dp0ViVeTool.exe" addconfig 30213886 0 1>> %logfile% 2>>&1
:: Windows 10X Boot Animation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BootControl" /v "BootProgressAnimation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
:: Windows Rounded UI
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting" /v "ImmersiveSearch" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override" /v "ImmersiveSearchFull" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override" /v "CenterScreenRoundedCornerRadius" /t REG_DWORD /d "9" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Установить расширенное контекстное меню?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	echo Установка расширенного контекстного меню. Пожалуйста подождите...
	@echo Установка расширенного контекстного меню. Пожалуйста подождите... 1>> %logfile%
	set timerStart=!time!
	md "%SystemRoot%\Tools" 1>> %logfile% 2>>&1
	xcopy "%~dp0\..\Tools\*.*" "%SystemRoot%\Tools\*.*" /e /c /i /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0devxexec.exe" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0devxexec.exe" "%SystemRoot%\SysWOW64" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0hidcon.exe" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0nircmdc.exe" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0subinacl.exe" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	if "%arch%"=="x64" (
	xcopy "%~dp0comctl32.ocx" "%SystemRoot%\SysWOW64" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0mscomctl.ocx" "%SystemRoot%\SysWOW64" /c /q /h /r /y 1>> %logfile% 2>>&1
	regsvr32 /s %SystemRoot%\SysWOW64\comctl32.ocx 1>> %logfile% 2>>&1
	regsvr32 /s %SystemRoot%\SysWOW64\mscomctl.ocx 1>> %logfile% 2>>&1
	)
	if "%arch%"=="x86" (
	xcopy "%~dp0comctl32.ocx" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	xcopy "%~dp0mscomctl.ocx" "%SystemRoot%\System32" /c /q /h /r /y 1>> %logfile% 2>>&1
	regsvr32 /s %SystemRoot%\System32\comctl32.ocx 1>> %logfile% 2>>&1
	regsvr32 /s %SystemRoot%\System32\mscomctl.ocx 1>> %logfile% 2>>&1
	)
	start "" /wait %~dp0\..\Installers\ComIntRep.exe
	start "" /wait %~dp0\..\Installers\DriveCleanup.exe
	start "" /wait %~dp0\..\Installers\DriveTidy.exe
	start "" /wait %~dp0\..\Installers\EasyServicesOptimizer.exe
	start "" /wait %~dp0\..\Installers\EjectFlash.exe
	start "" /wait %~dp0\..\Installers\Everything.exe
	start "" /wait %~dp0\..\Installers\FixWin.exe
	start "" /wait %~dp0\..\Installers\GoPing.exe
	start "" /wait %~dp0\..\Installers\herdProtect.exe
	start "" /wait %~dp0\..\Installers\KeyFreeze.exe
	start "" /wait %~dp0\..\Installers\NTFS_Stream_Explorer.exe
	start "" /wait %~dp0\..\Installers\ReduceMemory.exe
	start "" /wait %~dp0\..\Installers\RegistryFirstAid.exe
	start "" /wait %~dp0\..\Installers\ReIcon.exe
	start "" /wait %~dp0\..\Installers\RunBlock.exe
	start "" /wait %~dp0\..\Installers\Scanner.exe
	start "" /wait %~dp0\..\Installers\TopMost.exe
	start "" /wait %~dp0\..\Installers\UpdateTime.exe
	start "" /wait %~dp0\..\Installers\WebCam.exe
	REM ; Выставить группировку по типу файловой системы в Мой Компьютер
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\2\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" /v "Sort" /t REG_BINARY /d "0000000000000000000000000000000001000000354B179BFF40D211A27E00C04FC308710400000001000000" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\2\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" /v "GroupView" /t REG_DWORD /d "4294967295" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\2\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" /v "GroupByKey:FMTID" /t REG_SZ /d "{9B174B35-40FF-11D2-A27E-00C04FC30871}" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\2\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" /v "GroupByKey:PID" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppLaunch" /v "Microsoft.Windows.Explorer" /t REG_DWORD /d "90" /f 1>> %logfile% 2>>&1
	REM ; Стать владельцем по правой кнопке мыши
	reg add "HKCR\*\shell\TakeOwn" /v "MUIVerb" /t REG_SZ /d "Смена владельца" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\TakeOwn" /v "SubCommands" /t REG_SZ /d "file_takeown_trust;file_takeown_sys;file_takeown_adm" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\TakeOwn" /v "Icon" /t REG_SZ /d "imageres.dll,117" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\TakeOwn" /v "NoWorkingDirectory" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\TakeOwn" /v "Position" /t REG_SZ /d "middle" /f 1>> %logfile% 2>>&1
	REM ; Добавление меню для папок
	reg add "HKCR\Directory\shell\TakeOwn" /v "MUIVerb" /t REG_SZ /d "Смена владельца" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\TakeOwn" /v "SubCommands" /t REG_SZ /d "folder_takeown_trust;folder_takeown_sys;folder_takeown_adm" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\TakeOwn" /v "Icon" /t REG_SZ /d "imageres.dll,117" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\TakeOwn" /v "NoWorkingDirectory" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\TakeOwn" /v "Position" /t REG_SZ /d "middle" /f 1>> %logfile% 2>>&1
	REM ; Добавление меню для дисков
	reg add "HKCR\Drive\shell\TakeOwn" /v "MUIVerb" /t REG_SZ /d "Смена владельца" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\TakeOwn" /v "SubCommands" /t REG_SZ /d "folder_takeown_trust;folder_takeown_sys;folder_takeown_adm" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\TakeOwn" /v "Icon" /t REG_SZ /d "imageres.dll,117" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\TakeOwn" /v "NoWorkingDirectory" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\TakeOwn" /v "Position" /t REG_SZ /d "middle" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца TrustedInstaller для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_trust" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_trust" /ve /t REG_SZ /d "Назначить владельцем TrustedInstaller" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца TrustedInstaller для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_trust\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_trust\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца Система для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_sys" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_sys" /ve /t REG_SZ /d "Назначить владельцем Система" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца Система для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_sys\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-18" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_sys\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-18" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца Администраторы для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_adm" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_adm" /ve /t REG_SZ /d "Назначить владельцем Администраторы" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца Администраторы для файлов
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_adm\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-32-544" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\file_takeown_adm\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-32-544" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца TrustedInstaller для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_trust" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_trust" /ve /t REG_SZ /d "Назначить владельцем TrustedInstaller" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца TrustedInstaller для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_trust\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_trust\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца Система для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_sys" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_sys" /ve /t REG_SZ /d "Назначить владельцем Система" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца Система для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_sys\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-18 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-18" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_sys\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-18 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-18" /f 1>> %logfile% 2>>&1
	REM ; Название пункта меню установки владельца Администраторы для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_adm" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_adm" /ve /t REG_SZ /d "Назначить владельцем Администраторы" /f 1>> %logfile% 2>>&1
	REM ; Команда установки владельца Администраторы для файлов, дисков и папок
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_adm\command" /ve /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-32-544 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-32-544" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folder_takeown_adm\command" /v "IsolatedCommand" /t REG_SZ /d "nircmdc elevate cmd.exe /c subinacl /subdirectories \"%%1\" /setowner=S-1-5-32-544 & subinacl /subdirectories \"%%1\*.*\" /setowner=S-1-5-32-544" /f 1>> %logfile% 2>>&1
	REM ; Программы и компоненты в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{D20EA4E1-3957-11d2-A40B-0C5020524153}" /f 1>> %logfile% 2>>&1
	REM ; Сетевые подключения в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{7b81be6a-ce2b-4676-a29e-eb907a5126c5}" /f 1>> %logfile% 2>>&1
	REM ; Корзина в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{7007ACC7-3202-11D1-AAD2-00805FC1270E}" /f 1>> %logfile% 2>>&1
	REM ; Сеть в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{645FF040-5081-101B-9F08-00AA002F954E}" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{00000000-0000-0000-0000-123456725801}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}" /ve /t REG_SZ /d "Сеть рабочей группы" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}" /v "Infotip" /t REG_SZ /d "Доступ к компьютерам и устройствам в сети рабочей группы" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}\DefaultIcon" /ve /t REG_SZ /d "shell32.dll,17" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}\InProcServer32" /ve /t REG_SZ /d "shell32.dll" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725801}\Shell\Open\Command" /ve /t REG_SZ /d "\"explorer.exe\" shell:::{208D2C60-3AEA-1069-A2D7-08002B30309D}" /f 1>> %logfile% 2>>&1
	REM ; Все задачи в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{00000000-0000-0000-0000-123456725802}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}" /ve /t REG_SZ /d "Полный список настраиваемых параметров" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}" /v "Infotip" /t REG_SZ /d "Доступ ко всем параметрам системы в одной директорий" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}\DefaultIcon" /ve /t REG_SZ /d "shell32.dll,21" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}\InProcServer32" /ve /t REG_SZ /d "shell32.dll" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456725802}\Shell\Open\Command" /ve /t REG_SZ /d "\"explorer.exe\" shell:::{ED7BA470-8E54-465E-825C-99712043E01C}" /f 1>> %logfile% 2>>&1
	REM ; Таблица символов в папке Компьютер
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{00000000-0000-0000-0000-123456756840}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456756840}" /ve /t REG_SZ /d "Таблица символов" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456756840}" /v "InfoTip" /t REG_SZ /d "Таблица символов используется для добавления в текст дополнительных символов." /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456756840}" /v "System.ControlPanel.Category" /t REG_SZ /d "9" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456756840}\DefaultIcon" /ve /t REG_SZ /d "charmap.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{00000000-0000-0000-0000-123456756840}\Shell\Open\command" /ve /t REG_SZ /d "charmap.exe" /f 1>> %logfile% 2>>&1
	REM ; Создание пункта "Регистрация" в меню DLL или OCX-файлов
	reg add "HKCR\dllfile\Shell\DLLReg" /v "Icon" /t REG_SZ /d "shell32.dll,-153" /f 1>> %logfile% 2>>&1
	reg add "HKCR\dllfile\Shell\DLLReg" /ve /t REG_SZ /d "Зарегистрировать DLL файл в системе" /f 1>> %logfile% 2>>&1
	reg add "HKCR\dllfile\Shell\DLLReg\command" /ve /t REG_SZ /d "devxexec.exe /user:System \"regsvr32.exe \"%%1\"\"" /f 1>> %logfile% 2>>&1
	reg add "HKCR\dllfile\Shell\CancelReg" /v "Icon" /t REG_SZ /d "shell32.dll,-153" /f 1>> %logfile% 2>>&1
	reg add "HKCR\dllfile\Shell\CancelReg" /ve /t REG_SZ /d "Отменить регистрацию DLL" /f 1>> %logfile% 2>>&1
	reg add "HKCR\dllfile\Shell\CancelReg\command" /ve /t REG_SZ /d "devxexec.exe /user:System \"regsvr32.exe /u \"%%1\"\"" /f 1>> %logfile% 2>>&1
	reg add "HKCR\ocxfile\Shell\OCXReg" /v "Icon" /t REG_SZ /d "shell32.dll,-153" /f 1>> %logfile% 2>>&1
	reg add "HKCR\ocxfile\Shell\OCXReg" /ve /t REG_SZ /d "Зарегистрировать OCX файл в системе" /f 1>> %logfile% 2>>&1
	reg add "HKCR\ocxfile\Shell\OCXReg\command" /ve /t REG_SZ /d "devxexec.exe /user:System \"regsvr32.exe \"%%1\"\"" /f 1>> %logfile% 2>>&1
	REM ; Добавление пунктов "Запуск от имени администратора" и "Извлечь файлы из пакета" в контекстное меню MSI файлов
	reg add "HKCR\Msi.Package\Shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Msi.Package\shell\runas\Command" /ve /t REG_EXPAND_SZ /d "\"%SystemRoot%\System32\msiexec.exe\" /i \"%%1\" %%*" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Msi.Package\shell\ExtractAll" /ve /t REG_SZ /d "Извлечь файлы из пакета" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Msi.Package\shell\ExtractAll" /v "icon" /t REG_SZ /d "msiexec.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Classes\Msi.Package\shell\ExtractAll\command" /ve /t REG_SZ /d "msiexec.exe /a \"%%1\" /qb TARGETDIR=\"%%1 Contents\"" /f 1>> %logfile% 2>>&1
	REM ; Удаления пункта Сменить пароль из диалогового окна Безопасность Windows
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableChangePassword" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
	REM ; Добавление в Панель управления оснастки "Учетная запись опытного пользователя" (netplwiz), для расширенного управления учетными записями.
	reg add "HKCR\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /ve /t REG_SZ /d "Учетная запись опытного пользователя" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /v "InfoTip" /t REG_SZ /d "Расширенные настройки параметров учетных записей." /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /v "System.ControlPanel.Category" /t REG_SZ /d "9" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}\DefaultIcon" /ve /t REG_SZ /d "netplwiz.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\CLSID\{98641F47-8C25-4936-BEE4-C2CE1298969D}\Shell\Open\command" /ve /t REG_SZ /d "Control Userpasswords2" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{98641F47-8C25-4936-BEE4-C2CE1298969D}" /ve /t REG_SZ /d "Расширенные настройки параметров учетных записей" /f 1>> %logfile% 2>>&1
	REM ; Добавление классического всплывающего меню Программы (Programs) в меню Пуск вместо меню Избранное (Favorites).
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Favorites" /t REG_SZ /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs" /f 1>> %logfile% 2>>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Favorites" /t REG_EXPAND_SZ /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs" /f 1>> %logfile% 2>>&1
	REM ; Удаление пункта "Исправление неполадок совместимости" из контекстного меню ярлыков и исполняемых файлов.
	reg add "HKCR\batfile\ShellEx\ContextMenuHandlers\Compatibility" /ve /t REG_SZ /d "-{1d27f844-3a1f-4410-85ac-14651078412d}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\lnkfile\shellex\ContextMenuHandlers\Compatibility" /ve /t REG_SZ /d "-{1d27f844-3a1f-4410-85ac-14651078412d}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\exefile\shellex\ContextMenuHandlers\Compatibility" /ve /t REG_SZ /d "-{1d27f844-3a1f-4410-85ac-14651078412d}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\cmdfile\ShellEx\ContextMenuHandlers\Compatibility" /ve /t REG_SZ /d "-{1d27f844-3a1f-4410-85ac-14651078412d}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Msi.Package\shellex\ContextMenuHandlers\Compatibility" /ve /t REG_SZ /d "-{1d27f844-3a1f-4410-85ac-14651078412d}" /f 1>> %logfile% 2>>&1
	REM ; Добавление команды "Копировать как путь" в контекстном меню Проводника.
	reg add "HKCR\AllFilesystemObjects\shell\CopyAsPathMenu" /ve /t REG_SZ /d "Копировать как путь" /f 1>> %logfile% 2>>&1
	reg add "HKCR\AllFilesystemObjects\shell\CopyAsPathMenu" /v "Icon" /t REG_SZ /d "shell32.dll,-242" /f 1>> %logfile% 2>>&1
	reg add "HKCR\AllFilesystemObjects\shell\CopyAsPathMenu\command" /ve /t REG_SZ /d "cmd /c <nul (set/p var=%%1)|clip" /f 1>> %logfile% 2>>&1
	REM ; Создание пункта "Очистить содержимое папки"
	reg add "HKCR\Directory\shell\DeleteFolderContent" /v "MUIVerb" /t REG_SZ /d "Очистить содержимое папки" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\DeleteFolderContent" /v "Icon" /t REG_SZ /d "shell32.dll,-254" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\DeleteFolderContent\command" /ve /t REG_SZ /d "nircmdc elevate cmd /c cd /d \"%%1\" & del /s /f /q . & rmdir /s /q ." /f 1>> %logfile% 2>>&1
	REM ; Открывать все файлы блокнотом
	reg add "HKCR\*\shell\OpenWNotepad" /ve /t REG_SZ /d "Открыть в Блокноте" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\OpenWNotepad" /v "Icon" /t REG_SZ /d "shell32.dll,-152" /f 1>> %logfile% 2>>&1
	reg add "HKCR\*\shell\OpenWNotepad\command" /ve /t REG_SZ /d "notepad.exe \"%%1\"" /f 1>> %logfile% 2>>&1
	REM ; Запуск .exe файлов с пониженными правами
	reg add "HKCR\exefile\shell\RunAsInvoker" /v "Icon" /t REG_SZ /d "imageres.dll,1" /f 1>> %logfile% 2>>&1
	reg add "HKCR\exefile\shell\RunAsInvoker" /ve /t REG_SZ /d "Запуск с пониженными правами" /f 1>> %logfile% 2>>&1
	reg add "HKCR\exefile\shell\RunAsInvoker\command" /ve /t REG_SZ /d "cmd.exe /c set __COMPAT_LAYER=RunAsInvoker & start \"\" \"%%1\" %%*" /f 1>> %logfile% 2>>&1
	REM ; Очистка диска в контекстное меню дисков
	reg add "HKCR\Drive\shell\CleanMgr" /v "MUIVerb" /t REG_SZ /d "Очистка диска" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CleanMgr" /v "Icon" /t REG_SZ /d "cleanmgr.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CleanMgr" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CleanMgr\command" /ve /t REG_SZ /d "nircmdc elevate cleanmgr.exe /lowdisk /d %%1" /f 1>> %logfile% 2>>&1
	REM ;Пункт "Дефрагментация" в контекстное меню дисков
	reg add "HKCR\Drive\shell\Defrag" /ve /t REG_SZ /d "Дефрагментация" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\Defrag" /v "Icon" /t REG_SZ /d "dfrgui.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\Defrag" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\Defrag\command" /ve /t REG_SZ /d "defrag %%1" /f 1>> %logfile% 2>>&1
	REM ; Командная строка (вложенное меню в два пункта)
	reg add "HKCR\Directory\shell\CmdFolder" /v "MUIVerb" /t REG_SZ /d "Командная строка" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\CmdFolder" /v "SubCommands" /t REG_SZ /d "cmd_system;cmd_admin;cmd_user" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\CmdFolder" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\shell\CmdFolder" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CmdFolder" /v "MUIVerb" /t REG_SZ /d "Командная строка" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CmdFolder" /v "SubCommands" /t REG_SZ /d "cmd_system;cmd_admin;cmd_user" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CmdFolder" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CmdFolder" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CmdFolder" /v "MUIVerb" /t REG_SZ /d "Командная строка" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CmdFolder" /v "SubCommands" /t REG_SZ /d "cmd_system;cmd_admin;cmd_user" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CmdFolder" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Drive\shell\CmdFolder" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_system" /ve /t REG_SZ /d "От имени системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_system" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_system" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	::reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_system\command" /ve /t REG_SZ /d "devxexec.exe /user:System %SystemRoot%\System32\cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_system\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem %SystemRoot%\System32\cmd.exe /s /k pushd \"%%v\"" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_admin" /ve /t REG_SZ /d "От имени администратора" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_admin" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_admin" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_admin\command" /ve /t REG_SZ /d "nircmdc elevate cmd /s /k pushd \"%%v\"" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_user" /ve /t REG_SZ /d "От имени пользователя" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_user" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd_user\command" /ve /t REG_SZ /d "cmd.exe /s /k set __COMPAT_LAYER=RunAsInvoker & pushd \"%%v\"" /f 1>> %logfile% 2>>&1
	REM ; Цвет командной строки. С ограниченными правами 0A (зеленый текст на черном фоне) с правами администратора 0C (красный текст на черном фоне)
	reg add "HKLM\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "cls && reg query HKEY_USERS\S-1-5-19\Environment /v TEMP 2>&1 | findstr /i /c:REG_EXPAND_SZ 2>&1 >nul && (color 0C) || (color 0A)" /f 1>> %logfile% 2>>&1
	REM ; Удалить пункт "Восстановить прежнюю версию" из контекстного меню Проводника
	reg delete "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" /f 1>> %logfile% 2>>&1
	reg delete "HKCR\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\CompMgmt" /v "MUIVerb" /t REG_SZ /d "Дополнительно" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\CompMgmt" /v "SubCommands" /t REG_SZ /d "godmode;controlpanel;propertiesadvanced;services;deviceproperties;regedit;msconfig;gpedit;taskschd;eventvwr;diskmng;appwiz" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\CompMgmt" /v "Icon" /t REG_SZ /d "imageres.dll,104" /f 1>> %logfile% 2>>&1
	%SystemUser% reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\CompMgmt" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell" /ve /t REG_SZ /d "MyComp;Eject;CleanTools,Refresh,CmdFolder,Standart,System,Admin,Advanced,ReIcon,PowerMenu,Display,Gadgets,Personalize" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\MyComp" /v "MUIVerb" /t REG_SZ /d "Открыть проводник (Компьютер)" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\MyComp" /v "Icon" /t REG_SZ /d "explorer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\MyComp" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\MyComp\command" /ve /t REG_SZ /d "explorer.exe shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Eject" /v "MUIVerb" /t REG_SZ /d "Быстрое извлечение съемных носителей" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Eject" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\EjectFlash\RemoveDrive.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Eject" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Eject\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:System \"wscript.exe %SystemRoot%\Tools\EjectFlash\EjectFlash.vbs\"" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Refresh" /v "MUIVerb" /t REG_SZ /d "Обновить иконки/папки (2x)" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Refresh" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Refresh.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Refresh" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Refresh\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Refresh.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CleanTools" /v "MUIVerb" /t REG_SZ /d "Очистка/оптимизация/поиск вирусов" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CleanTools" /v "SubCommands" /t REG_SZ /d "emptyclip;clearrecycle;cleardsk;speedy;drivetidy;clearreg;6to4;reducemem;servopt;virscan" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CleanTools" /v "Icon" /t REG_SZ /d "shell32.dll,-254" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\CleanTools" /v "Position" /t REG_SZ /d "Top" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\NetTools" /v "MUIVerb" /t REG_SZ /d "Сетевые утилиты" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\NetTools" /v "SubCommands" /t REG_SZ /d "goping;copyip;updtime;http;rdp;fixbrowsers;netfix;macchanger;tcpoptimizer" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\NetTools" /v "Icon" /t REG_SZ /d "shell32.dll,-18" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Standart" /v "MUIVerb" /t REG_SZ /d "Стандартные программы" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Standart" /v "SubCommands" /t REG_SZ /d "mute;hide;topmost;centerall;closeall;winmanager;screen;search;scanner;webcam;calc;paint;charmap;soundrec;snip;psr" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Standart" /v "Icon" /t REG_SZ /d "imageres.dll,152" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Standart" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\System" /v "MUIVerb" /t REG_SZ /d "Система" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\System" /v "SubCommands" /t REG_SZ /d "control;devmgr;msconfig;sysdm;sysdir;networksh;wu;appwiz;rstrui;taskmgr;power;folderoptions;instinfo" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\System" /v "Icon" /t REG_SZ /d "imageres.dll,104" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\System" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Admin" /v "MUIVerb" /t REG_SZ /d "Администрирование" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Admin" /v "SubCommands" /t REG_SZ /d "regedit;services;rsop;run;taskschd;wf;network;useracc;useracc2;eventvwr;perfmon;relmon;trouble" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Admin" /v "Icon" /t REG_SZ /d "mmc.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Admin" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Advanced" /v "MUIVerb" /t REG_SZ /d "Дополнительно" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Advanced" /v "SubCommands" /t REG_SZ /d "runblock;showsysfiles;reloadex;reiconcache;fixprints;drive-clean;dpstyle;fixwin" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Advanced" /v "Icon" /t REG_SZ /d "shell32.dll,-22" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\Advanced" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\ReIcon" /v "MUIVerb" /t REG_SZ /d "Расположение файлов рабочего стола" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\ReIcon" /v "SubCommands" /t REG_SZ /d "res_reicon;save_reicon;launch_reicon" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\ReIcon" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\shell\ReIcon" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	REM ; Выключение компьютера через контекстное меню
	reg add "HKCR\Directory\Background\Shell\PowerMenu" /v "MUIVerb" /t REG_SZ /d "Выключение/перезагрузка/блокировка" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\Shell\PowerMenu" /v "SubCommands" /t REG_SZ /d "keylock;lockoffmon;lock;switch;logoff;sleep;hibernate;rrestart;restart;shutdown;hybridshutdown;cancelshutdown" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\Shell\PowerMenu" /v "Icon" /t REG_SZ /d "shell32.dll,215" /f 1>> %logfile% 2>>&1
	reg add "HKCR\Directory\Background\Shell\PowerMenu" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\netfix" /v "MUIVerb" /t REG_SZ /d "Исправить различные проблемы с сетью" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\netfix" /v "SubCommands" /t REG_SZ /d "intrep_x86;intrep_x64" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\netfix" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ComIntRep\ComIntRep.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock" /v "MUIVerb" /t REG_SZ /d "Лок/анлок мыши и клавиатуры (CtrLALtZ)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock" /v "SubCommands" /t REG_SZ /d "keylock_32;keylock_64" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\KeyFreeze\KeyFreeze.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drive-clean" /v "MUIVerb" /t REG_SZ /d "Очистить все неиспользуемые устройства" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drive-clean" /v "SubCommands" /t REG_SZ /d "drvcln_x86;drvcln_x64" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drive-clean" /v "Icon" /t REG_SZ /d "devmgr.dll,4" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drive-clean" /v "Position" /t REG_SZ /d "Bottom" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\godmode" /ve /t REG_SZ /d "Режим Бога" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\godmode" /v "Icon" /t REG_SZ /d "imageres.dll,-1033" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\godmode\command" /ve /t REG_SZ /d "explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C}" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig" /ve /t REG_SZ /d "Настройка системы (msconfig)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig" /v "Icon" /t REG_SZ /d "shell32.dll,-25" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\msconfig\command" /ve /t REG_SZ /d "msconfig.exe /s" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\controlpanel" /v "MUIVerb" /t REG_SZ /d "Панель управления" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\controlpanel" /v "Icon" /t REG_SZ /d "imageres.dll,22" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\controlpanel\command" /ve /t REG_SZ /d "control.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\deviceproperties" /v "MUIVerb" /t REG_SZ /d "Диспетчер устройств" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\deviceproperties" /v "Icon" /t REG_SZ /d "DeviceProperties.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\deviceproperties\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc devmgmt.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\diskmng" /v "MUIVerb" /t REG_SZ /d "Управление дисками" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\diskmng" /v "Icon" /t REG_SZ /d "dmdskres.dll,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\diskmng\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc diskmgmt.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\propertiesadvanced" /v "MUIVerb" /t REG_SZ /d "Дополнительные параметры" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\propertiesadvanced" /v "Icon" /t REG_SZ /d "SystemPropertiesAdvanced.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\propertiesadvanced\command" /ve /t REG_SZ /d "SystemPropertiesAdvanced.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services" /v "MUIVerb" /t REG_SZ /d "Службы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services" /v "Icon" /t REG_SZ /d "filemgmt.dll,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc services.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\gpedit" /v "MUIVerb" /t REG_SZ /d "Редактор групповой политики" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\gpedit" /v "Icon" /t REG_SZ /d "gpedit.dll,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\gpedit\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc gpedit.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rsop" /v "MUIVerb" /t REG_SZ /d "Редактор результирующей политики" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rsop" /v "Icon" /t REG_SZ /d "gpedit.dll,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rsop\command" /ve /t REG_SZ /d "mmc rsop.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskschd" /v "MUIVerb" /t REG_SZ /d "Планировщик заданий" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskschd" /v "Icon" /t REG_SZ /d "miguiresource.dll,1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskschd\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc taskschd.msc /s" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\eventvwr" /v "MUIVerb" /t REG_SZ /d "Просмотр событий" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\eventvwr" /v "Icon" /t REG_SZ /d "miguiresource.dll,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\eventvwr\command" /ve /t REG_SZ /d "nircmdc elevatecmd runassystem mmc eventvwr.msc /s" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\emptyclip" /ve /t REG_SZ /d "Очистить буфер обмена" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\emptyclip" /v "Icon" /t REG_SZ /d "shell32.dll,-254" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\emptyclip\command" /ve /t REG_SZ /d "nircmdc clipboard clear" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearrecycle" /ve /t REG_SZ /d "Очистить корзину и временные файлы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearrecycle" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearrecycle" /v "Icon" /t REG_SZ /d "shell32.dll,-254" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearrecycle\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ClearTrashTemp.exe a" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleardsk" /ve /t REG_SZ /d "Полная чистка дисков от мусора" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleardsk" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleardsk" /v "Icon" /t REG_SZ /d "cleanmgr.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cleardsk\command" /ve /t REG_SZ /d "nircmdc elevate cleanmgr /sageset:1 & nircmdc elevate cleanmgr /sagerun:1" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearreg" /ve /t REG_SZ /d "Оптимизировать и сжать реестр" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearreg" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearreg" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\RegistryFirstAid\RFA.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\clearreg\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\RegistryFirstAid\RFA.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\6to4" /ve /t REG_SZ /d "Удалить лишние 6to4 адаптеры" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\6to4" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\6to4" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\6to4remover.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\6to4\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\6to4remover.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reducemem" /ve /t REG_SZ /d "Очистить неиспользуемую память" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reducemem" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reducemem" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReduceMemory\ReduceMemory.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reducemem\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\ReduceMemory\ReduceMemory.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\speedy" /ve /t REG_SZ /d "Оптимизировать работу браузеров/скайпа" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\speedy" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\speedy" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\speedyfox.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\speedy\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\speedyfox.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drivetidy" /ve /t REG_SZ /d "Очистить диск от мусора" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drivetidy" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drivetidy" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\DriveTidy\DriveTidy.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drivetidy\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\DriveTidy\DriveTidy.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\servopt" /ve /t REG_SZ /d "Оптимизировать службы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\servopt" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\servopt" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\EasyServicesOptimizer\eso.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\servopt\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\EasyServicesOptimizer\eso.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\virscan" /ve /t REG_SZ /d "68 антивирусов в одном! (он-лайн)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\virscan" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\virscan" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\herdProtect\herdProtectScan.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\virscan\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\herdProtect\herdProtectScan.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_32" /ve /t REG_SZ /d "Для 32х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_32" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\KeyFreeze\KeyFreeze.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_32\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\KeyFreeze\KeyFreeze.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_64" /ve /t REG_SZ /d "Для 64х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_64" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\KeyFreeze\KeyFreeze_x64.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\keylock_64\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\KeyFreeze\KeyFreeze_x64.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lockoffmon" /ve /t REG_SZ /d "Блокировка и выключение монитора" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lockoffmon" /v "Icon" /t REG_SZ /d "imageres.dll,-101" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lockoffmon\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:System %SystemRoot%\Tools\MonitorOff.bat" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lock" /ve /t REG_SZ /d "Блокировка компьютера" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lock" /v "Icon" /t REG_SZ /d "shell32.dll,-48" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\lock\command" /ve /t REG_SZ /d "Rundll32 User32.dll,LockWorkStation" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff" /ve /t REG_SZ /d "Выход из системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff" /v "Icon" /t REG_SZ /d "shell32.dll,-45" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff\command" /ve /t REG_SZ /d "hidcon.exe shutdown -l" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\switch" /ve /t REG_SZ /d "Сменить пользователя" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\switch" /v "Icon" /t REG_SZ /d "imageres.dll,-88" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\switch\command" /ve /t REG_SZ /d "tsdiscon.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sleep" /ve /t REG_SZ /d "Режим Сон" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sleep" /v "Icon" /t REG_SZ /d "imageres.dll,-101" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sleep\command" /ve /t REG_SZ /d "rundll32.exe powrprof.dll,SetSuspendState Sleep" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hibernate" /ve /t REG_SZ /d "Режим Гибернация" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hibernate" /v "Icon" /t REG_SZ /d "shell32.dll,217" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hibernate\command" /ve /t REG_SZ /d "hidcon.exe shutdown -h" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\restart" /ve /t REG_SZ /d "Перезагрузка компьютера" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\restart" /v "Icon" /t REG_SZ /d "shell32.dll,-290" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\restart\command" /ve /t REG_SZ /d "hidcon.exe shutdown -r -f -t 00" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rrestart" /ve /t REG_SZ /d "Удаленная перезагрузка/выключение" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rrestart" /v "Icon" /t REG_SZ /d "shell32.dll,-18" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rrestart\command" /ve /t REG_SZ /d "hidcon.exe shutdown /i" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\shutdown" /ve /t REG_SZ /d "Выключить компьютер" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\shutdown" /v "Icon" /t REG_SZ /d "shell32.dll,-28" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\shutdown\command" /ve /t REG_SZ /d "hidcon.exe shutdown -s -f -t 00" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hybridshutdown" /ve /t REG_SZ /d "Гибридное выключение" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hybridshutdown" /v "Icon" /t REG_SZ /d "shell32.dll,-221" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hybridshutdown\command" /ve /t REG_SZ /d "hidcon.exe shutdown -s -f -t 00 -hybrid" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cancelshutdown" /ve /t REG_SZ /d "Отмена выключения/перезагрузки" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cancelshutdown" /v "Icon" /t REG_SZ /d "imageres.dll,-98" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cancelshutdown\command" /ve /t REG_SZ /d "devxexec.exe /user:System \"shutdown.exe -a\"" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\mute" /ve /t REG_SZ /d "Приглушить/возобновить звук" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\mute" /v "Icon" /t REG_SZ /d "sndvol.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\mute\command" /ve /t REG_SZ /d "nircmdc mutesysvolume 2" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hide" /ve /t REG_SZ /d "Свернуть/восстановить все окна" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hide" /v "Icon" /t REG_SZ /d "explorer.exe,-103" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\hide\command" /ve /t REG_SZ /d "explorer shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\topmost" /ve /t REG_SZ /d "Установить поверх всех окон" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\topmost" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\TopMost\TopMost.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\topmost\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\TopMost\TopMost.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\centerall" /ve /t REG_SZ /d "Оцентровать все окна" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\centerall" /v "Icon" /t REG_SZ /d "shell32.dll,-268" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\centerall\command" /ve /t REG_SZ /d "nircmdc win center alltop" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\closeall" /ve /t REG_SZ /d "Закрыть все окна" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\closeall" /v "Icon" /t REG_SZ /d "shell32.dll,-240" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\closeall\command" /ve /t REG_SZ /d "nircmdc win close class CabinetWClass" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\winmanager" /ve /t REG_SZ /d "Управление зависшими окнами" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\winmanager" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\winmanager" /v "Icon" /t REG_SZ /d "shell32.dll,-3" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\winmanager\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\WindowManager.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\webcam" /ve /t REG_SZ /d "Вкл/Выкл веб-камеру" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\webcam" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\WebCam\WebCam.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\webcam\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\WebCam\WebCam.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\screen" /ve /t REG_SZ /d "Сделать скриншот экрана" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\screen" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Screenshoter.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\screen\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Screenshoter.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\calc" /v "CommandFlags" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\calc" /ve /t REG_SZ /d "Калькулятор" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\calc" /v "Icon" /t REG_SZ /d "calc.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\calc\command" /ve /t REG_SZ /d "calc.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\notepad" /ve /t REG_SZ /d "Блокнот" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\notepad" /v "Icon" /t REG_SZ /d "notepad.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\notepad\command" /ve /t REG_SZ /d "notepad.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\paint" /ve /t REG_SZ /d "Paint" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\paint" /v "Icon" /t REG_SZ /d "mspaint.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\paint\command" /ve /t REG_SZ /d "mspaint.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wordpad" /ve /t REG_SZ /d "Wordpad" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wordpad" /v "Icon" /t REG_SZ /d "write.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wordpad\command" /ve /t REG_SZ /d "wordpad.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\soundrec" /ve /t REG_SZ /d "Звукозапись" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\soundrec" /v "Icon" /t REG_SZ /d "SoundRecorder.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\soundrec\command" /ve /t REG_SZ /d "SoundRecorder.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\snip" /ve /t REG_SZ /d "Ножницы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\snip" /v "Icon" /t REG_SZ /d "SnippingTool.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\snip\command" /ve /t REG_SZ /d "SnippingTool.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\charmap" /ve /t REG_SZ /d "Таблица символов" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\charmap" /v "Icon" /t REG_SZ /d "charmap.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\charmap\command" /ve /t REG_SZ /d "charmap.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\psr" /ve /t REG_SZ /d "Запись действий (PSR)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\psr" /v "Icon" /t REG_SZ /d "psr.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\psr\command" /ve /t REG_SZ /d "psr.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz" /ve /t REG_SZ /d "Программы и компоненты" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz" /v "Icon" /t REG_SZ /d "appwiz.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\appwiz\command" /ve /t REG_SZ /d "control appwiz.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reloadex" /ve /t REG_SZ /d "Перезагрузить оболочку (проводник)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reloadex" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reloadex" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Rexplorer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reloadex\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\Rexplorer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\runblock" /ve /t REG_SZ /d "Блокировать важные приложения" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\runblock" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\runblock" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\RunBlock\RunBlock.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\runblock\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\RunBlock\RunBlock.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\showsysfiles" /ve /t REG_SZ /d "Показать/скрыть скрытые файлы и папки" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\showsysfiles" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\showsysfiles" /v "Icon" /t REG_SZ /d "shell32.dll,-278" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\showsysfiles\command" /ve /t REG_EXPAND_SZ /d "wscript.exe %SystemRoot%\Tools\ShowSysFiles.vbs" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reiconcache" /ve /t REG_SZ /d "Перестроить кэш значков" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reiconcache" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reiconcache" /v "Icon" /t REG_SZ /d "shell32.dll,-289" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\reiconcache\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\ReIconCache.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\dpstyle" /ve /t REG_SZ /d "Просмотреть разметку дисков/разделов" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\dpstyle" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\DPStyle.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\dpstyle\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\DPStyle.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\copyip" /ve /t REG_SZ /d "Скопировать белый адрес IPv4 в буфер" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\copyip" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\CopyIP.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\copyip\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\CopyIP.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\goping" /ve /t REG_SZ /d "Утилита Пинг (GoPing)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\goping" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\GoPing\GoPing.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\goping\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\GoPing\GoPing.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\updtime" /ve /t REG_SZ /d "Обновить локальное время и дату" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\updtime" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\UpdateTime\UpdateTime.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\updtime\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\UpdateTime\UpdateTime.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\http" /ve /t REG_SZ /d "Запустить Web-сервер (Apache/PHP/MySql)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\http" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\http" /v "Icon" /t REG_SZ /d "shell32.dll,-244" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\http\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Web-Server\UniController.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixbrowsers" /ve /t REG_SZ /d "Исправить ошибки во многих браузерах" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixbrowsers" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixbrowsers" /v "Icon" /t REG_SZ /d "ieframe.dll,-190" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixbrowsers\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\fixBrowsers.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\macchanger" /ve /t REG_SZ /d "Сменить/восстановить MAC-адрес" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\macchanger" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\macchanger" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\MacAddrChanger.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\macchanger\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:TrustedInstaller %SystemRoot%\Tools\MacAddrChanger.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\tcpoptimizer" /ve /t REG_SZ /d "Оптимизация сетевого соединения" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\tcpoptimizer" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\tcpoptimizer" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\TCPOptimizer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\tcpoptimizer\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\TCPOptimizer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x86" /ve /t REG_SZ /d "Для 32х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x86" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x86" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ComIntRep\ComIntRep.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x86\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ComIntRep\ComIntRep.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x64" /ve /t REG_SZ /d "Для 64х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x64" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x64" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ComIntRep\ComIntRep_x64.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\intrep_x64\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ComIntRep\ComIntRep_x64.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixprints" /ve /t REG_SZ /d "Исправить диспетчер очереди печати" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixprints" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixprints" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\fixPrintS.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixprints\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\fixPrintS.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x86" /ve /t REG_SZ /d "Для 32х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x86" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x86" /v "Icon" /t REG_SZ /d "devmgr.dll,4" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x86\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:System \"%SystemRoot%\Tools\DriveCleanup\DriveCleanup_x86.exe -n\"" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x64" /ve /t REG_SZ /d "Для 64х битной системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x64" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x64" /v "Icon" /t REG_SZ /d "devmgr.dll,4" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\drvcln_x64\command" /ve /t REG_EXPAND_SZ /d "devxexec.exe /user:System \"%SystemRoot%\Tools\DriveCleanup\DriveCleanup_x64.exe -n\"" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\res_reicon" /ve /t REG_SZ /d "&Восстановить схему расположения" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\res_reicon" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\res_reicon" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe,5" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\res_reicon\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe /Restore" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\save_reicon" /ve /t REG_SZ /d "&Сохранить схему расположения" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\save_reicon" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\save_reicon" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe,6" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\save_reicon\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe /Save" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\launch_reicon" /v "CommandFlags" /t REG_DWORD /d "32" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\launch_reicon" /ve /t REG_SZ /d "&Запустить утилиту" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\launch_reicon" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\launch_reicon" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\launch_reicon\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\ReIcon\ReIcon.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\control" /ve /t REG_SZ /d "Панель управления" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\control" /v "Icon" /t REG_SZ /d "control.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\control\command" /ve /t REG_SZ /d "control.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdir" /ve /t REG_SZ /d "Системные папки" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdir" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Ex-Dir.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdir\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Ex-Dir.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\devmgr" /ve /t REG_SZ /d "Диспетчер устройств" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\devmgr" /v "Icon" /t REG_SZ /d "DeviceProperties.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\devmgr\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\system32\mmc.exe /s %SystemRoot%\system32\devmgmt.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folderoptions" /ve /t REG_SZ /d "Свойства папки" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folderoptions" /v "Icon" /t REG_SZ /d "explorer.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\folderoptions\command" /ve /t REG_SZ /d "control folders" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\networksh" /ve /t REG_SZ /d "Центр управления сетями" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\networksh" /v "Icon" /t REG_SZ /d "networkexplorer.dll,4" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\networksh\command" /ve /t REG_SZ /d "control /name Microsoft.NetworkAndSharingCenter" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\power" /ve /t REG_SZ /d "Электропитание" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\power" /v "Icon" /t REG_SZ /d "powercfg.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\power\command" /ve /t REG_SZ /d "control powercfg.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\instinfo" /ve /t REG_SZ /d "Список программ" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\instinfo" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\InstallInfo.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\instinfo\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\InstallInfo.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regedit" /ve /t REG_SZ /d "Редактор реестра" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regedit" /v "Icon" /t REG_SZ /d "regedit.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\regedit\command" /ve /t REG_SZ /d "devxexec.exe /user:TrustedInstaller regedit.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rstrui" /ve /t REG_SZ /d "Восстановление системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rstrui" /v "Icon" /t REG_SZ /d "rstrui.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rstrui\command" /ve /t REG_SZ /d "rstrui.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\search" /ve /t REG_SZ /d "Быстрый поиск файлов и папок" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\search" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Everything\Everything.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\search\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Everything\Everything.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\scanner" /ve /t REG_SZ /d "Оценка места на дисках" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\scanner" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Scanner\Scanner.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\scanner\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\Scanner\Scanner.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdm" /ve /t REG_SZ /d "Свойства системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdm" /v "Icon" /t REG_SZ /d "sysdm.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\sysdm\command" /ve /t REG_SZ /d "control sysdm.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskmgr" /ve /t REG_SZ /d "Диспетчер задач" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskmgr" /v "Icon" /t REG_SZ /d "taskmgr.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\taskmgr\command" /ve /t REG_SZ /d "devxexec.exe /user:TrustedInstaller taskmgr.exe" /f 1>> %logfile% 2>>&1
	::reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd" /ve /t REG_SZ /d "Командная строка" /f 1>> %logfile% 2>>&1
	::reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd" /v "Icon" /t REG_SZ /d "cmd.exe" /f 1>> %logfile% 2>>&1
	::reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	::reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\cmd\command" /ve /t REG_SZ /d "devxexec.exe /user:System cmd.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixwin" /ve /t REG_SZ /d "Менеджер исправлений ошибок" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixwin" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixwin" /v "Icon" /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\fixWin\fixWin.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\fixwin\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\Tools\fixWin\FixWin.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\perfmon" /ve /t REG_SZ /d "Монитор ресурсов" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\perfmon" /v "Icon" /t REG_SZ /d "imageres.dll,144" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\perfmon\command" /ve /t REG_SZ /d "perfmon.exe /res" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\relmon" /ve /t REG_SZ /d "Монитор надежности системы" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\relmon" /v "Icon" /t REG_SZ /d "perfmon.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\relmon\command" /ve /t REG_SZ /d "perfmon.exe /rel" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\trouble" /ve /t REG_SZ /d "Устранение неполадок" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\trouble" /v "Icon" /t REG_SZ /d "imageres.dll,124" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\trouble\command" /ve /t REG_SZ /d "control /name Microsoft.Troubleshooting" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc" /ve /t REG_SZ /d "Учетные записи" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc" /v "Icon" /t REG_SZ /d "imageres.dll,74" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc\command" /ve /t REG_SZ /d "Control userpasswords" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc2" /ve /t REG_SZ /d "Учетные записи (классич.)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc2" /v "Icon" /t REG_SZ /d "shell32.dll,111" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\useracc2\command" /ve /t REG_SZ /d "Control userpasswords2" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rdp" /ve /t REG_SZ /d "Удаленный рабочий стол (RDP)" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rdp" /v "Icon" /t REG_SZ /d "mstsc.exe,0" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\rdp\command" /ve /t REG_SZ /d "mstsc.exe" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\network" /ve /t REG_SZ /d "Сетевые подключения" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\network" /v "Icon" /t REG_SZ /d "ncpa.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\network\command" /ve /t REG_SZ /d "control ncpa.cpl" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wf" /ve /t REG_SZ /d "Брандмауэр Windows" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wf" /v "Icon" /t REG_SZ /d "wscui.cpl,3" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wf\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\system32\mmc.exe /s %SystemRoot%\system32\wf.msc" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wu" /ve /t REG_SZ /d "Центр обновления" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wu" /v "Icon" /t REG_SZ /d "shell32.dll,46" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\wu\command" /ve /t REG_SZ /d "explorer ms-settings:windowsupdate" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run" /ve /t REG_SZ /d "Выполнить" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run" /v "Icon" /t REG_SZ /d "shell32.dll,24" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run" /v "HasLUAShield" /t REG_SZ /d "" /f 1>> %logfile% 2>>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\run\command" /ve /t REG_SZ /d "explorer.exe shell:::{2559A1F3-21D7-11D4-BDAF-00C04F60B9F0}" /f 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
)
@echo. 1>> %logfile%
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Уменьшить размер буфера мыши и клавиатуры.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m если мышь ведет себя некорректно, увеличьте данные значения до 100.
@echo Уменьшить размер буфера мыши и клавиатуры. Предупреждение: если мышь ведет себя некорректно, увеличьте данные значения до 100. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
::reg delete "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
::@echo %clr%[36m Отключить счетчики производительности.%clr%[92m %clr%[7;31mВнимание: после отключения службы, наблюдается нестабильность системы и неработоспособность диспетчера задач.%clr%[0m%clr%[36m%clr%[92m
::set timerStart=!time!
::call :disable_svc pcw
::set timerEnd=!time!
::call :timer
::@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
::echo. 1>> %logfile% 2>>&1
@echo %clr%[36m Отключить PPM и уменьшить задержку в играх.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m если после отключения параметров производительность снизилась, выставите значения на 0.
@echo Отключить PPM и уменьшить задержку в играх. Предупреждение: если после отключения параметров производительность снизилась, выставите значения на 0. 1>> %logfile%
set timerStart=!time!
call :disable_svc AmdK8
call :disable_svc_sudo intelppm
call :disable_svc AmdPPM
call :disable_svc Processor
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Ускорить завершение обнаружения и восстановления тайм-аута (TDR).%clr%[92m
@echo Ускорить завершение обнаружения и восстановления тайм-аута (TDR). 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить состояние сверхнизкого энергопотребления для видеокарт Intel и AMD (ULPS).%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m помогает избавиться от фризов на старых и не оптимизированных играх.
@echo Отключить состояние сверхнизкого энергопотребления для видеокарт Intel и AMD (ULPS). Примечание: Помогает избавиться от фризов на старых и не оптимизированных играх. 1>> %logfile%
set timerStart=!time!
for /f "tokens=* delims=" %%l in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}" /s /v "DriverDesc"^|FindStr HKEY_') do (reg add "%%l" /v "EnableUlps" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1)
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Включить поддержку сглаживания анимации в драйвере nVidia (SILK Smooth).%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m помогает при микрофризах в играх. Последняя поддержка SILK содержится в драйвере 442.74 и настраивается в панели управления nVidia.
@echo Включить поддержку сглаживания анимации в драйвере nVidia (SILK Smooth). Примечание: помогает при микрофризах в играх. Последняя поддержка SILK содержится в драйвере 442.74 и настраивается в панели управления nVidia. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Принудительное выделение непрерывной памяти в драйвере nVidia.%clr%[92m %clr%[7;31mПримечание:%clr%[0m%clr%[36m%clr%[92m ветка 0000 может отличаться в зависимости от номера графического процессора.
@echo Принудительное выделение непрерывной памяти в драйвере nVidia. Примечание: ветка 0000 может отличаться в зависимости от номера графического процессора. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Отключить код исправления ошибок (ECC) на видеокартах nVidia.%clr%[92m
@echo Отключить код исправления ошибок (ECC) на видеокартах nVidia. 1>> %logfile%
set timerStart=!time!
"%ProgramFiles%\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -e 0
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Переключить режим драйвера из WDDM в TCC на видеокартах nVidia.%clr%[92m
@echo Переключить режим драйвера из WDDM в TCC на видеокартах nVidia. 1>> %logfile%
set timerStart=!time!
"%ProgramFiles%\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -fdm 1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Принудительное выделение непрерывной памяти в графическом ядре DirectX.%clr%[92m
@echo Принудительное выделение непрерывной памяти в графическом ядре DirectX. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DpiMapIommuContiguous" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Применение оптимизации V-Sync для ускорения игр.%clr%[92m
@echo Применение оптимизации V-Sync для ускорения игр. 1>> %logfile%
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "VsyncIdleTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Выберите желаемое приложение или игру для установки высокопроизводительного приоритета DirectX и использования виртуального адресного пространства для снижения микрофризов.%clr%[92m
@echo Выберите желаемое приложение или игру для установки высокопроизводительного приоритета DirectX и использования виртуального адресного пространства для снижения микрофризов. 1>> %logfile%
set timerStart=!time!
powershell -ExecutionPolicy Bypass -file "%~dp0ProcessPerformance.ps1" -wa SilentlyContinue 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Установка оптимизированного профиля nVidia.%clr%[92m
@echo Установка оптимизированного профиля nVidia. 1>> %logfile%
set timerStart=!time!
start "" /wait "%~dp0nvidiaProfileInspector.exe" "%~dp0nvprofile.nip"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Программа для настройки MSI на устройствах.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m применяйте параметры только для устройств с поддержкой msi.
@echo Программа для настройки MSI на устройствах. Предупреждение: применяйте параметры только для устройств с поддержкой msi. 1>> %logfile%
set timerStart=!time!
start "" /wait "%~dp0MSI_util_v3.exe"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Установка инструмента для применения максимального разрешения таймера при запуске ОС (проверить значение таймера можно с помощью утилиты TimerTool, находящейся в папке Apps).%clr%[92m
@echo Установка инструмента для применения максимального разрешения таймера при запуске ОС (проверить значение таймера можно с помощью утилиты TimerTool, находящейся в папке Apps) 1>> %logfile%
set timerStart=!time!
net stop STR 1>> %logfile% 2>>&1
start "" /wait /min %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /u %~dp0TimerResolution.exe
start "" /wait /min %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i %~dp0TimerResolution.exe
net start STR 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Применение инструмента в автозагрузку для отключения энергосбережения жестких дисков.%clr%[92m
@echo Применение инструмента в автозагрузку для отключения энергосбережения жестких дисков. 1>> %logfile%
set timerStart=!time!
start "" /wait "%~dp0..\Installers\quietHDD.exe"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "quietHDD" /t REG_SZ /d "%SystemRoot%\Tools\quietHDD\quietHDD.exe /NOTRAY /ACAPMVALUE:255 /DCAPMVALUE:255 /ACAAMVALUE:254 /DCAAMVALUE:254 /NOWARN" /f 1>> %logfile% 2>>&1
%SystemUser% reg.exe unload "HKU\.DEFAULT" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Программа для отключения ленты из проводника.%clr%[92m %clr%[7;31mПредупреждение:%clr%[0m%clr%[36m%clr%[92m после применения изменений не нажимайте кнопку Yes для дальнейшего применения скрипта.
@echo Программа для отключения ленты из проводника. Предупреждение: после применения изменений не нажимайте кнопку Yes для дальнейшего применения скрипта. 1>> %logfile%
set timerStart=!time!
call :acl_file "%SystemRoot%\System32\explorerframe.dll"
call :acl_file "%SystemRoot%\System32\explorerframe.dll.151"
call :acl_file "%SystemRoot%\System32\explorerframe.dll.winaero"
del /f /q "%SystemRoot%\System32\explorerframe.dll.151" 1>> %logfile% 2>>&1
start "" /wait "%~dp0RibbonDisabler.exe"
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Установить классический калькулятор и msconfig от Windows 7?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	set timerStart=!time!
	@echo %clr%[36m Установка классического калькулятора и msconfig от Windows 7 в ручном режиме.%clr%[92m
	@echo Установка классического калькулятора и msconfig от Windows 7 в ручном режиме. 1>> %logfile%
	start "" /wait "%~dp0ClassicCalculator.exe"
	start "" /wait "%~dp0ClassicMsconfig.exe"
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
@echo %clr%[36m Очистить следы подключения USB-дисков и DVD-ROM для корректной работы.%clr%[92m
@echo Очистить следы подключения USB-дисков и DVD-ROM для корректной работы. 1>> %logfile%
set timerStart=!time!
set saveregfile=%~dp0..\..\Backup\Backup_USB_DVD_%daytime%.reg
%~dp0USBOblivion_%arch% -enable -auto -lang:19 -norestorepoint -norestart -noexplorer -silent -save:%saveregfile% -log:%logfile%
set timerEnd=!time!
call :timer
@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
echo. 1>> %logfile%
@echo %clr%[36m Добавить утилиту мониторинга загрузки системы в автозагрузку?.%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	@echo Добавление утилиты мониторинга загрузки системы в автозагрузку. 1>> %logfile%
	set timerStart=!time!
	xcopy "%~dp0\..\Tools\EZUptime.exe" "%SystemRoot%\Tools\EZUptime.exe" /e /c /i /q /h /r /y 1>> %logfile% 2>>&1
	start "" "%SystemRoot%\Tools\EZUptime.exe"
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "EZUptime" /t REG_SZ /d "%SystemRoot%\Tools\EZUptime.exe" /f 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!totalsecs!.!ms!%clr%[0m секунд%clr%[93m]%clr%[92m
	echo. 1>> %logfile%
)
rem #########################################################################################################################################################################################################################
@echo %clr%[36m Выполнить обслуживание системы после настройки?%clr%[92m
choice /c yn /n /t %autoChoose% /d y /m %keySelY%
if !errorlevel!==1 (
	@echo %clr%[36m Сжатие данных ^(это может занять ~30 минут^).%clr%[92m
	echo Сжатие данных ^(это может занять ~30 минут^). 1>> %logfile%
	set timerStart=!time!
	compact /compactos:always 1>> %logfile% 2>>&1
	compact /c /s:"%ProgramFiles%" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
	compact /c /s:"%ProgramFiles(x86)%" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
	compact /c /s:"%ProgramData%" /a /i /exe:lzx 1>> %logfile% 2>>&1
	compact /c /s:"%UserProfile%\AppData" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
		for /f "delims=" %%d in ('dir %SystemRoot% /b /ad') do (
			if "%%d" neq "Boot" (
				if "%%d" neq "System32" (
					if "%%d" neq "SysWOW64" (
						if "%%d" neq "Fonts" (
							if "%%d" neq "Cursors" (
								if "%%d" neq "INF" (
									compact /c /s:"%SystemRoot%\%%d" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
								)
							)
						)
					)
				)
			)
		)
		for /f "delims=" %%f in ('dir %SystemRoot% /b /a-d') do (
			compact /c "%SystemRoot%\%%f" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
		)
	compact /c "%SystemRoot%" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
	set timerEnd=!time!
	call :timer
	@echo ОК %clr%[93m[%clr%[91m!mins!%clr%[0m минут%clr%[93m %clr%[91m!secs!%clr%[0m секунд%clr%[93m]%clr%[92m
)
rem #########################################################################################################################################################################################################################
start "" /min %~dp0EmptyStandbyList.exe "workingsets|modifiedpagelist|standbylist|priority0standbylist"
lodctr /e:PerfOS 1>> %logfile% 2>>&1
lodctr /r 1>> %logfile% 2>>&1
start "" "%SystemRoot%\explorer.exe"
timeout /t 1 /nobreak | break
ie4uinit -ClearIconCache
powershell "gps explorer | spps -wa SilentlyContinue" 1>> %logfile% 2>>&1
echo.%clr%[36m
echo. 1>> %logfile% 2>>&1
bcdedit /enum 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
rem #########################################################################################################################################################################################################################
echo.%clr%[42m%clr%[0m
timeout /t 5 /nobreak | break
rundll32 user32.dll, SetActiveWindow 1
timeout /t 2 /nobreak | break
rundll32 user32.dll, SetActiveWindow 1
@echo %clr%[42m Все настройки завершены. Перезагрузить компьютер для применения твиков прямо сейчас?%clr%[0m
choice /c yn /n /t %autoChoose% /d n /m %keySelN%
if !errorlevel!==1 (
move /y %~dp0InstallUtil.InstallLog %~dp0..\..\Logs\InstallUtil.InstallLog | break
move /y %~dp0TimerResolution.InstallLog %~dp0..\..\Logs\TimerResolution.InstallLog | break
move /y %~dp0TimerResolution.InstallState %~dp0..\..\Logs\TimerResolution.InstallState | break
@echo --- End of file --- 1>> %logfile% 2>>&1
del /f /q %~dp0logfile
del /f /q %tmpfile%
%SystemUser% del /f /q %SystemRoot%\System32\CodeIntegrity\SIPolicy.p7b
%SystemUser% del /f /q %SystemRoot%\System32\CodeIntegrity\driversipolicy.p7b
shutdown -r -t 0
goto :eof
)
move /y %~dp0InstallUtil.InstallLog %~dp0..\..\Logs\InstallUtil.InstallLog | break
move /y %~dp0TimerResolution.InstallLog %~dp0..\..\Logs\TimerResolution.InstallLog  | break
move /y %~dp0TimerResolution.InstallState %~dp0..\..\Logs\TimerResolution.InstallState  | break
@echo --- End of file --- 1>> %logfile% 2>>&1
del /f /q %~dp0logfile
del /f /q %tmpfile%
%SystemUser% del /f /q %SystemRoot%\System32\CodeIntegrity\SIPolicy.p7b
%SystemUser% del /f /q %SystemRoot%\System32\CodeIntegrity\driversipolicy.p7b
timeout -1 | break
goto :eof
rem #########################################################################################################################################################################################################################
:clr
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set clr=%%b)
goto :eof
:timer
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%timerStart%") do set timerStart_h=%%a&set /a timerStart_m=100%%b %% 100&set /a timerStart_s=100%%c %% 100&set /a timerStart_ms=100%%d %% 100
for /f %options% %%a in ("%timerEnd%") do set timerEnd_h=%%a&set /a timerEnd_m=100%%b %% 100&set /a timerEnd_s=100%%c %% 100&set /a timerEnd_ms=100%%d %% 100
set /a hours=%timerEnd_h%-%timerStart_h%
set /a mins=%timerEnd_m%-%timerStart_m%
set /a secs=%timerEnd_s%-%timerStart_s%
set /a ms=%timerEnd_ms%-%timerStart_ms%
if %ms% lss 0 set /a secs-=1 & set /a ms = 100%ms%
if %secs% lss 0 set /a mins-=1 & set /a secs = 60%secs%
if %mins% lss 0 set /a hours-=1 & set /a mins = 60%mins%
if %hours% lss 0 set /a hours = 24%hours%
if 1%ms% lss 100 set ms=0%ms%
set /a totalsecs = %hours%*3600 + %mins%*60 + %secs%
goto :eof
:kill
taskkill /f /im %~1 1>> %logfile% 2>>&1
goto :eof
:demand_svc
sc stop "%~1" 1>> %logfile% 2>>&1
sc config "%~1" start= demand 1>> %logfile% 2>>&1
goto :eof
:demand_svc_random
sc stop "%~1" 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%~1" /v "Start" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
)
call :demand_svc "%~1"
goto :eof
:demand_svc_sudo
%SystemUser% sc stop "%~1" 1>> %logfile% 2>>&1
%SystemUser% sc config "%~1" start= demand 1>> %logfile% 2>>&1
goto :eof
:disable_svc
sc stop "%~1" 1>> %logfile% 2>>&1
sc config "%~1" start= disabled 1>> %logfile% 2>>&1
goto :eof
:disable_svc_sudo
%SystemUser% sc stop "%~1" 1>> %logfile% 2>>&1
%SystemUser% sc config "%~1" start= disabled 1>> %logfile% 2>>&1
goto :eof
:disable_svc_hard
%SystemUser% %~dp0subinacl.exe /process "%~1" /setowner=S-1-5-32-544 /grant=S-1-5-32-544=f /grant=S-1-5-18=f 1>> %logfile% 2>>&1
%SystemUser% %~dp0subinacl.exe /subkeyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%~1" /setowner=S-1-5-32-544 /grant=S-1-5-32-544=f /grant=S-1-5-18=f 1>> %logfile% 2>>&1
%SystemUser% sc stop "%~1" 1>> %logfile% 2>>&1
%SystemUser% sc config "%~1" start= disabled 1>> %logfile% 2>>&1
goto :eof
:acl_file
%SystemUser% %~dp0subinacl.exe /file "%~1" /setowner=S-1-5-32-544 /grant=S-1-5-32-544=f /grant=S-1-5-18 1>> %logfile% 2>>&1
goto :eof
:acl_folders
%SystemUser% %~dp0subinacl.exe /subdirectories "%~1" /setowner=S-1-5-32-544 /grant=S-1-5-32-544=f /grant=S-1-5-18=f 1>> %logfile% 2>>&1
goto :eof
:acl_registry
%SystemUser% %~dp0subinacl.exe /subkeyreg "%~1" /setowner=S-1-5-32-544 /grant=S-1-5-32-544=f /grant=S-1-5-18=f 1>> %logfile% 2>>&1
goto :eof
:disable_task
schtasks /change /disable /tn "%~1" 1>> %logfile% 2>>&1
goto :eof
:disable_task_sudo
%SystemUser% schtasks /change /disable /tn "%~1" 1>> %logfile% 2>>&1
goto :eof
:trusted
tasklist /fo table /nh /fi "imagename eq trustedinstaller.exe" >nul | find /i "trustedinstaller.exe" >nul || (net start trustedinstaller 1>> %logfile% 2>>&1)
%~dp0devxexec.exe /user:TrustedInstaller "%~1" 1>> %logfile% 2>>&1
goto :eof
:remove_uwp
powershell "Get-AppxPackage *%~1* -AllUsers | Remove-AppxPackage -AllUsers -wa SilentlyContinue" 1>> %logfile% 2>>&1
goto :eof
:remove_uwp_hard
%~dp0install_wim_tweak.exe /o /r /c %~1 1>> %logfile% 2>>&1
goto :eof
:adapters
set "RegistryLine=%~1"
if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
for /f "tokens=2*" %%a in ("%RegistryLine%") do set "ProviderName=%%b"
echo %ProviderName% | findstr "search"
if !errorlevel!==1 (
	if "%ProviderName%" == "" goto :eof
	if "%ProviderName%" == "Microsoft" goto :eof
		reg add "%RegistryKey%" /v "*FlowControl" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "*InterruptModeration" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "*SpeedDuplex" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "AutoDisableGigabit" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "EEE" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "*PriorityVLANTag" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "*LsoV2IPv4" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "ApCompatMode" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
		reg add "%RegistryKey%" /v "PnPCapabilities" /t REG_DWORD /d "24" /f 1>> %logfile% 2>>&1
)
goto :eof
:browsers
set browsersFound=0
for /f %%x in ('tasklist /nh /fi "imagename eq chrome.exe"') do if %%x == chrome.exe set browsersFound=1
for /f %%x in ('tasklist /nh /fi "imagename eq firefox.exe"') do if %%x == firefox.exe set browsersFound=1
for /f %%x in ('tasklist /nh /fi "imagename eq opera.exe"') do if %%x == opera.exe set browsersFound=1
for /f %%x in ('tasklist /nh /fi "imagename eq msedge.exe"') do if %%x == msedge.exe set browsersFound=1
for /f %%x in ('tasklist /nh /fi "imagename eq vivaldi.exe"') do if %%x == vivaldi.exe set browsersFound=1
for /f %%x in ('tasklist /nh /fi "imagename eq thunderbird.exe"') do if %%x == thunderbird.exe set browsersFound=1
goto :eof
