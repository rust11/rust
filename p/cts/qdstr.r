;+++;	CTS:QDSTR - move this out to CTT:
file	qdstr - quad integer arithmetic string routines
include	rid:rider
include	rid:medef
include rid:stdef
include rid:mxdef
include rid:qddef

;	Unoptimised quad integer arithmetic support
;	Implemented to support quad time values;
;
;	Quads are represented as four 16-bit (unsigned) words,
;	stored in PDP-11 reverse word-order (as for longs)
;
;	quad:	.word	high-order	; sign bit is bit 15
;		.word	...
;		.word	..
;		.word	low-order	; quad bit 0 is bit 0

code	qd_set - quad maintenance set 

  func	qd_set
	qua : * WORD
	v0  : WORD
	v1  : WORD
	v2  : WORD
	v3  : WORD
  is	*qua++ = v0	; high
	*qua++ = v1	; ..
	*qua++ = v2	; ..
	*qua++ = v3	; low
  end

code	qd_dmp - quad maintenance dump

  func	qd_dmp
	str : * char
	val : * WORD
  is	PUT("%s:", str)
	PUT("%x %x %x %x ", val[0], val[1], val[2], val[3])
  end

code	qd_dec - display quad decimal value

  func	qd_dec
	val : * WORD
  is	qd_put ("%qd", val)
  end

code	qd_hex - display quad hex value

  func	qd_hex
	val : * WORD
  is	qd_put ("%qx", val)
  end

code	qd_put - display formatted quad

  func	qd_put
	fmt : * char
	val : * WORD
  is	str : [mxLIN] char
	qd_fmt (fmt, val, str)
	PUT("%s", str)
  end

code	qd_fmt - format quad

;	qd_fmt ("value: %qd", quad)
;	qd_fmt ("value: %qx", quad)

  func	qd_fmt
	fmt : * char
	val : * WORD
	str : * char
	()  : * char
  is	bas : int
	while *fmt
;	   if st_scn ("\n", fmt)
;	      PUT("\n"), fmt += 2
	   if st_scn ("%q", fmt)
	      bas = 10, fmt += 2
	      if *fmt eq 'x'
	         bas = 16, ++fmt
	      else
	      .. ++fmt if *fmt eq 'd'
	      str = qd_str (val, str, bas)
	   else
	   .. *str++ = *fmt++
	end
	reply str
  end

code	qd_str - convert quad to string

  func	qd_str
	val : * WORD
	str : * char
	bas : int		; 10 or 16
	()  : * char		; past result
  is	tmp : [4] WORD
	rem : [4] WORD
	ten : [4] WORD
	buf : [32] char
	ptr : * char = buf

	qd_mov (val, tmp)
	qd_clr (rem)
	qd_clr (ten), ten[3] = bas
	if tmp[0] & 0100000
	   *str++ = '-'
	.. qd_neg (tmp)		; 0100... case okay

	repeat
	   qd_div (tmp, ten, tmp, rem)
	   if rem[3] lt 10
	      *ptr++ = rem[3] + '0'
	   else
	   .. *ptr++ = (rem[3] - 10) + 'A'
	   quit if !qd_tst (tmp)
	forever
	while ptr ne buf
	   *str++ = *--ptr
	end
	*str = 0
	reply str
  end
