;	count if/while on line
file	ristm - ordinary statements
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include rid:chdef
include rid:medef
include rid:stdef
include rid:fidef
include rid:mxdef

	ri_dec	: (void) void		; declaration
	ri_ini	: (void) void
	ri_lab	: (int) int
	kw_stm	: riTkwd
	kw_ini	: riTkwd

code	kw_nth - nothing keyword

;	spin and nothing
;
;	spin while cnd		while (cnd) {empty};
;	spin until cnd
;	spin if    cnd

  proc	kw_nth
  is	ed_del (" ")			; dump spaces
	if *edPdot eq			; just an empty line
	.. exit ed_app (";")		;
	kw_stm ()			; adds ';' to statment
  end
file	kw_stm - ordinary statements

  proc	kw_stm
  is	pnt : * char
	tmp : * char

; PREPROCESSOR LINES

 	exit if ed_scn ("#")		; ignore preprocessor lines

; DECLARATIONS

	if ed_fnd (" : ")		; a declaration
	.. exit ri_dec ()		; handle it

; 'THAT' COMING
;
;	xxx
;	if that		if (xxx)

	if riVwas 			; got 'that' coming
	   if riVend 			; invalid with end
	   .. im_rep ("W-Invalid [that] with end in (%s)", riAseg)
	   ed_pre ("(")			; put this in (...)
	   ed_app (")")			;
	   tmp = edPbod			; get the body
	   ed_set (riPnxt->Atxt,riPnxt->Pbod) ; setup next
	   ed_rep ("that", tmp)		; and replace it
	   ed_set (riPcur->Atxt, tmp)	; get back this one
	   *tmp = 0			; take out the body (handle is)
	.. exit				; comes back again

; Good question???

	ed_del (" ")			; dump spaces
	exit if *edPdot eq		; blank line
	exit if (riVcnd | riVcon) ;???	; got condition coming

; stm UNTIL cnd
;
;	stm until cnd	for(;;) { stm; if (cnd) break; }
;
; ???	stm until that	for(;;) { if (that:cnd) break; }

	if (pnt = ed_rep ("until",	; stm until cnd
		   "; if (")) ne	;          stm; if (cnd
	   ed_pre ("for(;;) {")		; for(;;) {
	   ed_app (") break;}")		;			) break;}
	.. exit				;
					;
; stm WHILE cnd
; stm IF cnd
;
;	stm if cnd	if (cnd) { stm; }
;	stm while cnd	while (cnd) { stm; }

	if (pnt = ed_fnd ("if")) ne 	; got an if
	|| (pnt = ed_fnd ("while")) ne	; look for a while
	else				; neither
	.. exit ed_app (";")		; statement needs a semicolon

	ed_app (") {")			; if ...) { ... 

	me_mov (edPdot, st_end (edPdot), pnt-edPdot) ; move up the rest
	*(char*)that = 0		; terminate it
	st_mov (pnt, edPdot)		; move it all down
	ed_app (";}")			; terminate statement & block
					;
	if ed_del (" while")		; xxx while cnd
	   ed_pre ("while (")		;
	.. exit				;

; IF
;
;	stm1 if cnd		if (cnd) { stm1 } else
;	stm2 otherwise		{ stm2 }

	if not ed_del (" if")		; take if off
	   im_rep ("E-Invalid embedded if statement (%s)", riAseg)
	.. exit				;

	ed_pre ("if (")				; shove in the if
	tmp = edPbod				; get the body
	ed_set (riPnxt->Atxt,riPnxt->Pbod)	; setup next
	pnt = ed_fnd ("otherwise")		; look for "otherwise"
	ed_set (riPcur->Atxt, tmp)		; back home
	exit if pnt eq <>			; no such beast
	*pnt = 0				; remove the otherwise
	ed_app (" else {")			; add an else to this lot
	ri_put ()				; put it out
	++riVsup				; already out
	++riVnst				; up nest
	++riPnxt->Vend				; up next lines end count
  end
code	ri_dec - declaration

;	External declaration
;
;	nam : typ = {}
;
;	nam : typ is \...\ end
;	nam : typ\ is ...\ ...\ end

  proc	ri_dec
  is	bod : Int = 0			; has body
					;
	++bod if ed_rep(" is","=") ne <>; has a body
	ri_typ (edPdot, edPdot)		; translate the type
	exit ed_app (";") if not bod	; no body
	ri_ini ()			; get initializers
  end

code	kw_ini - init keyword

;	  init	x : t is ...		ri_dec
;	  init	x : t			t x = {0};
;	  init	x : t			t x = {
;	  is	...			   ...	
;	      lab:  vals
;	  end				};

  proc	kw_ini
  is	if ed_fnd (" is") ne <>		; init ... is ...	
	.. exit ri_dec ()		; treat as ordinary declaration
					;
	ri_typ (edPdot, edPdot)		; translate the type
	if riPnxt->Vis eq		; no is on next line
	   ed_app (" = {0};")		; define it simply
	.. exit				; done
	ed_app (" = ")			; start the initializer
	--riPnxt->Vis			; ri_ini handles nesting
	ri_ini ()			; get initializers
  end

code	ri_ini - handle initializers

  proc	ri_ini
  is	lab : int = 0			; label number
	ed_app (" {")			; start it
	ri_put ()			; write it
	++riVnst			; nest in

;	get initializers, add commas
;	add ; after }

	++riVini			; doing initializer
	repeat				;
	   if not ri_get ()		; eof
	      im_rep ("W-EOF in initializer (%s)", riAseg)
	   .. quit			;

	   if riVend			; got dots
	   .. quit --riPcur->Vend	; we handle nesting below
	   if ed_del (" end")		; got an end?
	   .. quit 			; yes 
	   lab = ri_lab (lab)		; pickup labels
	   if ed_mor ()			; got something
	   && *ed_lst () ne ','		; and no comma at end
	   .. ed_app (",")		; add one comma
	   ri_put ()			; write it out
	forever				;
	--riVini			; out of initializer
	ed_app ("};")			; terminate it	   
	ri_put ()			; put it
	--riVnst			; down the nest
	++riVsup			; already put
  end	

