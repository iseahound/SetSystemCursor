#Requires AutoHotkey v2-a138+
#include Cursor.ahk

dict := {APPSTARTING: 32650, 
         ARROW: 32512,
         CROSS: 32515,
         HAND: 32649, 
         HELP: 32651,
         IBEAM: 32513, 
         NO: 32648,
         SIZEALL: 32646, 
         SIZENESW: 32643, 
         SIZENS: 32645, 
         SIZENWSE: 32642, 
         SIZEWE: 32644, 
         UPARROW: 32516, 
         WAIT: 32514}

for name, id in dict.ownprops() {
   SetSystemCursor name
   MsgBox name
   RestoreCursor
}