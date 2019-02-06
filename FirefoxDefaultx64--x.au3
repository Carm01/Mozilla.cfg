#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=3.ico
#AutoIt3Wrapper_Outfile=FirefoxUpdater_x64Stable_x.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Preformes a clean install of Firefox 64bit Stable version. Auto downloads latest version.
#AutoIt3Wrapper_Res_Description=Updates to the Latest 64bit Stable
#AutoIt3Wrapper_Res_Fileversion=2.5.0.0
#AutoIt3Wrapper_Res_ProductVersion=2.5.0.0
#AutoIt3Wrapper_Res_LegalCopyright=carm0@sourceforge
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
If UBound(ProcessList(@ScriptName)) > 2 Then Exit
#include <InetConstants.au3>
#include <EventLog.au3>
#include <Inet.au3>
#include <File.au3>
#include <array.au3>
#include <Misc.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_CHECKED and $TRAY_ICONSTATE_SHOW constants.

TraySetToolTip("Firefox Updater")
HotKeySet("^!m", "MyExit") ; ctrl+Alt+m kills program ( hotkey )
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.
TrayCreateItem("About")
TrayItemSetOnEvent(-1, "About")
TrayCreateItem("") ; Create a separator line.
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "About") ; Display the About MsgBox when the tray icon is double clicked on with the primary mouse button.
TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

Local $sVersion, $CVersion, $ecode, $scheck = 0

;https://www.mozilla.org/en-US/firefox/developer/all/
;https://www.mozilla.org/en-US/firefox/all/#
;https://www.mozilla.org/en-US/firefox/all/#en-US
;https://www.mozilla.org/en-US/firefox/beta/all/#en-US
;https://archive.mozilla.org/pub/firefox/candidates/48.0b1-candidates/build2/
;https://archive.mozilla.org/pub/firefox/candidates/

If $CmdLine[0] >= 1 Then
	Call("line")
EndIf

getfiles()
If $scheck = 1 Then
	compare()
EndIf
killapps()
uninstall()
dlinstall()
Exit