code	ri_lab - handle init labels

;	   lab:	  val, val, ...
;	   lab::  val, val, ...		{ val, val, ... },

  func	ri_lab
	lab : int
	()  : int			; result label
  is	idt : [64] char
	ptr : * char			; to count comma's
	inc : int = 1			; label increment
	reply lab if !ed_mor ()		; strip spaces, check blank line
	if *ut_idt (edPdot, <>) eq ':'	; got a label
	   ed_sub (":", " ", idt)	; grab the label
	   ed_mor ()			; dump following spaces
	.. ri_fmt ("#define %s %d", idt, &lab)
	if *edPdot eq ':'		; got label:: ...
	   *edPdot++ = '{'		; replace it
	.. ++lab, inc = 0		; exactly one label
	ed_mor ()			; strip leading spaces
	ptr = edPdot			; count comma's
	lab += inc if *ptr ne 		; got at least one
	while *ptr ne			; got more
	   case *ptr			;
	   of ','			; got another
	      lab += inc if ptr[1] ne	;
	   of '\"'			;
	   or '\''			;
	   or '('			;
	      ptr = st_bal (ptr)	; skip it
	      next			;
	   end case			;
	   ++ptr			;
	end				;
	*ptr++ = '}' if inc eq		; was a group
	*ptr = 0
	reply lab			; send it back
  end
code	kw_mac - assembler

;	macro	...
;	macro
;	[is]
;
;	end macro

  proc	kw_mac
  is	lin : * riTlin = riPnxt
	txt : * char = lin->Atxt

;	if !lin->Vis
;	   ed_pre ("asm ")		;
;	   ri_put ()
;	   ++riVsup			; already put
;	.. exit				; simple
	ri_prt ("asm { ")		; start assembler
	++riVnst			; nest in

;	The next line we want is edPnxt already

	repeat				;
	   ed_set (txt, txt)		;
	   if ed_del (" end macro")	; got an end?
	   .. quit 			; yes 
	   ri_prt (txt)			; put it
	   if not ri_raw ()		; eof
	      im_rep ("W-EOF in macro section (%s)", riAseg)
	   .. quit			;
	forever				;
	ri_prt ("};")			; put it
	--riVnst			; down the nest
	++riVsup			; already put
	ri_get ()			; reprime next line
  end	
code	kw_asc - ascii insert

;	ascii "filespec"

  proc	kw_asc
  is	fil : * FILE
	spc : [mxSPC] char
	lin : [mxLIN+1] char
	buf : [mxLIN*3] char
	src : * char
	dst : * char
	st_fit (edPdot, spc, #spc)
	st_trm (spc)
	*edPdot = 0
	exit if (fil = fi_opn (spc, "r", "")) eq
	while fi_get (fil, lin, mxLIN) ge
	   src = lin
	   dst = st_cop (" \"", buf)
	   while *src
	      *dst++ = '\\' if st_mem (*src, "\\\'\"")
	      *dst++ = *src++
	   end
	   st_cop ("\\n\\r\"", dst)
	   ri_idn (0)
	   ri_dis (buf)
	   ri_new ()
	end
	fi_clo (fil, "")
  end	
end file
code	ri_pif - postfix if/otherwise

  proc	ri_pif 
  is	pnt : * char
	tmp : * char

	ed_pre ("if (")				; shove in the if
	tmp = edPbod				; get the body
	ed_set (riPnxt->Atxt,riPnxt->Pbod)	; setup next
	pnt = ed_fnd ("otherwise")		; look for "otherwise"
	ed_set (riPcur->Atxt, tmp)		; back home
	exit if pnt eq <>			; no such beast
	*pnt = 0				; remove the otherwise
	ed_app (" else {")			; add an else to this lot
	ri_put ()				; put it out
	++riVsup				; already out
	++riVnst				; up nest
	++riPnxt->Vend				; up next line's end count
  end
