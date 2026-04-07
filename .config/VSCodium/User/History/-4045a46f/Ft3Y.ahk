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


XButton1::
Send, 3
Random, randa, 150, 250
Sleep, %randa%

Send, 4
Random, randa, 150, 250
Sleep, %randa%

Send, 5
return

j::
MouseGetPos, xpos, ypos
Click, 1730 810 Right
Random, randa, 1505, 2505
Sleep, %randa%
Click, %xpos% %ypos%
return