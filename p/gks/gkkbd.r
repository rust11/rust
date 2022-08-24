file	gkkbd - keyboard character codes display
include	rid:rider
include	rid:mxdef
include	gkb:gkmod

;	special mode, rctrlo?

  func	gk_kbd
	dcl : * dcTdcl
  is	buf : [mxLIN] char
	ipt : * char
	opt : * char
	cnt : int

	PUT("?KBD-I-Type characters, then <enter>\n")

      repeat
	PUT("KBD> ")
	ipt = buf, cnt = mxLIN-3
	while cnt--
	   *ipt = rt_tin (1, 1)
	   quit if *ipt eq '!'
	   quit if *ipt eq '\r'		; return
	   ++ipt			;
	end				;

	rt_tin (1) if *ipt ne '!'	; get/skip lf
	cnt = ipt - buf			;
	opt = buf

	PUT("[")
	while cnt--
	   PUT("%o", *opt++ & 0377)	; next character
	   quit if !cnt			; nothing - we are done
	   PUT(", ")
	end
	PUT("] ")

	next PUT("\n") if *ipt ne '!'
	repeat
	   PUT("%c", *ipt)
	   *ipt = rt_tin (1, 1)
	   quit if *ipt eq '\r'		; return
	end				;
	PUT("\n")
     forever
	fine
  end
