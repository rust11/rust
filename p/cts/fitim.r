file	fitim - file time attribute operations
include	rid:rider
include	rid:fidef
include	rid:mxdef
include	rid:rttim
include	rid:tidef

	fiSACC  := "E-Error accessing file [%s]"
	fiSSET  := "E-Error setting file [%s]"
	fiAacc	: * char own = fiSACC
	fiAset	: * char own = fiSSET

code	fi_gtm - get file date/time

  func	fi_gtm
	spc : * char			; file spec
	val : * tiTval			; the time
	msg : * char			; error message
	()  : int			; fine/fail
  is	ftm : rtTftm			;
	str : [32] char
	plx : tiTplx			;
	if !rt_gfd (spc, &ftm.Vdat)	;
	|| !rt_gft (spc, &ftm.Vsec)	;
	.. fail fi$rep (msg,spc,fiAacc)	; error accessing file
;PUT("fi_gtm: dat=%d tim=%d\n", ftm.Vdat, ftm.Vsec&0x7FFF)
	rt_gfx (spc, &ftm.Vext)		; no error for extended time
	rt_tfp (&ftm, &plx)		; convert to plex
;ti_str (&plx, str)
;PUT("[%s]\n", str)
	ti_val (&plx, val)		; return value
	fine
  end 

code	fi_stm - set file date/time

  func	fi_stm
	spc : * char			; file spec
	val : * tiTval			; the time
	msg : * char			; error message
	()  : int			; fine/fail
  is	plx : tiTplx			;
	ftm : rtTftm			;
	ti_plx (val, &plx)		; get plex
	rt_tpf (&plx, &ftm)		; time: plex to filetime
					;
	if !rt_sfd (spc, <>, ftm.Vdat)	; set file date
	|| !rt_sft (spc, <>, ftm.Vsec)	; set file time
	.. fail fi$rep (msg,spc,fiAacc)	; error accessing file
;PUT("fi_gtm: dat=%d tim=%ld\n", ftm.Vdat)
	rt_sfx (spc, <>, ftm.Vext)	; no error for extended time
	fine
  end 
