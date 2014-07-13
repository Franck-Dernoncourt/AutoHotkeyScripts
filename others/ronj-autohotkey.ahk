; Variables definition
; -----------------------------------------------------------------------------
EnvGet, userProfile, USERPROFILE
Software := userProfile . "\Dropbox\software\"

; Launch or toggle program, http://lifehacker.com/5468862/create-a-shortcut-key-for-restoring-a-specific-window
; -----------------------------------------------------------------------------
ToggleWinMinimize(WindowTitle)
{
	SetTitleMatchMode,2
	DetectHiddenWindows, Off
	IfWinActive, %WindowTitle%
	WinMinimize, %WindowTitle%
	Else
	IfWinExist, %WindowTitle%
	{
		WinActivate
	}
	Return
}

RunOrActivateOrMinimizeProgram(Program, WorkingDir="", WindowSize="")
{
	SplitPath Program, ExeFile
	Process, Exist, %ExeFile%
	PID = %ErrorLevel%
	if (PID = 0)
	{
		Run, %Program%, %WorkingDir%, %WindowSize%
	}
	else
	{
		SetTitleMatchMode,2
		DetectHiddenWindows, Off
		IfWinActive, ahk_pid %PID%
		WinMinimize, ahk_pid %PID%
		Else
		IfWinExist, ahk_pid %PID%
		WinActivate, ahk_pid %PID%
		Return
	}
}

<^<!i::RunOrActivateOrMinimizeProgram(Software . "firefox\firefox.exe", UserProfile)
<^<!n::RunOrActivateOrMinimizeProgram(Software . "notepadpp\notepad++.exe", UserProfile)
<^<!a::RunOrActivateOrMinimizeProgram(Software . "foobar2000\foobar2000.exe", UserProfile)
<^<!m::RunOrActivateOrMinimizeProgram(Software . "sublimetext-x64\sublime_text.exe", UserProfile)
<^<!w::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\Microsoft Office\Office14\WINWORD.EXE", UserProfile)
<^<!x::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\Microsoft Office\Office14\EXCEL.EXE", UserProfile)
<^<!o::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\Microsoft Office\Office14\OUTLOOK.EXE", UserProfile)
<^<!v::RunOrActivateOrMinimizeProgram("C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe", UserProfile)
<^<!j::ToggleWinMinimize("ahk_class CabinetWClass")
<^<!k::ToggleWinMinimize("ahk_class ConsoleWindowClass")
; for Skype, I also like the text box to have focus, so that it's ready to type text
<^<!u::
	RunOrActivateOrMinimizeProgram(Software . "skype\Phone\Skype.exe", UserProfile)
	ControlClick, TChatRichEdit1, ahk_class tSkMainForm,,,,,,
	ControlClick, TChatRichEdit2, ahk_class tSkMainForm,,,,,,
	ControlClick, TChatRichEdit3, ahk_class tSkMainForm,,,,,,
	Return
; exceptions for a few programs that behave differently
<^<!h::Run, "%Software%\processhacker\x64\ProcessHacker.exe"
!F10::Run, "%Software%\tomboy\Tomboy.exe" --open-note work, "", ""
!F11::Run, "%Software%\tomboy\Tomboy.exe" --start-here, "", ""

; Paste as pure text, http://www.autohotkey.com/community/viewtopic.php?t=11427
; -----------------------------------------------------------------------------
<#v::
	Clip0 = %ClipBoardAll%
	ClipBoard = %ClipBoard%
	Send ^v
	Sleep 50
	ClipBoard = %Clip0%
	VarSetCapacity(Clip0, 0)
	Return

; Archive Outlook message
; -----------------------------------------------------------------------------
<^<+a::
	IfWinActive, ahk_class rctrl_renwnd32, MsoDockTop
	{
		SendInput ^+v
		Sleep, 100
		SendInput sent{Enter} ; I archive my mail in "Sent Items", adjust accordingly
		Return
	}
	Return

; Hotstrings
; -----------------------------------------------------------------------------
:R*:p@mail::my.personal@email.com
:R*:.pweb::http://my.personal.website.com
:R*:btw::by the way
:R*:afaik::as far as I know

; Toggle hidden files in Windows Explorer, http://www.autohotkey.com/community/viewtopic.php?t=73186
; -----------------------------------------------------------------------------
<^h::
IfWinActive, ahk_class CabinetWClass
{
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
	If HiddenFiles_Status = 2 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
	Else 
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
	WinGetClass, eh_Class,A
	If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA" OR A_OSVersion = "WIN_7")
		send, {F5}
	Else PostMessage, 0x111, 28931,,, A
}
Else SendInput ^h
Return

; Middle-click on title bar to minimize, http://www.autohotkey.com/forum/topic16364.html
; -----------------------------------------------------------------------------
~MButton::
	CoordMode, Mouse, Window
	MouseGetPos, ClickX, ClickY, WindowUnderMouseID
	WinActivate, ahk_id %WindowUnderMouseID%
	WinGetClass, class, A
	MouseGetPos, ClickX, ClickY, WindowUnderMouseID
	WinGetPos, x, y, w, h, ahk_id %WindowUnderMouseID%

	; check if title bar, with an exception for Firefox with tabs in title bar that can be middle-clicked to close
	if (ClickX < w  and ClickY < 24 and ClickY > 0 and ClickX > 0 and class != "MozillaWindowClass")
	{
		WinMinimize, A
	}
	Return
 
; Disable annoying keyboard keys
; -----------------------------------------------------------------------------
F1::Return
CapsLock::Return
Launch_Mail::Return
Launch_App2::Return
Browser_Home::Return

