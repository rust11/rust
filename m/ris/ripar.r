file	ripar - parse rider files
include rid:rider
include rib:eddef
include rib:ridef
include rid:imdef
include rid:medef
include rid:chdef
include rid:stdef

data	ripar - global data

	riVcod : char = 0		; 0=>data, 1=>code, -1=>formals
	riVcnd : char = 0		; conditional coming
	riVcon : char = 0		; continuation coming
	riVis  : char = 0		; { ... count
	riVbeg : char = 0		; ... { count
	riVend : char = 0		; ... } count
	riVwas : char = 0		; was coming
	riVsup : char = 0		; supress output
	riVinh : char = 0		; inhibit all output (pp_emd)
	riVnst : char = 0		; nesting level
	riVhdr : char = 0		; header level (end header missing)
	riAseg : [64] char = {0}	; program segment (for messages)
	riVini : char = 0		; doing initializers (ri_stm)
	riVfil : int = 0		; seen 'file' statement (ri_cas)

	ri_cod	: (void) void
	ri_ret	: (*char) void
	ri_pst	: (*char) void
	ri_eql	: (*char) void

;?	ri_bal : () * char
data	parse rider code

  type	riTkey 
  is	Pnam : * char			; keyword name
	Pfun : * () void		; keyword procedure
  end					;

	kw_fun : () void		; declare keywords
	kw_pro : () void
	kw_whi : () void
	kw_for : () void		; riloo - called by while in
	kw_rpt : () void		; riloo
	kw_nvr : () void		; riloo
	kw_fvr : () void		; riloo
	kw_unt : () void		; riloo
	kw_cnt : () void		; riloo
	kw_is  : () void
	kw_end : () void
	kw_if  : () void
	kw_els : () void
	kw_elf : () void
	kw_fil : () void
	kw_cod : () void
	kw_dat : () void
	kw_nxt : () void
	kw_qui : () void
	kw_exi : () void
	kw_rep : () void
	kw_fai : () void
	kw_fin : () void		
	kw_typ : () void		; ri...
	kw_uni : () void		; ri...
	kw_nth : () void
	kw_cas : () void		; ricas
	kw_eca : () void		; ricas
	kw_stm : () void		; ristm
	kw_ini : () void		; ristm
	kw_inc : () void
	kw_exe : () void
	kw_stp : () void
	kw_abt : () void
	kw_enu : () void		; rienu
	kw_asc : () void		; ristm

	pp_if  : () void		; ripre
	pp_elf : () void		;
	pp_els : () void		;
	pp_end : () void		;
	pp_pra : () void		;
	pp_hea : () void		;
	pp_ehd : () void		; end header
	pp_mod : () void		; module
	pp_emd : () void		; end module
	kw_mac : () void

  init	riAkey : [] riTkey		; keyword array
  is	"func",		&kw_fun
	"proc",		&kw_pro
	"while",	&kw_whi
	"repeat",	&kw_rpt
	"begin",	&kw_rpt
	"endless",	&kw_nvr		; obsolete
	"never",	&kw_nvr
	"forever",	&kw_fvr
	"until",	&kw_unt
	"count",	&kw_cnt
	"is",		&kw_is 
	"end",		&kw_end
	"if",		&kw_if 
	"else",		&kw_els
	"elif",		&kw_elf
	"file",		&kw_fil
	"code",		&kw_cod
	"data",		&kw_cod
	"next",		&kw_nxt
	"quit",		&kw_qui
	"exit",		&kw_exi
	"reply",	&kw_rep
	"fail",		&kw_fai
	"fine",		&kw_fin
	"type",		&kw_typ
	"unit",		&kw_uni
	"spin",		&kw_nth		; spin => nothing
	"nothing",	&kw_nth		; ristm
	"case",		&kw_cas		; ricas
	"end_case",	&kw_eca		;
	"include",	&kw_inc		; ricvt
	"stop",		&kw_stp		;
	"exeunt",	&kw_stp		; obselete
	"abort",	&kw_abt		; abort
	"init",		&kw_ini		;
	"enum",		&kw_enu		;
	"macro",	&kw_mac
	"ascii",	&kw_asc		; ascii
					;
	"If",		&pp_if		; ripre
	"Elif",		&pp_elf		;
	"Else",		&pp_els		;
	"End",		&pp_end		;
	"pragma",	&pp_pra		;
	"header",	&pp_hea		;
	"module",	&pp_mod		;
	"",		&kw_stm		; default - must be last
	<>,		<>
  end
code	ri_par - top level parse
	
  proc	ri_par 
  is	ed_ini ()			; init editor
	riAseg[0] = 0			; no segment yet
	repeat				; line loop
	   riVsup = 0			; do not suppress output
	   ri_get ()			; get next line
	   quit if fail			; no more lines
	   ri_cod ()			; try code stuff
	   if riVnst eq			; out of function
	   .. riVcod = 0		; done
	forever				;
					;
	if riVnst			; incomplete nesting
	.. im_rep ("W-Program ends nested", <>)
	if riVhdr			; missing 'end header'
	.. im_rep ("W-Missing [end header]", <>)
  end

code	ri_cod - process code keywords

;	Hunt thru keyword list for action routine
;	Default is kw_stm

  proc	ri_cod
  is
#ifdef V2
	lin : * riTlin = riPlin		; current line
	ent : * riTent = lin->Pent	;
	ed_del (" ")			; skip leading space
	if lin->Vflg & riKWD_		; got a keyword
	&& ed_del (ent->Pnam)		; still got it
	   (*ent->Pfun)()		; call the keyword
	else				;
	.. kw_stm ()			;
#else
	key : * riTkey~
	msg : [128] char
	key = riAkey			; keyword pointer
	ed_del (" ")			; skip leading space
	while key->Pnam ne <>		; got more
	   if *key->Pnam eq		; last one
	   .. quit kw_stm ()		; statement
	   if ed_del (key->Pnam) eq	; find and delete keyword
	   .. next ++key		; not found
	   if riVwas			; invalid for command
	      FMT(msg, "(%s) cant be 'that' [%s]", key->Pnam, riAseg)
 	   .. im_rep ("W-%s", msg)
	   quit (*key->Pfun)()		; found it, do it
	end				;
#endif
	exit if riVsup			; output suppressed
	ri_put ()			; write the line out
  end
code	kw_is - is keyword

;	Actually ri_buf intercepts this

  proc	kw_is
  is	++riPcur->Vis			; count it (never gets here)
  end

code	kw_end - end keyword

  proc	kw_end
  is
	if ed_del (" file")		; got end file
	   ++riVsup			; remember it
	   ++riPnxt->Veof 		; and force end of file on next line
	.. exit				; handle that

	exit kw_nvr () if ed_del (" block")	; end block
	exit kw_eca () if ed_del (" case")	; end case
	exit pp_ehd () if ed_del (" header")	; end header
	exit pp_emd () if ed_del (" module")	; end module
	ed_del (" loop")

;	if ed_del (" if")		; delete optionals
;	|| ed_del (" func")		;
;	|| ed_del (" proc")		;
	if riVnst eq			; no block to end
	   im_rep ("W-Too many ends in [%s]", riAseg)
	.. exit				;
	--riVnst			; nest back
	ed_pre ("} ")			; and prefix this
  end

code	kw_cod - code keyword

  proc	kw_cod
  is	++riVfil			; seen it
	ut_seg ("code", <>)		; pickup the segment
	ed_pre ("/* code - ")		; make a comment
	ed_app (" */")			;
  end

code	kw_dat - data keyword

  proc	kw_dat
  is	ut_seg ("data", <>)		; pickup the segment
	ed_pre ("/* data - ")		; make a comment
	ed_app (" */")			;
  end

code	kw_fil - file keyword

  proc	kw_fil
  is	++riVfil			; seen it (for ri_cas)
	ut_seg ("file", <>)		;
	ed_pre ("/* file - ")		; make a comment
	ed_app (" */")			;
  end
code	reply keywords

;	reply val [if cnd]
;	stop val [if cnd]
;	exeunt val [if cnd]

  proc	kw_rep
  is	ri_ret ("return")
  end

  proc	kw_stp				; stop (and obselete exeunt)
  is	ri_ret ("exit")			; C 'exit' image function
  end

code	ri_ret - construct temporary [return (value)] string

  proc	ri_ret
	kwd : * char
  is	tmp : [128] char
	pnt : * Char

	st_mov (kwd, tmp)		; return or exit
	st_app (" (", tmp)		; start value
#ifdef V2
	if riPcur->Vflg & riIIF_	; got embedded if
	&& (pnt = ed_fnd ("if")) ne <>	; check for if
	   me_mov (edPdot, st_end(tmp), pnt-edPdot)
	   *(char*)that = 0		; terminate string
	   st_mov (pnt, edPdot) 	; edPdot -> " if ..."
	else				; no if
	   st_app (edPdot, tmp)		; copy the lot
	.. ed_tru ()			; truncate line
#else
	pnt = ed_fnd ("if")		; check for if
	if that ne NULL			; found if
	   me_mov (edPdot, st_end(tmp), pnt-edPdot)
	   *(char*)that = 0		; terminate string
	   st_mov (pnt, edPdot) 	; move the rest down
	else				; no if
	   st_app (edPdot, tmp)		; copy the lot
	.. ed_tru ()			; truncate line
#endif
	st_app (")", tmp)		; finish up return
	ri_pst (tmp)			; do the rest
  end
code	postfix if keywords

;	next [stm] [if cnd]
;	quit [stm] [if cnd]
;	exit [stm] [if cnd]
;	fail [stm] [if cnd]
;	fine [stm] [if cnd]
;	abort[stm] [if cnd]
;	     [stm] [if cnd] (see kw_stm)
;
;	if cnd { kwd (val) }
;	if cnd { stm; kwd }

  proc	kw_nxt
  is	ri_pst ("continue")
  end

  proc	kw_qui
  is	ri_pst ("break")
  end

  proc	kw_exi
  is	ri_pst ("return")
  end

  proc	kw_fai
  is	ri_pst ("return 0")
  end

  proc	kw_fin
  is	ri_pst ("return 1")
  end

  proc	kw_abt
  is	ed_del (" ")			; dump " ( ) "
	ed_del ("(")			;
	ed_del (" ")			;
	ed_del (")")			;
	ri_pst ("abort ()")
  end

code	ri_pst - postfix ifs

  proc	ri_pst
	stm : * char			; statement
  is	tmp : [128] char		; some space to build it
	pnt : * char			; for the find

	if ed_del (" if") 		; got: stm if cnd
	   st_mov (stm, tmp)		; make a copy
	   st_app (";", tmp)		; add semicolon
	   ri_cnd ("if", tmp)		;
	.. exit				;

	pnt = ed_fnd ("if")		; check for if
	if null				; no if coming
	   if *edPdot ne		; got embedded
	   .. ed_app (";")		; terminate embedded
	   ed_app (stm)  		; append keyword statement
	   ed_app (";")			; and terminate that
	.. exit				;

;	got: stm exp if cnd
;
;	tmp: { exp; stm; } 

	*tmp = '{'			; start the block
	me_mov (edPdot, tmp+1, pnt-edPdot); move out the statement
	*(char*)that = 0		; terminate the statement
	st_mov (pnt, edPdot)		; move the "if ..." down
	ed_del (" if")			; delete the "if"
	st_app ("; ", tmp)		; terminate statement
	st_app (stm, tmp)		; add keyword
	st_app (";}", tmp)		; finish the block

	ri_cnd ("if", tmp)		; now handle the conditional
  end
code	conditional keywords

code	kw_whi - while keyword

  proc	kw_whi
  is	if ed_fnd (" in ")		; long form
	|| ed_fnd (" down ")		;
	   kw_for ()			; use that
	else				;
	.. ri_cnd ("while ", <>)	; simple
  end

code	kw_elf - elif keyword

  proc	kw_elf
  is	--riVnst			; reduce nest first
	ri_cnd ("} else if ", <>)	; this increases it again
  end

code	kw_if - if keyword

  proc	kw_if
  is	ri_cnd ("if ", <>)
  end

code	kw_els - else keyword

  proc	kw_els
  is	if *edPdot			; got more coming
	.. ed_app (";")			; assume a statement
	ed_pre ("} else {")		;
  end
code	ri_cnd - conditional statements

;	Handles all multiline conditionals (if, while...)
;
;	if cnd			if cnd
;	&& cnd			!& cnd
;	&& cnd			!& cnd
;	.. stm			.. stm
;
;	if ((c) && (c))		if (!((c) && (c)))
;
;	ri_ipt skips leading connectives 

  proc	ri_cnd
	str : * Char			; "if", "while", etc
	stm : * Char			; "stm" or <>
					; edPdot -> conditional code
  is	cnd : int = riVcnd		; ||, && etc on next line
	ri_eql (edPdot)			; warn a = b
					;
	ed_pre ("(")			;       (...
	ed_app (")")			;	(...)
	if cnd eq 			; one-line
	   ed_pre (str)			; while (...
	else				; multiline
	   ed_pre ("(!(") if cnd lt	;       (!((...)
	   ed_pre ("(")   otherwise	;       ( (...)
	   ed_pre (str)			; while (*(...)
	   repeat			; handle continuation lines
	      ri_put ()			; dump it
	      ri_get ()			; get the next
	      if fail			; yuk
		 im_rep ("E-End of file in conditional [%s]", riAseg)
	      .. exit ++riVsup		; forget this line
	      ri_eql (edPdot)		; check condition
	      ed_pre ("(")		; && (
	      ed_app (")")		;	    ... )
	      quit if riVcnd eq		; that was the last
	      if cnd ne riVcnd		; changed from && to !& etc
	      .. im_rep ("W-Mixed conditional negation [%s]", riAseg)
	   forever			;
	      ed_app ("))") if cnd lt	;
	      ed_app (")") otherwise	;
 	end				;
	ed_app (stm) if stm ne <>	; append it
	ri_beg ()    otherwise		; start nest with {
  end
code	ri_eql - check risky conditions

;	if x = 0	probably wants (x eq 0)
;	(...)		check matching (), "", ''

  proc	ri_eql
	cnd : * char			; condition string
  is	str : * Char = cnd		; copy of condition
	msg : [128] char		;
#ifdef V2
	exit if (riPcur & riASN_) eq	; none on line anyway
#endif
	while *str			; got more string
	   if st_scn (" = ", str)	; plain eq
	      FMT(msg, "Risky conditional [%s] in [%s]", cnd, riAseg)
	      im_rep ("W-%s", msg)
	   .. exit

	   if *str eq _paren		; skip (...)
	   || *str eq _quotes		; skip "..."
	   || *str eq _apost		; skip '...'
	       str = st_bal (str)	; skip it
	   else				;
	   .. ++str			; skip character
	end
  end
