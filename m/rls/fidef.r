file	fidef - default file spec
include rid:rider
include rid:chdef
include rid:fidef
include rid:medef
include rid:mxdef
include rid:stdef

;	Handle default filespec
;
;	node:: device: [directory] filename .type ;version
;	device: \directory\directory\ filename .type

data	fiAdef - state table

;	Special treatment for RSX [m,g] specs

  init	fiAdef : [] char
  is	 0 , ':', ':'		; node
	 0 , ':', -1		; device
	'[', ']', -1		; directory
	 0 , '.',  0		; filename
	'.', ';',  0		; filetype
	';',  0,   0		; version
	-1			;
  end

	fi_itm	: (*char, *char) int own
code	fi_def - merge default spec

  func	fi_def
	spc : * char~ 			; file spec
	def : * char			; default spec
	dst : * char			; result spec
	()  : int			; fail => invalid spec
  is	tmp : [mxSPC] char		;
	out : * char~ = tmp		; output pointer
	sta : * char~ = fiAdef		; state table
	lft : int			; spc item length
	rgt : int			; def item length
					;
      repeat				;
	lft = fi_itm (sta, spc)		; parse spec
	rgt = fi_itm (sta, def)		; parse default
	if lft				; found it in spec
	   out = me_cop (spc, out, lft)	; move it in
	else 				; found in default
	.. out = me_cop (def, out, rgt)	; move in default
	*out = 0			; terminate it
	spc += lft			; advance that
	def += rgt			; advance that
	sta += 3			; skip to next set
      until *sta eq -1			; more
	*out = 0			; terminate it
	if (out = st_fnd (":.",tmp)) ne	; got silly result	
	.. out[1] = 0			; device only
					;
	rgt = *spc			; save closing state
	st_cop (tmp, dst)		; return result
					;
	fail if *spc || out eq dst	; invalid filespec
	fine fi_loc (dst, dst)		; fine - convert result
  end
code	fi_itm - get file spec item

  func	fi_itm
	sta : * char~			; state list
	ptr : * char~			; filespec
	()  : int			; item length
  is	str : * char~ = ptr		; string pointer

	fail if str eq NULL		; no string - forget it

;	parse next part
;	check prefix

      repeat
	if *sta++			; need prefix
	.. fail if *(sta-1) ne *str	; wrong prefix

;	Find terminator

	while *str ne *sta		; not at terminator
	   if *str eq 0			; exhausted line
	      if (*sta == '.')		; null matchs dot
              || (*sta == ';')		; null matchs semicolon
	      .. quit			; done
	   .. fail			; else failed
	.. ++str			; next in string

;	Skip or retain terminator

	quit if *++sta eq		; skip terminator
					;
	++str				; retain terminator
	if *sta ne -1			; need double terminator (::)
	   fail if *sta ne *str		; but missed it
	.. ++str			; retain it
      never				;
					;
	reply str-ptr			; return substring length
  end
