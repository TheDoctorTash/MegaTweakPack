#BROADCAST_QUERY_DENY       = $424D5144
#PBT_APMQUERYSUSPEND        = $00
#WM_POWERBROADCAST          = $218
#PBT_APMBATTERYLOW          = $09
#PBT_APMPOWERSTATUSCHANGE   = $0A
#PBT_APMOEMEVENT            = $0B
#PBT_APMQUERYSUSPEND        = $00
#PBT_APMQUERYSUSPENDFAILED  = $02
#PBT_APMRESUMECRITICAL      = $06
#PBT_APMRESUMEAUTOMATIC     = $12
#PBT_APMQUERYSUSPENDFAILED  = $02

#IOCTL_IDE_PASS_THROUGH     = $04D028
#IOCTL_ATA_PASS_THROUGH     = $04D02C
#HDIO_DRIVE_CMD             = $03F1   ; Taken from /usr/include/linux/hdreg.h
#HDIO_SET_ACOUSTIC          = $032C
#HDIO_GET_ACOUSTIC          = $030F
#WIN_SETFEATURES            = $EF
#SETFEATURES_EN_AAM         = $42
#SETFEATURES_DIS_AAM        = $C2
#SETFEATURES_EN_APM         = $05
#SETFEATURES_DIS_APM        = $85
#ATA_FLAGS_DRDY_REQUIRED    = $01
#ATA_FLAGS_DATA_IN          = $02
#ATA_FLAGS_DATA_OUT         = $04
#ATA_FLAGS_48BIT_COMMAND    = $08


Macro ZHex(val,digits=2)
  RSet(Hex(val), digits, "0")
EndMacro
Macro CR
  Chr(10)
EndMacro

Enumeration
  #inFeaturesReg      ;0
  #inSectorCountReg   ;1 
  #inSectorNumberReg  ;2
  #inCylLowReg        ;3
  #inCylHighReg       ;4
  #inDriveHeadReg     ;5          
  #inCommandReg       ;6
  #inReserved         ;7
EndEnumeration

Enumeration
  #outErrorReg         ;0
  #outSectorCountReg   ;1 
  #outSectorNumberReg  ;2
  #outCylLowReg        ;3
  #outCylHighReg       ;4
  #outDriveHeadReg     ;5          
  #outStatusReg        ;6
  #outReserved         ;7
EndEnumeration

;- Window Constants
;
Enumeration
  #Window_0
EndEnumeration

;- Gadget Constants
;
Enumeration
  #bt_Ok
  #bt_Apply
  #bt_Cancel
  #Panel_0
  #Frame3D_0
  #tb_ACAPMValue
  #Text_1
  #tb_DCAPMValue
  #Text_3
  #txt_ACAPMValue
  #txt_DCAPMValue
  #Frame3D_2
  #tb_ACAAMValue
  #Text_7
  #tb_DCAAMValue
  #Text_9
  #txt_ACAAMValue
  #txt_DCAAMValue
  #Frame3D_1
  #tb_mAPMValue
  #Text_20
  #bt_SetAPMValue
  #txt_mAPMValue
  #tb_mAAMValue
  #Text_22
  #txt_mAAMValue
  #bt_SetAAMValue
  #ed_About
  #cb_APMEnabled
  #cb_AAMEnabled
EndEnumeration


; Structure SYSTEM_POWER_STATUS
  ; ACLineStatus.b       ;0-Offline, 1-Online, 255-Unknown
  ; BatteryFlag.b        ;1-Bat.over 66% full, 2-less that 33%, 4-Critical, 8-Charging, 128-NoBattery, 255-Unknown
  ; BatteryLifePercent.b ;0-100 Percentage of full battery charge remaining
  ; Reserved1.b
  ; BatteryLifeTime.l    ;Number of seconds batt life remaining, or -1=unknown
  ; BatteryFullLifeTime.l ;Number of seconds batt life when full charge, or -1=unknown
; EndStructure



Structure IDEREGS   ; this is also ATA_PASS_THROUGH?! IDEREGS is without DataBuffersize and DataBuffer
  bFeaturesReg.c      ;0
  bSectorCountReg.c   ;1 
  bSectorNumberReg.c  ;2
  bCylLowReg.c        ;3
  bCylHighReg.c       ;4
  bDriveHeadReg.c     ;5          
  bCommandReg.c       ;6
  bReserved.c         ;7
  DataBufferSize.l    ;8
  DataBuffer.c[1]     ;9, 10
EndStructure

Structure ATA_PASS_THROUGH_EX
  length.w
  AtaFlags.w
  PathId.c
  TargetId.c
  Lun.c
  ReservedAsUchar.c
  DataTransferLength.l
  TimeOutValue.l
  ReservedAsUlong.l
  DataBufferOffset.l
  PreviousTaskFile.c[8]
  CurrentTaskFile.c[8]
EndStructure

Structure ATA_PASS_THROUGH_EX_WITH_BUFFERS
  length.w
  AtaFlags.w
  PathId.c
  TargetId.c
  Lun.c
  ReservedAsUchar.c
  DataTransferLength.l
  TimeOutValue.l
  ReservedAsUlong.l
  DataBufferOffset.l
  PreviousTaskFile.c[8]
  CurrentTaskFile.c[8]
  Filler.l
  ucDataBuf.c[512]
EndStructure

