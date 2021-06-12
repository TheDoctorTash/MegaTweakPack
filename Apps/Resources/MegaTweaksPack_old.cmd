@echo off
chcp 1251 | break
setlocal enableDelayedExpansion
if defined SAFEBOOT_OPTION (
	echo  *** Вы находитесь в безопасном режиме^^! Данный скрипт предназначен только для запуска в обычном режиме. ***
	timeout /t 10 /nobreak | break
	goto :eof
)
ver | findstr /i "10\.0\." | break
if %errorLevel% neq 0 (
	echo  *** Ваша ОС не поддерживается^^! Данный скрипт предназначен только для применения в ОС Windows 10. ***
	timeout /t 10 /nobreak | break
	goto :eof
)
set "dv==::"
if %errorlevel% neq 0 (
echo *** Попытка получения прав администратора с повышенными правами... ***
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /b
) else ( goto :Start )
:: #########################################################################################################################################################################################################################
:Start
pushd "%cd%"
cd /d "%~dp0"
if /i not "%cd%\"=="%~dp0" cd /d "%~dp0"
wmic os get osarchitecture | find "64" | break && set superuser=%~dp0superUser64.exe -w -c || set superuser=%~dp0superUser32.exe -w -c
set iwt=%~dp0install_wim_tweak.exe /o /r /c
powershell "Set-ExecutionPolicy Unrestricted" | break
set tmpfile=%~dp0\..\..\Logs\time.dat
time /t > %tmpfile%
set /p ftime= < %tmpfile%
set daytime=%date:~6%%date:~3,2%%date:~0,2%_%ftime:~0,2%%ftime:~3,2%
set logfile=%~dp0\..\..\Logs\MegaTweakPack_%daytime%.txt
call :color
cls
:: #########################################################################################################################################################################################################################
title MegaTweaksPack for Highest Performance by TheDoctor
@echo %COLOR%[42m MegaTweaksPack for Highest Performance by TheDoctor %COLOR%[0m
@echo *** MegaTweaksPack for Highest Performance by TheDoctor *** 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
timeout /t 5 /nobreak | break
%~dp0ExitExplorer.exe
taskkill /f /im "explorer.exe" 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Создание точки восстановления.%COLOR%[0m
echo.%COLOR%[36m%COLOR%[92m
@echo Создание точки восстановления. 1>> %logfile% 2>>&1
set timerStart=!time!
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "DisableConfig" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "DisableSR" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableConfig" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
sc config srservice start=auto 1>> %logfile% 2>>&1
powershell "$SysDrive = $env:SystemDrive; Enable-ComputerRestore $SysDrive" 1>> %logfile% 2>>&1
cmd.exe /c "vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10GB" 1>> %logfile% 2>>&1
powershell "Checkpoint-Computer -Description 'Установлен MegaTweakPack - %DATE%' -RestorePointType 'MODIFY_SETTINGS'" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
echo.
:: #########################################################################################################################################################################################################################
set conf=Y
set /p "conf=Выполнить обслуживание системы перед настройкой? [Y:Да/N:Нет]"
if "%conf%" neq "Y" if "%conf%" neq "y" goto :endservice
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Выполнение обслуживания ОС ^(это может занять некоторое время^).%COLOR%[0m
echo.%COLOR%[36m%COLOR%[92m
@echo Выполнение обслуживания ОС ^(это может занять некоторое время^). 1>> %logfile% 2>>&1
set timerStart=!time!
powershell -ExecutionPolicy Bypass -file "%~dp0OutdatedDrivers.ps1" -WarningAction SilentlyContinue 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\ngen.exe update /force /queue" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\ngen.exe update /force /queue 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\ngen.exe executequeueditems" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\ngen.exe executequeueditems" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /force /queue" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe update /force /queue" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\ngen.exe executequeueditems" 1>> %logfile% 2>>&1
%superuser% "%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe executequeueditems" 1>> %logfile% 2>>&1
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth 1>> %logfile% 2>>&1
sfc /scannow 1>> %logfile% 2>>&1
%~dp0\..\Cleanmgr+\Cleanmgr+.exe /nowindow
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:endservice
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Загрузка %COLOR%[0m
@echo Загрузка 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1)%COLOR%[36m Время ожидания выбора ОС.%COLOR%[92m
@echo Время ожидания выбора ОС. 1>> %logfile% 2>>&1
set timerStart=!time!
bcdedit /timeout 2 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Включить NumLock при загрузке.%COLOR%[92m
@echo Включить NumLock при загрузке. 1>> %logfile% 2>>&1
set timerStart=!time!
bcdedit /set numlock Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Отключить режим автоматического восстановления во время загрузки, если система не завершила предыдущую загрузку или завершение работы.%COLOR%[92m
@echo Отключить режим автоматического восстановления во время загрузки, если система не завершила предыдущую загрузку или завершение работы. 1>> %logfile% 2>>&1
set timerStart=!time!
bcdedit /set bootstatuspolicy IgnoreAllFailures 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить использование сторонней оболочки при загрузке в безопасном режиме.%COLOR%[92m
@echo Отключить использование сторонней оболочки при загрузке в безопасном режиме. 1>> %logfile% 2>>&1
set timerStart=!time!
bcdedit /set safebootalternateshell No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Память %COLOR%[0m
@echo Память 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1)%COLOR%[36m Позволяет избегать использования памяти ниже указанного физического адреса в загрузчике.%COLOR%[92m
@echo Позволяет избегать использования памяти ниже указанного физического адреса в загрузчике.>> %logfile%
set timerStart=!time!
bcdedit /set avoidlowmemory 0x8000000 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Контролирует включение и выключение пятиуровневой подкачки для приложения (default, optout или optin).%COLOR%[92m
@echo Контролирует включение и выключение пятиуровневой подкачки для приложения (default, optout или optin).>> %logfile%
set timerStart=!time!
bcdedit /set linearaddress57 optout 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Режим PAE. Разблокирует 4Gb оперативной памяти в Windows 7 x86 (0 = Default, 1 = ForceEnable, 2 = ForceDisable).%COLOR%[92m
@echo Режим PAE. Разблокирует 4Gb оперативной памяти в Windows 7 x86 (0 = Default, 1 = ForceEnable, 2 = ForceDisable).>> %logfile%
set timerStart=!time!
bcdedit /set pae ForceDisable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить DEP. Этот параметр доступен только в 32-разрядных версиях Windows при работе на процессорах, поддерживающих память без выполнения, и только тогда, когда также включен PAE. Это обеспечивает защиту от невыполнения. Защита от невыполнения всегда включена в 64-разрядных версиях Windows на процессорах x64 (0 = OptIn, 1 = OptOut, 2 = AlwaysOff, 3 = AlwaysOn).%COLOR%[92m
@echo Отключить DEP. Этот параметр доступен только в 32-разрядных версиях Windows при работе на процессорах, поддерживающих память без выполнения, и только тогда, когда также включен PAE. Это обеспечивает защиту от невыполнения. Защита от невыполнения всегда включена в 64-разрядных версиях Windows на процессорах x64 (0 = OptIn, 1 = OptOut, 2 = AlwaysOff, 3 = AlwaysOn). 1>> %logfile% 2>>&1
set timerStart=!time!
bcdedit /set nx AlwaysOff 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Удалить ненужный параметр от проблем с памятью пула страниц.%COLOR%[92m
@echo Удалить ненужный параметр от проблем с памятью пула страниц.>> %logfile%
set timerStart=!time!
bcdedit /deletevalue increaseuserva 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Если не используется PAE, удалить или отключить данный параметр.%COLOR%[92m
@echo Если не используется PAE, удалить или отключить данный параметр.>> %logfile%
set timerStart=!time!
bcdedit /deletevalue nolowmem 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Устройства и оборудование %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Определяет, как 1МБ физической памяти потребляется HAL для смягчения повреждений BIOS во время переключения питания.%COLOR%[92m
set timerStart=!time!
bcdedit /set firstmegabytepolicy UseAll 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Использовать загрузочным приложениям поддержку BIOS для расширенного ввода с консоли.%COLOR%[92m
set timerStart=!time!
bcdedit /set extendedinput Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Устранить проблему с нехваткой ресурсов для устройств в диспетчере устройств.%COLOR%[92m
set timerStart=!time!
bcdedit /set configaccesspolicy DisallowMmConfig 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Процессоры и контроллеры APIC %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Задать число используемых потоков процессора.%COLOR%[92m
set timerStart=!time!
bcdedit /set numproc %NUMBER_OF_PROCESSORS% 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Включить максимальное число процессоров в системе.%COLOR%[92m
set timerStart=!time!
bcdedit /set maxproc Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Использовать только загрузочный ЦП на компьютере с более чем одним логическим процессором.%COLOR%[92m
set timerStart=!time!
bcdedit /set onecpu No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Включить использование физического APIC.%COLOR%[92m
set timerStart=!time!
bcdedit /set usephysicaldestination No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Включить использование устаревшего режима APIC, даже если процессоры и набор микросхем поддерживают расширенный режим APIC.%COLOR%[92m
set timerStart=!time!
bcdedit /set uselegacyapicmode No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Включить или отключить использование расширенного режима APIC, если он поддерживается. По умолчанию система использует расширенный режим APIC, если он доступен.%COLOR%[92m
set timerStart=!time!
bcdedit /set x2apicpolicy Enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 7)%COLOR%[36m Включить AVX инструкции в ОС.%COLOR%[92m
set timerStart=!time!
bcdedit /set xsavedisable 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 8)%COLOR%[36m Отключить некоторые ограничения памяти ядра. Вызывает сбои/циклы загрузки, если включен Intel Software Guard Extensions.%COLOR%[92m
set timerStart=!time!
bcdedit /set allowedinmemorysettings 0x0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 9)%COLOR%[36m Отключить принудительное шифрование FIPS.%COLOR%[92m
set timerStart=!time!
bcdedit /set forcefipscrypto No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 10)%COLOR%[36m Задать флаги конфигурации, специфические для процессора.%COLOR%[92m
set timerStart=!time!
bcdedit /set configflags 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Слой абстрагирования оборудования (HAL) и ядра (KERNEL) %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Отключить специальную точку останова слоя абстрагирования оборудования (HAL).%COLOR%[92m
set timerStart=!time!
bcdedit /set halbreakpoint No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Предварительно включите HPET в BIOS после применения параметра.%COLOR%[92m
set timerStart=!time!
bcdedit /deletevalue useplatformclock 1>> %logfile% 2>>&1
::bcdedit /set useplatformclock No 1>> %logfile% 2>>&1 TEST
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Сообщить ОС, что в системе присутствуют устаревшие устройства, например CMOS, контроллер клавиатуры и т.д.%COLOR%[92m
set timerStart=!time!
bcdedit /set forcelegacyplatform No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Включить расширенную временную синхронизацию (Legacy, Enhanced).%COLOR%[92m
set timerStart=!time!
bcdedit /set tscsyncpolicy Enhanced 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Отключить таймеры платформы в качестве счетчика производительности системы.%COLOR%[92m
set timerStart=!time!
bcdedit /set useplatformtick Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Включить динамические процессорные такты (+энергосбережение для ноутбуков).%COLOR%[92m
set timerStart=!time!
::bcdedit /set disabledynamictick Yes 1>> %logfile% 2>>&1 TEST
bcdedit /deletevalue disabledynamictick 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m VESA, PCI, VGA и TPM %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Блокировка PCI. Позволяет запретить PCI-устройствам выполнение динамического назначения IRQ и других ресурсов ввода-вывода.%COLOR%[92m
set timerStart=!time!
bcdedit /set usefirmwarepcisettings No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Отключить поддержку сообщений, сигнализируемых прерываний.%COLOR%[92m
set timerStart=!time!
bcdedit /set MSI Default 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Включить политику энтропии загрузки TPM и передать ее ядру. При использовании энтропии загрузки TPM заполняет генератор случайных чисел (RNG) ядра данными, полученными от TPM.%COLOR%[92m
set timerStart=!time!
bcdedit /set tpmbootentropy ForceEnable 1>> %logfile% 2>>&1
sc config TPM start= demand 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить режим VGA. Исправляет черный экран при загрузке на некоторых видеокартах.%COLOR%[92m
set timerStart=!time!
bcdedit /set novesa yes 1>> %logfile% 2>>&1
bcdedit /set novga yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Отключить встроенный контроль PCI Express (default, forcedisable).%COLOR%[92m
set timerStart=!time!
bcdedit /set pciexpress forcedisable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Драйверы %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Отключить службы аварийного управления для записи операционной системы.%COLOR%[92m
set timerStart=!time!
bcdedit /ems Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Отключить службы аварийного управления для приложения загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /bootems Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Отключить тестовый режим.%COLOR%[92m
set timerStart=!time!
bcdedit /set testsigning No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить проверку цифровой подписи драйверов.%COLOR%[92m
set timerStart=!time!
bcdedit /set nointegritychecks Yes 1>> %logfile% 2>>&1
bcdedit /set loadoptions DDISABLE_INTEGRITY_CHECKS 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Отключить отображение имен драйверов в процессе загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /set sos No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Экраны ошибок %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Отключить завершение работы после отображения экрана ошибки в течение 1 минуты.%COLOR%[92m
set timerStart=!time!
bcdedit /set bootshutdowndisabled Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Задать тип графического интерфейса при ошибках загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /set booterrorux Simple 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Отладка и логирование %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Отключить журнал загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /set bootlog No 1>> %logfile% 2>>&1
bcdedit /event Off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Формат журнала загрузки (0 = Default, 1 = Sha1).%COLOR%[92m
set timerStart=!time!
bcdedit /set measuredbootlogformat Default 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Отключить отладку.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить выделение памяти для тестирования производительности.%COLOR%[92m
set timerStart=!time!
bcdedit /set perfmem 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Исправить зависание при загрузке при включеном режиме отладки.%COLOR%[92m
set timerStart=!time!
bcdedit /set noumex Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Настройки низкоуровневой оболочки %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Отключить отладку гипервизора.%COLOR%[92m
set timerStart=!time!
bcdedit /set hypervisordebug No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Включить защиту от CVE-2018-3646 для виртуальных машин.%COLOR%[92m
set timerStart=!time!
bcdedit /set hypervisorschedulertype Core 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Включить загрузку гипервизора в системе для Hyper-V.%COLOR%[92m
set timerStart=!time!
bcdedit /set hypervisorlaunchtype Auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Управляет политикой IOMMU низкоуровневой оболочки. Значения: default, enable и disable.%COLOR%[92m
set timerStart=!time!
bcdedit /set hypervisoriommupolicy Enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Позволяет гипервизору использовать большее количество записей виртуального TLB.%COLOR%[92m
set timerStart=!time!
bcdedit /set hypervisoruselargevtlb Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Отключить безопасный режим памяти DMA и изоляцию ядер для машин Hyper-V. Предупреждение: включение режима может привести к сбою старых приложений и драйверов или даже к BSOD.%COLOR%[92m
set timerStart=!time!
bcdedit /set vsmlaunchtype Off 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Отключить изоляцию процессов через защитник Windows в виртуальном окружении.%COLOR%[92m
set timerStart=!time!
bcdedit /set isolatedcontext No 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Отображение %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[91m 1)%COLOR%[36m Определяет использование графики при возобновлении.%COLOR%[92m
set timerStart=!time!
bcdedit /set bootux Disabled 1>> %logfile% 2>>&1
bcdedit /set bootuxdisabled Yes 1>> %logfile% 2>>&1
bcdedit /set nobootuxtext Yes 1>> %logfile% 2>>&1
bcdedit /set nobootuxprogress Yes 1>> %logfile% 2>>&1
bcdedit /set nobootuxfade Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Время перехода анимации при возобновлении.%COLOR%[92m
set timerStart=!time!
bcdedit /set bootuxtransitiontime 5 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Включить отображение растрового изображения с высоким разрешением вместо отображения экрана загрузки Windows и анимации.%COLOR%[92m
set timerStart=!time!
bcdedit /set quietboot Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Включить текстовый режим загрузки через F8 (0 = Legacy, 1 = Standard).%COLOR%[92m
set timerStart=!time!
bcdedit /set bootmenupolicy Legacy 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Отключить графический режим для загрузочных приложений.%COLOR%[92m
set timerStart=!time!
bcdedit /set graphicsmodedisabled Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Разрешить приложениям загрузки использовать максимальный графический режим, предоставляемый встроенным ПО.%COLOR%[92m
set timerStart=!time!
bcdedit /set highestmode Yes 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 7)%COLOR%[36m Отключить логотип загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000067 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 8)%COLOR%[36m Отключить круг анимации загрузки.%COLOR%[92m
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000069 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 9)%COLOR%[36m Отключить загрузочные сообщения.%COLOR%[92m
set timerStart=!time!
bcdedit /set {globalsettings} custom:16000068 true 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Windows Defender, SmartScreen и Edge %COLOR%[0m
@echo Windows Defender, SmartScreen и Edge 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1)%COLOR%[36m Отключить Windows Defender Antivirus.%COLOR%[92m
set timerStart=!time!
powershell "Set-MpPreference -EnableControlledFolderAccess Disabled -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Set-MpPreference -EnableNetworkProtection Disabled -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Set-MpPreference -PUAProtection Disabled -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
setx /m MP_FORCE_USE_SANDBOX 0 1>> %logfile% 2>>&1
bcdedit /set disableelamdrivers Yes 1>> %logfile% 2>>&1
net stop windefend 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "AllowNonAdminFunctionality" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%disable_svc_hard% reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\UX Configuration" /v "AllowNonAdminFunctionality" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
sc config Wdnsfltr start=disabled 1>> %logfile% 2>>&1
call :disable_svc_hard wscsvc
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{13F6A0B6-57AF-4BA7-ACAA-614BC89CA9D8}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{13F6A0B6-57AF-4BA7-ACAA-614BC89CA9D8}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{94F35585-C5D7-4D95-BA71-A745AE76E2E2}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{94F35585-C5D7-4D95-BA71-A745AE76E2E2}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\TypeLib\{8C389764-F036-48F2-9AE2-88C260DCF43B}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\TypeLib\{8C389764-F036-48F2-9AE2-88C260DCF43B}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{FDA74D11-C4A6-4577-9F73-D7CA8586E10D}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\Wow6432Node\CLSID\{FDA74D11-C4A6-4577-9F73-D7CA8586E10D}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /v "" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecHealthUI.exe" /v "Debugger" /t REG_SZ /d "%windir%\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
taskkill /f /im SecurityHealthSystray.exe 1>> %logfile% 2>>&1
%superuser% sc config SecurityHealthService start=disabled 1>> %logfile% 2>>&1
sc config Sense start=disabled 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" 1>> %logfile% 2>>&1
powershell "Disable-WindowsOptionalFeature -online -FeatureName 'Windows-Defender-ApplicationGuard' -NoRestart -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
takeown /f "%PROGRAMDATA%\Microsoft\Windows Defender\Platform" /a /r /d y 1>> %logfile% 2>>&1
icacls %PROGRAMDATA%"\Microsoft\Windows Defender\Platform\*MsMpEng.exe" /deny SYSTEM:(RX) /t /c /deny Администраторы:(RX) /t /c /deny Пользователи:(RX) /t /c 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
@echo %COLOR%[91m 2)%COLOR%[36m Отключить SmartScreen.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows Security Health\State" /v "AccountProtection_MicrosoftAccount_Disconnected" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows Security Health\State" /v "AppAndBrowser_EdgeSmartScreenOff" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t "REG_SZ" /d "Off" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "SmartScreenEnabled" /t "REG_SZ" /d "Off" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableHHDEP" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
@echo %COLOR%[91m 3)%COLOR%[36m Отключить Microsoft Edge.%COLOR%[92m
set timerStart=!time!
taskkill /f /im "browser_broker.exe" 1>> %logfile% 2>>&1
taskkill /f /im "RuntimeBroker.exe" 1>> %logfile% 2>>&1
taskkill /f /im "MicrosoftEdge.exe" 1>> %logfile% 2>>&1
taskkill /f /im "MicrosoftEdgeCP.exe" 1>> %logfile% 2>>&1
taskkill /f /im "MicrosoftEdgeSH.exe" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
move "%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" "%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe_old" 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe_old" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MicrosoftEdge.exe" /v "Debugger" /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe" /v "Debugger" /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
del /f /q "%AppData%\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
timeout /t 3 /nobreak | break
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Отчеты и реклама %COLOR%[0m
@echo Отчеты и реклама 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1)%COLOR%[36m Отключить отчеты об ошибках Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Отключить очередь сообщений об ошибках.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Отключить советы Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\WindowsInkWorkspace" /v "AllowSuggestedAppsInWindowsInkWorkspace" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Отключить отображение рекламы, предложения приложений и их автоматическую установку.%COLOR%[92m
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
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314559Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "Set-ItemProperty -Path (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current').PSPath -Name 'Data' -Type Binary -Value (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current').Data[0..15] -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
sc stop ShellExperienceHost 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Запретить приложениям использовать рекламный идентификатор.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Запретить веб-сайтам предоставлять местную информацию за счет доступа к списку языков.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Сетевая оптимизация %COLOR%[0m
@echo Сетевая оптимизация 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1)%COLOR%[36m Применение настроек сетевой оптимизации.%COLOR%[92m
set timerStart=!time!
netsh winsock reset 1>> %logfile% 2>>&1
ipconfig /flushdns 1>> %logfile% 2>>&1
netsh interface ip delete arpcache 1>> %logfile% 2>>&1
del /q /s /f "%Appdata%\Macromedia\Flashp~1">> %logfile% 2>>&1
rd /s /q "%Appdata%\Macromedia\Flashp~1">> %logfile% 2>>&1
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
reg add "HKLM\SYSTEM\CurrentControlSet\Services\iphlpsvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2)%COLOR%[36m Отключить эвристику масштабирования, чтобы предотвратить изменение уровня автонастройки окна.%COLOR%[92m
set timerStart=!time!
netsh int tcp set heuristics disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3)%COLOR%[36m Установить 2 попытки восстановления соединения.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global maxsynretransmissions=2 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4)%COLOR%[36m Включить прямой доступ к кешу.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global dca=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5)%COLOR%[36m Включить отказоустойчивость без SACK RTT.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global nonsackrttresiliency=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6)%COLOR%[36m Установить начальное окно перегрузки на 10.%COLOR%[92m
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName Internet -InitialCongestionWindow 10" 1>> %logfile% 2>>&1
netsh int tcp set supplemental template=Custom icw=10 1>> %logfile% 2>>&1
netsh int tcp set supplemental template=Internet icw=10 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 7)%COLOR%[36m Отключить защиту от давления памяти.%COLOR%[92m
set timerStart=!time!
netsh int tcp set security mpp=disabled 1>> %logfile% 2>>&1
netsh int tcp set security profiles=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 8)%COLOR%[36m Установить для параметра Maximum Transmission Unit (MTU) значение 1492.%COLOR%[92m
set timerStart=!time!
set interfaceName=%*
netsh int ipv4 set subinterface "!interfaceName!" mtu=1492 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 9)%COLOR%[36m Установить TTL на 64.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d "64" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 10)%COLOR%[36m Установить поддержку пользовательских портов до 65534.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d "65534" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 11)%COLOR%[36m Установить время ожидания TCP до 30.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 12)%COLOR%[36m Установить приоритеты разрешения хоста.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d "5" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d "6" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d "7" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 13)%COLOR%[36m Установить QoS Reserved Bandwidth на 0.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 14)%COLOR%[36m Отключить эвристику масштабирования.%COLOR%[92m
set timerStart=!time!
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableHeuristics" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 15)%COLOR%[36m Включить масштабирование окна RFC 1323.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 16)%COLOR%[36m Установить размер пакета UDP на 1280.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "MaximumUdpPacketSize" /t REG_DWORD /d "1280" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 17)%COLOR%[36m Задать параметры времени кэширования DNS.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 18)%COLOR%[36m Получение идентификатора устройства для настройки параметров сетевых адаптеров.%COLOR%[92m
set timerStart=!time!
for /F "delims=" %%I in ('%SystemRoot%\System32\reg.exe query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /s /v ProviderName 2^>nul') do call :setAdapters "%%I"
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 19)%COLOR%[36m Установить алгоритмы Nagle для сетевых интерфейсов.%COLOR%[92m
set timerStart=!time!
for /f "tokens=3 delims=_ " %%I in ('net config rdr ^| find /i "tcpip"') do (
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%I" /v TcpAckFrequency /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%I" /v TCPNoDelay /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%I" /v TcpDelAckTicks /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%I" /v TcpAckFrequency /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%I" /v TCPNoDelay /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters\Interfaces\%%I" /v TcpDelAckTicks /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
)
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 20)%COLOR%[36m Запретить весь NTLM траффик. Предупреждение: блокировка запросов NTLM нарушает работу RDP и Samba.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t "REG_DWORD" /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t "REG_DWORD" /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 21)%COLOR%[36m Запретить доступ в интернет для DRM Windows Media.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 22)%COLOR%[36m Отключить общий доступ к проигрывателю Windows Media.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 23)%COLOR%[36m Не ждать наличия сети при запуске компьютера и входе в сеть для рабочих групп.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "SyncForegroundPolicy" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 24)%COLOR%[36m Отключить тестирование сетевого подключения.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" /v "NoActiveProbe" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 25)%COLOR%[36m Отключить одноранговую сеть.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Peernet" /v "Disabled" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 26)%COLOR%[36m Отключить лимитное подключение и использование данных сети.%COLOR%[92m
set timerStart=!time!
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "3G" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "4G" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Default" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
powershell "Get-ChildItem 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DusmSvc\Profiles\*\*' | Set-ItemProperty -Name UserCost -Value 0" 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DusmSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 27)%COLOR%[36m Исправить некоторые настройки для VPN канала.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "AssumeUDPEncapsulationContextOnSendRule" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters" /v "DisableIKENameEkuCheck" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters" /v "NegotiateDH2048_AES256" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 28)%COLOR%[36m Отключить привязку QoS.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_pacer" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 29)%COLOR%[36m Отключить использование пакетов QoS.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterQos -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
sc config Psched start=disabled 1>> %logfile% 2>>&1
sc config QWAVEdrv start=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 30)%COLOR%[36m Включить маркировку DSCP для пакетов QoS.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Application DSCP Marking Request" /t REG_SZ /d "Allowed" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Do not use NLA" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
netsh winsock set autotuning on 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 31)%COLOR%[36m Отключить захват NDIS.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_ndiscap" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 32)%COLOR%[36m Отключить протокол обнаружения локальных каналов (LLDP).%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_lldp" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 33)%COLOR%[36m Отключить обнаружение топологии локального канала (LLTD).%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_lltdio" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_rspndr" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 34)%COLOR%[36m Отключить сетевой стек IPv6.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterBinding -Name * -ComponentID "ms_tcpip6" -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
sc config Tcpip6 start=disabled 1>> %logfile% 2>>&1
sc config wanarpv6 start=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 35)%COLOR%[36m Отключить механизм, позволяющий передавать IPv6-пакеты через IPv4-сети.%COLOR%[92m
set timerStart=!time!
powershell "Set-Net6to4Configuration -State Disabled -AutoSharing Disabled -RelayState Disabled -RelayName '6to4.ipv6.microsoft.com' -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
netsh int 6to4 set state state=disabled undoonstop=disabled 1>> %logfile% 2>>&1
netsh int 6to4 set routing routing=disabled sitelocals=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 36)%COLOR%[36m Отключить Teredo и протокол 6to4.%COLOR%[92m
set timerStart=!time!
netsh int ipv6 isatap set state disabled 1>> %logfile% 2>>&1
netsh int teredo set state disabled 1>> %logfile% 2>>&1
netsh int ipv6 6to4 set state state=disabled undoonstop=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 37)%COLOR%[36m Включить экспериментальную автонастройку и провайдер перегрузки CTCP (для стабильных сетей рекомендуется выставить cubic).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "Tcp Autotuning Level" /t REG_SZ /d "Experimental" /f 1>> %logfile% 2>>&1
netsh int tcp set global autotuning=experimental 1>> %logfile% 2>>&1
%superuser% powershell "Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider CTCP" 1>> %logfile% 2>>&1
%superuser% powershell "Set-NetTCPSetting -SettingName Internet -CongestionProvider CTCP" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 38)%COLOR%[36m Настройка медленного старта TCP для отправки 10 кадров.%COLOR%[92m
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName Internet -InitialCongestionWindow 10" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 39)%COLOR%[36m Отключить разгрузку TCP Chimney.%COLOR%[92m
set timerStart=!time!
powershell "Set-NetOffloadGlobalSetting -Chimney Disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 40)%COLOR%[36m Отключить объединение пакетов. Полезно для игр и Wi-Fi адаптеров.%COLOR%[92m
set timerStart=!time!
powershell "Set-NetOffloadGlobalSetting -PacketCoalescingFilter disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 41)%COLOR%[36m Отключить объединение сегментов приема.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global rsc=disabled 1>> %logfile% 2>>&1
powershell "Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing disabled" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 42)%COLOR%[36m Включить отправку и получение Weak Host и настройка IP политик.%COLOR%[92m
set timerStart=!time!
powershell "Get-NetAdapter -Name * -IncludeHidden | Set-NetIPInterface -WeakHostSend Enabled -WeakHostReceive Enabled -RetransmitTimeMs 0 -Forwarding Disabled -EcnMarking Disabled -AdvertiseDefaultRoute Disabled -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 43)%COLOR%[36m Включить явное уведомление о перегрузке.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global ecncapability=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 44)%COLOR%[36m Включить отметку времени RFC.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global timestamps=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 45)%COLOR%[36m Выставить RTO в 2.5 секунды.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global initialRto=2500 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 46)%COLOR%[36m Выставить минимальное RTO.%COLOR%[92m
set timerStart=!time!
powershell "Set-NetTCPSetting -SettingName Internet -MinRto 300" 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 47)%COLOR%[36m Включить Fastopen.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global fastopen=enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 48)%COLOR%[36m Отключить HyStart.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global hystart=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 49)%COLOR%[36m Отключить TCP Pacing.%COLOR%[92m
set timerStart=!time!
netsh int tcp set global pacingprofile=off 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 50)%COLOR%[36m Выставить минимальное MTU на 576.%COLOR%[92m
set timerStart=!time!
netsh int ip set global minmtu=576 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 51)%COLOR%[36m Отключить метку IP-потока.%COLOR%[92m
set timerStart=!time!
netsh int ip set global flowlabel=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 52)%COLOR%[36m Отключить перезапуск окна TCP.%COLOR%[92m
set timerStart=!time!
netsh int tcp set supplemental Internet enablecwndrestart=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 53)%COLOR%[36m Отключить перенаправления ICMP.%COLOR%[92m
set timerStart=!time!
netsh int ip set global icmpredirects=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 54)%COLOR%[36m Отключить многоадресную пересылку.%COLOR%[92m
set timerStart=!time!
netsh int ip set global multicastforwarding=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 55)%COLOR%[36m Отключить групповые перенаправленные фрагменты.%COLOR%[92m
set timerStart=!time!
netsh int ip set global groupforwardedfragments=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 56)%COLOR%[36m Отключить раздувание TCP.%COLOR%[92m
set timerStart=!time!
netsh int tcp set security mpp=disabled profiles=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 57)%COLOR%[36m Отключить эвристику TCP.%COLOR%[92m
set timerStart=!time!
netsh int tcp set heur forcews=disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 58)%COLOR%[36m Отключить управление питанием сетевого адаптера.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterPowerManagement -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 59)%COLOR%[36m Включить разгрузку контрольной суммы.%COLOR%[92m
set timerStart=!time!
powershell "Enable-NetAdapterChecksumOffload -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 60)%COLOR%[36m Отключить разгрузку задачи инкапсулированного пакета.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterEncapsulatedPacketTaskOffload -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 61)%COLOR%[36m Включить разгрузку IPsec.%COLOR%[92m
set timerStart=!time!
powershell "Enable-NetAdapterIPsecOffload -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 62)%COLOR%[36m Отключить разгрузку большой отправки.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterLso -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 63)%COLOR%[36m Включить PacketDirect для снижения джиттера.%COLOR%[92m
set timerStart=!time!
powershell "Enable-NetAdapterPacketDirect -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 64)%COLOR%[36m Отключить объединение сегментов приема.%COLOR%[92m
set timerStart=!time!
powershell "Disable-NetAdapterRsc -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 65)%COLOR%[36m Включить масштабирование сегментов приема.%COLOR%[92m
set timerStart=!time!
powershell "Enable-NetAdapterRss -Name * -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
netsh interface tcp set heuristics wsh=enabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 66)%COLOR%[36m Выполнить оптимизацию интернет браузеров (запущенный браузер автоматически закроется).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v "explorer.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v "iexplore.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v "explorer.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v "iexplore.exe" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN" /V "DNSPreresolution" /t REG_DWORD /d "8" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN" /V "Use_Async_DNS" /t REG_SZ /d "yes" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V "DnsCacheEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V "DnsCacheEntries" /t REG_DWORD /d "200" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V "DnsCacheTimeout" /t REG_DWORD /d "15180" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /V "EnablePreBinding" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext" /V "DisableAddonLoadTimePerformanceNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext" /V "NoFirsttimeprompt" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /V "DisableInPrivateBlocking" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /V "StartMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::start "" rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351 (очистка истории и кэша паролей браузера)
regsvr32 /s actxprxy 1>> %logfile% 2>>&1
del /q /s /f "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Intern~1" 1>> %logfile% 2>>&1
rd /s /q "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Intern~1" 1>> %logfile% 2>>&1
del /q /s /f "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Windows\History" 1>> %logfile% 2>>&1
rd /s /q "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Windows\History" 1>> %logfile% 2>>&1
del /q /s /f "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Tempor~1" 1>> %logfile% 2>>&1
rd /s /q "%HomeDrive%\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Tempor~1" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\firefox.exe" /V "UseLargePages" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\chrome.exe" /V "UseLargePages" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
cmd.exe /c "%~dp0\..\SpeedyFox\speedyfox.exe "/Firefox:all" "/Chrome:all" "/Skype:all" "/Thunderbird:all" "/Opera:all" "/Vivaldi:all" "/Yandex Browser:all" "/Cyberfox:all" "/FossaMail:all" "/Pale Moon:all" "/SeaMonkey:all"" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Настройка уведомлений %COLOR%[0m
@echo Настройка уведомлений 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1) %COLOR%[36m Отключить уведомления Центра действий.%COLOR%[92m
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
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WindowsTip" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2) %COLOR%[36m Отключить уведомления поставщика синхронизации.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3) %COLOR%[36m Отключить значок и уведомления центра поддержки.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "UseActionCenterExperience" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAHealth" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4) %COLOR%[36m Отключить уведомления службы поддержки.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5) %COLOR%[36m Отключить уведомления фокусировки внимания.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\QuietHours" /v "Enabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\QuietHours" /v "AllowCalls" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Notifications\Data" /v "0D83063EA3BF1C75" /t REG_BINARY /d "3F00000000000000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6) %COLOR%[36m Отключить уведомления Windows Defender, файервола и центра обновлений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "AntiVirusDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "AntiVirusOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "FirewallDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "FirewallOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "AntiSpywareDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SOFTWARE\Microsoft\Security Center\Svc" /v "AntiSpywareOverride" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "UpdatesDisableNotify" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 7) %COLOR%[36m Отключить историю уведомлений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "ClearTilesOnExit" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Настройка обновления Windows%COLOR%[0m
@echo Настройка обновления Windows 1>> %logfile% 2>>&1
echo ••••••••••••
echo •••••••••••• 1>> %logfile% 2>>&1
@echo %COLOR%[91m 1) %COLOR%[36m Отключить обновление драйверов через центр обновления Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate" /v "Value" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 2) %COLOR%[36m Разрешить получение обновлений для других продуктов Microsoft через центр обновления Windows.%COLOR%[92m
set timerStart=!time!
powershell "(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '')" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 3) %COLOR%[36m Отключить автоматическую загрузку с центра обновления Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t "REG_DWORD" /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 4) %COLOR%[36m Отключить автоматическую загрузку обновлений приложений из Магазина.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 5) %COLOR%[36m Отключить автоматическое обновление карт.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\Maps" /v "AutoUpdateEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 6) %COLOR%[36m Отключить автоматическую перезагрузку и уведомление после завершения обновления.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "RestartNotificationsAllowed2" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" /v "Debugger" /t "REG_SZ" /d "cmd.exe" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 7) %COLOR%[36m Отключить ночное пробуждение для автоматического обслуживания и обновлений Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUPowerManagement" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[91m 8) %COLOR%[36m Отключить автоматический перезапуск после входа в систему при установке обновлений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableAutomaticRestartSignOn" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
@echo %COLOR%[7m Разное %COLOR%[0m
echo ••••••••••••
@echo %COLOR%[36m Применение параметров для отключения высоких задержек DPC/ISR.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Принудительное отключение логгирования.%COLOR%[92m
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
powershell "Get-AutologgerConfig | Set-AutologgerConfig -Start 0 -InitStatus 0 -Confirm:$False -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WUDF" /v "LogLevel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Credssp" /v "DebugLogLevel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Применение политики для ресурсов CPU.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Применение параметров для ускорения ОС и оптимизации 3D игр.%COLOR%[92m
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
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "DisableVidMemVBs" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MMX Fast Path" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "FlipNoVsync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\DirectDraw" /v "EmulationOnly" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
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
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GraphicsPerfSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "AlpcWakePolicy" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xusb22\Parameters" /v "IoQueueWorkItem" /t REG_DWORD /d "10" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\bam" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dam" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SystemUsageReportSvc_QUEENCREEK" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Intel(R) SUR QC SAM" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kdnic" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LMS" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MEIx64" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
sc config Beep start=disabled 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WmiPrvSE.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RuntimeBroker.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\fontdrvhost.exe" /v "MaxLoaderThreads" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Применение оптимизации службы планировщика классов Multimedia для игр (MMCSS).%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Применение настроек оптимизации для SSD дисков.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Применение настроек оптимизации электропитания.%COLOR%[92m
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
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отобразить все скрытые пункты в схемах управления питанием.%COLOR%[92m
set timerStart=!time!
for /f %%k in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings" /s /v "Attributes"^|FindStr HKEY_') do (
reg add "%%k" /v "Attributes" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
)
powercfg -attributes SUB_DISK 6b013a00-f775-4d61-9036-a62f7e7a6a5b -ATTRIB_HIDE 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить сбалансированную схему управления питанием.%COLOR%[92m
set timerStart=!time!
powercfg /setactive scheme_balanced 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отключить Game DVR, службы Xbox, Logitech Gaming и Razer Game Scanner.%COLOR%[92m
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
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\System\GameConfigStore\Children" /f 1>> %logfile% 2>>&1
reg delete "HKCU\System\GameConfigStore\Parents" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\XblGameSave\XblGameSaveTask" 1>> %logfile% 2>>&1
takeown /f "%SystemRoot%\System32\GameBarPresenceWriter.exe" /a 1>> %logfile% 2>>&1
icacls "%SystemRoot%\System32\GameBarPresenceWriter.exe" /grant:r Администраторы:F /c 1>> %logfile% 2>>&1
taskkill /f /im "GameBarPresenceWriter.exe" 1>> %logfile% 2>>&1
move "%SystemRoot%\System32\GameBarPresenceWriter.exe" "%SystemRoot%\System32\GameBarPresenceWriter.old" 1>> %logfile% 2>>&1
taskkill /f /im "bcastdvr.exe" 1>> %logfile% 2>>&1
icacls "%SystemRoot%\System32\bcastdvr.exe" /grant:r Администраторы:F /c 1>> %logfile% 2>>&1
move "%SystemRoot%\System32\bcastdvr.exe" "%SystemRoot%\System32\bcastdvr.old" 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LogiRegistryService" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Razer Game Scanner Service" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отключить службу поиска и Cortana.%COLOR%[92m
set timerStart=!time!
taskkill /f /im "SearchUI.exe" 1>> %logfile% 2>>&1
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
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" /v "State" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Experience" /v "AllowCortana" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "Get-AppxPackage 'Microsoft.549981C3F5F10' -AllUsers | Remove-AppxPackage -AllUsers -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Cortana.exe" /v "Debugger" /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{2765E0F4-2918-4A46-B9C9-43CDD8FCBA2B}" /t REG_SZ /d "BlockCortana|Action=Block|Active=TRUE|Dir=Out|App=C:\Windows\systemapps\microsoft.windows.cortana_cw5n1h2txyewy\searchui.exe|Name=Search and Cortana application|" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{2765E0F4-2918-4A46-B9C9-43CDD8FCBA2B}" /t REG_SZ /d "BlockCortana|Action=Block|Active=TRUE|Dir=Out|App=C:\Windows\systemapps\microsoft.windows.cortana_cw5n1h2txyewy\searchui.exe|Name=Search and Cortana application|" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отключить Wi-Fi Sense (данный функционал позволяет делиться доступом к своим сетям Wi-Fi со своими контактами и автоматически подключаться к сетям друзей).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "Value" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "WiFISenseAllowed" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
sc delete Sense 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Удалить остатки IFEO.%COLOR%[92m
set timerStart=!time!
powershell "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' -Name * -Force -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить сжатие памяти и предзагрузку приложении в ОС.%COLOR%[92m
set timerStart=!time!
powershell "Disable-MMAgent -MemoryCompression -ApplicationPreLaunch -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить средства защиты процессов и ядра.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "22222222222222222002000000200000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "20000020202022220000000000000000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "foreach ($mit in (Get-Command -Name Set-ProcessMitigation).Parameters['Disable'].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $mit.ToString().Replace(' \', '\').Replace('`n\', '\') -ErrorAction SilentlyContinue}" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Использовать приоритет реального времени для csrss.exe%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "KernelSEHOPEnabled" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить память, управляемую ядром и отключить исправления Meltdown/Spectre.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Запретить загрузку системных файлов, таких как ядро и драйверы оборудования в виртуальную память.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить объединение страниц памяти, таких как совместное использование страниц для изображений, копирование при записи для страниц данных и сжатие.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingCombining" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить большой системный кэш, чтобы исправить микрофризы.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить дополнительные средства защиты NTFS/ReFS.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить временную метку 0 мс. Для неоптимизированных систем рекомендуется выставить параметр 1.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить разделение процесса svchost.exe в диспетчере задач.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "33554432" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Browser" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcaSvc" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RapiMgr" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RemoteAccess" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WAS" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WcesComm" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Предотвратить ошибки при отключении драйверов.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "ErrorControl" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Services\fvevol" /v "ErrorControl" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}" /v "UpperFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e967-e325-11ce-bfc1-08002be10318}" /v "LowerFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{6bdd1fc6-810f-11d0-bec7-08002be2092f}" /v "UpperFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
reg add "HKLM\System\CurrentControlSet\Control\Class\{71a27cdd-812a-11d0-bec7-08002be2092f}" /v "LowerFilters" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить службу Superfetch.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\EnableSuperfetch" /v "DIPM" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить службу индексации поиска.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
sc stop WSearch 1>> %logfile% 2>>&1
%superuser% cmd.exe /c del /f /q C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить использование корзины. Файлы будут удаляться окончательно (полезно для SSD дисков).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecycleFiles" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Увеличение объема используемой памяти для файловой системы NTFS.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить поставщика алгоритмов помощника оборудования.%COLOR%[92m
set timerStart=!time!
sc config cnghwassist start=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить помощника по совместимости программ.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить удаленный помощник. Не применимо к серверу (если удаленный помощник не установлен явно).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powershell "Get-WindowsCapability -Online | Where-Object { $_.Name -like 'App.Support.QuickAssist*' } | Remove-WindowsCapability -Online -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить обновление групповой политики во время загрузки Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousUserGroupPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousMachineGroupPolicy" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить службу отчета об ошибках.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить предвыборку для ускорения запуска Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить TRIM оптимизацию SSD дисков.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" /v "Enable" /t "REG_SZ" /d "Y" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" /v "EnableAutoLayout" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
fsutil behavior set DisableDeleteNotify 0 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить создание последней удачной конфигрурации загрузки.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ReportBootOk" /t "REG_SZ" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить проверку диска при запуске Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Автоматически завершать не отвечающие приложения.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t "REG_SZ" /d "5000" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t "REG_SZ" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowBlockingAppsAtShutdown" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить лишние апплеты в расширенном запуске.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ShellServiceObjectDelayLoad" /v "WebCheck" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "VMApplet" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить обнаружение UPnP устройств в сети.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SSDPSRV" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить контроль системных событий.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить отправку отчетов об ошибках.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить установку компонентов языковых пакетов из интернета.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\LanguageComponentsInstaller\Installation" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить службы диагностики.%COLOR%[92m
set timerStart=!time!
%superuser% reg add "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
%superuser% reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkServiceTriggers\Triggers\bc90d167-9470-4139-a9ba-be0bbbf5b74d" /v "795B6BF9-97B6-4F89-BD8D-2F42BBBE996E" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkServiceTriggers\Triggers\bc90d167-9470-4139-a9ba-be0bbbf5b74d" /v "945693c4-3648-4966-b2aa-37d66e24495f" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автозапуск CD-DVD и съемных устройств.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ShellHWDetection" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Не отображать подробные сообщения о состоянии при запуске и завершении работы Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить систему авто-выравнивания звука.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio" /v "UserDuckingPreference" /t REG_DWORD /d "3" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выключить функцию Время последнего доступа.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
fsutil behavior set DisableLastAccess 1 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить широкиие контекстные меню.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\FlightedFeatures" /v "ImmersiveContextMenu" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить миниатюры сетевых папок.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "DisableThumbnailsOnNetworkFolders" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать буквы дисков перед именем дисков.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowDriveLettersFirst" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Увеличить максимальное количество рабочих потоков.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellTaskScheduler" /v "MaxWorkerThreadsPerScheduler" /t REG_DWORD /d "255" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить автозавершение в адресной строке и автоматический ввод в поле поиска.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TypeAhead" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" /v "Append Completion" /t "REG_SZ" /d "Yes" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить сворачивание окон при встряхивании (Aero Shake).%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автоматическое обнаружение типа папок.%COLOR%[92m
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Classes\Local Settings\SOFTWARE\Microsoft\Windows\Shell\Bags" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\SOFTWARE\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установить имя новой папки и ярлыка как _ .%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "RenameNameTemplate" /t "REG_SZ" /d "_" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "CopyNameTemplate" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "CopyNameTemplate" /t "REG_SZ" /d "%%s_" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Не добавлять суффикс - Ярлык к имени созданного ярлыка.%COLOR%[92m
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "ShortcutNameTemplate" /t "REG_SZ" /d "%%s.lnk" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить стрелку с ярлыков, файлов и сетевых ярлыков.%COLOR%[92m
set timerStart=!time!
xcopy %~dp0Blank.ico %SystemRoot% /h /c /y 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /t REG_SZ /d "%SystemRoot%\Blank.ico,0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "77" /t REG_SZ /d "%SystemRoot%\Blank.ico,0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить режим планшета.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAppsVisibleInTabletMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell" /v "ConvertibleSlateModePromptPreference" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить живые плитки.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить запрос Как вы хотите открыть этот файл.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть последние добавленные приложения.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecentlyAddedApps" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Разрешить очистку последних файлов при выходе.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ClearRecentDocsOnExit" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить создание списков последних использованных элементов (MRU), таких как меню Последние элементы в меню Пуск, списки переходов и ярлыки в нижней части меню Файл в приложениях.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocs" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить поиск Bing в меню Пуск.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить создание файла подкачки swapfile.sys для приложении и освободить 256 МБ дискового пространства.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SwapfileControl" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить 60 сек. ожидание при первом входе в систему.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "FSIASleepTimeInMs" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить несуществующие ярлыки запуска.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "table30.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "fsquirt.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "dfshim.dll" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "setup.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "install.exe" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" /v "cmmgr32.exe" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить предупреждение системы безопасности при открытии файлов из интернета.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Environment" /v "SEE_MASK_NOZONECHECKS" /t REG_SZ /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить отображение графического пароля.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "BlockDomainPicturePassword" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить историю активности в Представлении задач.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить функции датчика, такие как автоматический поворот экрана.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить функцию определения местоположения и скрипты для функции определения местоположения.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить историю недавних документов и часто используемых папок.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить USB порт после безопасного отключения USB-устройства.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbhub\HubG" /v "DisableOnSoftRemove" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableRemovableDriveIndexing" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить Kernel из черного списка.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\BlockList\Kernel" /va /reg:64 /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить DPC Watchdog.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить экран блокировки.%COLOR%[92m
set timerStart=!time!
taskkill /f /im "LockApp.exe" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData" /v "AllowLockScreen" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Настроить компьютер на полное выключение.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /v "PowerdownAfterShutdown" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автоматическое обслуживание.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить фоновые приложения.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить биометрические функции.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics\Credential Provider" /v "Enabled" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к информации об аккаунте.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessAccountInfo" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить приложениям доступ к уведомлениям.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessNotifications" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к календарю.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCalendar" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к истории звонков.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCallHistory" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к задачам.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessTasks" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к видео.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к камере.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCamera" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к несопряженным устройствам.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsSyncWithDevices" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к контактам.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessContacts" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к диагностике.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsGetDiagnosticInfo" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к документам.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к изображениям.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к радио.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessRadios" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к почте.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessEmail" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к файловой системе.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к вводу взглядом.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessGazeInput" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\gazeInput" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к геолокации.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к обмену сообщениями.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMessaging" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить доступ приложениям к микрофону.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMicrophone" /t REG_DWORD /d "2" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t "REG_SZ" /d "Deny" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить эксперименты.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "value" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить историю файлов.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\FileHistory" /v "Disabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить гибернацию и быстрый запуск.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowHibernateOption" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
powercfg /h on 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить спящий режим и кнопку Sleep на клавиатуре.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
powercfg /X standby-timeout-ac 0 1>> %logfile% 2>>&1
powercfg /X standby-timeout-dc 0 1>> %logfile% 2>>&1
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 1>> %logfile% 2>>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить предложение средства удаления вредоносных программ через центр обновления Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автоматическую перезагрузку при сбое системы (BSOD).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "AutoReboot" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить низкий уровень UAC (контроль учетных записей). Полное отключение приведет к поломке некоторых приложений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить предотвращение выполнения данных (DEP) для Internet Explorer.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DEPOff" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить проверку отзыва сертификатов и включить их прозрачность.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers" /v "authenticodeenabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers" /v "TransparentEnabled" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить обратную связь с пером.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\TabletPC" /v "TurnOffPenFeedback" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить задержку запуска Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Ускорить вход в систему.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\AppEvents\Schemes" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отключить отправку и синхронизацию файлов с облаком.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
::@echo %COLOR%[36m Отключить файервол. После отключения возможно не будет работать файервол в сторонней антивирусной программе.%COLOR%[92m
::set timerStart=!time!
::reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v "EnableFirewall" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
::netsh advfirewall firewall set rule group="Network Discovery" new enable=No 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
::reg delete "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f 1>> %logfile% 2>>&1
::netsh advfirewall set allprofiles state off 1>> %logfile% 2>>&1
::sc config MpsSvc start=disabled 1>> %logfile% 2>>&1
::sc config mpsdrv start=disabled 1>> %logfile% 2>>&1
::set timerEnd=!time!
call :timer
::@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
::echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Добавление дополнительных правил файервола для усиления защиты ОС.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установить файл Hosts от StevenBlack, блокирующий рекламу и телеметрию.%COLOR%[92m
set timerStart=!time!
copy "%SystemRoot%\System32\drivers\etc\hosts" "%~dp0\..\..\Backup\hosts" 1>> %logfile% 2>>&1
powershell "Invoke-WebRequest 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' -OutFile '%SystemRoot%\System32\drivers\etc\hosts' -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Добавление черного списка телеметрии в файл hosts и правила файервола.%COLOR%[92m
set timerStart=!time!
powershell -ExecutionPolicy Bypass -file "%~dp0BlacklistTelemetry.ps1" -WarningAction SilentlyContinue 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Добавление AdGuard DoH провайдеров для фильтрации рекламы. DoH протокол обладает более высокой надёжностью по сравнению с DNSCrypt.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Отключить обратную связь Windows.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /f 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Feedback\Siuf\DmClient" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Запретить приложениям на других устройствах запускать приложения и отправлять сообщения на этом устройстве.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Не предлагать способ завершения настройки устройства.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Не предлагать индивидуальный подход, основанный на настройках диагностических данных.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать значок «Этот компьютер» на рабочем столе.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать расширения файлов.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать конфликты слияния папок.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideMergeConflicts" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Запретить смену регистра имен файлов в проводнике.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontPrettyPath" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить Библиотеки из панели навигации проводника.%COLOR%[92m
set timerStart=!time!
reg delete "HKCU\SOFTWARE\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" /v "System.IsPinnedToNameSpaceTree" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить восстановление открытых окон проводника при входе в систему.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "PersistBrowsers" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть кнопку Люди на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показывать секунды на часах панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отображать маленькие значки на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Открывать проводник для Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Запускать окна проводника как отдельные процессы.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить предварительный просмотр рабочего стола на кнопке Свернуть.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть кнопку Представление задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить прозрачность Меню Пуск, панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Увеличить прозрачность панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить прозрачность командной строки и Powershell.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Console" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
::reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
::reg add "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
::reg add "HKCU\Console\%%SystemRoot%%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe" /v "WindowAlpha" /t REG_DWORD /d "206" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать все папки на панели проводника.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NavPaneShowAllFolders" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Открывать последнее активное окно на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LastActiveClick" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть строку меню в проводнике, перед удалением ленты.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AlwaysShowMenus" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть последние открытые элементы в меню Пуск и панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отображать маленькие иконки в меню Пуск.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_LargeMFUIcons" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Увеличить кэш памяти для вида папок.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell" /v "BagMRU Size" /t REG_DWORD /d "20000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Видео из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Документы из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Загрузки из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Изображения из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Музыка из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку Рабочий стол из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть папку 3D-объекты из Этот компьютер.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Всегда отображать диалоговое окно передачи файлов в подробном режиме.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" /v "EnthusiastMode" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть ленту в проводнике.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" /v "MinimizedStateTabletModeOff" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть панель быстрого доступа в проводнике.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть часто используемые папки и файлы в меню быстрого доступа.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить все папки из меню Этот компьютер.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить помощника по привязке на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SnapAssist" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть кнопку Поиск на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть кнопку Windows Ink Workspace на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceButtonDesiredVisibility" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть кнопку Mail на панели задач.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins" /v "MailPin" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg load "hku\Default" "%HomeDrive%\Users\Default\NTUSER.DAT" 1>> %logfile% 2>>&1
reg add HKEY_USERS\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins /v "MailPin" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg unload "hku\Default" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть значок MeetNow в области уведомлений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить просмотр значков панели управления по категориям.%COLOR%[92m
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerStart=!time!
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть анимацию первого входа после обновления.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableFirstLogonAnimation" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить максимальное качество обоев для рабочего стола в формате JPEG.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t "REG_DWORD" /d "100" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Сделать рабочий стол быстрым.%COLOR%[92m
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
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить запуск диспетчера задач в развернутом режиме.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" /v "Preferences" /t REG_BINARY /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить контроль за свободным пространством жестких дисков.%COLOR%[92m
set timerStart=!time!
powershell "Remove-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Recurse -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалять не используемые временные файлы. Будет применяться, если включен контроль за свободным пространством.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "04" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить пути NTFS длиной более 260 символов.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отображать информацию о Stop ошибках на BSOD.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить оптимизацию доставки.%COLOR%[92m
set timerStart=!time!
reg add "HKU\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Заменить метод ввода по умолчанию на английский.%COLOR%[92m
set timerStart=!time!
powershell "Set-WinDefaultInputMethodOverride -InputTip '0409:00000409' -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Запрос подтверждения перед запуском средства устранения неполадок.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsMitigation" /v "UserPreference" /t "REG_DWORD" /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Скрыть инсайдерскую страницу.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить и удалить зарезервированное хранилище (только для сборок 20H1 и выше).%COLOR%[92m
set timerStart=!time!
dism /online /Set-ReservedStorageState /State:Disabled 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить активацию устройств расширенного хранилища.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" /v "TCGSecurityActivationDisabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить клавишу справки F1 в проводнике и на рабочем столе.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" /v "(default)" /t REG_BINARY /d "" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Показать полный путь к каталогу в строке заголовка проводника.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" /v "FullPath" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить Num Lock при запуске.%COLOR%[92m
set timerStart=!time!
reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2147483650" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить залипание клавиш после 5-кратного нажатия клавиши Shift.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 1>> %logfile% 2>>&1
reg add "HKU\.DEFAULT\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автозапуск для всех носителей и устройств.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t "REG_DWORD" /d "255" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить автозапуск не закрытых приложений после перезагрузки или обновления.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "RestartApps" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
for /f "tokens=* skip=1" %%n in ('wmic useraccount where "name='%username%'" get sid ^| findstr "."') do (set SID=%%n)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\%SID%" /v "OptOut" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автонастройку часов активности в зависимости от ежедневного использования.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "SmartActiveHoursState" /t "REG_DWORD" /d "2" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить перезапуск устройства, если перезагрузка требуется для установки обновления.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "IsExpedited" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Включить NET Framework 3.5 версии.%COLOR%[92m
set timerStart=!time!
Dism /online /enable-feature /featurename:"NetFX3" /All /Source:"%~dp0microsoft-windows-netfx3.cab" /LimitAccess /norestart 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить компоненты прежних версии.%COLOR%[92m
set timerStart=!time!
dism /online /enable-feature /featurename:LegacyComponents /all /norestart 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить компоненты DirectPlay.%COLOR%[92m
set timerStart=!time!
dism /online /enable-feature /featurename:DirectPlay /all /norestart 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить подсистему Linux (WSL).%COLOR%[92m
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить песочницу Windows.%COLOR%[92m
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -All -Online -NoRestart -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить виртуальную платформу Hyper-V.%COLOR%[92m
set timerStart=!time!
powershell "Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -All -Online -NoRestart -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установить кодек HEVC для воспроизведения 4К видео.%COLOR%[92m
set timerStart=!time!
powershell -ExecutionPolicy Unrestricted "Add-AppxPackage -Path '%~dp0Microsoft.HEVCVideoExtension_1.0.32762.0_x64__8wekyb3d8bbwe.Appx' -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить аудит событий, генерируемых при создании или запуска процесса.%COLOR%[92m
set timerStart=!time!
auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Не включать командную строку в события создания процесса.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_Enabled" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Удалить создание строки Создание процесса в планировщике событий.%COLOR%[92m
set timerStart=!time!
powershell "Remove-Item -Path '%ProgramData%\Microsoft\Event Viewer\Views\ProcessCreation.xml' -Force -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить ведение журнала для всех модулей Windows PowerShell.%COLOR%[92m
set timerStart=!time!
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v "EnableModuleLogging" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v "EnableScriptBlockLogging" /f 1>> %logfile% 2>>&1
powershell "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name * -Force -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить диспетчер вложений, помечающий файлы, загруженные из Интернета, как небезопасные.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить поддержку TLS 1.2 для старых версий .NET Framework (для 4.6 и более поздних версий по умолчанию включено).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить Магазин Windows. Необходим для поддержки некоторых игр и приложений.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "StoreAppsOnTaskbar" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить оптимизацию доставки P2P центра обновления Windows компьютерам в локальной сети (полное отключение приводит к ошибке при загрузке с магазина Windows).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить потребительский опыт от Microsoft.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить автоматическое обновление драйверов. Требуется для установки специфичных или устаревших драйверов для устройств.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v "DenyDeviceIDs" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v "DenyDeviceIDsRetroactive" /t "REG_DWORD" /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить сервера pool.ntp.org для синхронизации времени.%COLOR%[92m
set timerStart=!time!
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить инструмент отслеживания производительности.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Выполнить полное удаление OneDrive.%COLOR%[92m
set timerStart=!time!
taskkill /f /im "OneDrive.exe" 1>> %logfile% 2>>&1
set x86=%SystemRoot%\System32\OneDriveSetup.exe
set x64=%SystemRoot%\SysWOW64\OneDriveSetup.exe
if exist %x64% (%x64% /uninstall 1>> %logfile% 2>>&1) else (%x86% /uninstall 1>> %logfile% 2>>&1)
takeown /f "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /a 1>> %logfile% 2>>&1
icacls "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\SysWOW64\OneDriveSetup.exe" 1>> %logfile% 2>>&1
del /f /q "%LocalAppData%\Microsoft\OneDrive\OneDriveStandaloneUpdater.exe" 1>> %logfile% 2>>&1
rmdir "%UserProfile%\OneDrive" "%ProgramData%\Microsoft OneDrive" "%LocalAppData%\Microsoft\OneDrive" "%HomeDrive%\OneDriveTemp" /s /q 1>> %logfile% 2>>&1
del /f /q "%AppData%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" 1>> %logfile% 2>>&1
powershell "Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false" 1>> %logfile% 2>>&1
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 1>> %logfile% 2>>&1
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 1>> %logfile% 2>>&1
takeown /f "%SystemRoot%\WinSxS\*onedrive*" /a /r /d y 1>> %logfile% 2>>&1
icacls "%SystemRoot%\WinSxS\*onedrive*" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
icacls "%SystemRoot%\WinSxS\wow64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.17763.404_none_4e94aed5fb38925a\f\OneDriveSettingSyncProvider.dll" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
icacls "%SystemRoot%\WinSxS\wow64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.17763.404_none_4e94aed5fb38925a\r\OneDriveSettingSyncProvider.dll" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
icacls "%SystemRoot%\WinSxS\amd64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.17763.404_none_44400483c6d7d05f\f\OneDriveSettingSyncProvider.dll" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
icacls "%SystemRoot%\WinSxS\amd64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.17763.404_none_44400483c6d7d05f\r\OneDriveSettingSyncProvider.dll" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
powershell "foreach ($item in (Get-ChildItem %SystemRoot%\WinSxS\*onedrive*)) {Remove-Item -Recurse -Force $item.FullName}" 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SkyDrive" /v "DisableFileSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\OneDrive" /v "DisablePersonalSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\Software\Policies\Microsoft\Windows" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t "REG_DWORD" /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableLibrariesDefaultSaveToOneDrive" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 1>> %logfile% 2>>&1
reg load "hku\Default" "%HomeDrive%\Users\Default\NTUSER.DAT" 1>> %logfile% 2>>&1
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f 1>> %logfile% 2>>&1
reg unload "hku\Default" 1>> %logfile% 2>>&1
sc config CldFlt start=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Удалить поиск Windows.%COLOR%[92m
set timerStart=!time!
Dism /online /Disable-Feature /FeatureName:"SearchEngine-Client-Package" /Remove /norestart 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Удалить UWP приложения.%COLOR%[92m
set timerStart=!time!
powershell "Get-AppxPackage *Microsoft.3dbuilder* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft3DViewer* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
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
powershell "Get-AppxPackage *Microsoft.BingFinance* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingTranslator* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingFoodAndDrink* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingHealthAndFitness* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingTravel* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.MicrosoftPowerBIForWindows* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Wallet* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.WindowsReadingList* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.WindowsAlarms* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.FeedbackHub* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Asphalt8Airborne* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.WindowsCamera* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.DrawboardPDF* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.GetHelp* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BioEnrollment* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.CredDialogHost* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.ECApp* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.LockApp* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *microsoft.windowscommunicationsapps* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.WindowsMaps* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Messaging* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Advertising.Xaml* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingNews* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Todos* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Whiteboard* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *MinecraftUWP* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.MixedReality.Portal* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.OneConnect* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.NetworkSpeedTest* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.MicrosoftOfficeHub* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Office.Lens* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Office.OneNote* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Office.Sway* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Office.Todo.List* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *People* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *WindowsPhone* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *CommsPhone* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Print3D* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *WindowsScan* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.SkypeApp* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.MicrosoftStickyNotes* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.Getstarted* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.WindowsSoundRecorder* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.BingWeather* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.YourPhone* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.ZuneMusic* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.ZuneVideo* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.XboxApp* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.XboxGameOverlay* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.XboxGamingOverlay* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Microsoft.549981C3F5F10* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
:: другие приложения
powershell "Get-AppxPackage *PicsArt-PhotoStudio* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *ActiproSoftwareLLC* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *AdobePhotoshopExpress* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *AutodeskSketchBook* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *bingsports* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *candycrush* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *DolbyAccess* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *empires* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Facebook* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *FarmHeroesSaga* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *PandoraMediaInc* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *spotify* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Shazam* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Twitter* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Yandex.Music* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *xing* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *EclipseManager* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Netflix -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *PolarrPhotoEditorAcademicEdition -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Wunderlist -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *LinkedInforWindows -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *DisneyMagicKingdoms -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *MarchofEmpires -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Plex -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *iHeartRadio -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *FarmVille2CountryEscape -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Duolingo-LearnLanguagesforFree -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *CyberLinkMediaSuiteEssentials -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *DrawboardPDF -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *FitbitCoach -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Flipboard -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *Asphalt8Airborne -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "KeeperSecurityInc.Keeper" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "NORDCURRENT.COOKINGFEVER" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *CaesarsSlotsFreeCasino -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *SlingTV -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *SpotifyMusic -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *PhototasticCollage -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *WinZipUniversal -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage *RoyalRevolt2 -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "king.com.*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "king.com.BubbleWitch3Saga" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "king.com.CandyCrushSaga" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Get-AppxPackage "king.com.CandyCrushSodaSaga" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
:: принудительное удаление приложений
%iwt% InputApp 1>> %logfile% 2>>&1
%iwt% Microsoft.LockApp 1>> %logfile% 2>>&1
%iwt% Microsoft.PrintDialog 1>> %logfile% 2>>&1
%iwt% Microsoft.BioEnrollment 1>> %logfile% 2>>&1
%iwt% Windows.ContactSupport 1>> %logfile% 2>>&1
%iwt% Microsoft-Windows-ContactSupport 1>> %logfile% 2>>&1
%iwt% Microsoft-Windows-Help 1>> %logfile% 2>>&1
%iwt% Microsoft.PPIProjection 1>> %logfile% 2>>&1
%iwt% microsoft.windowscommunicationsapps 1>> %logfile% 2>>&1
%iwt% Microsoft.WindowsFeedback 1>> %logfile% 2>>&1
%iwt% Microsoft.Windows.Cortana 1>> %logfile% 2>>&1
%iwt% Microsoft-Windows-Internet-Browser-Package 1>> %logfile% 2>>&1
%iwt% Microsoft.EdgeDevToolsPlugin 1>> %logfile% 2>>&1
%iwt% Microsoft.MicrosoftEdgeDevToolsClient 1>> %logfile% 2>>&1
%iwt% Microsoft.MicrosoftEdge 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Использовать Windows Photo Viewer.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\SOFTWARE\Classes\.jpg" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.jpeg" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.gif" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.png" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.bmp" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.tiff" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Classes\.ico" /ve /t "REG_SZ" /d "PhotoViewer.FileAssoc.Tiff" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить мониторинг использования сетевых данных.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Ndu" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить службу push-уведомлений по протоколу беспроводных приложений (WAP) для управления устройствами. Предупреждение: эта служба необходима для взаимодействия с Microsoft Intune.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
sc config dmwappushsvc start=disabled 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить возможности подключенного пользователя и телеметрию (ранее называвшуюся службой отслеживания диагностики), заблокировать соединение единой телеметрии через правила брандмауэра для исходящего трафика.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagtrack" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
powershell "Get-NetFirewallRule -Group DiagTrack | Set-NetFirewallRule -Enabled False -Action Block -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установить Internet шаблон.%COLOR%[92m
set timerStart=!time!
netsh int tcp set supplemental template=Internet 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить совместимость оценщика.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить программу улучшения качества программного обеспечения.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\Uploader" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить сборщик дисковых данных.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить диагностику памяти.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnostic" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить анализ диагностики энергоэффективности.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить запланированную дефгарментацию дисков.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Полное отключение всех видов телеметрии.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP" /v "CEIPEnable" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CorporateSQMURL" /t REG_SZ /d "0.0.0.0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Microsoft\Assistance\Client\1.0\Settings" /v "ImplicitFeedback" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" /v "AllowLinguisticDataCollection" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\15.0\osm" /v "Enablelogging" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\15.0\osm" /v "EnableUpload" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "Enablelogging" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "EnableUpload" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\ClickToRun\OverRide" /v "DisableLogManagement" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v "TimerInterval" /t REG_SZ /d "900000" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
del /f /q C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DeviceCensus.exe" /v "Debugger" /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v Debugger /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
for /F "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v "LastLoggedOnUserSID" 2^>nul') do (set UID=%%b)
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
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Autochk\Proxy" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\AppID\SmartScreenSpecific" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Application Experience\AitAgent" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Application Experience\StartupAppTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\DiskFootprint\Diagnostics" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\FileHistory\File History (maintenance mode)" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Maintenance\WinSAT" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\PI\Sqm-Tasks" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Shell\FamilySafetyMonitor" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Shell\FamilySafetyRefresh" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Shell\FamilySafetyUpload" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Shell\FamilySafetyRefreshTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\WindowsUpdate\Automatic App Update" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\License Manager\TempSignedLicenseExchange" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Clip\License Validation" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\ApplicationData\DsSvcCleanup" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\PushToInstall\LoginCheck" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\PushToInstall\Registration" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Subscription\EnableLicenseAcquisition" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Subscription\LicenseAcquisition" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Diagnosis\Scheduled" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\NetTrace\GatherNetworkInfo" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Maps\MapsUpdateTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Maps\MapsToastTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Chkdsk\ProactiveScan" 1>> %logfile% 2>>&1
%superuser% schtasks /change /disable /tn "\Microsoft\Windows\Chkdsk\SyspartRepair" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\Office ClickToRun Service Monitor" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetryAgentFallBack2016" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetryAgentLogOn2016" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetry\AgentFallBack2016" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\Office 15 Subscription Heartbeat" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetryAgentFallBack" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Office\OfficeTelemetryAgentLogOn" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\HelloFace\FODCleanupTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\Uploader" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\SysNative\Tasks\Microsoft\Windows\SettingSync\*" 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\System32\Tasks\Microsoft\Windows\SettingSync\*" 1>> %logfile% 2>>&1
sc delete DiagTrack 1>> %logfile% 2>>&1
sc delete diagnosticshub.standardcollector.service 1>> %logfile% 2>>&1
sc delete dmwappushservice 1>> %logfile% 2>>&1
sc delete WerSvc 1>> %logfile% 2>>&1
sc delete wercplsupport 1>> %logfile% 2>>&1
sc delete PcaSvc 1>> %logfile% 2>>&1
sc delete wisvc 1>> %logfile% 2>>&1
sc delete RetailDemo 1>> %logfile% 2>>&1
sc delete diagsvc 1>> %logfile% 2>>&1
sc delete shpamsvc 1>> %logfile% 2>>&1
sc delete TermService 1>> %logfile% 2>>&1
sc delete UmRdpService 1>> %logfile% 2>>&1
sc delete SessionEnv 1>> %logfile% 2>>&1
sc delete TroubleshootingSvc 1>> %logfile% 2>>&1
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "OneSyncSvc" ^| find /i "OneSyncSvc"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "MessagingService" ^| find /i "MessagingService"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "PimIndexMaintenanceSvc" ^| find /i "PimIndexMaintenanceSvc"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UserDataSvc" ^| find /i "UserDataSvc"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UnistoreSvc" ^| find /i "UnistoreSvc"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "BcastDVRUserService" ^| find /i "BcastDVRUserService"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
for /f "tokens=1" %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "Sgrmbroker" ^| find /i "Sgrmbroker"') do (reg delete %%I /f 1>> %logfile% 2>>&1)
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить задачи телеметрии NVIDIA.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\Startup\SendTelemetryData" /v "@" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить задачи телеметрии Intel.%COLOR%[92m
set timerStart=!time!
schtasks /change /disable /tn "\IntelSURQC-Upgrade-86621605-2a0b-4128-8ffc-15514c247132" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\IntelSURQC-Upgrade-86621605-2a0b-4128-8ffc-15514c247132-Logon" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\Intel PTT EK Recertification" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\USER_ESRV_SVC_QUEENCREEK" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить телеметрию Mozilla Firefox.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableTelemetry" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableDefaultBrowserAgent" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить Software Reporter Tool и сервис обновления в Google Chrome.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupReportingEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe" /v Debugger /t REG_SZ /d "C:\Windows\System32\taskkill.exe" /f 1>> %logfile% 2>>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_SZ /d "0" /f 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\GoogleUpdateTaskMachineCore" 1>> %logfile% 2>>&1
schtasks /change /disable /tn "\GoogleUpdateTaskMachineUA" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выставить запуск по требованию для службы Microsoft Windows Live ID.%COLOR%[92m
set timerStart=!time!
sc config wlidsvc start=demand 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Включить перечислитель виртуальных дисков.%COLOR%[92m
set timerStart=!time!
sc config vdrvroot start=auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить инфраструктуру виртуализации Hyper-V.%COLOR%[92m
set timerStart=!time!
sc config Vid start=delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить перечислитель виртуальных сетевых карт.%COLOR%[92m
set timerStart=!time!
sc config NdisVirtualBus start=delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить составную шину.%COLOR%[92m
set timerStart=!time!
sc config CompositeBus start=delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить UMBus.%COLOR%[92m
set timerStart=!time!
sc config umbus start=delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить шину RDP.%COLOR%[92m
set timerStart=!time!
sc config rdpbus start=delayed-auto 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить устаревший протокол SMB 1.0 и Samba сервер.%COLOR%[92m
set timerStart=!time!
sc config mrxsmb start=delayed-auto 1>> %logfile% 2>>&1
sc config Mrxsmb10 start=delayed-auto 1>> %logfile% 2>>&1
sc config Mrxsmb20 start=delayed-auto 1>> %logfile% 2>>&1
sc config srv2 start=delayed-auto 1>> %logfile% 2>>&1
powershell "Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
powershell "Enable-NetAdapterBinding -Name * -ComponentID 'ms_server' -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить протокол Link-Local Multicast Name Resolution (LLMNR).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SOFTWARE\policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Включить восстановление системы и сброс до заводских настроек (Windows RE).%COLOR%[92m
set timerStart=!time!
reagentc /enable 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить повышенную точность указателя.%COLOR%[92m
set timerStart=!time!
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t "REG_SZ" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t "REG_SZ" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t "REG_SZ" /d "0" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000c0cc0c0000000000809919000000000040662600000000000033330000000000" /f 1>> %logfile% 2>>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000a800000000000000e00000000000" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Установить новые возможности от Windows 10X (только для сборок 20H1 и выше).%COLOR%[92m
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
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BootControl" /v BootProgressAnimation /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
:: Windows Rounded UI
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting" /v ImmersiveSearch /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override" /v ImmersiveSearchFull /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override" /v CenterScreenRoundedCornerRadius /t REG_DWORD /d "9" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
@echo %COLOR%[36m Уменьшить размер буфера мыши и клавиатуры.%COLOR%[92m %COLOR%[7;31mПредупреждение: если мышь ведет себя некорректно, увеличьте данные значения до 100.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
::reg delete "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "16" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
::@echo %COLOR%[36m Отключить счетчики производительности.%COLOR%[92m %COLOR%[7;31mВнимание: после отключения службы, наблюдается нестабильность системы и неработоспособность диспетчера задач.%COLOR%[0m%COLOR%[36m%COLOR%[92m
::set timerStart=!time!
::sc config pcw start=disabled 1>> %logfile% 2>>&1
::set timerEnd=!time!
::call :timer
::@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
::echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить PPM и уменьшить задержку в играх.%COLOR%[92m %COLOR%[7;31mПредупреждение: если после отключения параметров производительность снизилась, выставите значения на 0.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmdK8" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\intelppm" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmdPPM" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "Start" /t REG_DWORD /d "4" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Ускорить завершение обнаружения и восстановления тайм-аута (TDR).%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Включить поддержку сглаживания анимации в драйвере nVidia (SILK Smooth).%COLOR%[92m %COLOR%[7;31mПримечание: помогает при микрофризах в играх. Последняя поддержка SILK содержится в драйвере 442.74 и настраивается в панели управления nVidia.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
reg add "HKLM\System\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Принудительное выделение непрерывной памяти в драйвере nVidia.%COLOR%[92m %COLOR%[7;31mПримечание: ветка 0000 может отличаться в зависимости от номера графического процессора.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Отключить код исправления ошибок (ECC) на видеокартах nVidia.%COLOR%[92m
set timerStart=!time!
"%ProgramFiles%\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -e 0
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Переключить режим драйвера из WDDM в TCC на видеокартах nVidia.%COLOR%[92m
set timerStart=!time!
"%ProgramFiles%\NVIDIA Corporation\NVSMI\nvidia-smi.exe" -fdm 1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Принудительное выделение непрерывной памяти в графическом ядре DirectX.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DpiMapIommuContiguous" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Применение оптимизации V-Sync для ускорения игр.%COLOR%[92m
set timerStart=!time!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "1" /f 1>> %logfile% 2>>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "VsyncIdleTimeout" /t REG_DWORD /d "0" /f 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Выберите желаемое приложение или игру для установки высокопроизводительного приоритета DirectX и использования виртуального адресного пространства для снижения микрофризов.%COLOR%[92m
set timerStart=!time!
powershell -ExecutionPolicy Bypass -file "%~dp0ProcessPerformance.ps1" -WarningAction SilentlyContinue 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установка оптимизированного профиля nVidia.%COLOR%[92m
set timerStart=!time!
start "" /wait "%~dp0nvidiaProfileInspector.exe" "%~dp0nvprofile.nip"
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Программа для настройки MSI на устройствах.%COLOR%[92m %COLOR%[7;31mПредупреждение: Применяйте параметры только для устройств с поддержкой msi.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
start "" /wait "%~dp0MSI_util_v3.exe"
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Установка инструмента для применения максимального разрешения таймера при запуске ОС (проверить значение таймера можно с помощью утилиты TimerTool, находящейся в папке Apps).%COLOR%[92m
set timerStart=!time!
net stop STR 1>> %logfile% 2>>&1
start "" /wait %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /u %~dp0TimerResolution.exe
start "" /wait %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i %~dp0TimerResolution.exe
net start STR 1>> %logfile% 2>>&1
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Применение инструмента в автозагрузку для отключения энергосбережения жестких дисков.%COLOR%[92m
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "quietHDD" /t "REG_SZ" /d "%~dp0\..\quietHDD\quietHDD.exe /NOTRAY /ACAPMVALUE:255 /DCAPMVALUE:255 /ACAAMVALUE:254 /DCAAMVALUE:254 /NOWARN" /f 1>> %logfile% 2>>&1
set timerStart=!time!
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
echo. 1>> %logfile% 2>>&1
@echo %COLOR%[36m Программа для отключения ленты из проводника.%COLOR%[92m %COLOR%[7;31mПредупреждение: После применения изменений не нажимайте кнопку Yes для дальнейшего применения скрипта.%COLOR%[0m%COLOR%[36m%COLOR%[92m
set timerStart=!time!
takeown /f "%SystemRoot%\System32\explorerframe.dll" /a 1>> %logfile% 2>>&1
takeown /f "%SystemRoot%\System32\explorerframe.dll.151" /a 1>> %logfile% 2>>&1
takeown /f "%SystemRoot%\System32\explorerframe.dll.winaero" /a 1>> %logfile% 2>>&1
icacls "%SystemRoot%\System32\explorerframe.dll" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
icacls "%SystemRoot%\System32\explorerframe.dll.151" /grant SYSTEM:F /c /grant Администраторы:F /c /grant Пользователи:F /c 1>> %logfile% 2>>&1
del /f /q "%SystemRoot%\System32\explorerframe.dll.151" 1>> %logfile% 2>>&1
start "" /wait "%~dp0RibbonDisabler.exe"
set timerEnd=!time!
call :timer
@echo ОК %COLOR%[93m[%COLOR%[91m!totalsecs!.!ms!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
:: #########################################################################################################################################################################################################################
echo.%COLOR%[7m%COLOR%[0m
set conf=Y
set /p "conf=Выполнить обслуживание системы после настройки? [Y:Да/N:Нет]"
if "%conf%" neq "Y" if "%conf%" neq "y" goto :endcompact
@echo %COLOR%[36m Сжатие данных ^(это может занять некоторое время^).%COLOR%[92m
@echo Сжатие данных ^(это может занять некоторое время^). 1>> %logfile% 2>>&1
set timerStart=!time!
compact /compactos:always 1>> %logfile% 2>>&1
compact /c /s:"%ProgramFiles%" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
compact /c /s:"%ProgramFiles(x86)%" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
compact /c /s:"%ProgramData%" /a /i /exe:lzx 1>> %logfile% 2>>&1
compact /c /s:"%userprofile%\AppData" /a /i /q /exe:lzx 1>> %logfile% 2>>&1
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
@echo ОК %COLOR%[93m[%COLOR%[91m!mins!%COLOR%[0m минут%COLOR%[93m %COLOR%[91m!secs!%COLOR%[0m секунд%COLOR%[93m]%COLOR%[92m
:endcompact
:: #########################################################################################################################################################################################################################
cmd.exe /c "%~dp0EmptyStandbyList.exe workingsets|modifiedpagelist|standbylist|priority0standbylist" 1>> %logfile% 2>>&1
lodctr /e:PerfOS 1>> %logfile% 2>>&1
lodctr /r 1>> %logfile% 2>>&1
start "" "%SystemRoot%\explorer.exe"
timeout /t 1 /nobreak | break
%SystemRoot%\System32\ie4uinit.exe -ClearIconCache
powershell "gps explorer | spps -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1"
echo.%COLOR%[36m
echo. 1>> %logfile% 2>>&1
bcdedit /enum 1>> %logfile% 2>>&1
echo. 1>> %logfile% 2>>&1
:: #########################################################################################################################################################################################################################
echo.%COLOR%[42m%COLOR%[0m
timeout /t 5 /nobreak | break
rundll32 user32.dll, SetActiveWindow 1
rundll32 user32.dll, SetActiveWindow 1
set conf=Y
set /p "conf=Все настройки завершены. Перезагрузить компьютер для применения твиков прямо сейчас? [Y:Да/N:Нет]"
if "%conf%" neq "Y" if "%conf%" neq "y" goto :endshutdown
move /y %~dp0InstallUtil.InstallLog %~dp0\..\..\Logs\InstallUtil.InstallLog 1>> %logfile% 2>>&1
move /y %~dp0TimerResolution.InstallLog %~dp0\..\..\Logs\TimerResolution.InstallLog 1>> %logfile% 2>>&1
move /y %~dp0TimerResolution.InstallState %~dp0\..\..\Logs\TimerResolution.InstallState 1>> %logfile% 2>>&1
@echo --- End of file --- 1>> %logfile% 2>>&1
del %tmpfile%
shutdown -r -t 0
goto :eof
:endshutdown
move /y %~dp0InstallUtil.InstallLog %~dp0\..\..\Logs\InstallUtil.InstallLog 1>> %logfile% 2>>&1
move /y %~dp0TimerResolution.InstallLog %~dp0\..\..\Logs\TimerResolution.InstallLog 1>> %logfile% 2>>&1
move /y %~dp0TimerResolution.InstallState %~dp0\..\..\Logs\TimerResolution.InstallState 1>> %logfile% 2>>&1
@echo --- End of file --- 1>> %logfile% 2>>&1
del %tmpfile%
timeout -1 | break
goto :eof
:: #########################################################################################################################################################################################################################
:color
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set COLOR=%%b)
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
:disable_svc
sc stop %~1 1>> %logfile% 2>>&1
sc config %~1 start= disabled 1>> %logfile% 2>>&1
goto :eof
:disable_svc_sudo
%superuser% cmd.exe /c sc config %~1 start= disabled ^& sc stop %~1 1>> %logfile% 2>>&1
goto :eof
:disable_svc_lite
sc stop %~1 1>> %logfile% 2>>&1
sc config %~1 start= demand 1>> %logfile% 2>>&1
goto :eof
:disable_svc_sudo_lite
%superuser% cmd.exe /c sc config %~1 start= demand ^& sc stop %~1 1>> %logfile% 2>>&1
goto :eof
:disable_svc_rand
for /f "tokens=5 delims=\" %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /k /f %~1_') do (
    sc stop %%a 1>> %logfile% 2>>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d 3 /f 1>> %logfile% 2>>&1
)
call :disable_svc_lite %~1
goto :eof
:disable_svc_hard
%superuser% sc stop %~1
powershell "Import-Module -DisableNameChecking '%~dp0takeown.psm1'; Takeown-Registry('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%~1'); Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\%~1' 'Start' '4' -ErrorAction SilentlyContinue" 1>> %logfile% 2>>&1
goto :eof
:rm_uwp
powershell "Get-AppxPackage *%~1* -AllUsers | Remove-AppxPackage -AllUsers -WarningAction SilentlyContinue" 1>> %logfile% 2>>&1
goto :eof
:setAdapters
set "RegistryLine=%~1"
if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
for /F "tokens=2*" %%A in ("%RegistryLine%") do set "ProviderName=%%B"
echo %ProviderName% | findstr "search"
if %errorlevel%==1 (
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