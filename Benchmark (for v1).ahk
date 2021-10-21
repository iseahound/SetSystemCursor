#include Cursor (for v1).ahk
SetBatchLines -1
DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
f := 300, a := 0, b := 0

; A small delay helps even out benchmarks.
Sleep 2000

p1 := "IDC_SizeWE"
p2 := 0
P3 := 0

; Make sure to place the tests together to reduce branch prediction.
Loop % f {

DllCall("QueryPerformanceCounter", "int64*", start:=0)
SetSystemCursor2(p1, p2, p3)
DllCall("QueryPerformanceCounter", "int64*", end:=0)
a += end - start
RestoreCursor()
Sleep 1

DllCall("QueryPerformanceCounter", "int64*", start:=0)
SetSystemCursor(p1, p2, p3)
DllCall("QueryPerformanceCounter", "int64*", end:=0)
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

MsgBox % "Old Version:`t" f/a " fps"
     . "`nNew Version:`t" f/b " fps"
     . "`n" winner


ExitApp
Esc:: ExitApp

SetSystemCursor0( Cursor = "", cx = 0, cy = 0 )
{
	BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init
	
	SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
	,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
	,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
	,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP
	
	If Cursor = ; empty, so create blank cursor 
	{
		VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
		BlankCursor = 1 ; flag for later
	}
	Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
	{
		Loop, Parse, SystemCursors, `,
		{
			CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
			CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
			SystemCursor = 1
			If ( CursorName = Cursor )
			{
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
				Break					
			}
		}	
		If CursorHandle = ; invalid cursor name given
		{
			Msgbox,, SetCursor, Error: Invalid cursor name
			CursorHandle = Error
		}
	}	
	Else If FileExist( Cursor )
	{
		SplitPath, Cursor,,, Ext ; auto-detect type
		If Ext = ico 
			uType := 0x1	
		Else If Ext in cur,ani
			uType := 0x2		
		Else ; invalid file ext
		{
			Msgbox,, SetCursor, Error: Invalid file type
			CursorHandle = Error
		}		
		FileCursor = 1
	}
	Else
	{	
		Msgbox,, SetCursor, Error: Invalid file path or cursor name
		CursorHandle = Error ; raise for later
	}
	If CursorHandle != Error 
	{
		Loop, Parse, SystemCursors, `,
		{
			If BlankCursor = 1 
			{
				Type = BlankCursor
				%Type%%A_Index% := DllCall( "CreateCursor"
				, Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}			
			Else If SystemCursor = 1
			{
				Type = SystemCursor
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
				%Type%%A_Index% := DllCall( "CopyImage"
				, Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )		
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
			Else If FileCursor = 1
			{
				Type = FileCursor
				%Type%%A_Index% := DllCall( "LoadImageA"
				, UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 ) 
				DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )			
			}          
		}
	}	
}

; Source:   Serenity - https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
; Modified: iseahound - https://www.autohotkey.com/boards/viewtopic.php?t=75867

SetSystemCursor2(Cursor := "", cx := 0, cy := 0) {

   SystemCursors := "32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS,32516IDC_UPARROW,32642IDC_SIZENWSE,32643IDC_SIZENESW,"
                  . "32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP"

   if (Cursor = "") {
      VarSetCapacity(AndMask, 128, 0xFF), VarSetCapacity(XorMask, 128, 0)

      Loop Parse, SystemCursors, % ","
      {
         CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", &AndMask, "ptr", &XorMask, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }

   if (Cursor ~= "i)(AppStarting|Arrow|Cross|Hand|Help|IBeam|Icon|No|Size|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)") {
      Loop Parse, SystemCursors, % ","
      {
         CursorName := SubStr(A_LoopField, 6) ; get the cursor name
         CursorID := SubStr(A_LoopField, 1, 5) ; get the cursor id
      } until (CursorName ~= "i)" Cursor)

      if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", CursorID, "ptr"))
         throw Exception("Error: Invalid cursor name")

      Loop Parse, SystemCursors, % ","
      {
         CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }

   if FileExist(Cursor) {
      SplitPath Cursor,,, Ext ; auto-detect type
      if !(uType := (Ext = "ani" || Ext = "cur") ? 2 : (Ext = "ico") ? 1 : 0)
         throw Exception("Error: Invalid file type")

      if (Ext = "ani") {
         Loop Parse, SystemCursors, % ","
         {
            CursorHandle := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x10, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
         }
      } else {
         if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x00008010, "ptr"))
            throw Exception("Error: Corrupted file")

         Loop Parse, SystemCursors, % ","
         {
            CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
         }
      }
      return
   }

   throw Exception("Error: Invalid file path or cursor name")
}
