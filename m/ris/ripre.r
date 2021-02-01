file	ripre - preprocessor functions
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include	rid:iodef	; module
include rid:stdef

code	pp_if - preprocessor conditional

  proc	pp_if
  is	ed_del (" ")
	if ed_del ("!&")
	   ed_pre ("#ifndef ")
	elif ed_del ("&")
	   ed_pre ("#ifdef ")
	else
	.. ed_pre ("#if ")
	++riVpre
  end

code	pp_elf - preprocessor elif

  proc	pp_elf
  is	ed_pre ("#elif ")
  end

code	pp_els - preprocessor else

  proc	pp_els
  is	ed_pre ("#else ")
  end

code	pp_end - preprocessor end

  proc	pp_end
  is	ed_pre ("#endif ")
	--riVpre
  end

code	pp_pra - pragma

  proc	pp_pra
  is	ed_pre ("#pragma ")		; insert it
  end

code	pp_rep - report

  proc	pp_rep
  is	ed_pre	("#error ")		; error
  end

code	pp_hea - preprocessor header

;	header ridef
;
;	#ifndef _HEADER_ridef
;	#define _HEADER_ridef 1

  proc	pp_hea
  is	nam : [64] char			; the name of it
	idt : [64] char
	ed_del (" ")			; cleanup
	ut_idt (edPdot, idt)		; get identifier
	if idt[0] eq			;
	   im_rep ("E-Header name missing [%s]", riAseg)
	.. exit				;
	ut_seg ("header", <>)		; setup segment name
	ed_rst (nam)			; save it all
	ri_fmt ("/* header %s */", nam)	; say so
	ri_fmt ("#ifndef _RIDER_H_%s", idt)
	ri_fmt ("#define _RIDER_H_%s 1", idt)
	if riVhdr 			; nested header
	.. im_rep ("W-Nested header [%s]", riAseg)
	++riVhdr			; remember it
  end

code	pp_ehd - end header

  proc	pp_ehd
  is	if riVhdr eq			; was no start of header
	   im_rep ("E-End header outside header [%s]", riAseg)
	else				;
	.. --riVhdr			; down with it
	ri_fmt ("#endif")		; end header
  end
code	pp_fix - fixup conditional variable

;		true if:
;	&nam	name is defined
;	!&nam	name is not defined
;	*nam	name value is not zero
;	*&nam	name is defined and its value
;	!nam	name is not defined, or has zero value
;
;	cnd  ?= val If ...		Experimental - RIDOS.H
;
;	cnd  ?=  &nam	||  &nam  ...	
;		 *nam	&&  *...  ...
;		*&nam	   *&nam
;
;	#undef cnd, #define cnd 0
;	#ifdef exp			; &nam
;	#if exp				; *nam or nam
;	#undef cnd, #define cnd 1
;	#endif
;	#endif
;	#if !(cnd)			; ||
;	...
;	#endif

	ppBEG	:= 0
	ppOR	:= 1
	ppAND	:= 2
	ppEND	:= 3

  proc	pp_fix
  is	cnd : [64] char			; condition name
	exp : [64] char			; expression
	rep : [64] char			; replacement value
	tst : int = 0			; test 
	def : int = 0			; need (defined) check
	val : int = 0			; need value
	opr : int			; operator
	nxt : int = ppBEG		; next operator
     repeat				;
	case (opr = nxt)		; do next state
	of ppBEG			; first
	   ed_del (" ")			; strip spaces
	   ed_sub (" ?= ", "", cnd)	; get the condition name
	   quit if fail			; oops
	   ed_sub (" If ", "", rep)	; get value
	   tst = that ne <>		;
	of ppOR				; ... || ...
	   ri_fmt ("#if !(%s)", cnd)	; not handled yet
	of ppAND			; ... && ...
	   ri_fmt ("#if (%s)", cnd)	;
	of ppEND			;
	   exit				;
	end case			;

;	Get qualifiers

	ed_del (" ")			; dump spaces
	val = def = 0			; reset these
	++val if ed_del ("*")		; want value
	++def if ed_del ("&")		; want defined
	--def if ed_del ("!&")		; want not defined
	++val if !def ;otherwise	; force value if not define test

;	Extract expression, check next state

	if ed_sub (" || ", "", exp)	; got more
	   nxt = ppOR			;
	elif ed_sub (" && ", "", exp)	; got &&
	   nxt = ppAND			;
	else 				;
	   nxt = ppEND			;
	   ed_rst (exp)			;
	.. quit if exp[0] eq		; oops
					;
	if !tst && opr ne ppAND		; not known to be zero
	   ri_fmt ("#undef %s", cnd)	; undefine it
	.. ri_fmt ("#define %s 0", cnd)	; assume off
					;
	ri_fmt ("#ifndef %s",exp) if def lt ; check defined
	ri_fmt ("#ifdef %s",exp) if def	gt  ; check defined
	ri_fmt ("#if (%s)", exp) if val	; check value
	if !tst				; not test 
	   ri_fmt ("#undef %s", cnd)	;
	   ri_fmt ("#define %s 1", cnd)	;
	else
;	   ri_fmt ("#undef %s", cnd)	;
	   st_rep (" (", "(", cnd)	; BIT (n) ?= (...)
	.. ri_fmt ("#define %s %s", cnd, rep)
	ri_fmt ("#endif") if def	;
	ri_fmt ("#endif") if val	;
	case opr			; handle post-processing
	of ppOR				;
	or ppAND			;
	   ri_fmt ("#endif")		;
	end case			;
     forever				;
	im_rep ("W-Invalid conditional fixup in [%s]", riAseg)
  end
code	pp_mod - output module

;	Create a new output module
;
;	module "filespec"

  proc	pp_mod
  is	buf : [64] char			; the filespec
	lst : * char			; last in line
	ed_del (" \"")			; delete leading (")
	ed_rst (buf)			; get the filespec
	lst = st_lst (buf)		;
	*lst = 0 if *lst eq '\"'	; delete trailing (")
					;
	++riVsup			; suppress this line
	riVinh = 0			; turn off inhibitions
	if buf[0] eq			; got no filename
	   im_rep ("E-No module filespec [%s]", riAseg)
	.. exit				;

	io_clo (ioCout)			; close current
	io_opn (ioCout, buf, "noname.c", "w")
	exit if fine			; no problems
	io_opn (ioCout, riPsop, "noname.c", "w")
	im_rep ("E-Error creating module [%s]", buf)
  end

code	pp_emd - end module

;	Close current module
;	Inhibit further output

  proc	pp_emd
  is	io_clo (ioCout)		; close current
	++riVinh		; inhibit all output
  end
