;???;	literal ^! and ^; required in dfmod
file	dfexp - expand definition
include rid:rider
include	rid:dfdef
include	rid:stdef
include	rid:chdef
include	rid:ctdef
include	rid:fidef

;	df_exp (ctx, def, lin, dst, mxLIN, '#', 0) 
;
;	^^		literal ^
;	^0		definition name
;	^1..^9		parameter 1 to 9
; ???	^A..^Z		caps are parameters A (10) to Z
;	^a		all the command
;	^d#..^e		default ^n to "...", nesting permitted
;	^f#		all command from ^n
;	^p#		"T" if present, "F" if missing
;	^n		insert newline
;	^r#		required parameter n
;	^t#		translated parameter n
;	^x		check excess parameters
;	^<space>	insert newline (same as '^n')
;	^<nl>		inhibit implicit parameters
;
;	^D1
;
;	cmd aaa bbb ccc
;	^1		aaa
;	^2		bbb
; !!!	^a		aaa bbb ccc
;	^d1yyy^e	aaa
;	^d8zzz^e	zzz
;	^f1		aaa bbb ccc
;	^f2		bbb ccc
;	^r1		aaa
;	^r4		%SHE-E-Not enough arguments
;
;	Choice of operators is limited to those that have no other meaning.
;	(*, :, .) must be available for filenames.

	_dfOVR	:= "E-Definition buffer overflow [%s]"
	_dfMIS	:= "E-Not enough arguments [%s]"
	_dfXCS	:= "E-Too many arguments [%s]"
	_dfARG	:= "E-Invalid argument in [%s]"
	_dfSYN	:= "E-Invalid definition operator in [%s]"

	dfARG	:= 0
	dfREQ	:= 1
	dfFRM	:= 2
	dfALL	:= 3
	dfDEF	:= 4
	dfTRN   := 5
	dfPRS   := 6

	df_arg	: (*dfTctx, int, *char, **char) int-	; get nth argument
code	df_trn - translate definition

;	Parse leading identifier
;	Lookup definition
;	Parse definition with line remainder

  func	df_trn
	ctx : * dfTctx
	src : * char
	dst : * char
	len : int
  is	def : * dfTdef 
	idt : [34] char
	ptr : * char = src
	cnt : int = 0
	while *ptr && *ptr gt ' '
	   if cnt lt 32
	   .. idt[cnt++] = *ptr
	   ++ptr
	end
	idt[cnt] = 0
	ptr = st_skp (ptr)
	def = df_loo (ctx, idt)
	pass fail
	df_exp (ctx, def, ptr, dst, len, '^', 0)
	reply that
  end
