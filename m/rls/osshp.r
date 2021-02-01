file	osshp - O/S SHAREplus/RT-11 support
include rid:rider

;	os_ini ()	detect SHAREplus
;			get ccl command string
;
;	os_war ()	set warning status
;	os_err ()	set error status
;	os_fat ()	set fatal status
;	os_exi ()	exit image
;???	os_abt ()	abort image
;
;	ANSIC requires that 0 signify success
;	The remainder are implementation dependant
;
;			exit(0)		exit(1)		exit(n)
;	ANSIC		success		undefined	undefined
;	Unix		success		failure		failure - code
;	Zortech		success		failure		byte failure code
;	VAXC		undefined	success		VMS status code
;	Whitesmiths	failure		success		success
;	DECUSC		?		?		?
;
;	For RT-11/SHARE we set the error bits by hand
;	Exit reports redundant success (since DCL ignores this)

	esCsuc := 1			; success
;	esCfai := 0			; failure

;	esBsuc := BIT(0)		; success
;	esBinf := BIT(1)		; informational
	esBwar := BIT(2)		; warning
	esBerr := BIT(3)		; error
	esBfat := BIT(4)		; fatal
	jbBsev : * char = 053		; severity
	imPpre : "?"			; message prefix

code	os_ini - init for o/s

  proc	os_ini
  is	nothing
  end

  proc	os_war
  is	*jbVsev |= esBwar		; set warning status
  end

  proc	os_err
  is	*jbVsev |= esBerr		; set error status
  end

  proc	os_fat
  is	*jbVsev |= esBfat		; set error status
  end

  proc	os_exi 
  is	exeunt esCsuc			; exit image with success
  end
