file	dikbd - keyboard display
include	rid:rider
include	gkb:gkmod
include	rid:mxdef

  func	gk_kbd
	dcl : * dcTdcl
  is	buf : [mxLIN] char
	ipt : * char
	opt : * char
	cnt : int

;	special mode, rctrlo
	PUT("?DIAG-I-Type characters, then return\n")
      repeat
	PUT("> ")
	ipt = buf, cnt = mxLIN-1
	while cnt--
	   *ipt = rt_tin (1, 1)
	   quit if *ipt eq '\r'
	   ++ipt
	end
	rt_tin (1)			; get/skip lf
	cnt = ipt - buf			;
	opt = buf
	PUT("\n[")
	while cnt--
	   PUT("%o", *opt++ & 0377)	; next character
	   quit if !cnt
	   PUT(", ")
	end
	PUT("]\n")
     forever
	fine
  end