code	df_exp - expand definition

  func	df_exp
	ctx : * dfTctx				; definition context
	def : * dfTdef				; the definition
	rem : * char				; remainder of command line
	dst : * char				; destination string
	max : int				; dst max (with zero)
	pre : int				; prefix character
	syn : int				; syntax - unused at present
	()  : int				; fail => overrun
  is	bod : * char = def->Pbod		; definition body
	arg : * char				; argument
	msg : * char				; error message
	exp : int = 0				; was explicit
	top : int = 0				; highest parameter seen
	len : int = 2				; we need two extra
	cha : int				;
	cas : int				;
	idx : int				;
	cnt : int				;
	bas : * char = dst			;
						;
     repeat					;
	*dst = 0				; terminate it
	if *bod eq				; all over
	   fine if exp || *rem eq		; was explicit or no remainder
	   *dst++ = ' ', ++len, cha = 'a'	; force remainder (++exp below)
	else					;
	   quit msg=_dfOVR if ++len ge max	; gone too far
	   if *bod eq '|'			; | is newline
	      fine *dst=0 if !bod[1]		; |<nl> ends it
	   .. next *dst++='\n' if *++bod ne '|'	; || is |
	   if (*bod ne '^') && (*bod ne pre)	; old style
	   .. next *dst++ = *bod++		;
	   next *dst++=*bod++ if *bod++ eq *bod ; ^^ is ^
	   fine *dst=0 if (cha = *bod++&255) eq	; ^<nl> ends it 
	.. --len				; adjust for assumption
	++exp					; we have explicit state
	if cha eq 'x'				; checking excess
	   next if df_arg (ctx,top,rem,&arg) eq	; is the last
	.. quit msg=_dfXCS			; has excess arguments
						;
	case cha 				;
	of 'd'    cas = dfDEF			; ^dn...^e default
	of 'e'	  next				; ^e - end of default
	of ' '					; 
	or 'n'	  next  *dst++ = '\n'		; insert newline
	of 'a'    cas = dfALL			; all command
	of 'f'    cas = dfFRM			; from
	of 'p'	  cas = dfPRS			; argument is present
	of 'r'    cas = dfREQ			; required
	of 't'    cas = dfTRN			; translate required
	of other  cas = dfARG			; default
	end case				;
						;
	if cas ne dfALL				; need parameter address
	   cha = *bod++ & 255 if cas ne dfARG	; skip command code
	   quit msg=_dfARG if cha eq		;
	   if ct_dig (cha)			;
	      idx = cha - '0'			;
	   elif ct_upr (cha)			;
	      idx = (cha - 'a') + 10		;
	   else					;
	   .. quit msg=_dfARG			;
	   top = idx if idx gt top		; maximize top
	.. cnt = df_arg (ctx, idx-1, rem, &arg)	; pick it up
						;
	case cas				; 
	of dfALL  arg = rem, cnt = st_len (rem)	; want whole command 
	of dfFRM  cnt = st_len (arg) if cnt ne	; want command tail
	of dfTRN  fi_loc (arg, arg)		; translate to local form
		  cnt = st_len (arg)		;
	of dfDEF  quit if cnt eq		; need the default
		  idx = 1			; nesting level
		  while *bod ne			; skip the default
		     next  if *bod++ ne pre	; not the prefix
		     quit  if (cha=*bod++) eq	; end of line
		     ++idx if cha eq 'd'	; enclosed default
		     --idx if cha eq 'e'	; down a level
		     quit  if idx eq		; end of it
		  end				;
	of dfPRS  arg = "T" if cnt		; argument is present
		  arg = "F" otherwise		; argument is absent
		  cnt = 1			;
	end case				;
						;
	quit msg=_dfMIS if cnt eq && cas eq dfREQ; required parameter missing
	quit msg=_dfOVR if (len += cnt) ge max	; too much of it
	*dst++ = *arg++ while cnt--		; move in the string
     end					;
	df_rep (ctx, msg, def->Pnam)		; report it
	msg = def->Pbod
	PUT("[")
	PUT("%c", *msg++) while *msg && msg lt bod
	PUT("^%s]\n", msg)			;
	fail					;
  end
code	df_arg - isolates nth argument 

  func	df_arg
	ctx : * dfTctx			; the context
	nth : int			; the argument required
	str : * char			; string to vectorize (and destroy)
	res : ** char			; result pointer
	()  : int			; length of it or fail
  is	bal : * char			;
	sep : int = ctx->Vsep		; space or comma
	fail if nth lt			; negative index
      repeat				; the nth
	++str while ct_spc (*str)	; skip leading spaces
	fail if *str eq			; all done
	*res = str			; save start address
	while *str ne			; got more
	   bal = ctx->Pbal		; balance set
	   while *bal ne		; look for balance member
	      if *str eq *bal++		; balance this one?
	   .. .. quit str = st_bal (str);
	   quit if *str eq sep || !*str	; gotcha or eol (from st_bal)
	   ++str			; try again
	end				;
 	quit if nth-- eq		; found it
	++str if *str ne		; skip terminator
      forever				; look at next
	reply str-*res			;
  end
end file
