#MaxThreadsPerHotkey 3
#SingleInstance force
Random, randa, 250, 300
SetKeyDelay, %randa%, %randa%

^!r::Reload ; Assign a hotkey to restart the script.
^!p::Pause

;Ctrl z: enable auto press t every 1 sec
^z::
#MaxThreadsPerHotkey 1
if KeepWinZRunning = y  ; This means an underlying thread is already running the loop below.
{
	KeepWinZRunning =  ; Make it blank to signal that thread's loop to stop.
	return  ; End this thread so that the one underneath will resume and see the change.
}
; Otherwise:
KeepWinZRunning = y
Loop,
{
	if KeepWinZRunning =  ; The user signaled the loop to stop by pressing Win-Z again.
		break  ; Break out of this loop.qr
	SetKeyDelay, 200, 200
	Send, r
	Send, q
	Sleep, 3000
	Send, q
	Sleep, 3000
	Send, q
	Sleep, 2000
	Send, r
	Sleep, 1000
	Send, q
	if KeepWinZRunning =  ; The user signaled the loop to stop by pressing Win-Z again.
		break  ; Break out of this loop.
}
return

; ~q::
;     KeyWait q, T0.5                 ; Wait 1/2 second for user to release "a" key
;     If ErrorLevel                   ; Still held down
;         Loop
; 			{
; 				GetKeyState, state, q, P

; 			}
; 		While GetKeyState("a","p"){ ; While it is held down
;             Click
;             Send a
;             Sleep 100
;         }
;     Else                            ; They let go in time
;         Send a
; return

*a::
MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
Send, {t down}
Send, {q down}
KeyWait, a   ; Wait for the key to be released.
MouseClick, left,,, 1, 0, U  ; Release the mouse button.
Send, {t up}
Send, {q up}
return

XButton1::
Send, s
Send, d
Send, f
return

Space::
Random, randa, 250, 300
SetKeyDelay, %randa%, %randa%
Send, d
Send, r
Send, t
Send, {SPACE}
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
Random, randa, 200, 250
Sleep, %randa%
Click, 1052 652
Sleep, 200
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