;
; installer.nsi - NSIS install script for hdparm
;
; Copyright (C) 2006 Christian Franke
;
; Download and install NSIS from: http://nsis.sourceforge.net/Download
; Process with makensis to create installer (tested with NSIS 2.18).
;


;--------------------------------------------------------------------
; Command line arguments:
; makensis /DINPDIR=<input-dir> /DOUTFILE=<output-file> installer.nsi

!ifndef INPDIR
  !define INPDIR "."
!endif

!ifndef OUTFILE
  !define OUTFILE "hdparm.win32-setup.exe"
!endif

;--------------------------------------------------------------------
; General

Name "hdparm"
OutFile "${OUTFILE}"

SetCompressor /solid lzma

XPStyle on
InstallColors /windows

InstallDir "$PROGRAMFILES\hdparm"
InstallDirRegKey HKLM "Software\hdparm" "Install_Dir"

LicenseData "${INPDIR}\doc\LICENSE.win32.txt"

;--------------------------------------------------------------------
; Pages

Page license
Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

InstType "Full"
InstType "Extract files only"


;--------------------------------------------------------------------
; Sections

Section "Program file"

  SectionIn 1 2

  SetOutPath "$INSTDIR\bin"
  File "${INPDIR}\bin\hdparm.exe"

SectionEnd

Section "Documentation"

  SectionIn 1 2

  SetOutPath "$INSTDIR\doc"
  File "${INPDIR}\doc\Changelog.txt"
  File "${INPDIR}\doc\Changelog.win32.txt"
  File "${INPDIR}\doc\LICENSE.win32.txt"
  File "${INPDIR}\doc\README.acoustic.txt"
  File "${INPDIR}\doc\hdparm.8.html"
  File "${INPDIR}\doc\hdparm.8.txt"

SectionEnd

Section "Uninstaller"

  SectionIn 1
  AddSize 35

  CreateDirectory "$INSTDIR"

  ; Save installation location
  WriteRegStr HKLM "Software\hdparm" "Install_Dir" "$INSTDIR"

  ; Write uninstall keys and program
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\hdparm" "DisplayName" "hdparm"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\hdparm" "UninstallString" '"$INSTDIR\uninst-hdparm.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\hdparm" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\hdparm" "NoRepair" 1
  WriteUninstaller "uninst-hdparm.exe"

SectionEnd

Section "Start Menu Shortcuts"

  SectionIn 1

  CreateDirectory "$SMPROGRAMS\hdparm"

  IfFileExists "$INSTDIR\bin\hdparm.exe" 0 nobin
    SetOutPath "$INSTDIR\bin"
    DetailPrint "Create file: $INSTDIR\bin\hdparm-run.bat"
    FileOpen $0 "$INSTDIR\bin\hdparm-run.bat" "w"
    FileWrite $0 "@echo off$\r$\necho hdparm %1 %2 %3 %4 %5$\r$\nhdparm %1 %2 %3 %4 %5$\r$\npause$\r$\n"
    FileClose $0
    CreateDirectory "$SMPROGRAMS\hdparm\hdparm Examples"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Show supported hdparm commands (-h).lnk"    "$INSTDIR\bin\hdparm-run.bat" "-h"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Identify 1st disk (-I hda).lnk"             "$INSTDIR\bin\hdparm-run.bat" "-I hda"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Identify 2nd disk (-I hdb).lnk"             "$INSTDIR\bin\hdparm-run.bat" "-I hdb"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Identify 1st CD drive (-I scd0).lnk"        "$INSTDIR\bin\hdparm-run.bat" "-I scd0"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Check 2nd disk power status (-C hdb).lnk"   "$INSTDIR\bin\hdparm-run.bat" "-C hdb"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Set 2nd disk to standby (-y hdb).lnk"       "$INSTDIR\bin\hdparm-run.bat" "-y hdb"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Perform 2nd disk read timings (-t hdb).lnk" "$INSTDIR\bin\hdparm-run.bat" "-t hdb"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Security Freeze 1st disk (--security-freeze hda).lnk" "$INSTDIR\bin\hdparm-run.bat" "--security-freeze hda"
    CreateShortCut "$SMPROGRAMS\hdparm\hdparm Examples\Security Freeze 2nd disk (--security-freeze hdb).lnk" "$INSTDIR\bin\hdparm-run.bat" "--security-freeze hdb"
  nobin:

  IfFileExists "$INSTDIR\doc\LICENSE.win32.txt" 0 nodoc
    SetOutPath "$INSTDIR\doc"
    CreateDirectory "$SMPROGRAMS\hdparm\Documentation"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\hdparm manual page (html).lnk" "$INSTDIR\doc\hdparm.8.html"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\hdparm manual page (txt).lnk"  "$INSTDIR\doc\hdparm.8.txt"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\Changelog.lnk"                 "$INSTDIR\doc\Changelog.txt"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\Changelog.win32.lnk"           "$INSTDIR\doc\Changelog.win32.txt"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\LICENSE.win32.lnk"             "$INSTDIR\doc\LICENSE.win32.txt"
    CreateShortCut "$SMPROGRAMS\hdparm\Documentation\README.acoustic.lnk"           "$INSTDIR\doc\README.acoustic.txt"
  nodoc:

  CreateShortCut "$SMPROGRAMS\hdparm\hdparm Sourceforge Project Page.lnk" "http://sourceforge.net/projects/hdparm/"

  ; Uninstall
  IfFileExists "$INSTDIR\uninst-hdparm.exe" 0 +2
    CreateShortCut "$SMPROGRAMS\hdparm\Uninstall hdparm.lnk" "$INSTDIR\uninst-hdparm.exe"

