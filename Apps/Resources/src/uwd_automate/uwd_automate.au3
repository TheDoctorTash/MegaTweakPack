#include <WinAPI.au3>
#include <File.au3>
Local $iSum = 0
$sFileExe = @ScriptDir & '\uwd.exe'
Run($sFileExe, @ScriptDir, @SW_HIDE)
While 1
$aList = WinList()
For $i = 1 To $aList[0][0]
    If StringInStr ($aList[$i][0],"Universal Watermark Disabler") > 0 And _WinAPI_GetClassName($aList[$i][1]) = "TfrmMain" Then
			WinActivate($aList[$i][0])
            WinActivate($aList[$i][1])
			WinWaitActive($aList[$i][1], "", 10)
            ControlClick($aList[$i][1], "", "[CLASS:TButton; INSTANCE:1]", "Left", 1)
			WinSetState($aList[$i][0], "", @SW_HIDE)
			WinSetState($aList[$i][1], "", @SW_HIDE)
			If (WinActive("Warning")) Then
				ControlClick("Warning", "", "[CLASS:Button; INSTANCE:1]", "Left", 1)
			EndIf
			If (WinWait("Warning")) Then
				WinSetState("Warning", "", @SW_HIDE)
			EndIf
            ProcessClose("uwd.exe")
			If ProcessExists("explorer.exe") Then
				Run("taskkill /f /im explorer.exe")
			EndIf
			Local $i = 2
			ExitLoop
    EndIf
Next
If $i = 2 Then
	ExitLoop
EndIf
WEnd