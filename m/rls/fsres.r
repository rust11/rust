;???;	FIRES is in a bad way
;???;	FIMOD also has a fi_res function and its different
;???;	CTS: uses only this module (not FSMOD)
file	fsres - form resultant file spec
include rid:rider
include rid:fsdef
include rid:mxdef
include rid:stdef

;	fi_res (mod, spc, res)
;
;	def	optional file path, applied to result
;	fil	derived file name and type - no wildcards
;	mod	wildcard model
;	res	output string
;
;	o There are no errors -- this is a replacement process,
;	  not a wildcard pattern matcher.
;	o The rules must be simple to remember and decode.

	ut_app : (*char, *char, *char, int, int) *char-
	ut_ovr : (*char) int-

  func	fs_res
	mod : * char~
	spc : * char
	res : * char~
  is
	res = ut_app (mod, spc, res, fsDEV_, 4)
	res = ut_app (mod, spc, res, fsDIR_, 16)
	res = ut_app (mod, spc, res, fsNAM_, 6)
	res = ut_app (mod, spc, res, fsTYP_, 4)
  end

code	ut_app - apply 

;	insert:		if the next wildcard is '*'
;	overstrike:	if the next wildcard is '%'
;
;	xyz	c*d	cxyzd
;	xyz	c%*d	cyd
;	xyz	*%%
;
;	Axyz
;	xyzA

PUTSS(s1,s2) := printf("s1=[%s] s2=[%s]\n", s1, s2)

  func	ut_app
	mod : * char~
	spc : * char~
	res : * char~
	msk : int
	lim : int
	()  : * char			; past res
  is	rgt : [mxNAM] char		; temp buffers
	lft : [mxNAM] char		;
	rem : int

PUTSS(mod,spc)
	fs_ext (mod, lft, msk)		; extract fields
	fs_ext (spc, rgt, msk)		;
	mod = lft			; use pointers
	spc = rgt			; and our buffers

PUTSS(lft,rgt)
	if !st_int (mod, "*%", <>)	; standard logic
	   mod = spc if !*mod		;
	   st_cop (mod, res)		;
	.. reply st_end (res)		;
	if *spc eq '.'			; always special
	.. *res++ = *spc++, --lim	;
	++mod if *mod eq '.'		;

      while *mod && lim			; copy loop
	case *mod++			;
	of '%'
	   *res++ = *spc++,--lim if *spc;
	of '*'				;
	   rem = lim - st_len (mod)	;
	   while *spc && rem--		;
	   .. *res++ = *spc++, --lim	;
	of other
	   if *mod eq *spc		; matching non-control
	      *res++ = *spc++		;
	   .. next ++mod, --lim		;
	   *res++ = mod[-1], --lim	;
	   ++spc if *spc && ut_ovr (mod);
	end case
      end

	*res = 0
	reply st_end (res)
  end

code	ut_ovr - overstrike check

  func	ut_ovr
	str : * char~
  is	while *str
	   fail if *str++ eq '*'
	end
	fine
  end
end	file
;	   source	  destination
;	src	mod	res
;	x	*	x
;	x	y	y
;	abcdef	xy????	xycdef
;	abcd	xy????	xycd??	missmatch
;	abcdef	xy*	xycdef
;	abcdef	xy**mn	xycdmn
;	abcdef	???xy?	abcxyf
;	abcdef	*xy	abcdxy
;	abcdef	?xy*	axydef
;	abcdef	*xy*	error
;	abc	*?xy	abcxy
;		m*?xy	
;	abc	*xy*	xyabc
;		xy****
;
;	abcd	x*	xabcd
;	abcd	x*???	xbcd
;	abcd	x?*	xbcd
;
;	Only one '*' may appear in a field.
;		copy forward
;	'*'	get remaining length in src	
		subtract remaining length in mod
;		copy from src
;
;
;	-	*	*
;	-	-	-