SectionEnd

Section "Add install dir to PATH" PATH_IDX

  SectionIn 1

  IfFileExists "$WINDIR\system32\cmd.exe" 0 +3
    Push "$INSTDIR\bin"
    Call AddToPath
 
SectionEnd

;--------------------------------------------------------------------

Section "Uninstall"
  
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\hdparm"
  DeleteRegKey HKLM "Software\hdparm"

  Delete "$INSTDIR\bin\hdparm.exe"
  Delete "$INSTDIR\bin\hdparm-run.bat"
  Delete "$INSTDIR\doc\Changelog.txt"
  Delete "$INSTDIR\doc\Changelog.win32.txt"
  Delete "$INSTDIR\doc\LICENSE.win32.txt"
  Delete "$INSTDIR\doc\README.acoustic.txt"
  Delete "$INSTDIR\doc\hdparm.8.html"
  Delete "$INSTDIR\doc\hdparm.8.txt"
  Delete "$INSTDIR\uninst-hdparm.exe"

  Delete "$SMPROGRAMS\hdparm\*.*"
  Delete "$SMPROGRAMS\hdparm\Documentation\*.*"
  Delete "$SMPROGRAMS\hdparm\hdparm Examples\*.*"

  RMDir  "$SMPROGRAMS\hdparm\Documentation"
  RMDir  "$SMPROGRAMS\hdparm\hdparm Examples"
  RMDir  "$SMPROGRAMS\hdparm"
  RMDir  "$INSTDIR\bin"
  RMDir  "$INSTDIR\doc"
  RMDir  "$INSTDIR"

  ; Remove install dir from PATH
  IfFileExists "$WINDIR\system32\cmd.exe" 0 +3
    Push "$INSTDIR\bin"
    Call un.RemoveFromPath

  IfFileExists "$INSTDIR" 0 +2
    MessageBox MB_OK "Note: $INSTDIR could not be removed."

  IfFileExists "$SMPROGRAMS\hdparm" 0 +2
    MessageBox MB_OK "Note: $SMPROGRAMS\hdparm could not be removed."

SectionEnd

;--------------------------------------------------------------------

Function .onInit

  IfFileExists "$WINDIR\system32\cmd.exe" +3 0
    MessageBox MB_OK "Note: hdparm does not support Win9x/ME."
    SectionSetText ${PATH_IDX} ""

FunctionEnd


;--------------------------------------------------------------------
; Utility functions
;
; Based on example from:
; http://nsis.sourceforge.net/Path_Manipulation
;


!include "WinMessages.nsh"

; Registry Entry for environment (NT4,2000,XP)
; All users:
;!define Environ 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
; Current user only:
!define Environ 'HKCU "Environment"'


; AddToPath - Appends dir to PATH
;   (does not work on Win9x/ME)
;
; Usage:
;   Push "dir"
;   Call AddToPath

Function AddToPath
  Exch $0
  Push $1
  Push $2
  Push $3
 
  ReadRegStr $1 ${Environ} "PATH"
  Push "$1;"
  Push "$0;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" done
  Push "$1;"
  Push "$0\;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" done
 
  DetailPrint "Add to PATH: $0"
  StrCpy $2 $1 1 -1
  StrCmp $2 ";" 0 +2
    StrCpy $1 $1 -1 ; remove trailing ';'
  StrCmp $1 "" +2   ; no leading ';'
    StrCpy $0 "$1;$0"
  WriteRegExpandStr ${Environ} "PATH" $0
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
 
done:
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd


; RemoveFromPath - Removes dir from PATH
;
; Usage:
;   Push "dir"
;   Call RemoveFromPath
 
Function un.RemoveFromPath
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6
 
  ReadRegStr $1 ${Environ} "PATH"
  StrCpy $5 $1 1 -1
  StrCmp $5 ";" +2
    StrCpy $1 "$1;" ; ensure trailing ';'
  Push $1
  Push "$0;"
  Call un.StrStr
  Pop $2 ; pos of our dir
  StrCmp $2 "" done

  DetailPrint "Remove from PATH: $0"
  StrLen $3 "$0;"
  StrLen $4 $2
  StrCpy $5 $1 -$4 ; $5 is now the part before the path to remove
  StrCpy $6 $2 "" $3 ; $6 is now the part after the path to remove
  StrCpy $3 "$5$6"
  StrCpy $5 $3 1 -1
  StrCmp $5 ";" 0 +2
    StrCpy $3 $3 -1 ; remove trailing ';'
  WriteRegExpandStr ${Environ} "PATH" $3
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

done:
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd
 

; StrStr - find substring in a string
;
; Usage:
;   Push "this is some string"
;   Push "some"
;   Call StrStr
;   Pop $0 ; "some string"
 
!macro StrStr un
Function ${un}StrStr
  Exch $R1 ; $R1=substring, stack=[old$R1,string,...]
  Exch     ;                stack=[string,old$R1,...]
  Exch $R2 ; $R2=string,    stack=[old$R2,old$R1,...]
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=substring, $R2=string, $R3=strlen(substring)
  ; $R4=count, $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1 ; $R1=old$R1, stack=[result,...]
FunctionEnd
!macroend
!insertmacro StrStr ""
!insertmacro StrStr "un."