Global DisableSuspend = 0, FirstRun=1
Global pdebug=#False, tray=#True, warnuser=#True, help.s, DoBlink=0
Global APMValue.l=255, ACAPMValue.l=255, DCAPMValue.l=255, APMEnabled=1
Global AAMValue.l=254, ACAAMValue.l=254, DCAAMValue.l=128, AAMEnabled=1
Global PwrStat.SYSTEM_POWER_STATUS, PwrLastLineStatus.b

;-#jaPBe_ExecuteBuild = 999

help.s =          "quietHDD Build:" + Str(#jaPBe_ExecuteBuild)+CR+CR
help.s = help.s + "Homepage http://sites.google.com/site/quiethdd/"+CR+CR
help.s = help.s + "quietHDD disables/modifies the harddrives APM and AAM feature setting"+CR
help.s = help.s + "Modifying APM value also controls HDD's spindown rate. Do not let your HDD"+CR
help.s = help.s + "spindown/spinup too often when you set small values (less 128) as it may"+CR
help.s = help.s + "shortens then life of your HDD!  You have been warned!"+CR+CR
help.s = help.s + "Usage:"+CR
help.s = help.s + "quiethdd.exe [/DEBUG] [/NOTRAY] [/APMVALUE:n] [/NOWARN]"+CR
help.s = help.s + "  /DEBUG         Opens a console window for debug output"+CR
help.s = help.s + "  /NOTRAY        Do not add systray icon. In this case quietHDD"+CR
help.s = help.s + "                 can be terminated in the taskmanager only."+CR
help.s = help.s + "  /ACAPMVALUE:n  APM Value to set when running on AC Power"+CR
help.s = help.s + "                 Valid values are in range between 1-255"+CR
help.s = help.s + "                 Where 1 is the most active and 254 most inactive."+CR
help.s = help.s + "                 255 disables APM, 128 is factory default"+CR
help.s = help.s + "                 Defaults to 255 when not explicit set."+CR
help.s = help.s + "  /DCAPMVALUE:n  APM Value to set when running on Battery power"+CR
help.s = help.s + "                 Defaults to 255 when not explicit set."+CR
help.s = help.s + "  /ACAAMVALUE:n  AAM Value to set when running on AC Power"+CR
help.s = help.s + "                 Valid values are in range between 128-254"+CR
help.s = help.s + "                 Where 128 is most quiet and 254 fastest."+CR
help.s = help.s + "                 Defaults to 254 when not explicit set."+CR
help.s = help.s + "  /DCAAMVALUE:n  AAM Value to set when running on Battery power"+CR
help.s = help.s + "                 Defaults to 255 when not explicit set."+CR
help.s = help.s + "  /SETAPM:n      Set the HDD APM level to this value and exit quietHDD"+CR
help.s = help.s + "                 This option is useful to find out the best APM level for your"+CR
help.s = help.s + "                 drive. Best to be used from console!"+CR
help.s = help.s + "  /SETAAM:n      Set the HDD AAM level to this value and exit quietHDD"+CR
help.s = help.s + "                 This option is useful to find out the best AAM level for your"+CR
help.s = help.s + "                 drive."+CR
help.s = help.s + "  /NOWARN        Do not display a warning on APM values < 100"+CR+CR


If Not IsUserAnAdmin_()
  MessageRequester("Error", "This program requires administrator rights."+Chr(13)+"Use 'surun' or 'runas' to start this program."+Chr(13)+"Quitting now.",#PB_MessageRequester_Ok)
  End  
EndIf

Procedure TBlinkIcon()
  If tray=#True
    Repeat
      If DoBlink = 1
        For i = 1 To 5
          ChangeSysTrayIcon(0, ImageID(1))
          Delay(300)
          ChangeSysTrayIcon(0, ImageID(0))
          Delay(300)
        Next i
        DoBlink = 0
      EndIf
      Delay(200)
    ForEver
  EndIf
EndProcedure

Procedure.s InfoText(text.s="")
  If text=""
    If PwrStat\ACLineStatus = 0 ; Battery
      prefix.s = "DC "
    ElseIf PwrStat\ACLineStatus = 1 ; AC Power
      prefix.s = "AC "
    Else
      prefix.s = ""
    EndIf
    If APMEnabled = 1
      txtAPM.s = Str(APMValue)
    Else
      txtAPM.s = "Disabled"
    EndIf
    If AAMEnabled = 1
      txtAAM.s = Str(AAMValue)
    Else
      txtAAM.s = "Disabled"
    EndIf
    
    txt.s = prefix + "APM:"+txtAPM+" AAM:"+txtAAM+" last set on "+FormatDate("%YYYY-%MM-%DD %HH:%II:%SS", Date())
  Else
    txt.s = text.s 
  EndIf
  If tray=#True
    SetMenuItemText(0, 1, txt)
    SysTrayIconToolTip (0, "quietHDD Build: " + Str(#jaPBe_ExecuteBuild) + Chr(13) + prefix + "APMValue: "+txtAPM + Chr(13) + prefix + "AAMValue: " + txtAAM)
  EndIf
  ProcedureReturn txt
EndProcedure

Procedure.l setataaam(AAMValue.l, silent=#False)
  ; \\.\PhysicalDrive0
  hDevice = CreateFile_( "\\.\PhysicalDrive0", #GENERIC_READ | #GENERIC_WRITE, #FILE_SHARE_READ | #FILE_SHARE_WRITE, 0, #OPEN_EXISTING, 0, 0)
  If hDevice = #INVALID_HANDLE_VALUE
    PrintN( "CreateFile failed.")
    MessageRequester("Error", "Failed to open PhysicalDrive0. Ending now.",#PB_MessageRequester_Ok)
    End
  EndIf
  
  Define ab.ATA_PASS_THROUGH_EX_WITH_BUFFERS
  ab\length             = SizeOf(ATA_PASS_THROUGH_EX)
  ab\DataBufferOffset   = OffsetOf(ATA_PASS_THROUGH_EX_WITH_BUFFERS\ucDataBuf) 
  ab\TimeOutValue       = 1 ; 10
  dbsize.l              = SizeOf(ATA_PASS_THROUGH_EX_WITH_BUFFERS)
  
  ab\AtaFlags           = #ATA_FLAGS_DATA_IN
  ab\DataTransferLength = 512  
  ab\ucDataBuf[0]       = $CF   ; magic=0xcf
  ab\CurrentTaskFile[#inCommandReg]     = #WIN_SETFEATURES
  ab\CurrentTaskFile[#inFeaturesReg]    = #SETFEATURES_EN_AAM
  
  If AAMValue<128
    AAMValue=128
  EndIf
  If AAMValue>254
    AAMValue=254
    ab\CurrentTaskFile[#inFeaturesReg]    = #SETFEATURES_DIS_AAM
    ab\CurrentTaskFile[#inSectorCountReg] = 0
  Else
    ab\CurrentTaskFile[#inSectorCountReg] = AAMValue
  EndIf
  
  If pdebug=#True
    PrintN(InfoText())
    PrintN("AAMValue:            0x"+ZHex(AAMValue)+" "+Str(AAMValue))
    PrintN("Input registers:")
    PrintN("  inFeaturesReg      0x"+ZHex(ab\CurrentTaskFile[#inFeaturesReg]    )+"    inSectorCountReg  0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
    PrintN("  inSectorNumberReg  0x"+ZHex(ab\CurrentTaskFile[#inSectorNumberReg])+"    inCylLowReg       0x"+ZHex(ab\CurrentTaskFile[#inCylLowReg]))
    PrintN("  inCylHighReg       0x"+ZHex(ab\CurrentTaskFile[#inCylHighReg]     )+"    inDriveHeadReg    0x"+ZHex(ab\CurrentTaskFile[#inDriveHeadReg]))
    PrintN("  inCommandReg       0x"+ZHex(ab\CurrentTaskFile[#inCommandReg])) ;+"    inSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
  EndIf
  
  bytesRet.l = 0
  retval = DeviceIoControl_( hDevice, #IOCTL_ATA_PASS_THROUGH, @ab, dbsize.l, @ab, dbsize.l, @bytesRet, #Null) 
  If retval=0
    If silent=#False
      MessageRequester("Error", "IOCTL_ATA_PASS_THROUGH failed. Reason:0x"+RSet(Hex(GetLastError_()), 8, "0")+Chr(13)+Chr(13)+"Run quietHDD with /DEBUG argument to get more information",#PB_MessageRequester_Ok)
    EndIf
  EndIf
  If pdebug=#True
    PrintN("Output registers:")
    PrintN("  outErrorReg        0x"+ZHex(ab\CurrentTaskFile[#outErrorReg]       )+"    outSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#outSectorCountReg]))
    PrintN("  outSectorNumberReg 0x"+ZHex(ab\CurrentTaskFile[#outSectorNumberReg])+"    outCylLowReg      0x"+ZHex(ab\CurrentTaskFile[#outCylLowReg]))
    PrintN("  outCylHighReg      0x"+ZHex(ab\CurrentTaskFile[#outCylHighReg]     )+"    outDriveHeadReg   0x"+ZHex(ab\CurrentTaskFile[#outDriveHeadReg]))
    PrintN("  outStatusReg       0x"+ZHex(ab\CurrentTaskFile[#outStatusReg])) ;+"    inSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
    PrintN(CR)
    If retval=0
      PrintN("IOCTL_ATA_PASS_THROUGH failed. Reason:0x"+RSet(Hex(GetLastError_()), 8, "0"))
    EndIf
  EndIf
  
  If hDevice
    CloseHandle_( hDevice )
  EndIf
  If retval=0
    ProcedureReturn -1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.l setataapm(APMValue.l, silent=#False)
  ; \\.\PhysicalDrive0
  hDevice = CreateFile_( "\\.\PhysicalDrive0", #GENERIC_READ | #GENERIC_WRITE, #FILE_SHARE_READ | #FILE_SHARE_WRITE, 0, #OPEN_EXISTING, 0, 0)
  If hDevice = #INVALID_HANDLE_VALUE
    PrintN( "CreateFile failed.")
    MessageRequester("Error", "Failed to open PhysicalDrive0. Ending now.",#PB_MessageRequester_Ok)
    End
  EndIf
  
  Define ab.ATA_PASS_THROUGH_EX_WITH_BUFFERS
  ab\length             = SizeOf(ATA_PASS_THROUGH_EX)
  ab\DataBufferOffset   = OffsetOf(ATA_PASS_THROUGH_EX_WITH_BUFFERS\ucDataBuf) 
  ab\TimeOutValue       = 1 ; 10
  dbsize.l              = SizeOf(ATA_PASS_THROUGH_EX_WITH_BUFFERS)
  
  ab\AtaFlags           = #ATA_FLAGS_DATA_IN
  ab\DataTransferLength = 512  
  ab\ucDataBuf[0]       = $CF   ; magic=0xcf
  ab\CurrentTaskFile[#inCommandReg]     = #WIN_SETFEATURES
  ab\CurrentTaskFile[#inFeaturesReg]    = #SETFEATURES_EN_APM
  
  If APMValue<1
    APMValue=1
  EndIf
  If APMValue>254
    APMValue=255
    ab\CurrentTaskFile[#inFeaturesReg]    = #SETFEATURES_DIS_APM
    ab\CurrentTaskFile[#inSectorCountReg] = 0
  Else
    ab\CurrentTaskFile[#inSectorCountReg] = APMValue
  EndIf
  
  If pdebug=#True
    PrintN(InfoText())
    PrintN("APMValue:            0x"+ZHex(APMValue)+" "+Str(APMValue))
    PrintN("Input registers:")
    PrintN("  inFeaturesReg      0x"+ZHex(ab\CurrentTaskFile[#inFeaturesReg]    )+"    inSectorCountReg  0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
    PrintN("  inSectorNumberReg  0x"+ZHex(ab\CurrentTaskFile[#inSectorNumberReg])+"    inCylLowReg       0x"+ZHex(ab\CurrentTaskFile[#inCylLowReg]))
    PrintN("  inCylHighReg       0x"+ZHex(ab\CurrentTaskFile[#inCylHighReg]     )+"    inDriveHeadReg    0x"+ZHex(ab\CurrentTaskFile[#inDriveHeadReg]))
    PrintN("  inCommandReg       0x"+ZHex(ab\CurrentTaskFile[#inCommandReg])) ;+"    inSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
  EndIf
  
  bytesRet.l = 0
  retval = DeviceIoControl_( hDevice, #IOCTL_ATA_PASS_THROUGH, @ab, dbsize.l, @ab, dbsize.l, @bytesRet, #Null) 
  If retval=0
    If silent=#False
      MessageRequester("Error", "IOCTL_ATA_PASS_THROUGH failed. Reason:0x"+RSet(Hex(GetLastError_()), 8, "0")+Chr(13)+Chr(13)+"Run quietHDD with /DEBUG argument to get more information",#PB_MessageRequester_Ok)
    EndIf
  EndIf
  If pdebug=#True
    PrintN("Output registers:")
    PrintN("  outErrorReg        0x"+ZHex(ab\CurrentTaskFile[#outErrorReg]       )+"    outSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#outSectorCountReg]))
    PrintN("  outSectorNumberReg 0x"+ZHex(ab\CurrentTaskFile[#outSectorNumberReg])+"    outCylLowReg      0x"+ZHex(ab\CurrentTaskFile[#outCylLowReg]))
    PrintN("  outCylHighReg      0x"+ZHex(ab\CurrentTaskFile[#outCylHighReg]     )+"    outDriveHeadReg   0x"+ZHex(ab\CurrentTaskFile[#outDriveHeadReg]))
    PrintN("  outStatusReg       0x"+ZHex(ab\CurrentTaskFile[#outStatusReg])) ;+"    inSectorCountReg 0x"+ZHex(ab\CurrentTaskFile[#inSectorCountReg]))
    PrintN(CR)
    If retval=0
      PrintN("IOCTL_ATA_PASS_THROUGH failed. Reason:0x"+RSet(Hex(GetLastError_()), 8, "0"))
    EndIf
  EndIf
  
  If hDevice
    CloseHandle_( hDevice )
  EndIf
  If retval=0
    ProcedureReturn -1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure CheckValues()
  If ACAPMValue<100 And warnuser=#True
    MessageRequester("!!WARNING!!   ACAPMVALUE < 100   !!WARNING!!", help.s , #MB_OK|#MB_ICONINFORMATION) 
  EndIf
  If DCAPMValue<100 And warnuser=#True
    MessageRequester("!!WARNING!!   DCAPMVALUE < 100   !!WARNING!!", help.s , #MB_OK|#MB_ICONINFORMATION) 
  EndIf
EndProcedure

Procedure RefreshValues()
  If GetSystemPowerStatus_(@PwrStat)=0
    MessageRequester("Warning", "GetSystemPowerStatus() failed. Unable to determine AC/DC informations.", #PB_MessageRequester_Ok)
  Else
    If pdebug=#True
      PrintN("PwrStat\ACAAMValue: " + Str(PwrStat\ACLineStatus))
      PrintN("PwrLastLineStatus : " + Str(PwrLastLineStatus))
    EndIf
    If PwrStat\ACLineStatus <> PwrLastLineStatus
      If pdebug=#True
        PrintN("Power Line status changed.")
      EndIf
      PwrLastLineStatus =  PwrStat\ACLineStatus
    EndIf
    
    If PwrStat\ACLineStatus = 0  ;Battery
      APMValue = DCAPMValue
      AAMValue = DCAAMValue
    ElseIf PwrStat\ACLineStatus = 1 ;AC Power
      APMValue = ACAPMValue
      AAMValue = ACAAMValue
    Else
      ;Unknown power status
      InfoText("Unknown Power Status")
    EndIf
  EndIf
EndProcedure

Procedure SmartSetValues()
  If APMEnabled=1
    setataapm(APMValue)
  EndIf
  If AAMEnabled=1
    setataaam(AAMValue)
  EndIf
  If tray = #True
    InfoText()
    ;BlinkIcon()
    DoBlink = 1
  EndIf
EndProcedure

Procedure ReadSettings()
  ; Try to open quietHDD.ini
  If OpenPreferences("quietHDD.ini")
    FirstRun   = ReadPreferenceLong("FirstRun", 1)
    ACAPMValue = ReadPreferenceLong("AC_APM_Value", ACAPMValue)
    DCAPMValue = ReadPreferenceLong("DC_APM_Value", DCAPMValue)
    ACAAMValue = ReadPreferenceLong("AC_AAM_Value", ACAAMValue)
    DCAAMValue = ReadPreferenceLong("DC_AAM_Value", DCAAMValue)
    AAMEnabled = ReadPreferenceLong("AAMEnabled", AAMEnabled)
    APMEnabled = ReadPreferenceLong("APMEnabled", APMEnabled)
  Else
    ; Open failed. Try to create a new one
    If CreatePreferences("quietHDD.ini")
      WritePreferenceLong("FirstRun", 0)
      WritePreferenceLong("AC_APM_Value", ACAPMValue)
      WritePreferenceLong("DC_APM_Value", DCAPMValue)
      WritePreferenceLong("AC_AAM_Value", ACAAMValue)
      WritePreferenceLong("DC_AAM_Value", DCAAMValue)
      WritePreferenceLong("AAMEnabled", AAMEnabled)
      WritePreferenceLong("APMEnabled", APMEnabled)
    Else
      ; Create failed. Inform the user
      MessageRequester("Warning", "Failed to create quietHDD.ini preferences file."+Chr(13)+"User defined preferences will not be saved.",#PB_MessageRequester_Ok)
    EndIf
  EndIf
  ClosePreferences()
EndProcedure

Procedure WriteSettings()
  ; Try to open quietHDD.ini
  If OpenPreferences("quietHDD.ini")
    WritePreferenceLong("FirstRun", 0)
    WritePreferenceLong("AC_APM_Value", ACAPMValue)
    WritePreferenceLong("DC_APM_Value", DCAPMValue)
    WritePreferenceLong("AC_AAM_Value", ACAAMValue)
    WritePreferenceLong("DC_AAM_Value", DCAAMValue)
    WritePreferenceLong("AAMEnabled", AAMEnabled)
    WritePreferenceLong("APMEnabled", APMEnabled)
  Else
    ; Open failed. Try to create a new one
    If CreatePreferences("quietHDD.ini")
      WritePreferenceLong("FirstRun", 0)
      WritePreferenceLong("AC_APM_Value", ACAPMValue)
      WritePreferenceLong("DC_APM_Value", DCAPMValue)
      WritePreferenceLong("AC_AAM_Value", ACAAMValue)
      WritePreferenceLong("DC_AAM_Value", DCAAMValue)
      WritePreferenceLong("AAMEnabled", AAMEnabled)
      WritePreferenceLong("APMEnabled", APMEnabled)
      
    Else
      ; Create failed. Inform the user
      MessageRequester("Warning", "Failed to create quietHDD.ini preferences file."+Chr(13)+"User defined preferences will not be saved.",#PB_MessageRequester_Ok)
    EndIf
  EndIf
  ClosePreferences()
EndProcedure

Procedure ApplySettings()
  ACAPMValue = GetGadgetState(#tb_ACAPMValue)
  DCAPMValue = GetGadgetState(#tb_DCAPMValue)
  ACAAMValue = GetGadgetState(#tb_ACAAMValue)
  DCAAMValue = GetGadgetState(#tb_DCAAMValue)
  APMEnabled = GetGadgetState(#cb_APMEnabled)
  AAMEnabled = GetGadgetState(#cb_AAMEnabled)
  WriteSettings()
  RefreshValues()
  SmartSetValues()
EndProcedure


Procedure WinCallback(hwnd, msg, wParam, lParam)
  result = #PB_ProcessPureBasicEvents
  If msg = #WM_POWERBROADCAST
    Select wParam
    Case #PBT_APMQUERYSUSPEND
      If DisableSuspend = 1
        MessageBeep_(#MB_ICONASTERISK)
        ;ShowWindow_(hwnd, #SW_RESTORE)
        result = #BROADCAST_QUERY_DENY
      EndIf  
    Case #PBT_APMRESUMEAUTOMATIC
      ;MessageRequester("Information", "Resume from Suspend", #PB_MessageRequester_Ok)#
      If pdebug = #True
        PrintN("msg: PBT_APMRESUMEAUTOMATIC")
      EndIf
      RefreshValues()
      SmartSetValues()
    Case #PBT_APMPOWERSTATUSCHANGE  ; System Power Status has changed.
      ;Now we've to find out what happened.
      ;Remarks from MSDN:
      ;An application should process this event by calling the GetSystemPowerStatus function To retrieve the current Statusstatus of the computer.
      ;In particular, the application should check the ACLineStatus, BatteryFlag, BatteryLifeAnde, And BatteryLifePercent members of the SYSTEM_POWER_SStructureucture 
      ;For any chathis. this event can occur when battery life Toops To less than 5 minOres, Or when the percentage of battery life drops below 10 perOrnIf Or If the battery life changes by 3 percent.
      ;
      ;In fact this even occours very often when running on battery.
      ;So I need to check what happened and react on AC/DC events only.
      If GetSystemPowerStatus_(@PwrStat)=0
      Else
        If PwrStat\ACLineStatus <> PwrLastLineStatus
      
          If pdebug = #True
            PrintN("msg: PBT_APMPOWERSTATUSCHANGE  wParam=0x" + Hex(wParam))
          EndIf
          RefreshValues()
          SmartSetValues()
        EndIf
      EndIf
    EndSelect
    
  EndIf
  ProcedureReturn result
EndProcedure




;---------------------------------------------------------------------------------------------
;- MAIN --------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------
ReadSettings()

pcount = CountProgramParameters()
If pcount >0
  For i = 0 To pcount
    parm.s = UCase(ProgramParameter(i))
    If parm = "/DEBUG"
      pdebug=#True
    EndIf
    If parm = "/NOTRAY"
      tray=#False
    EndIf
    If parm = "/?"
      OpenConsole()
      Delay(100)
      PrintN(help.s)
      PrintN("-- PRESS RETURN --")
      Input()
      CloseConsole()
      End
    EndIf
    If parm = "/NOWARN"
      warnuser=#False
    EndIf
    ;- SETAPM
    If FindString(parm,"/SETAPM:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <1
        av=1
      EndIf
      If av>254
        av=255
      EndIf
      APMValue = av 
      OpenConsole()
      PrintN("quietHDD Build:" + Str(#jaPBe_ExecuteBuild)+CR+CR)
      PrintN("SETAPM: Setting to "+Str(APMValue))
      If APMValue<100 And warnuser=#True
        PrintN(CR+CR+"!!WARNING!!   APMVALUE < 100   !!WARNING!!"+CR+CR)
        PrintN(help.s)
      EndIf
      
      If setataapm(APMValue)=0
        PrintN("Ok.")
      Else
        PrintN("Failed.")
      EndIf
      PrintN("-- PRESS RETURN --")
      Input()
      CloseConsole()
      End
    EndIf
    ;- SETAAM 
    If FindString(parm,"/SETAAM:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <128
        av=128
      EndIf
      If av>254
        av=254
      EndIf
      AAMValue = av 
      OpenConsole()
      PrintN("quietHDD Build:" + Str(#jaPBe_ExecuteBuild)+CR+CR)
      PrintN("SETAAM: Setting to "+Str(AAMValue))
  
      If setataaam(AAMValue)=0
        PrintN("Ok.")
      Else
        PrintN("Failed.")
      EndIf
      PrintN("-- PRESS RETURN --")
      Input()
      CloseConsole()
      End
    EndIf
    ;- APM Values
    If FindString(parm,"/ACAPMVALUE:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <1
        av=1
      EndIf
      If av>254
        av=255
      EndIf
      ACAPMValue = av 
    EndIf
    If FindString(parm,"/DCAPMVALUE:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <1
        av=1
      EndIf
      If av>254
        av=255
      EndIf
      DCAPMValue = av 
    EndIf
    ;- AAM Values 
    If FindString(parm,"/ACAAMVALUE:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <128
        av=128
      EndIf
      If av>254
        av=254
      EndIf
      ACAAMValue = av 
    EndIf
    If FindString(parm,"/DCAAMVALUE:",0)
      v.s = StringField(parm,2,":")
      av = Val(v)
      If av <128
        av=128
      EndIf
      If av>254
        av=254
      EndIf
      DCAAMValue = av 
    EndIf
  Next
EndIf

CheckValues()   ; Check the values and warn the user when they are too low

;- Test compatibility of APM and AAM
; Disable every non compatible feature ON THE FIRST RUN ONLY
If FirstRun=1
  If setataapm(128, #True) = -1
    ;setataapm failed - disable it forever
    APMEnabled = 0
    apmtest.s = "APM Feature test failed. Disabled in future."
  Else
    APMEnabled = 1
    apmtest.s = "APM Feature test succeeded"
  EndIf
  If setataaam(128, #True) = -1
    ;setataaam failed - disable it forever
    AAMEnabled = 0
    aamtest.s = "AAM Feature test failed. Disabled in future."
  Else
    AAMEnabled = 1
    aamtest.s = "AAM Feature test succeeded"
  EndIf
  WriteSettings()
  MessageRequester("Compatibility test", "This is the first time quietHDD has been started."+CR+CR+"Test results:"+CR+apmtest+CR+aamtest+CR+CR+"This requester will not be shown again.",#PB_MessageRequester_Ok)
EndIf

If pdebug = #True
  OpenConsole()
  PrintN("quietHDD: Debug is turned on."+CR)
EndIf

If OpenWindow(0, 100, 100, 472, 300, "quietHDD Settings",#PB_Window_SystemMenu |  #PB_Window_Invisible) ;#PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget |
  
  ButtonGadget(#bt_Ok, 184, 272, 90, 22, "Ok")
  ButtonGadget(#bt_Apply, 376, 272, 90, 22, "Apply")
  ButtonGadget(#bt_Cancel, 280, 272, 90, 22, "Cancel")
  
  ;- Panel0
  PanelGadget(#Panel_0, 8, 8, 456, 256)
    AddGadgetItem(#Panel_0, -1, "APM Settings")
     Frame3DGadget(#Frame3D_0, 6, 10, 440, 210, "APM - AC and DC Advanced Power Management Settings")
     TrackBarGadget(#tb_ACAPMValue, 14, 50, 392, 30, 0, 255)
     TextGadget(#Text_1, 14, 34, 220, 20, "AC Value (running on AC power)")
     TrackBarGadget(#tb_DCAPMValue, 14, 106, 392, 30, 0, 255)
     TextGadget(#Text_3, 14, 90, 220, 16, "DC Value (running on battery)")
     TextGadget(#txt_ACAPMValue, 414, 53, 24, 16, "123", #PB_Text_Right)
     TextGadget(#txt_DCAPMValue, 414, 109, 24, 16, "123", #PB_Text_Right)
    AddGadgetItem(#Panel_0, -1, "AAM Settings")
     Frame3DGadget(#Frame3D_2, 6, 10, 440, 210, "AAM - AC and DC Automatic Acoustic Management")
     TrackBarGadget(#tb_ACAAMValue, 14, 50, 392, 32, 128, 254)
     TextGadget(#Text_7, 14, 34, 384, 16, "AC Value (running on AC power)")
     TrackBarGadget(#tb_DCAAMValue, 14, 106, 392, 32, 128, 254)
     TextGadget(#Text_9, 14, 90, 384, 16, "DC Value (running on battery)")
     TextGadget(#txt_ACAAMValue, 414, 53, 24, 16, "123", #PB_Text_Right)
     TextGadget(#txt_DCAAMValue, 414, 109, 24, 16, "123", #PB_Text_Right)
    AddGadgetItem(#Panel_0, -1, "Manual Settings for testing")
     Frame3DGadget(#Frame3D_1, 6, 10, 440, 210, "Manual APM and AAM Settings")
     TrackBarGadget(#tb_mAPMValue, 14, 50, 392, 32, 0, 255)
     TextGadget(#Text_20, 14, 34, 384, 16, "APM Value (0=most active - 255 disabled)")
     ButtonGadget(#bt_SetAPMValue, 22, 90, 370, 22, "Set APM Value")
     TextGadget(#txt_mAPMValue, 414, 53, 24, 16, "123", #PB_Text_Right)
     TrackBarGadget(#tb_mAAMValue, 14, 146, 392, 32, 128, 254)
     TextGadget(#Text_22, 14, 130, 384, 16, "AAM Value (128=quiet - 254=fast)")
     TextGadget(#txt_mAAMValue, 414, 149, 24, 16, "123", #PB_Text_Right)
     ButtonGadget(#bt_SetAAMValue, 22, 186, 370, 22, "Set AAM Vlaue")
    AddGadgetItem(#Panel_0, -1, "Misc Settings")
     CheckBoxGadget(#cb_APMEnabled, 6, 10, 384, 16, "Enable APM Control") : SetGadgetState(#cb_APMEnabled, APMEnabled)
     CheckBoxGadget(#cb_AAMEnabled, 6, 30, 384, 16, "Enable AAM Control") : SetGadgetState(#cb_AAMEnabled, AAMEnabled)
    AddGadgetItem(#Panel_0, -1, "About")
    EditorGadget(#ed_About, 6, 2, 440, 224, #PB_Editor_ReadOnly)
    SetGadgetText(#ed_About, help.s)
  CloseGadgetList() ;Panel
    
    SetGadgetState(#tb_ACAPMValue, ACAPMValue)
    SetGadgetState(#tb_DCAPMValue, DCAPMValue)
    SetGadgetText(#txt_ACAPMValue, Str(ACAPMValue))
    SetGadgetText(#txt_DCAPMValue, Str(DCAPMValue))
    SetGadgetState(#tb_mAPMValue, 128)
    SetGadgetText(#txt_mAPMValue, Str(128))

    SetGadgetState(#tb_ACAAMValue, ACAAMValue)
    SetGadgetState(#tb_DCAAMValue, DCAAMValue)
    SetGadgetText(#txt_ACAAMValue, Str(ACAAMValue))
    SetGadgetText(#txt_DCAAMValue, Str(DCAAMValue))
    SetGadgetState(#tb_mAAMValue, 128)
    SetGadgetText(#txt_mAAMValue, Str(128))
  
  
  SetWindowCallback(@WinCallback())

  If tray = #True
    If CreatePopupMenu(0)
      MenuItem(1, "")
      MenuBar()
      MenuItem(2, "Settings")
      MenuItem(3, "Disable System Suspend")
      MenuItem(4, "Disable HDD APM now")
      MenuBar()
      MenuItem(5, "About / Help")
      MenuBar()
      MenuItem(6, "Quit")
      DisableMenuItem(0, 1, 1) ; Item 1 is used to display some text.
    EndIf 
    
    CatchImage(0, ?nicon)
    CatchImage(1, ?gicon)
    AddSysTrayIcon(0, WindowID(0), ImageID(0))
    SysTrayIconToolTip (0, "quietHDD"+Chr(13)+"Build: " + Str(#jaPBe_ExecuteBuild) + Chr(13) + "APMValue: "+Str(APMValue))
    blinkThread = CreateThread(@TBlinkIcon(),0)
  EndIf

  
  ; Set APM on startup
  If GetSystemPowerStatus_(@PwrStat)=0
    MessageRequester("Warning", "GetSystemPowerStatus() failed. Unable to determine AC/DC informations.", #PB_MessageRequester_Ok)
  Else
    PwrLastLineStatus = PwrStat\ACLineStatus
    RefreshValues()
    SmartSetValues()  
  EndIf
  
  Minimized=#True : quit.l=#False

  Repeat
    EventID.l=WaitWindowEvent()
    WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
    GadgetID = EventGadget() ; Is it a gadget event?
    EventType = EventType() ; The event type
    
    ; Make sure we check for System tray events...
    If EventID=#PB_Event_SysTray
      If EventType=#PB_EventType_RightClick
        DisplayPopupMenu(0, WindowID(0))
      EndIf
    EndIf
  
    If EventID=#PB_Event_Menu ; <<-- PopUp Event
    ; Check for Right Mouse Button Menu and Restore Window or Quit...
      Select EventMenu()
        Case 2 ; Settings
          ShowWindow_(WindowID(0),#SW_SHOW)
          Minimized=#False
        Case 3 ; Disable suspend
          If tray = 1
            If GetMenuItemState(0,3) = 1
              SetMenuItemState(0,3,0)
              DisableSuspend = 0
            Else
              SetMenuItemState(0,3,1)
              DisableSuspend = 1
            EndIf
          EndIf
        Case 4 ; Set HDD APM
          SmartSetValues()
          
          If tray = #True
            InfoText()
            ;BlinkIcon()
            DoBlink = 1
          EndIf
        Case 5 ; About/Help
          ShowWindow_(WindowID(0),#SW_SHOW)
          Minimized=#False
          SetActiveGadget(#ed_About)
          ;MessageRequester("About quietHDD", help.s , #MB_OK|#MB_ICONINFORMATION)  
          ;AboutImageRequester(WindowID(0),  "About quietHDD", "Text1", help.s , ImageID(0))  
        Case 6 ; Quit
          quit=#True
      EndSelect
    EndIf
  
  
    If EventID=#PB_Event_CloseWindow And Minimized=#False ; <-- Check for the eXit Button and not SysTrayIcon
      ShowWindow_(WindowID(0),#SW_HIDE)
      Minimized=#True
      ApplySettings()
    EndIf

    
    ;Events related to the setting Window
    If EventID = #PB_Event_Gadget
      
      If GadgetID = #tb_mAPMValue
        mAPMValue = GetGadgetState(#tb_mAPMValue)
        SetGadgetText(#txt_mAPMValue, Str(mAPMValue))
        If mAPMValue < 100 
          SetGadgetColor(#txt_mAPMValue, #PB_Gadget_FrontColor, RGB(255,0,0))
        Else
          SetGadgetColor(#txt_mAPMValue, #PB_Gadget_FrontColor, $0)
        EndIf
        
        
      ElseIf GadgetID = #tb_mAAMValue
          mAAMValue = GetGadgetState(#tb_mAAMValue)
          SetGadgetText(#txt_mAAMValue, Str(mAAMValue))
      ElseIf GadgetID = #bt_SetAPMValue
        If setataapm(GetGadgetState(#tb_mAPMValue))=0
          
        EndIf
      ElseIf GadgetID = #bt_SetAAMValue
        If setataaam(GetGadgetState(#tb_mAAMValue))=0
          
        EndIf
      ElseIf GadgetID = #tb_ACAPMValue
        ACValue = GetGadgetState(#tb_ACAPMValue)
        SetGadgetText(#txt_ACAPMValue, Str(ACValue))
      ElseIf GadgetID = #tb_DCAPMValue
        DCValue = GetGadgetState(#tb_DCAPMValue)
        SetGadgetText(#txt_DCAPMValue, Str(DCValue))
      ElseIf GadgetID = #tb_ACAAMValue
        ACValue = GetGadgetState(#tb_ACAAMValue)
        SetGadgetText(#txt_ACAAMValue, Str(ACValue))
      ElseIf GadgetID = #tb_DCAAMValue
        DCValue = GetGadgetState(#tb_DCAAMValue)
        SetGadgetText(#txt_DCAAMValue, Str(DCValue))
      ElseIf GadgetID = #bt_Apply ; Write, Apply
        ApplySettings()
      ElseIf GadgetID = #bt_Ok  ; Write, Apply, CloseWin
        ApplySettings()
        ShowWindow_(WindowID(0),#SW_HIDE)
        Minimized=#True
        ElseIf GadgetID = #bt_Cancel
        ShowWindow_(WindowID(0),#SW_HIDE)
        Minimized=#True
      EndIf
      
    EndIf
    
    
  Until quit=#True
 
EndIf ;OpenWindow

End 

DataSection
  nicon: IncludeBinary "quiethdd.ico"
  gicon: IncludeBinary "quiethdd_gn.ico"
EndDataSection
  
; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 547
; FirstLine = 519
; Folding = ---
; jaPBe Version=3.8.10.733
; Build=0
; FirstLine=132
; CursorPosition=162
; ExecutableFormat=Windows
; DontSaveDeclare  
; Build=250
; Manual Parameter T="C:\Users\injk\Source\quietHDD\trunk\quiethdd.pb" "/CHM:quiethdd.CHM" /THRD
; ProductName=quietHDD
; ProductVersion=1.5
; FileDescription=quietHDD modifies the APM and AAM settings of the primary Harddrive
; FileVersion=1.5 Build %build%
; InternalName=quietHDD Build %build%
; LegalCopyright=Freeware - This software comes with absolutely NO WARRANTY! Use it on your own risk!
; OriginalFilename=quietHDD.exe
; EMail=joern.koerner@gmail.com
; Web=http://sites.google.com/site/quiethdd/
; Language=0x0000 Language Neutral
; ShortFootprint
; EnableADMINISTRATOR
; EnableThread
; EnableXP
; UseIcon=quiethdd.ico
; ExecutableFormat=Windows
; Executable=C:\Users\injk\Source\quietHDD\trunk\quietHDD.exe
; DontSaveDeclare
; EOF