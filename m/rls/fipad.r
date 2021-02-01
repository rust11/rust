file	fipad - padded read/write
include	rid:rider
include	rid:fidef
include	rid:medef

;	fiSUC	All transferred
;	fiPAR	Partial transfer, padded
;	fiEOF	No transfer
;	fiERR	I/O error

  func	fi_prd
	fil : * FILE			; the file
	buf : * char			; the buffer
	fst : size			; first byte (not block)
	cnt : size			; byte count
	trn : * size			; optional transfer size (minus padding)
 is	lst : size = fst + cnt		; lst  last to read
	eod : size			; eod  dos size
	eof : size			; eof  rt11a size after rounding
	rem : size = 0			; rem  eof-eod padding
	sts : int = fiSUC		; assume fine
	*trn = 0 if trn			; assume nothing transferred

	eod = fi_len (fil)		; Win32 file size
	eof = (eod + 511) & (~511)	; rt-11 eof

;PUT("eof=%d fst=%d lst=%d cnt=%d\n", eof, fst, lst, cnt)

	if fst ge eof			; no hope
	.. reply fiEOF			;
	if lst gt eof			;
	   sts = fiPAR			; EOF
	   cnt = (eof - fst)		; adjust count
	.. lst = eof			; adjust length
	if lst gt eod			; need padding?
	   rem = lst - eod		; remainder to clear
	   cnt = eod - fst		; adjust count
	end				;
					;
	fi_see (fil, fst)		; seek to it
	fi_rea (fil, buf, cnt)		; read
	reply fiERR if fail		;
	me_clr (buf+cnt, rem) if rem	; pad with nulls
	*trn = cnt if trn		; optional result
	reply sts			;
  end