; Move window to other monitor / Maximize window / Close window
; -----------------------------------------------------------------------------
#a:: SendInput #+{Left}
#q:: SendInput #{Up}
<^<!Enter::
	SendInput !{F4} ;WinClose, A
	Return

; Open in Chrome/IE
; -----------------------------------------------------------------------------
<^<!c::
	SetTitleMatchMode,2
	DetectHiddenWindows, Off
	IfWinActive, ahk_class MozillaWindowClass
	{
		clipboard = 
		SendInput ^l^c{TAB}{TAB}
		ClipWait
		EnvGet, chromeFolder, LOCALAPPDATA
		Run "%chromeFolder%\Google\Chrome\Application\chrome.exe" --incognito %clipboard%
	}
	Else SendInput ^!l
	Return

<^<!e::
	SetTitleMatchMode,2
	DetectHiddenWindows, Off
	IfWinActive, ahk_class MozillaWindowClass
	{
		clipboard = 
		SendInput ^l^c{TAB}{TAB}
		ClipWait
		Run "iexplore" %clipboard%
	}
	Else SendInput ^!l
	Return

; Resize current window to standard sizes
; -----------------------------------------------------------------------------
MoveWindow(width, height)
{
	WinMove, A, , , , width, height
	ToolTip, %width%x%height%
	Sleep, 500
	ToolTip,
	Return
}
<#1::MoveWindow(1619, 1049) ; that's not "standard", just my whole screen
<#2::MoveWindow(1280, 800)
<#3::MoveWindow(1024, 768)
<#4::MoveWindow(800, 600)

; Insert <code></code> or surround selected text with it
; -----------------------------------------------------------------------------

<^<+.::
	ClipboardOld = %Clipboard%
	clipboard = 
	Send, ^c
	ClipboardNew = %Clipboard%
	Sleep, 50
	If (ClipboardNew <> "")
	{
		SendInput <code></code>{Left 7}
		SendRaw %ClipboardNew%
	}
	Else SendInput <code></code>{Left 7}
	ClipBoard = %ClipboardOld%
	Return

; Increase/lower/mute volume
; -----------------------------------------------------------------------------
<^<!PgDn::Send {Volume_Down}
<^<!PgUp::Send {Volume_Up}
<^<!End::
	; exclude MSTSC, which uses Ctrl+Alt+End for Ctrl+Alt+Delete
	IfWinNotActive, ahk_class TscShellContainerClass
		Send {Volume_Mute}
	Else SendInput ^!{End}
	Return

; Clear console log with Ctrl+L and exit it with Ctrl+D
; -----------------------------------------------------------------------------
<^l::
	SetTitleMatchMode,2
	IfWinActive, ahk_class ConsoleWindowClass
	{
		SendInput ^c
		SendInput cls{ENTER}
		Return
	}
	Else SendInput ^l
	Return

<^d::
	SetTitleMatchMode,2
	IfWinActive, ahk_class ConsoleWindowClass
	{
		SendInput ^c
		SendInput exit{ENTER}
		Return
	}
	Else SendInput ^d
	Return

; Process killer, © Skrommel 2005. Click a window to close it; Ctrl-click to kill it; Esc to cancel
; -----------------------------------------------------------------------------
<^<!Backspace::
	#SingleInstance,Force
	CoordMode,Mouse,Screen

	MouseGetPos,x2,y2,winid,ctrlid
	wx:=x2+15
	wy:=y2+15
	Gui,+Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow
	Gui,Margin,0,0
	Gui,Color,AAAAAA
	Gui,Add,Picture,Icon1,C:\WINDOWS\system32\taskmgr.exe
	Gui,Show,X%wx% Y%wy% W32 H32 NoActivate,KillSkull
	WinSet,TransColor,AAAAAA,KillSkull

	Loop
	{
		MouseGetPos,x1,y1,winid,ctrlid
		If x1=%x2%
		If y1=%y2%
			Continue
		wx:=x1+15
		wy:=y1+15
		WinMove,KillSkull,,%wx%,%wy%
		GetKeyState,esc,Esc,P
		If esc=D
			Break
		GetKeyState,lbutton,LButton,P
		If lbutton=D
		{
			WinKill,ahk_id %winid%
			Break
		}
		x2=%x1%
		y2=%y2%
	}
	Gui,Destroy
	Return

; Reduce mouse sensitivity temporarily, http://www.autohotkey.com/community/viewtopic.php?t=14795
; -----------------------------------------------------------------------------
^RShift::DllCall("SystemParametersInfo", Int,113, Int,0, UInt,1, Int,2)
^RShift Up::DllCall("SystemParametersInfo", Int,113, Int,0, UInt,10, Int,2)

; Meta: Open AutoHotkey.ahk, Open ahk's help file, Open Window Spy, Auto-reload the running AutoHotkey script when you save it with CTRL+S in an editor
; -----------------------------------------------------------------------------
<^<+h::
	Run "%Software%\notepadpp\notepad++.exe" %A_ScriptFullPath%
	Return

<^<+j::
	Run hh.exe "%A_WorkingDir%\AutoHotkey.chm"
	WinWait, AutoHotkey_L Help
	WinMaximize
	Return

<^<+k::RunOrActivateOrMinimizeProgram("%Software%\autohotkey-64\AU3_Spy.exe", UserProfile)

~^s::
	SetTitleMatchMode 2
	IfWinActive, AutoHotkey.ahk
	{
		Sleep, 300
		ToolTip, Reloading...
		Sleep, 300
		Reload
	}
	Else SendInput ^s
	return