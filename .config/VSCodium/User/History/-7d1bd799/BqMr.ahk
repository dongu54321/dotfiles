;#MaxThreadsPerHotkey 3
#SingleInstance force
; Random, randa, 250, 300
; SetKeyDelay, %randa%, %randa%
SetKeyDelay, 0, 150
^!r::Reload ; Assign a hotkey to restart the script.
^!z::Pause


!e::
SetTimer, RepeaE, off
return
^e::
SetTimer, RepeaE, 4500
return

XButton1::
Random, randa, 250, 300
SetKeyDelay, %randa%, %randa%
Send, q
Send, s
Send, d
Send, f
return

RepeaE:
Send, e
Random, randa, 250, 300
Sleep, %randa%
return

XButton2::
SetKeyDelay, 0, 150
Send, r
Send, q
Send, w
return

XButton1::
SetKeyDelay, 0, 150
Send, w
Send, q
Send, a
; Send, r
; MouseClick, left
; Sleep, 70
; Send, e
; MouseClick, left
; Sleep, 70
; Send, r
; MouseClick, left
; Sleep, 70
; Send, w
; Sleep, 70
return

2::
SetKeyDelay, 0, 150
Send, r
MouseClick, left
Sleep, 50
Send, e
MouseClick, left
Sleep, 50
Send, r
MouseClick, left
Sleep, 50
Send, w
Sleep, 50
return

Space::
SetKeyDelay, 0, 150
Send, r
MouseClick, left
Sleep, 70
Send, q
MouseClick, left
Sleep, 70
Send, w
MouseClick, left
Sleep, 70

; Send, 2
; Send, 3
; Send, 4
; Send, 5
return

; RButton::
; if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
; {
; 	winc_presses += 1
; 	return
; }
; ; Otherwise, this is the first press of a new series. Set count to 1 and start
; ; the timer:
; winc_presses = 1
; SetTimer, KeyWinC, 150 ; Wait for more presses within a 400 millisecond window.
; return

; KeyWinC:
; SetTimer, KeyWinC, off
; if winc_presses = 1 ; The key was pressed once.
; {
; 	Click, Right
; }
; else if winc_presses = 2 ; The key was pressed twice.
; {
; 	Send, w  ; Open a different folder.
; }
; else if winc_presses > 2
; {
; 	MsgBox, Three or more clicks detected.
; }
; ; Regardless of which action above was triggered, reset the count to
; ; prepare for the next series of presses:
; winc_presses = 0
; return

;Press Ctrl 1: identified item
^1::w
;IfWinNotActive, Path of Exile
; 	WinActivate, Path of Exile
;	return
MouseGetPos, xpos, ypos
Click, 1730 810 Right
Random, randa, 150, 250
Sleep, %randa%
Click, %xpos% %ypos%
return

;Press Ctrl 2: drop items

^2::
;IfWinNotActive, Path of Exile
; 	WinActivate, Path of Exile
;	return
MouseGetPos, xpos, ypos
Click, %xpos% %ypos%
Random, randa, 500, 550
Sleep, %randa%
Click, 1052 652
Sleep, %randa%
Click, %xpos% %ypos%
;Send, {ENTER}
return


^3:: ;Destroy in Hideout
;IfWinNotActive, Path of Exile
; 	WinActivate, Path of Exile
;	return
MouseGetPos, xpos, ypos
Click, %xpos% %ypos%
Random, randa, 100, 250
Sleep, %randa%
Click, 1052 652
Sleep, 100
Click, %xpos% %ypos%
Send, {ENTER}
return

F5::
;IfWinNotActive, Path of Exile
; 	WinActivate, Path of Exile
;	return
Send, {ENTER}
Send, /hideout
Send, {ENTER}
return

F7::
;IfWinNotActive, Path of Exile
; 	WinActivate, Path of Exile
;	return
Send, {ENTER}
Send, /exit
Send, {ENTER}
return

^z::
#MaxThreadsPerHotkey 1
if KeepWinZRunning = y
	KeepWinZRunning =
	return
}
; Otherwise:
KeepWinZRunning = y
Loop,
{
	SetKeyDelay, 250, 250
	Send, q
	Sleep, 3000
	if KeepWinZRunning =
		break
}
return



; *a::
; Random, randa, 250, 300
; SetKeyDelay, %randa%, %randa%
; MouseClick, left
; Sleep, 70,,, 1, 0, D  ; Hold down the left
; Sleep, 70 mouse button.
; Send, {LButton down}
; Send, {t down}
; Send, {q down}
; KeyWait, a   ; Wait for the key to be released.
; ; MouseClick, left
; Sleep, 70,,, 1, 0, U  ; Release the mouse button.
; Send, {t up}
; Send, {q up}
; Send, {LButton up}
; return