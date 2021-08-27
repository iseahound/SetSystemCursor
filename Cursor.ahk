; Source:   Serenity - https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
; Modified: iseahound - https://www.autohotkey.com/boards/viewtopic.php?t=75867

SetSystemCursor(Cursor := "", cx := 0, cy := 0) {

   SystemCursors := "32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS,32516IDC_UPARROW,32642IDC_SIZENWSE,32643IDC_SIZENESW,"
                  . "32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP"

   if (Cursor = "") {
      AndMask := Buffer(128, 0xFF), XorMask := Buffer(128, 0)

      Loop Parse, SystemCursors, ","
      {
         CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", AndMask, "ptr", XorMask, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }

   if (Cursor ~= "i)(AppStarting|Arrow|Cross|Hand|Help|IBeam|Icon|No|Size|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)") {
      Loop Parse, SystemCursors, ","
      {
         CursorName := SubStr(A_LoopField, 6) ; get the cursor name
         CursorID := SubStr(A_LoopField, 1, 5) ; get the cursor id
      } until (CursorName ~= "i)" Cursor)

      if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", CursorID, "ptr"))
         throw Error("Error: Invalid cursor name")

      Loop Parse, SystemCursors, ","
      {
         CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }

   if FileExist(Cursor) {
      SplitPath Cursor,,, &Ext:="" ; auto-detect type
      if !(uType := (Ext = "ani" || Ext = "cur") ? 2 : (Ext = "ico") ? 1 : 0)
         throw Error("Error: Invalid file type")

      if (Ext = "ani") {
         Loop Parse, SystemCursors, ","
         {
            CursorHandle := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x10, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
         }
      } else {
         if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x00008010, "ptr"))
            throw Error("Error: Corrupted file")

         Loop Parse, SystemCursors, ","
         {
            CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
         }
      }
      return
   }

   throw Error("Error: Invalid file path or cursor name")
}

RestoreCursor() {
   return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}
