; PureBasic Visual Designer v3.95 build 1485 (PB4Code)


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
EndEnumeration


Procedure Open_Window_0()
  If OpenWindow(#Window_0, 100, 427, 473, 300, "quietHDD Settings",  #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_TitleBar )
    If CreateGadgetList(WindowID(#Window_0))
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
      TrackBarGadget(#tb_mAPMValue, 14, 50, 392, 32, 0, 254)
      TextGadget(#Text_20, 14, 34, 384, 16, "APM Value (0=most active - 255 disabled)")
      ButtonGadget(#bt_SetAPMValue, 22, 90, 370, 22, "Set APM Value")
      TextGadget(#txt_mAPMValue, 414, 53, 24, 16, "123", #PB_Text_Right)
      TrackBarGadget(#tb_mAAMValue, 14, 146, 392, 32, 128, 254)
      TextGadget(#Text_22, 14, 130, 384, 16, "AAM Value (128=quiet - 254=fast)")
      TextGadget(#txt_mAAMValue, 414, 149, 24, 16, "123", #PB_Text_Right)
      ButtonGadget(#bt_SetAAMValue, 22, 186, 370, 22, "Set AAM Vlaue")
      AddGadgetItem(#Panel_0, -1, "Misc Settings")
      AddGadgetItem(#Panel_0, -1, "About")
      EditorGadget(#ed_About, 6, 2, 440, 224)
      CloseGadgetList()
      
    EndIf
  EndIf
EndProcedure

