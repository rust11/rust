file	osvms - O/S VAX/VMS support
include rid:rider
include rid:osdef

;	VAXC requires VAX/VMS exit status
;	The high-order bit inhibits message display

	esCsuc := 1 | (1 << 28)		; success
;	esCinf := 3 | (1 << 28)		; informational
	esCwar := 0 | (1 << 28)		; warning
	esCerr := 2 | (1 << 28)		; error
	esCfat := 4 | (1 << 28)		; fatal (severe)

	osVsys : int = osKvms		; system
	osVimp : int = osKvms		; implementation
	osVhst : int = osKvms		; host
	osVcpu : int = osKvax		; cpu
	osVend : int = osKbig		; endian
					;
	osVsev : int own = esCsuc	; assume success

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
  is	exeunt osVsev		; exit image
	fail
  end
