#include Cursor.ahk

DllCall("QueryPerformanceFrequency", "int64*", &frequency:=0)
f := 300, a := 0, b := 0

; A small delay helps even out benchmarks.
Sleep 2000

p1 := "IDC_SizeWE"
p2 := 0
P3 := 0

; Make sure to place the tests together to reduce branch prediction.
Loop f {

DllCall("QueryPerformanceCounter", "int64*", &start:=0)
SetSystemCursor2(p1, p2, p3)
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
a += end - start
RestoreCursor()
Sleep 1

DllCall("QueryPerformanceCounter", "int64*", &start:=0)
SetSystemCursor(p1, p2, p3)
DllCall("QueryPerformanceCounter", "int64*", &end:=0)
b += end - start
RestoreCursor()
Sleep 1

}

a := a / frequency
b := b / frequency

if (a > b)
   winner := "New Version wins by " a - b " seconds and is " Abs(a - b)/b*100 "% faster."
else
   winner := "Old Version wins by " b - a " seconds and is " Abs(a - b)/a*100 "% faster."

MsgBox "Old Version:`t" f/a " fps"
     . "`nNew Version:`t" f/b " fps"
     . "`n" winner


ExitApp
Esc:: ExitApp

SetSystemCursor2(Cursor := "", cx := 0, cy := 0) {

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

   if (Cursor ~= "i)(AppStarting|Arrow|Cross|Hand|Help|IBeam|No|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)") {
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
         if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x8010, "ptr"))
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
