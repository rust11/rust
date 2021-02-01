file	oswin - Windows support
include rid:rider
include	rid:osdef
include	rid:wimod
include	rid:dbdef
include	<stdlib.h>			; exit()

data	locals

	esCsuc := 0			; success
	esCwar := 0			; warning (treated as success)
	esCerr := 1			; error
	esCfat := 1			; fatal

If Wnt
	osVsys : int = osKw32		; system
	osVimp : int = osKwnt		; implementation
	osVhst : int = osKwnt		; host
Else
	osVsys : int = osKw16		; system
	osVimp : int = osKwin		; implementation
	osVhst : int = osKdos		; host
End
	osVcpu : int = osKx86		; cpu
	osVend : int = osKbig		; endian
	osVsev : int = esCsuc		; error severity

code	os_ini - init for o/s

  func	os_ini
  is	fine
  end

code	os_war - register warning

  proc	os_war
  is	osVsev = esCwar if osVsev lt esCwar
  end

code	os_err - register error

  proc	os_err
  is	osVsev = esCerr if osVsev lt esCerr
  end

code	os_fat - register fatal error

  proc	os_fat
  is	osVsev = esCfat
  end

code	os_exi - exit image

  func	os_exi 
  is
If Wnt
	exeunt osVsev
;sic]	ExitProcess (osVsev)		; aborts I/O without rundown
Else
	exeunt osVsev
End
	fail
  end

code	os_idl - execute system idle loop

;	Duration is undefined

  func	os_idl
  is	fine Sleep (0)		; give up rest of timeslice
  end

code	os_wai - wait n milliseconds

;	Zero returns immediately
;	~0 may be infinite

  func	os_wai
	cnt : LONG
  is	min : int
	fine if !cnt			; waits no time at all
	fine Sleep (cnt)		; portable wait
;	while cnt--
;	   min = 1000000		;
;	   spin while --min
;	end
;	fine
  end

code	os_w95 - is Windows 95

  func	os_w95
  is	reply  (GetVersion () & 0xc0000000) eq 0xc0000000
  end

code	os_wnt - is Windows Nt

  func	os_wnt
  is	reply !os_w95 ()
  end

code	os_dbg - is debug (not retail)

  func	os_dbg
  is	reply GetSystemMetrics (SM_DEBUG) ne
  end
code	rt_ctc - zortech code
#ifdef __SC__
;include <int.h>			; signals

;	type rtTint : INT_DATA struct	; interrupt frame
	rtFctc : int volatile = 0	; ctrl/c seen
	rtFres : int = 0		; need to restore vector

code	rt_ctc - catch ctrl/c

  func	rt_ctc 				; signal routine
;	frm : * rtTint			; interrupt frame
	() : int			; 0 => call previous
  is	++rtFctc			; remember it
	reply 0				; call previous handler
  end

code	rt_ini - init system stuff

  func	rt_ini
  is
;	int_intercept (0x1b, &rt_ctc, 200)
;	++rtFres if that eq		; succeeded - restore later
  end

code	rt_exi - exit cleanup

  func	rt_exi
  is
;	if rtFres			; need to restore
;	.. int_restore (0x1b)		; restore break vector
  end
#endif
code	os_del - delete file

  func	os_del
	spc : * char
	sts : * int
  is	fine if DeleteFile (spc)	; delete worked
	fail if !sts			; no status required
;	err = GetLastError ()		; find out why
;	pass fine
;	db_lst ("Delete")
	fail
  end
