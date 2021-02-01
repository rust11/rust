;+++;	RIS:RITYP - A '*' for .WEAK; implement as PRAGMA ...
file	rityp - convert rider type to C type
include rid:rider
include rib:eddef
include rib:ridef
include rid:medef
include	rid:imdef
include	rid:ctdef
include rid:stdef
include rid:chdef

;	rityp	rider-to-C type translation
;
;	ri_typ	generic type decoder
;	ri_cst	<type> cast translation
;	ri_abs  abstract declarator	
;	ri_cla	storage class (+-?.)
;	ri_siz	#type sizeof operator
;
;	ri_bit	bitfields are deprecated
;	ri_kon	end code

data	locals

	ri_abs : (*char, *char, int) *char own

code	ri_typ - generic declaration conversion

;	nam : () [] * ... char fast
;	nam : typ = ini
;	nam : typ is
;	nam : "..."
;	nam : * "..."

  func	ri_typ
	str  : * char~			; string to convert
	dst  : * char			; result - may overlap source
	()   : int			; FAIL if wrong
  is	buf  : [128] char~		; result
	len  : int~			;
	buf[0] = 0			; terminate buffer
					;
	fail if !st_fnd (" : ", str)	; no type
	str = ri_abs (str, buf, '=')	; get abstract declarator
	len = st_len (buf)		; get result length
	st_mov (str, dst + len)		; move remainder into place
	me_mov (buf, dst, len)		; preprend result
	fine				; got it
  end

code	ri_cst - process <> casts 

