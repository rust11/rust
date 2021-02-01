file	clprm - read command with prompt
include	rid:rider
include	rid:cldef
include	rid:mxdef
include	rid:stdef
include	rid:stdef
include	rid:codef
include	<stdio.h>

;	Windows version

code	cl_cmd - read command with prompt - easy call

;	Return image command line if no prompt

  func	cl_cmd
	prm : * char
	buf : * char			; defaults to no reply
  is	reply cl_lin (buf) if !prm	;
	reply cl_prm (stdin, prm, buf, mxLIN)
  end

code	cl_prm - read command with prompt

  func	cl_prm
	fil : * FILE			; input channel
	prm : * char			; prompt or <>
	buf : * char			; input buffer (optional)
	max : int			; buffer length (at least 128)
	()  : int			; fail => eof
  is	tmp : [mxLIN] char		;
	opt : * FILE			; output channel
	lst : * char			;
	buf = tmp if !buf		; use throw-away buffer
					;
	if cl_tty (fil)			; check terminal 
	   fine co_prm (prm, buf, max)	;
	else				;
	   (max ge 0) ? max ?? -max	; adjust max
	   fgets (buf, that, fil)	; get it from file or wherever
	.. fail if null			; end of file or error
	st_rep ("\n", "", buf)		; dump newlines
	st_rep ("\r", "", buf)		; and returns
	fine				;
  end
end file
If Vms
include	rid:medef
include	<stdio.h>
include	<unixio.h>
include <rmsdef.h>
include <fab.h>
include <rab.h>

;	o  VMS overwrites prompts written by C programs because it has
;	   an internal end-of-line/start-of-line protocol for terminals.
;
;	o  VMS and DOS both support last-line editing - but it is restricted
;	   to internal calls and requires tailored logic.

	rmTfab	:= struct FAB
	rmTrab	:= struct RAB
	SS$_CONTROLC := 1617		; control/c completion

code	cl_prm - read command with prompt

  func	cl_prm
	fil : * FILE			; input channel
	prm : * char			; prompt or <>
	buf : * char			; input buffer
	len : int			; buffer length
	()  : int			; fail => eof
  is	spc : [128] char		; filespec
	fab : rmTfab			;
	rab : rmTrab			;
	sta : int			; status
					;
	if isatty (fileno (fil)) eq	; not a terminal
	   fgets (buf, len, fil)	; get from file
	.. reply that ne <>		;
					;
     repeat				; fail block
	me_mov (&cc$rms_fab, &fab, #rmTfab)
	me_mov (&cc$rms_rab, &rab, #rmTrab)
					;
	getname (fileno(fil), spc)	; get the open name
	fab.fab$l_fna = spc		; the filespec
	fab.fab$b_fns = st_len (spc)	;
	 FAB$M_GET|FAB$M_BRO		; get block/record
	fab.fab$b_fac = FAB$M_GET	; get only
	 FAB$M_PUT|FAB$M_GET|FAB$M_DEL	;
	 FAB$M_UPD|FAB$M_UPI|that	;
	fab.fab$b_shr = that		; sharing
	sta = sys$open (&fab)		; open the file
	fail if (sta & 1) eq		; failed
					;
	rab.rab$l_fab = &fab		; setup fab address
	rab.rab$l_rop = RAB$M_NLK	; don't lock records
	rab.rab$w_isi = 0		; zap rab
	sta = sys$connect (&rab)	; connect rab
	quit if (sta & 1) eq		; failed

;	M$_ETO

	rab.rab$l_ubf = buf		; buffer address
	rab.rab$w_usz = <short>(len - 1); setup the transfer count
	rab.rab$l_pbf = prm 		; the prompt buffer
	rab.rab$b_psz = st_len (prm)	;
	rab.rab$l_rop |= RAB$M_PMT	; use prompt buffer
	sta = sys$get (&rab)		; read it
	buf[rab.rab$w_rsz] = 0		; terminate buffer
	sys$disconnect (&rab)		;
     never				;
	sys$close (&fab)		;
	*buf = 0 if sta eq RMS$_CONTROLC; completed under control/c
	reply (sta & 1) eq 1		;
  end
End
end file
If Wnt || Win
code	cl_prm - windows prompt
include	rid:imdef

  func	cl_prm
	fil : * FILE			; input channel
	prm : * char			; prompt or <>
	buf : * char			; input buffer
	len : int			; buffer length
	()  : int			; fail => eof
  is	cnt : int 			; result size
	im_rep ("I-Prompt: %s", prm)	;
	fail				;
  end

End
