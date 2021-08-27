# SetSystemCursor
Changes the pointer. Original by Serenity. 

    SetSystemCursor("Cross")
    SetSystemCursor("IDC_Cross")

Supports .ani, .cur, and .ico files.

    SetSystemCursor("Animation.ani")
    
Creates an invisible cursor.

    SetSystemCursor()
    
If the system cursor is not changing, restore the original cursor.

    RestoreCursor()
