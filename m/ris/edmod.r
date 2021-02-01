file	edmod - editing functions
include rid:rider
include rib:eddef
include rid:chdef
include rid:ctdef
include rid:medef
include rid:stdef

;	ed_ini		setup
;	ed_set		define current line
;	ed_scn		scan leading substring
;	ed_skp		skip over leading substring - reset body
;	ed_rem		remove leading substring
;	ed_eli		elide all to pointer
;	ed_pre		prepend just before body
;	ed_app		append at end of line
;
;	ed_fnd		find substring
;	ed_rep		replace substring
;
;	ed_del		delete string
;	ed_exc		exchange string 

	ed_lst : () * char

	edPlin : * char = <>		; start of line
	edPbod : * char = <>		; body - past prefix 
	edPdot : * char = <>		; working position

code	ed_ini - init editor

  func	ed_ini
	()  : int
  is	fine				; no function
  end

code	ed_set - setup editor pointers

  proc	ed_set
	lin : * char			; line plex
	bod : * char			; body pointer
  is	edPlin = lin			; line pointer
	edPbod = bod			; body pointer
	edPdot = bod			; dot pointer
  end
code	ed_del - delete string if found

;	" ..."		skip leading spaces
;	" A.."		alphanumeric strings must terminate

  func	ed_del
	str : * char			; string to delete
	()  : int			; fine/fail
  is	pnt : * char~			; a pointer
	pnt = ed_scn (str)		; attempt to scan it
	fail if null			; not found
	st_mov (pnt, edPdot)		; copy the rest down
	fine				;
  end
 
code	ed_eli - elide to this point

  func	ed_eli
	pnt : * char
  is	st_mov (pnt, edPdot)
  end

code	ed_chg - change leading substring

  func	ed_chg
	str : * char			; target string
	rep : * char			; replacement string
  is	dot : * char~			; pointer
	fail if not ed_del (str)	; string not found
	dot = edPdot			; save dot
	ed_pre (rep)			; put in replacement string
	edPdot = dot			; restore dot
	fine				; great
  end
 
code	ed_skp - skip string if found

;	" ..."		skip leading spaces
;	" A.."		alphanumeric strings must terminate

  func	ed_skp
	str : * char			; string to skip
	()  : int			; fine/fail
  is	pnt : * char~			; a pointer
	pnt = ed_scn (str)		; attempt to scan it
	fail if null			; not found
	edPbod = pnt			; reset body
	edPdot = pnt			; retain it
	fine				; it worked
  end

code	ed_scn - scan leading substring

  func	ed_scn
	str : * char~			; target string
	()  : * char			; past it, or NULL
  is	dot : * char~ = edPdot		; current char

	if *str eq _space		; leading whitespace
	   str++			; skip pattern
	.. dot = st_skp (dot)		; skip whitespace in line

	dot = st_scn (str, dot)		; find substring
	pass <>				; not found
	if ct_aln (*str)		; starts with alpha
	&& ct_aln (*dot)		; and not done
	.. reply <>			; reply null
	reply dot			; found it
  end
code	ed_sub - substring locate/remove, copy prefix

;	ed_sub ("=", " x = y", dst)	dst = "x"

  func	ed_sub
	mod : * char			; model
	rep : * char			; replacement (<> to retain)
	dst : * char			; substring
	()  : * char			; <> or end of dst
  is	pnt : * char~			;
	ed_del (" ")			; drop leading spaces
	pnt = ed_rep (mod, rep)		; handle replacement
	pass <>				; not found
	me_mov (edPdot, dst, pnt-edPdot); copy the string back
	*<*char>that=0			; terminate the string
	st_mov (pnt, edPdot)		; and wipe it out
	st_trm (dst)			; trim trailing spaces
	reply that			; point at end of dst
  end

code	ed_rst - copy/delete rest of line

  func	ed_rst
	dst : * char
	()  : * char			;
  is	ed_del (" ")			; dump leading spaces
	st_mov (edPdot, dst)		; move it
	ed_tru ()			; dump the line
	st_trm (dst)			; trim trailing spaces
	reply that			; return past it
  end

code	ed_rep - replace string if found

  func	ed_rep
	mod : * char			; model string
	rep : * char			; replacement string
	()  : * char			; past replacement or NULL
  is	pnt : * char~			; pointer
	pnt = ed_fnd (mod)		; locate the model
	pass <>				; not found
	reply pnt if rep eq <>		; just want to find it
	ed_exc (rep, pnt, st_len (mod))	; replace it
	reply that			; return past replacement
  end

code	ed_fnd - find substring
	
;	String must follow ascii rules

  func	ed_fnd
	str : * char			; model string
  	()  : * char			; pointer or NULL
  is	reply ed_loc (str, edPdot)	; look for it
  end

code	ed_exc - exchange substring

  func	ed_exc
	rep : * char~			; replacement string
	dst : * char~			; destination exchange pointer
	old : int			; exchange size
	()  : * char			;
  is	new : int~ = st_len (rep)	; get replacement size
	dif : int = old - new		; get difference

;	" not ", " ! "
;	more or same

	if dif ge			; it will fit
	   dst = me_mov (rep, dst, new)	; overwrite it
	   if dif			; not exact
	   .. st_mov (dst+dif, dst)	; copy rest down
	.. reply dst			; past it

;	less

	st_mov (dst, dst-dif)		; move up (dif is negative)
	me_mov (rep, dst, new)		; move in the remainder
	reply dst+new			; result
  end

code	ed_tru - truncate line 

  proc	ed_tru
  is	*edPdot = 0			; truncate the line
  end
code	ed_pre - prepend substring 

;	dot moves, body stays
;	separate alpha's with a space
;
;	line start moved past prepended string

  func	ed_pre
	str : * char~			; prepend string
	()  : * char			; past prepended
  is	len : int~ = st_len (str)	; get string length
	if ed_gap (str, edPbod)		; need separator
	.. ed_pre (" ")			; force a space (update edPdot)
	st_mov (edPbod, edPbod+len)	; move up string
	me_mov (str, edPbod, len)	; move in new string
	reply edPdot += len		; return pointer past preface
  end

code	ed_app - append substring

;	Dot not moved

  func	ed_app
	str : * char~			; string to append
	()  : * char			;
  is	if ed_gap (edPdot, str)		; need separator
	.. ed_app (" ")			; force a space
	reply st_app (str, edPdot)	; append them
  end

code	ed_gap - check alpha gap

  func	ed_gap
	src : * char			; source string
	dst : * char			; destination string
  is	reply ct_aln (*st_lst (src)) && ct_aln(*dst)
  end

code	ed_mor - skip spaces and check more on line

  func	ed_mor
	()  : int
  is	ed_del (" ")			; skip any following
	reply *edPdot			; more coming
  end

code	ed_lst - look at last character

  func	ed_lst
	()  : * char			; at last character
  is	reply st_lst (edPdot)		; simplice
  end
