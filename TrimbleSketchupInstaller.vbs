 '*******************************************************************************  
 '   Program: Install.vbs  
 '   Author: Mick Pletcher  
 '    Date: 24 July 2012  
 '  Modified:  
 '  
 '   Program: Trimble Sketchup  
 '   Version: 8  
 ' Description: This will install Sketchup with a network license  
 '                 1) Define the relative installation path  
 '                 2) Create the Log Folder  
 '                 3) Check if Sketchup is already installed  
 '                 3) Install  
 '                 4) Copy Network License File  
 '                 5) Cleanup Global Variables  
 '*******************************************************************************  
 Option Explicit  

 REM Define Constants  
 CONST TempFolder    = "c:\temp\"  
 CONST LogFolderName = "Sketchup"  

 REM Define Global Variables  
 DIM Architecture : Set Architecture = Nothing  
 DIM RegKeyx86    : RegKeyx86        = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{88A47643-0A80-4FA8-A568-E9A63AAA98F4}"  
 DIM RegKeyx64    : RegKeyx64        = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{88A47643-0A80-4FA8-A568-E9A63AAA98F4}"  
 DIM LogFolder    : LogFolder        = TempFolder & LogFolderName & "\"  
 DIM RelativePath : Set RelativePath = Nothing  

 If NOT RegKeyExists("HKLM", RegKeyx86, "DisplayName") or NOT RegKeyExists("HKLM", RegKeyx64, "DisplayName") then  
      REM Define the relative installation path  
      DefineRelativePath()  
      REM Create the Log Folder  
      CreateLogFolder()  
      REM Determine OS Architecture  
      DetermineArchitecture()  
      REM Install  
      Install()  
      REM Copy Network License File  
      CopyLicenseFile()  
 End If  
 REM Cleanup Global Variables  
 GlobalVariableCleanup()  

 '*******************************************************************************  
 '******************************************************************************* 
 
 Sub DefineRelativePath()  

      REM Get File Name with full relative path  
      RelativePath = WScript.ScriptFullName  
      REM Remove file name, leaving relative path only  
      RelativePath = Left(RelativePath, InStrRev(RelativePath, "\"))  

 End Sub  

 '******************************************************************************* 
 
 Sub CreateLogFolder()  

      REM Define Local Objects  
      DIM FSO : Set FSO = CreateObject("Scripting.FileSystemObject")  

      If NOT FSO.FolderExists(TempFolder) then  
           FSO.CreateFolder(TempFolder)  
      End If  
      If NOT FSO.FolderExists(LogFolder) then  
           FSO.CreateFolder(LogFolder)  
      End If  

      REM Cleanup Memory  
      Set FSO = Nothing  

 End Sub  

 '******************************************************************************* 
 
 Sub DetermineArchitecture()  

      REM Define Local Objects  
      DIM WshShell : Set WshShell = CreateObject("WScript.Shell")  

      REM Define Local Variables  
      DIM OSType : OsType = WshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")  

      If OSType = "x86" then  
           Architecture = "x86"  
      elseif OSType = "AMD64" then  
           Architecture = "x64"  
      end if  

      REM Cleanup Memory  
      Set OSType = Nothing  

 End Sub  

 '*******************************************************************************  

 Sub Install()  

      REM Define Local Objects  
      DIM oShell : SET oShell = CreateObject("Wscript.Shell")  

      REM Define Local Variables  
      DIM MSI        : MSI        = Chr(32) & RelativePath & "GoogleSketchUp8.msi"  
      DIM Logs       : Logs       = Chr(32) & "/lvx" & Chr(32) & LogFolder & LogFolderName & ".log"  
      DIM Transform  : Transform  = Chr(32) & "TRANSFORMS=" & RelativePath & "transform.mst"  
      DIM Parameters : Parameters = Chr(32) & "/qb- /norestart INSTALLGOOGLETOOLBAR=0 LicenseAccepted=1"  
      DIM Install    : Install    = "msiexec.exe /i" & MSI & Logs & Parameters  

      oShell.Run Install, 1, True  

      REM Cleanup Memory  
      Set Install    = Nothing  
      Set Logs       = Nothing  
      Set MSI        = Nothing  
      Set oShell     = Nothing  
      Set Parameters = Nothing  
      Set Transform  = Nothing  

 End Sub  

 '******************************************************************************* 
 
 Sub CopyLicenseFile()  

      REM Define Local Objects  
      DIM FSO : Set FSO = CreateObject("Scripting.FileSystemObject")  

      If Architecture = "x86" then  
                FSO.CopyFile "\\global.gsp\data\clients\na_clients\Trimble\Sketchup\server.dat", "C:\Program Files\Google\Google SketchUp 8\server.dat", True  
      ElseIf Architecture = "x64" then  
                FSO.CopyFile "\\global.gsp\data\clients\na_clients\Trimble\Sketchup\server.dat", "C:\Program Files (x86)\Google\Google SketchUp 8\server.dat", True  
      End If  

      REM Cleanup Memory  
      Set FSO = Nothing  

 End Sub  

 '*******************************************************************************  

 Function RegKeyExists(nHive, strPath, strValueName)  

      Select Case Left(nHive, 20)  
           Case "HKCR", "HKEY_CLASSES_ROOT"  
                nHive = &H80000000  
           Case "HKCU", "HKEY_CURRENT_USER"  
                nHive = &H80000001  
           Case "HKLM", "HKEY_LOCAL_MACHINE"  
                nHive = &H80000002  
           Case "HKU", "HKEY_USERS"  
                nHive = &H80000003  
           Case "HKCC", "HKEY_CURRENT_CONFIG"  
                nHive = &H80000005  
           Case Else  
                WScript.Echo "Hive Not Supported."  
                GlobalVariableCleanup()  
                WScript.Quit  
      End Select  

      REM Define Local Constants  
      CONST strComputer = "."  

      REM Define Local Objects  
      DIM objRegistry : Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")  

      REM Define Local Variables  
      DIM strValue : Set strValue = Nothing  

      objRegistry.GetStringValue nHive, strPath, strValueName, strValue  
      RegKeyExists = Not IsNull(strValue)  
      RegKeyExists = CStr (RegKeyExists) 
 
      REM Cleanup Local Memory  
      Set objRegistry = Nothing  
      Set strValue    = Nothing  

 End Function  

 '*******************************************************************************  

 Sub GlobalVariableCleanup()  

      Set Architecture = Nothing  
      Set LogFolder    = Nothing  
      Set RegKeyx86    = Nothing  
      Set RegKeyx64    = Nothing  
      Set RelativePath = Nothing  

 End Sub  
