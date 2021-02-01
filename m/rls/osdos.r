file	osdos - O/S MS-DOS support
include rid:rider
include	rid:osdef
include	<stdlib.h>			; exit()

data	locals

	esCsuc := 0			; success
	esCwar := 0			; warning (treated as success)
	esCerr := 1			; error
	esCfat := 1			; fatal

	osVsys : int = osKdos		; system
	osVimp : int = osKdos		; implementation
	osVhst : int = osKdos		; host
	osVcpu : int = osKx86		; cpu
	osVend : int = osKbig		; endian
	osVsev : int = 0		; error severity

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
  is	exeunt osVsev
	fail
  end
code	rt_ctc - zortech code
#ifdef __ZTC__
include <int.h>				; signals

	type rtTint : INT_DATA struct	; interrupt frame
	rtFctc : int volatile = 0	; ctrl/c seen
	rtFres : int = 0		; need to restore vector

code	rt_ctc - catch ctrl/c

  func	rt_ctc 				; signal routine
	frm : * rtTint			; interrupt frame
	() : int			; 0 => call previous
  is	++rtFctc			; remember it
	reply 0				; call previous handler
  end

code	rt_ini - init system stuff

  func	rt_ini
  is
If not Wdw
	int_intercept (0x1b, &rt_ctc, 200)
	++rtFres if that eq		; succeeded - restore later
End
  end

code	rt_exi - exit cleanup

  func	rt_exi
  is
If not Wdw
	if rtFres			; need to restore
	.. int_restore (0x1b)		; restore break vector
End
  end
#endif
code	os_upt - uptime checks
include	rid:dsdef
include	rid:dslib

;	This code used to live in SHE

  proc	os_upt
  is
If 0
	reg : dsTreg			; some registers
	wrd : *far short		;
	byt : *far char			;
	byt = FAR(char, 0x40, 0x17)	; terminal control
	*byt &= ~(BIT(5))		; turn off num lock
	exit if ds_DetWin ()		; skip this under windows
	ds_SndOff ()			; turn off the speaker
;	BX=0, ds_r86 (0x16, 0x0305)	; set typematic fast
	wrd = FAR(short, 0x40, 0x13)	; check memory size
	if *wrd lt 640-2		; we expect more memory
	.. ut_rep ("W-Less than 640k low memory\n", <>)
End
 end
