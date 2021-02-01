file	sccf - ztc filter
include	rid:rider
include	rid:imdef
include	rid:mxdef
include	rid:abdef
include	rid:stdef
include	rid:fidef
include	<stdio.h>

data	locals

	cuMAX	:= (mxLIN * 4)
	cu_abo	: (void) void

  init	cuAabo : [] * char
  is	"SCCF - Filter ZTC output (c) HAMMONDsoftware 1992"
	""
	"	Removes useless information from ZTC output"
	""
	"	sc ...  | sccf"
  end

  type	cuTrep
  is	Prep : * char
	Pmod : * char
  end

  init	cuApar : [] cuTrep
  is	"was:",		"It was declared as:"
	"now:",		"It is now declared:"
	"had:",		"Had:"
	"now:",		"and:"
	"far",		"far C func"
	"",		"C func"
	"",		"returning"
	"*SS",		"ss *"
	"@",		"<far *>"
	"",		"struct "
	" ",		"><"
	"",		"<"
	"",		">"
	<>,		<>
  end

  init	cuAmsg : [] cuTrep
  is	"",		"Syntax error"
	"",		"Warning"
	"redeclared",	"previously declared as something else"
	"unused value",	"value of expression is not used"
	"-> and * require pointer",
			"pointer required before '->' or after '*'"
	"misses prototype"
			"does not match function prototype"
;
;			"possible unintended assignment"
	"not a member of"
			"is not a member of struct"
	"not a member of"
			"is not a member of"
	<>,		<>
  end

code	main - filter ZTC output

  proc	main
	cnt : int
	vec : **char
  is	ipt : * FILE = stdin		; the input line
	opt : * FILE = stdout		;
	arr : [cuMAX] char		;
	msg : [cuMAX] char		;
					;
	fst : [cuMAX] char		; previous line
	snd : [cuMAX] char		;
	lin : * char = fst		;
	nxt : * char = snd		;
	rep : * cuTrep			;
	tot : int = 0			; total errors

 	im_ini ("SCCF")			;
	ab_enb ()			;
	cu_abo () if cnt ne 1		; about
	*nxt = 0			; starts clean
     repeat				;
	if *nxt ne			; already have next
	   st_cop (nxt, lin), *nxt = 0	; take it
	else				;
	   fi_get (ipt, lin, cuMAX)	; get another
	.. quit if eof			;
	*nxt = 0			; assume no more
	fi_get (ipt, nxt, cuMAX)	; get another
	next if cu_arr (lin, nxt, arr)	; was arrow pair
	if cu_msg (lin)			; was a message
	   im_exi () if ++tot gt 100	; too many messages
	   PUT("\n%s\n", lin)		;
	   PUT("%s\n", arr) if arr[0]	;
	.. next lin[0] = arr[0] = 0	;
	rep = cuApar			; parameter line
	while rep->Pmod			;
	   spin while st_rep (rep->Pmod, rep->Prep, lin)
	   ++rep			;
	end				;
	PUT("%s\n", lin) if *lin	;
	lin[0] = 0			;
     end				;
	PUT("%s\n", lin) if lin[0]	;
	PUT("%s\n", nxt) if nxt[0]	;
	im_exi ()			; reporting error
  end

code	cu_msg - handle messages

  func	cu_msg
	str : * char
  is	fine if st_fnd (") : Error", str);
	fail
  end

;	fail if *src ne '\"'		; not a message
;	fail if (ptr = st_fnd ("\"", src+1)) eq ; not a trailer
;	*dst++ = *src while ++src ne ptr; get the file name
;	src = st_scn (", line ", ptr+1) ; skip next part
;	fail if null			;
;	*dst++ = '-'			;
;	*dst++ = *src++ while *src && *src ne ' '
;	++src if *src eq ' '		;
;	while rep->Pmod
;	   st_rep (rep->Pmod, rep->Prep, src)
;	   ++rep			;
;	end				;
;	st_cop (src, dst)		; add the message
;	st_cop (msg, str)		; return result
;	fine
;  end

code	cu_arr - handle arrows

  func	cu_arr
	lin : * char
	nxt : * char
	res : * char
  is	bas : * char = nxt
	arr : int = 0
	cnt : int = 0
	cha : int
	while (cha = *nxt++) ne		;
	   if cha eq '^'		;
	      ++arr			; got one
	   elif cha eq ' '		;
	   .. ++cnt if !arr		; no arrow yet
	end				;
	fail if !arr			; no arrow
	fail if st_len (lin) lt cnt	; nowhere to go
	st_ins ("^", lin+cnt+1)		; insert the arrow
	*bas = 0			; dump next line
	st_cop (lin, res)		; return arrow line
	fine
  end

code	cu_abo - about us

  proc	cu_abo
  is	abo : ** char = cuAabo		;
	txt : * char			;
	while (txt = *abo++) ne		;
	   puts (txt), puts ("\n")	; avoid printf package
	end				;
	im_exi ()			; forget the rest
  end
