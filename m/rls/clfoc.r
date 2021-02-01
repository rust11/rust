file	clfoc - get command line focus
include	rid:rider
include rid:dbdef
If Win
include	rid:wimod
	thr_prc	: (HWND, LPARAM) CALLBACK BOOL own
End

;	Help a console-mode application to get the keyboard focus
;	back when a spawned image completes. Many techniques fail
;	because it is difficult to locate the window handle of
;	the console app. The technique used here is to get and
;	store the foreground window handle before spawning, and
;	then to restore after. For example:
;
;	wnd : * void = cl_foc (0)	; save foreground
;	system (...)			; spawn image and wait
;	cl_foc (wnd)			; restore foreground

code	cl_foc - restore focus

  func	cl_foc
	han : * void			; window handle
	()  : * void			; 
  is
If Win
	wnd : HWND = <HWND>han
	if !wnd
	   wnd = GetForegroundWindow ()
;	   PUT("GetForegrond failed\n") if fail
;	   PUT("wnd=%X\n", wnd) otherwise
	.. reply <*void>wnd
	SetForegroundWindow (wnd)
;	PUT("SetForeground failed\n") if fail
	SetFocus (wnd)
;	PUT("SetFocus failed\n") if fail
End
	reply <>
  end

