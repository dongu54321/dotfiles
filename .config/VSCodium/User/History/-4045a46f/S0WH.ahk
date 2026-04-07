#MaxThreadsPerHotkey 3

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
	Send, t
	if KeepWinZRunning =  ; The user signaled the loop to stop by pressing Win-Z again.
		break  ; Break out of this loop.
	Sleep, 1000
}
return

;Press mouse4 to auto 3 4 5
XButton1::
Send, 3
Random, randa, 150, 250
Sleep, %randa%

Send, 4
Random, randa, 150, 250
Sleep, %randa%

Send, 5
return

;Press J: identified item
j::
MouseGetPos, xpos, ypos
Click, 1730 810 Right
Random, randa, 150, 250
Sleep, %randa%
Click, %xpos% %ypos%
return

XButton2::
MouseGetPos, xpos, ypos
Click, %xpos% %ypos%
Random, randa, 100, 150
Sleep, %randa%
Click, 1052 652
Sleep, 100
Send, {ENTER}
return