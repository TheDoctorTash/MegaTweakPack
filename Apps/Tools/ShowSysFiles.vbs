Option Explicit
Dim dblHiddenData, strHiddenKey, strSuperHiddenKey, strFileExtKey
Dim strKey, WshShell
On Error Resume Next
 
strKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
strHiddenKey = strKey & "\Hidden"
strSuperHiddenKey = strKey & "\ShowSuperHidden"
'strFileExtKey = strKey & "\HideFileExt"
 
Set WshShell = WScript.CreateObject("WScript.Shell")
dblHiddenData = WshShell.RegRead(strHiddenKey)
 
If dblHiddenData = 2 Then
    'Скрытые файлы
    WshShell.RegWrite strHiddenKey, 1, "REG_DWORD"
    'Системные файлы
    WshShell.RegWrite strSuperHiddenKey, 1, "REG_DWORD"
    'Расширения
    'WshShell.RegWrite strFileExtKey, 0, "REG_DWORD"
    WSHShell.SendKeys "{F5}" 
     
Else
    WshShell.RegWrite strHiddenKey, 2, "REG_DWORD"
    WshShell.RegWrite strSuperHiddenKey, 0, "REG_DWORD"
    'WshShell.RegWrite strFileExtKey, 1, "REG_DWORD"
    WSHShell.SendKeys "{F5}" 
 
End If