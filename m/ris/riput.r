file	riput - write output
RIFMT := 1
include rid:rider
include rib:eddef
include rib:ridef
include	rid:iodef
include	rid:stdef

code	ri_put - emit line

;	Preprocessor lines go out without any decoration

  proc	ri_put
  is	lin : * riTlin fast = riPcur	; output line
	nst : Int = riVnst		; nesting level
					;
;	while --(lin->Vnul) ge		; do blank lines
;	.. ri_new ()			; newline
					;
	if *lin->Atxt eq '#'		; got control line (#...)
	   ri_prt (lin->Atxt)		; print with indent
	.. *lin->Atxt = 0		; and delete it
					;
	while --(lin->Vis) ge		; { ...
	   ed_pre ("{")			; put back is's
	.. ++riVnst			; remember nest
					;
	while --(lin->Vbeg) ge		; ... {
	   ed_app (" {")		; terminate it
	.. ++riVnst			; count back down
					;
	while --(lin->Vend) ge		; ... }
	   ed_app (" }")		; terminate it
	.. --riVnst			; count back down
					;
	if *lin->Asrc eq '\f'		; starts with formfeed
	   ri_dis ("\f")		; put it back
	.. *lin->Asrc = 0		; once only
					;
	if *lin->Atxt ne		; got something to display
	   while --nst ge		; indent
	   .. ri_dis ("  ")		;
	.. ri_prt (lin->Atxt)		; display the line
  end

code	ri_idn - indent for case

  proc	ri_idn
	ext : int			; extra indents
  is	nst : Int 			;
	nst = riVnst + ext		; nesting level
	while --nst ge 			; indent
	.. ri_dis ("   ")		;
  end

code	ri_prt - print a line

  proc	ri_prt
	str : * Char			; string to print
  is	ri_dis (str)			; display it
	ri_new ()			; and newline
  end

code	ri_new - print a newline

  proc	ri_new
  is	ri_dis ("\n")
  end

code	ri_dis - print string

	riVpln : int = 1
	riVnln : int = 0

  proc	ri_dis
	str : * Char
  is	buf : [128] char
	ptr : * char 
	exit if riVinh			; output inhibited
	exit io_put (str) if !quFlin	; don't want line numbers
	ptr = buf
	while *str 
	   *ptr++ = *str
	   *ptr = 0
	   next if *str++ ne '\n'
	   io_put (buf)
	   FMT(buf, "#line %d\n", riVpln++)
	   io_put (buf)
	   ptr = buf
	end
	*ptr = 0
	exit if !buf[0]
	io_put (buf)
  end
code	ri_fmt - write formatted string

;	Writes formatted string without regard to indents etc

  proc	ri_fmt 
	msg : * char
	p1  : * void
	p2  : * void
	p3  : * void
	p4  : * void
  is	par : int = 1			; first parameter
	var : * void			; the variable
	val : int			; integer variables
	mod : int			;
	buf : [128] char		; temp buffer
	dst : * char = buf		;
      while *msg ne			; got more
	if *msg eq '%'			; want something special
	   ++msg			; skip the %
	   mod = *msg++	 if *msg	; get the mode
	   mod = '?'     otherwise	;
	   if mod eq '%'		; %%
	   .. next *dst++ = mod		; store it
	   case par++			; get the parameter
	   of 1   var = p1		;
	   of 2   var = p2		;
	   of 3	  var = p3		;
	   of 4   var = p4		;
	   of other			;
		  var = "???"		;
	   end_case			;
	   case mod			;
	   of 's'			; string	
	      st_cop(<*char>var, dst)	; copy it 
	      dst = that		;
	   of 'd'			; decimal
	      val = *<*int>var		; get the value
	      sprintf (dst, "%d", val)	; convert it
	      dst += that		;
	   of other			; invalid
	      *dst++ = '['		; [%x]
	      *dst++ = '%'		;
	      *dst++ = par		;
	      *dst++ = ']'		;
	   end_case			;
	   next				;
	end				;
					;
	while *msg ne			; got more
	   quit if *msg eq '%'		; something else coming
	   if msg[0] eq '\\'		; got backslash
	   && msg[1] ne			;
	   .. *dst++ = *msg++		; copy two
	   *dst++ = *msg++		; copy one
	end				;
      end				;
	*dst = 0			;
	ri_prt (buf)			; write result out
  end
