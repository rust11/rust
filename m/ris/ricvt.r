file	ricvt - convert things
include rid:rider
include rid:fidef
include rid:chdef
include rid:stdef
;nclude rid:lndef
include rib:eddef
include rib:ridef

	cv_dos	: (void) void own
	cv_unx	: (void) void own
	cv_trn	: (*char) int own

data	kw_inc - include

  init	cvAstd : [] * char
  is	"dos"
	"setjmp"
	"assert"
	"errno"
	"float"
	"limits"
	"locale"
	"math"
	"signal"
	"stdarg"
	"stddef"
	"stdio"
	"stdlib"
	"string"
	"time"
	<>
  end

code	kw_inc - include

;	stdio		<stdio.h>	Fixup for VAX
;	<...>		<...>
;	"..."		"..."
;	ffccc.t		"ffccc.t"
;	ffccc		"ffccc.h"
;	(...)		...		VAX text library

  proc	kw_inc
  is	dot : * char~
	std : ** char~ = cvAstd
	ed_del (" ")			; drop leading whitespace
	dot = edPdot			;
	while *std ne			;
	   next if !st_sam (*std++, dot); not a standard header
	   st_ins ("<", dot)		;
	   st_app (".h>", dot)		;
	   quit				;
	end				;
					;
;	st_rep ("rll:", "rid:", dot)	; temporary ???
;	st_rep ("lib:", "rid:", dot)	; temporary ???
					;
	if *dot ne '\"' && *dot ne '<'	;
	&& *dot ne '('			;
	   if !st_fnd (".", edPdot)	; no type
	   .. st_app (".h", dot)	; add type
	   st_ins ("\"", dot)		; add quotes
	.. st_app ("\"", dot)		;
					;
	st_rep ("(", "", dot)		; remove parentheses
	st_rep (")", "", dot)		;
					;
	if quFdos ne			; need dos
	   cv_dos ()			; do the dos stuff
	elif quFunx ne			; need unix
	.. cv_unx ()			;
	ed_pre ("#include ")		; put back directive
  end
code	cv_dos - convert to DOS name

;	"dev:file.typ"	=> "\dev\file.typ"
;	Look for environment name

  proc cv_dos
  is	exit if !ed_del ("\"")		; not quoted
	exit if !ed_rep ("\"", "")	; remove the trailing quote
	fi_loc (edPdot, edPdot)		; translate the name
;	if !cv_trn (edPdot)		; has system translation
;	&& ed_rep (":", "\\")		; has device name
;	.. ed_pre ("c:\\")		; put in directory prefix
	ed_pre ("\"")			; put back quote
	ed_app ("\"")			;
  end

code	cv_unx - convert to UNIX name

  proc	cv_unx
  is	exit if not ed_del ("\"")	; not quoted
	if ed_rep (":", "/")		; has device name
	.. ed_pre ("/")			; put in directory prefix
	ed_pre ("\"")			; put back quote
  end
end file
code	cv_trn -- translate logical name

;	nam:aaaaaaa := e:\aaa\

  func	cv_trn
	spc : * char
	()  : int
  is	tmp : [128] char
	equ : [128] char
	trm : * char
	st_cop (spc, tmp)		; get a copy
	lst = st_lst (tmp)		;
	trm = *lst			; save it
	*lst = 0 if trm eq '"'		;
	fi_trn (tmp, equ)		; translate the filename

PUT("tmp=[%s]\n", tmp)
	trm = st_fnd (":", tmp)		; find the colon
	fail if null			;
	*trm++ = 0			; drop it
PUT("trm=[%s]\n", trm)
	st_upr (tmp)			; make upper case
	ln_trn (tmp, equ, 0)		; translate it
	pass fail			; nothing found
PUT("trn=[%s]\n", tmp)
	fail if st_len (trm) + st_len (equ) gt 126
	st_cop (equ, spc)		; replace it
	if *st_lst (spc) ne '\\'	; missing last one
	.. st_app ("\\", spc)		; add one
	st_app (trm, spc)		;
PUT("spc=[%s]\n", spc)
PUT("trm=[%s]\n", trm)
PUT("app=[%s]\n", spc)
	fine
  end
end file
code	cv_trn -- translate logical name

;	nam:aaaaaaa := e:\aaa\

  func	cv_trn
	spc : * char
	()  : int
  is	tmp : [128] char
	equ : [128] char
	trm : * char
	st_cop (spc, tmp)		; get a copy
PUT("tmp=[%s]\n", tmp)
	trm = st_fnd (":", tmp)		; find the colon
	fail if null			;
	*trm++ = 0			; drop it
PUT("trm=[%s]\n", trm)
	st_upr (tmp)			; make upper case
	ln_trn (tmp, equ, 0)		; translate it
	pass fail			; nothing found
PUT("trn=[%s]\n", tmp)
	fail if st_len (trm) + st_len (equ) gt 126
	st_cop (equ, spc)		; replace it
	if *st_lst (spc) ne '\\'	; missing last one
	.. st_app ("\\", spc)		; add one
	st_app (trm, spc)		;
PUT("spc=[%s]\n", spc)
PUT("trm=[%s]\n", trm)
PUT("app=[%s]\n", spc)
	fine
  end
end file
code	cv_trn -- translate logical name

;	nam:aaaaaaa := e:\aaa\

  func	cv_trn
	spc : * char
	()  : int
  is	tmp : [128] char
	trm : * char
	rep : * char
	st_cop (spc, tmp)		; get a copy
	trm = st_fnd (":", tmp)		; find the colon
	fail if null			;
	*trm++ = 0			; drop it
	st_upr (tmp)			; make upper case
	rep = getenv (tmp)		; get a replacement string
	fail if null			; ain't none
	fail if st_len (trm) + st_len (rep) gt 126
	st_cop (rep, spc)		; replace it
	if *st_lst (spc) ne '\\'	; missing last one
	.. st_app ("\\", spc)		; add one
	st_app (trm, spc)		;
	fine
  end