;	Preprocess any casts on the line
;
;	rider:	x = <**char>y
;	c:	x = (char**)y
;
;	Casts must be processed before lt, le, etc
;	Casts should not occur in declarations (they will be processed twice)
;???	Turn of function prototypes in cast?

  func	ri_cst
	str : * char~			; any line
  is	dst : * char~			; result - may overlap source
	dat : [128] char		; result data
	res : * char~ = dat		; pointer to data
	len : int			; length of cast string
					;
	while *str ne			; got more
	   if *str eq '"'		; "
	   || *str eq '\''		; '
	      str = st_bal (str)	; balance them
	   .. next			;
	   next ++str if *str ne '<'	; not a cast
	   if str[1] eq '<'		; << - shift operator
	   || str[1] eq '>'		; <> - null
	   .. next str += 2		; skip both and try again
	   *str++ = '('			; replace < with (
					;
	   dst = str			; for post relocation
	   *res = 0			; terminate result
	   str = ri_abs (str, res, '>')	; get abstract declarator
	   if *str eq '>'		; terminated correctly
	      *str = ')'		; replace it
	   else				;
	   .. im_rep ("W-Missing [>] in cast [%s]", str)
	   len = st_len (res)		; get result length
	   st_mov (str, dst + len)	; move up remainder
	   me_mov (res, dst, len)	; insert result
	   str = dst + len		; point past cast
	end				; look for another
	fine				;
  end
code	ri_abs - get abstract declarator

	skip (str) := ++str while ct_spc (*str)
	last (str) := ++str while *str ne

;	Declators end with one or more identifiers.
;	A class flag may be tacked onto an identifier (no whitespace)
;
;	aaa : int~	register
;	aaa : int-	static
;	aaa : int+	extern

	ri_cla : (*char, *char) *char	; check class

  func	ri_abs
	str : * char~			; string to process
	res : * char~			; result string
	ter : int			; terminator
	()  : * char			; string remainder
  is	buf : [64] char			; identifier buffer
	pbf : [64] char			; pointer buffer
	cla : [32] char			; register etc
	ptr : * Char			; pointer to identifier
	alp : int = 0			; seen alpha
;V4	kon : int = 0			; needs 'const' modifier
	pex : * char			; "*", "far *", "near *"
	cut : * char			; cut out function parameters
	cla[0] = 0			; no class

;V4--	nam : [k] bits	->  nam : k	bit field

If 0
	if (ptr = st_fnd (" bits", str)) ne <>; nam : [k] bits
	   res = st_end (res)		; skip to end of it
	   while str lt ptr		; copy first part
	      if *str eq '['		; not [k]
	      || *str eq ']'		;
	      else			;
	      .. *res++ = *str		; copy another
	      ++str			; skip to next
	   end				;
	   *res = 0			; terminate result
	   str += 5			; skip " bits"
	.. reply str			;
End

    while *str				; got more
	str = st_skp (str)		; skip whitespace
	quit if *str eq ter		; end on terminator
	quit if *str eq ','		; end on commas
					;
	str = st_skp (str)		; skip whitespace
	if st_scn (": ", str)		; got the first part
	   str += 2			; skip it
	   alp = 0			; accept alphas again
	   if st_scn ("* \"", str)	; * "
;	   if str[0] eq '*'		; got * ...
;	   && str[1] eq ' '		; got * space ...
;	   && str[2] eq '"'		; got * " ...
	      st_ins ("char = ", str+2)	; * char = "..."
	   .. next			;
	   next if *str ne '"'		; xxx : "string"
	   st_ins ("[] char = ", str)	; [] char = "..."
	.. next 			; go again

;	alphanumeric - one only unless far, near

	pex = "*"			; assume simple pointer
	ptr = <>			; discriminate ...
	if ct_alp (*str)		; got alpha
	|| (ptr = st_scn ("...", str)) ne ; or one special symbol
	   ++alp			; remember alpha
	   if ptr ne <>			; got ...
	      str = ptr			; skip it
	      st_cop ("... ", buf)	;
	   else				;
	      ptr = buf			; get the address
	      while ct_aln (*str)	; get them all  
	      .. *ptr++ = *str++	; move one
	   .. *ptr++ = ' ', *ptr = 0	; add a space
	   str = ri_cla (str, cla)	; check class
	   str = st_skp (str)		; skip whitespace
					;
	   if st_sam (buf, "near ")	; got dos stuff
	      pex = " near *"		;
	   elif  st_sam (buf, "far ")	;
	      pex = " far *"		;
	   else				;
	      if *str eq '*'		; WINAPI* 
		 st_cop (buf, pbf)	;
		 st_app ("*", pbf)	;
		 pex = pbf		;
	      else			;
	   .. .. next st_ins (buf, res)	; just insert it
					;
	   --alp			; far/near don't count as alphas
	   if *str eq '*' ;V4|| *str eq '@'; got a pointer coming
	   else				; no pointer - i'm lost
	.. .. next st_ins (buf, res)	; let them report the error

;	pex now points to the next pointer expression ("*", "far*", "near*")
;	No punctuation is permitted after the first alpha

;       next ++reg,++str if *str eq '~'	; register
	if alp				; had alpha
	.. im_rep ("W-Invalid type in (%s)", riAseg);

;V4-	@...  => const *...
;	*...

	case *str & 255
;V4	of '@'				; const *
;V4	   ++kon			; need 'const' after all this
	of '*'				;
	   ++str			; skip it
	   str = st_skp (str)		; skip whitespace

	   if not *res			; no result yet?
	   .. next st_ins (pex, res)	; just "...*" for functions

;	just *... if next is alpha

	   if ct_alp (*str)		; next is alpha
	   .. next st_ins (pex, res)	;

;	*... => (*...)

	   st_ins (pex, res)		;  * ...
	   st_ins ("(", res)		; (* ...
	   st_app (")", res)		; (* ... )
	   next

;	[...]

	of '['
	   ptr = st_end (res)		; end of result
	   repeat
	      quit if *str eq		; no more string
	      *ptr++ = *str		; copy it
	      *ptr = 0			; terminate it
	   until *str++ eq ']'		; till we get it
	   next

;	()		expression returning ...
;	(..., ...)	type parameter list
;	(...)		type expression

	of '('
	      ++str			; skip (
	      st_app ("(", res)		; need (
	      cut = st_end (res)	; in case we cut it	;V4
	   repeat			; (...,...)
	      str = st_skp (str)	; skip whitestuff
	      if *str eq ')'		; simple?
	         st_app (")", res)	; add that
	      .. quit ++str		; done, skip )
	      ri_abs (str, st_end (res), ')')	; get inner
	      str = that		; point at remainder
	      if *str eq ','		; got ,
	         st_app (",", res)	; add a comma
		 next ++str		; skip and look again
	      elif *str eq ')'		; missed closure
	         ++str			; skip ')'
	         st_app (")", res)	; add )
	      else			;
	         im_rep ("W-Missing [)] in type [%s]", str)
	      end			;
	   never			;
	   str = ri_cla (str, cla)	; check class
	   if quFear			; early C?
	      *cut = 0			;
	   .. st_app (")", res)		; add that
;?V4???
	   next				; go for more
	end case			;


	im_rep ("W-Unknown type in [%s]", str) ;riAseg);
	quit				;
     end 				; of while
;V4	if kon ne			; needs 'const'
;V4	.. st_ins (" const ", res)	; const ...
	st_ins (cla, res) if cla[0]	; register/static/extern
	reply str			; send it back
  end

code	ri_cla - decode storage class

;	~	register
;	+	external
;	-	static
;
;	?	volatile	
;	.	const	(const placement is actually important)
;???;	*	weak global symbol [pragma weak name,name]

  func	ri_cla
	str : * char
	cla : * char
	()  : * char
  is	prv : int = 0
	cur : int = 0
      while ch_mat ("~-+?.", *str)
	cur = 2
	case *str++
	of '~'  --cur, st_app ("register ", cla)
	of '-'  --cur, st_app ("static ", cla)
	of '+'  --cur, st_app ("extern ", cla)
	of '?'  st_app ("volatile ", cla) if !quFear
	of '.'  st_app ("const ", cla) if !quFear
	end case
	if cur & prv 
	   ++str while ch_mat ("~-+%.", *str)
	.. quit im_rep ("W-Too many class specifiers [%s]\n", cla)
	prv |= cur
      end
	reply str
  end
code	ri_siz - sizeof operator

;	#(...)		sizeof(...)
;	#idt		sizeof(idt)
;	#idt.idt	sizeof(idt.idt)
;	#idt->idt	sizeof(idt->idt)
;
;	May not move edPdot
;	Must check for obselete keywords
;
;	Casts have been done, so <int> is now (int)

  proc	ri_siz
  is	pnt : * char~
	pnt = ed_fnd ("#")		; find one of them
	exit if eq <>			; are none
	if st_scn ("#include", pnt) ne <>
	|| st_scn ("#if ",     pnt) ne <>
	|| st_scn ("#ifdef",   pnt) ne <>
	|| st_scn ("#ifndef",  pnt) ne <>
	|| st_scn ("#elif",    pnt) ne <>
	|| st_scn ("#else",    pnt) ne <>
	|| st_scn ("#endif",   pnt) ne <>
	|| st_scn ("#undef",   pnt) ne <>
	.. exit				; obselete conditional
     repeat
	pnt = ed_rep ("#"," sizeof")	;
	quit if <>			; are no more
	pnt = st_skp (pnt)		; skip spaces
	next if *pnt eq '('		; already bracketed
	st_mov (pnt, pnt+1)		; move up the string
	*pnt++ = '('			; insert 
	while ct_aln (*pnt)		; skip symbol
	|| *pnt eq '_'			;
	|| *pnt eq '$'			;
	|| *pnt eq '.'			; xxx.yyy
	|| st_scn ("->", pnt)		;
	   ++pnt if *pnt eq '-'		;
	.. ++pnt			;
	st_mov (pnt, pnt+1)		; move it up
	*pnt = ')'			; terminate it
     forever				;
  end
If 0
code	ri_kon - pointer to constant operator

;	... @ idt ...		* idt const
;	... @ (exp) ...		* (exp) const
;
;	Usually caught by type translation
;	May not move edPdot

  proc	ri_kon
  is	pnt : * char
     repeat
	pnt = ed_rep ("@", "*")		;
	quit if <>			; are no more
	pnt = st_skp (pnt)		; skip spaces
	if *pnt eq '('			; got '(' form
	   pnt = st_bal (pnt)		; skip them
	else				;
	   while ct_aln (*pnt)		; skip symbol
	   || *pnt eq '_'		;
	   || *pnt eq '$'		;
	.. .. ++pnt			;
	st_mov (pnt, pnt+7)		; move it up
	me_mov (" const ", pnt, 7)	; insert keyword
     forever				;
  end
End
If 0
code	ri_bit - bit operator

;	... ` idt ...		(1 << (idt))
;	... ` (exp) ...		(1 << (exp))
;
;	May not move edPdot

  proc	ri_bit
  is	pnt : * char
	par : int = 0			;
	cnt : int			;
     repeat				;
	pnt = ed_rep ("`", "")		;
	quit if <>			; are no more
	pnt = st_skp (pnt)		; skip spaces
					;
	cnt = 7				; assume '(' necessary
	if *pnt eq '('			; already got one
	.. --cnt, ++par			; adjust and remember
					;
	st_mov (pnt, pnt+cnt)		; move it up
	me_mov ("(1 << (", pnt, cnt)	; move in start of it
	pnt = that			;
					;
	if par				; got '('
	   pnt = st_bal (pnt)		; skip them
	else				;
	   while ct_aln (*pnt)		; skip symbol
	   || *pnt eq '_'		;
	   || *pnt eq '$'		;
	.. .. ++pnt			;
	cnt = par ? 1 ?? 2		; ')' or '))'
	st_mov (pnt, pnt+cnt)		; move it up
	me_mov ("))", pnt, cnt)		; end it up
     forever				;
  end
End
