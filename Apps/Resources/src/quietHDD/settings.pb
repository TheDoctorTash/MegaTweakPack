; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

IncludeFile "Common.pb"

Open_Window_0()

Repeat ; Start of the event loop
  
  Event = WaitWindowEvent() ; This line waits until an event is received from Windows
  
  WindowID = EventWindow() ; The Window where the event is generated, can be used in the gadget procedures
  
  GadgetID = EventGadget() ; Is it a gadget event?
  
  EventType = EventType() ; The event type
  
  ;You can place code here, and use the result as parameters for the procedures
  
  If Event = #PB_Event_Gadget
    
    If GadgetID = #tb_mAPMValue
      
    ElseIf GadgetID = #bt_Apply
      
    ElseIf GadgetID = #bt_Ok
      
    ElseIf GadgetID = #bt_Cancel
      
    ElseIf GadgetID = #Panel_0
      
    ElseIf GadgetID = #tb_ACAPMValue
      
    ElseIf GadgetID = #tb_DCAPMValue
      
    ElseIf GadgetID = #tb_ACAAMValue
      
    ElseIf GadgetID = #tb_DCAAMValue
      
    ElseIf GadgetID = #bt_SetAPMVlaue
      
    ElseIf GadgetID = #tb_mAAMValue
      
    ElseIf GadgetID = #bt_SetAAMVlaue
      
    ElseIf GadgetID = #ed_About
      
    Endif
    
  EndIf
  
Until Event = #PB_Event_CloseWindow ; End of the event loop

End
;
