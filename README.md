# SetSystemCursor
[Download](https://raw.githubusercontent.com/iseahound/SetSystemCursor/main/Cursor%20(for%20v1).ahk) Cursor (for v1).ahk and rename it to Cursor.ahk

Changes the pointer. Original by Serenity. 

    SetSystemCursor("Cross")
    SetSystemCursor("IDC_Cross")

Set cursor size in pixels. 

    SetSystemCursor("IDC_Cross", 100, 100)

Supports .ani, .cur, and .ico files.

    SetSystemCursor("Animation.ani")
    
Creates an invisible cursor.

    SetSystemCursor()
    
If the system cursor is not changing, restore the original cursor.

    RestoreCursor()
