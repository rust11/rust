file	immod - image routines
include rid:rider
include rid:imdef
include rid:osdef

;	im_ini()	Setup facility name, init things
;	im_exi()	Exit with accumulated status
;	im_war()	Warn - continue
;	im_err()	Error - restart or abort
;	im_fat()	Fatal - abort

data	immod 

	imPpre : * "?"			; message prefix
	imPfac : * "NONAME"		; default facility name
					;
	im_nop : imTcbk-		; forward nop routine
	imPwar : * imTcbk = &im_nop	; warning routine
	imPerr : * imTcbk = &im_nop	; error routine
	imPfat : * imTcbk = &im_nop	; fatal routine
	imPexi : * imTcbk = &im_nop	; exit routine

code	im_ini - image init

  func	im_ini
	fac : * char			; facility name
	()  : int			; fine/fail
  is	imPfac = fac if fac		; store it
	fine os_ini ()			; init o/s
  end

code	im_nop - do nothing

  proc	own im_nop
  is	nothing				; always happy
  end

code	im_war - image warning

  func	im_war
	()  : int			; fine
  is	os_war ()			; do o/s part
	(*imPwar) ()			; do user part
	fine				; o.k. to continue
  end

code	im_err - image error

  func	im_err
	()  : int			; fine
  is	os_err ()			; do o/s part
	(*imPerr) ()			; do user part
	fine				; o.k. to continue
  end

code	im_fat - image fatal

  func	im_fat
	()  : int			; undefined
  is	os_fat ()			; do o/s part
	(*imPfat) ()			; do user part
	im_exi ()			; exit image
	reply that			; should not occur
  end

code	im_exi - exit image

  func	im_exi
	()  : int			; undefined
  is	(*imPexi) ()			; user bypass
	os_exi ()			; exit with previously defined status
	reply that			; should not return
  end
