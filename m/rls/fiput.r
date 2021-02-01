file	fiput - put next line
include rid:rider
include	rid:fidef
include rid:chdef
include rid:cldef

code	fi_put - Write line to file

;	Converts 0/cr/lf to (cr/)lf

  func	fi_put
	fil : * FILE~			; the file
	buf : * char~			; the buffer
	()  : int			; EOF or FINE
  is	cha : char fast			; next character
If Wdw					;
	if cl_tty (fil) ne <>		; terminal output
	   PUT (buf)			; windows console buffer
	.. fine				;
End					;
	repeat				;
	   cha = *buf++			; get next
	   if (that eq _cr		;
	    && *buf eq _nl)		; cr/lf pair
	   || cha eq			; or null
;	   || cha eq _nl		; or newline
;	      putc (_cr, fil)		; prepend return
	   .. cha = _nl			; force newline
	   putc (cha, fil)		;
	until (cha eq _nl)		;
	fine				; always succeeds
  end
end file

;	function not in use

code	fi_prt - Put line without nl

  func	fi_prt
	fil : * FILE~			; the file
	buf : * char~			; the buffer
	()  : int			; EOF or FINE
  is	cha : char fast			; next character
If Wdw					;
	if cl_tty (fil) ne <>		; terminal output
	   PUT ("%s", buf)		; windows console buffer
	.. fine				;
End					;
	while (cha = *buf++) ne		; got another
	   putc (cha, fil)		;
	end				;
	fine				; always succeeds
  end
