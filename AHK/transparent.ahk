; MSPaint
#IfWinActive ahk_class Notepad
^space::
   MsgBox, You pressed Win+Spacebar in  MSPaint!
Return
::msg::You typed msg in MSPaint!
#IfWinActive