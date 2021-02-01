file	wsmsg - windows server message output
include	rid:rider
include	rid:wsdef
include	rid:wsmsg
include	rid:imdef
include	rid:mxdef
include	rid:stdef
include	<stdio.h>

code	ws_msg - windows message

  func	ws_msg
	msg : * char
	obj : * char
  is	han : HWND = GetActiveWindow ()
	bod : [128] char
	typ : int = wmbOC_		; only an OK button
	res : int 			;
	case *msg			; facility
	of 'I' 	 typ |= wmbINFO_	;
	of 'F'				; fatal 
	or 'E'   typ |= wmbERROR_	;
	of 'W'   typ |= wmbWARN_	;
	of 'Q'   typ = wmbQUERY_|wmbYNC_; query, yes/no/cancel
	of other typ |= wmbWARN_	; default
	end case			;
	if *msg && msg[1] eq '-'	; got a facility 
	..  msg += 2			; skip it
	FMT (bod, msg, obj)		; format message and objects
	MessageBox (0, bod, imPfac, typ);
	res = that			;
	if res eq IDCANCEL		; hit cancel
	&& typ ne (wmbQUERY_|wmbYNC_)	;
	.. im_exi ()			; all over
	reply res			;
  end
end file
;	See if these still get used
code	ws_pch - duplicate PUTCHAR function

;	Called from fi_xxx modules for TT handles

	wsApch : [84] char own		
	wsVpch : int own = 2		;

  proc	ws_pch				; putchar dummy
	cha : int			;
  is	buf : * char = wsApch		;
	idx : int = wsVpch		; static index
	if cha ge 32			; printing
	&& cha le 127			;
	.. buf[idx] = cha		;
	if cha eq '\n'			; end of line
	|| idx gt 82			;
	   buf[0] = 'I'			;
	   buf[1] = '-'			;
	   buf[idx] = 0			;
	   ws_msg (buf, "")		;
	   idx = 2			;
	else				;
	.. ++idx			;
	wsVpch = idx
   end
code	ws_dec - decimal message
include	rid:opdef
include	rid:stdef

  func	ws_dec
	msg : * char
	val : int
  is	buf : [128] char
	ptr : * char = st_cop (msg, buf)
	*ptr++ = ' '
	op_dec (val, ptr)
	MessageBox (0, buf, imPfac, wmbOK_|wmbINFO_);
	fine
  end
code	ws_prt - printf replacement

	wsVprt : int = 0		; not reentrant
  func	ws_prt
	fmt : * char const
	... : ...
  	()  : int
  is	str : [mxLIN*2] char
	res : int
	ptr : * char = str
	fine if wsVprt
	++wsVprt
	res = vsprintf(str, fmt, <va_list>&(fmt) + #fmt)
	ws_pch (*ptr++) while *ptr
	--wsVprt
	fine
  end