Func killapps()
	; kill firefox and plugin if running
	If FileExists("C:\Program Files\Mozilla Firefox\") Then
		$cmd = "taskkill.exe /im firefox.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
		Sleep(300)
		$cmd = "taskkill.exe /im plugin* /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
		Sleep(300)
		Call("remcfg64")
	EndIf

	If FileExists("C:\Program Files (x86)\Mozilla Firefox\") Then
		$cmd = "taskkill.exe /im firefox.exe /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
		Sleep(300)
		$cmd = "taskkill.exe /im plugin* /f /t"
		RunWait('"' & @ComSpec & '" /c ' & $cmd, @SystemDir, @SW_HIDE)
		Sleep(300)
		Call("remcfg32")
	EndIf
EndFunc   ;==>killapps


Func remcfg64()
	; delete existing config file if exist
	$SSlist = _FileListToArrayRec("C:\Program Files\Mozilla Firefox\", "*", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	For $i = 1 To UBound($SSlist) - 1
		If StringInStr($SSlist[$i], "mozilla.cfg") > 1 Then
			FileDelete($SSlist[$i])
		ElseIf StringInStr($SSlist[$i], "override.ini") > 1 Then
			FileDelete($SSlist[$i])
		ElseIf StringInStr($SSlist[$i], "local-settings.js") > 1 Then
			FileDelete($SSlist[$i])
		EndIf
	Next
EndFunc   ;==>remcfg64

Func remcfg32()
	$SSlist = _FileListToArrayRec("C:\Program Files (x86)\Mozilla Firefox\", "*", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	For $i = 1 To UBound($SSlist) - 1
		If StringInStr($SSlist[$i], "mozilla.cfg") > 1 Then
			FileDelete($SSlist[$i])
		ElseIf StringInStr($SSlist[$i], "override.ini") > 1 Then
			FileDelete($SSlist[$i])
		ElseIf StringInStr($SSlist[$i], "local-settings.js") > 1 Then
			FileDelete($SSlist[$i])
		EndIf
	Next
EndFunc   ;==>remcfg32

Func uninstall()
	; uninstall existing Firefox
	If FileExists("C:\Program Files\Mozilla Firefox\Firefox.exe") Then
		ShellExecuteWait("helper.exe", " /S", "C:\Program Files\Mozilla Firefox\uninstall")
	EndIf

	If FileExists("C:\Program Files (x86)\Mozilla Firefox\Firefox.exe") Then
		ShellExecuteWait("helper.exe", " /S", "C:\Program Files (x86)\Mozilla Firefox\uninstall")
	EndIf

	Sleep(1500)
	DirRemove("C:\Program Files (x86)\Mozilla Firefox\", 1)
	DirRemove("C:\Program Files\Mozilla Firefox\", 1)
EndFunc   ;==>uninstall

Func getfiles()
	; get latest download
	Local $sTxt, $sTxt1
	$xjs = "C:\windows\temp\xjs.tmp"
	$xjs1 = "C:\windows\temp\xjs1.tmp"
	;$sSite = "https://www.mozilla.org/en-US/firefox/beta/all/"
	$sSite = "https://www.mozilla.org/en-US/firefox/all/"
	;$sNotes = "https://www.mozilla.org/en-US/firefox/beta/notes/"
	$sNotes = "https://www.mozilla.org/en-US/firefox/notes/"
	SplashTextOn("Progress", "", 210, 75, -1, -1, 18, "Tahoma", 10)
	ControlSetText("Progress", "", "Static1", "Initializing", 2)
	$source = _INetGetSource($sSite)
	$sTxt = StringSplit($source, @LF)

	$q = 0
	$i = 0
	For $i = 1 To UBound($sTxt) - 1 ; is like saying read the line number
		;GUIGetMsg();prevent high cpu usage
		If StringInStr($sTxt[$i], "=win64&amp;lang=en-US") > 1 And StringInStr($sTxt[$i], "stub") =0  Then
			$sActiveX1 = StringSplit($sTxt[$i], 'href="', 1)
			$sActiveX2 = StringSplit($sActiveX1[2], '"')
			Global $dia = $sActiveX2[1]
			$q = 1
		EndIf

		If UBound($sTxt) - 1 = $i Then
			$ecode = '404'
			EventLog()
			Exit
		EndIf

		If $q = 1 Then
			ExitLoop
		EndIf
	Next

	; FIND VERSION
	$source = _INetGetSource($sNotes)
	$sTxt1 = StringSplit($source, @LF)

	$q = 0
	$i = 0
	For $i = 1 To UBound($sTxt1) - 1 ; is like saying read the line number
		;GUIGetMsg();prevent high cpu usage
		If StringInStr($sTxt1[$i], "<title>Firefox") > 1 Then
			$sActiveX1 = StringSplit($sTxt1[$i], '<title>Firefox', 1)
			$sActiveX2 = StringSplit($sActiveX1[2], ',')
			$sVersion = StringStripWS($sActiveX2[1], 3)
			$q = 1
		EndIf
		If $sVersion = "" Then ; error correcting if mozilla changes page where version notes are located.
			$sVersion = "Current Version"
		EndIf
		If $q = 1 Then
			ExitLoop
		EndIf
	Next
	SplashOff()
EndFunc   ;==>getfiles


Func dlinstall()
	; download and install
	$Version = $sVersion & " - 64 bit"
	_webDownloader($dia, "FFInstall.exe", $Version)

	SplashTextOn("Progress", "", 210, 75, -1, -1, 18, "Tahoma", 10)
	ControlSetText("Progress", "", "Static1", "Installing Version " & $sVersion, 2)
	ShellExecuteWait("FFInstall.exe", " -ms", "C:\Windows\Temp\")

	If FileExists(@ScriptDir & "\mozilla.cfg") Then
		FileCopy(@ScriptDir & "\mozilla.cfg", "C:\Program Files\Mozilla Firefox\mozilla.cfg", 1)
	Else
		FileInstall("mozilla.cfg", "C:\Program Files\Mozilla Firefox\mozilla.cfg", 1)
	EndIf

	FileWrite("C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js", 'pref("general.config.obscure_value", 0);' & @CRLF & 'pref("general.config.filename", "mozilla.cfg");' & @CRLF)
	FileWrite("C:\Program Files\Mozilla Firefox\browser\override.ini", '[XRE]' & @CRLF & 'EnableProfileMigrator=false' & @CRLF)
	FileDelete("C:\windows\temp\" & "\FFInstall.exe")
	$CVersion = FileGetVersion('C:\Program Files\Mozilla Firefox\firefox.exe', $FV_PRODUCTVERSION)
	SplashOff()
EndFunc   ;==>dlinstall

Func _webDownloader($sSourceURL, $sTargetName, $sVisibleName, $sTargetDir = "C:\windows\temp", $bProgressOff = True, $iEndMsgTime = 2000, $sDownloaderTitle = "Mozilla Firefox")
	; Declare some general vars
	Local $iMBbytes = 1048576

	; If the target directory doesn't exist -> create the dir
	If Not FileExists($sTargetDir) Then DirCreate($sTargetDir)

	; Get download and target info
	Local $sTargetPath = $sTargetDir & "\" & $sTargetName
	Local $iFileSize = InetGetSize($sSourceURL)
	Local $hFileDownload = InetGet($sSourceURL, $sTargetPath, $INET_LOCALCACHE, $INET_DOWNLOADBACKGROUND)

	; Show progress UI
	ProgressOn($sDownloaderTitle, "" & $sVisibleName)
	GUISetFont(8, 400)
	; Keep checking until download completed
	Do
		Sleep(250)

		; Set vars
		Local $iDLPercentage = Round(InetGetInfo($hFileDownload, $INET_DOWNLOADREAD) * 100 / $iFileSize, 0)
		Local $iDLBytes = Round(InetGetInfo($hFileDownload, $INET_DOWNLOADREAD) / $iMBbytes, 2)
		Local $iDLTotalBytes = Round($iFileSize / $iMBbytes, 2)

		; Update progress UI
		If IsNumber($iDLBytes) And $iDLBytes >= 0 Then
			ProgressSet($iDLPercentage, $iDLPercentage & "% - Downloaded " & $iDLBytes & " MB of " & $iDLTotalBytes & " MB")
		Else
			ProgressSet(0, "Downloading '" & $sVisibleName & "'")
		EndIf
	Until InetGetInfo($hFileDownload, $INET_DOWNLOADCOMPLETE)

	; If the download was successfull, return the target location
	If InetGetInfo($hFileDownload, $INET_DOWNLOADSUCCESS) Then
		ProgressSet(100, "Downloading '" & $sVisibleName & "' completed")
		If $bProgressOff Then
			Sleep($iEndMsgTime)
			ProgressOff()
		EndIf
		Return $sTargetPath
		; If the download failed, set @error and return False
	Else
		Local $errorCode = InetGetInfo($hFileDownload, $INET_DOWNLOADERROR)
		ProgressSet(0, "Downloading '" & $sVisibleName & "' failed." & @CRLF & "Error code: " & $errorCode)
		If $bProgressOff Then
			Sleep($iEndMsgTime)
			ProgressOff()
		EndIf
		SetError(1, $errorCode, False)
		FileDelete("C:\windows\temp\" & "\FFInstall.exe")
		SplashOff()
	EndIf
EndFunc   ;==>_webDownloader

Func compare()
	$CVersion = FileGetVersion('C:\Program Files\Mozilla Firefox\firefox.exe', $FV_PRODUCTVERSION)
	If $sVersion = $CVersion Then
		$ecode = '444'
		MsgBox(64, "Firefox says:", 'You have the latest version ' & $CVersion, 5)
		EventLog()
		Exit
	EndIf
EndFunc   ;==>compare


Func EventLog()

	If $ecode = '404' Then
		Local $hEventLog, $aData[4] = [0, 4, 0, 4]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 1, 0, 404, @UserName, @UserName & ' No "exe" found for Mozilla Firefox. The webpage and/or download link might have changed. ' & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '411' Then
		Local $hEventLog, $aData[4] = [0, 4, 1, 1]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 0, 0, 411, @UserName, @UserName & " Mozilla Firefox " & "version " & $CVersion & " successfully installed." & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '444' Then
		Local $hEventLog, $aData[4] = [0, 4, 4, 4]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 0, 0, 444, @UserName, @UserName & " The current version of Firefox is already installed " & $CVersion & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf
EndFunc   ;==>EventLog



Func MyExit()
	Exit
EndFunc   ;==>MyExit

Func About()
	; Display a message box about the AutoIt version and installation path of the AutoIt executable.
	MsgBox($MB_SYSTEMMODAL, "", "Firefox Update Tool" & @CRLF & @CRLF & _
			"Version: 2.5.0.0" & @CRLF & _
			"Firefox Updater by Carm0@Sourceforge" & @CRLF & "CTRL+ALT+m to kill", 5) ; Find the folder of a full path.
EndFunc   ;==>About

Func ExitScript()
	Exit
EndFunc   ;==>ExitScript

#comments-start
	http://superuser.com/questions/823530/change-some-default-settings-for-firefox-globally
	http://mxr.mozilla.org/mozilla-release/source/browser/app/profile/firefox.js#387
	http://smallbusiness.chron.com/change-default-homepage-users-54727.html
	https://developer.mozilla.org/en-US/Firefox/Enterprise_deployment
	https://mike.kaply.com/2012/03/16/customizing-firefox-autoconfig-files/
	https://wiki.mozilla.org/Installer:Command_Line_Arguments
	https://support.mozilla.org/en-US/questions/971189
	http://forums.mozillazine.org/viewtopic.php?p=2228066
	http://forums.mozillazine.org/viewtopic.php?f=38&t=2950829 ; updates auto
	http://forums.mozillazine.org/viewtopic.php?f=8&t=2753795
	http://superuser.com/questions/697018/how-to-disable-popups-in-firefox-without-add-ons
	http://www.itninja.com/blog/view/deploy-popup-allowed-sites-with-firefox  deploy with certain opous enabled
#ce





Func line()

	For $z = 1 To UBound($CmdLine) - 1

		If StringInStr($CmdLine[$z], "-") <> 1 Then
			MsgBox(0, "Grasshopper Says:", 'Wrong switch please use a "-"')
			Exit
		EndIf
		; the -i command cannot be used alone but with one of the following a,n,s o install the selected players
		If StringInStr($CmdLine[$z], "c") = 2 Then
			$scheck = 1
		EndIf

		If StringInStr($CmdLine[$z], "c") <> 2 Then
			MsgBox(0, "Invalad parameter", "Valid parameters are currently:" & @CRLF & " -c (check and only reinstall if out of date)", 5)
			Exit
		EndIf
	Next
EndFunc   ;==>line
