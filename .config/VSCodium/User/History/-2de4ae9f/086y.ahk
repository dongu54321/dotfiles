#MaxThreadsPerHotkey 3
#Persistent
SetTimer, WatchCursor, 100
return

WatchCursor:
MouseGetPos, , , id, control
WinGetTitle, title, ahk_id %id%
WinGetClass, class, ahk_id %id%
ToolTip, ahk_id %id%`nahk_class %class%`n%title%`nControl: %control%
return

#z::
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
	Sleep, 3000
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

