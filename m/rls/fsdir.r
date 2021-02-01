file	fsdir - normalise and format directory spec
include	rid:rider
include	rid:fidef
include	rid:fsdef
include rid:stdef

;	fs_dir (dir, dst, mod)
;
;	\one\two\ => \one\two
;	[0,0.one.two] => \001002\one\two
;
;	Used by MD and RD

  func	fs_dir
	src : * char
	spc : * char~
	()  : int		; length of result field
  is	prv : * char
	lst : * char

	lst = st_lst (spc)
	*lst = 0 if *lst eq '\\'
	if *lst eq ']'
	   while --lst ge spc
	      if (*lst eq '.') || (*lst eq '[')
	      .. quit *lst = '\\'
	      next if lst ne spc
	      fail im_rep ("E-Invalid directory specification %s", dis)
	   end
	end
  end
end file
code	fs_rsx - normalise RSX directory spec

; ???	handle wildcards

;	[*]	???
;	[*2]	??2
;	[*2*]	?2?
;
;	[*23] 	?23
;	[1*]	1??
;	[1*3]	1*3
;	
;	[0,0.abc] => [001002.abc]
;	[,2]
;	[0,.]
;	[]	elided

;	[*,1*]

	lo_par : (*char, *char, *int)-

  init	laAspc : ",01234567*?%"-

  func	fs_rsx
	src : * char
	dst : * char
	mod : int
  is	res : [mxSPC] char
	bck : * char = <>
	bra : int = 0
	act : int = 0
	cha : int
	lft : [4] char
	rgt : [4] char
	scn : int = 1

	st_cop (src, dst)
	src = st_fnd ("[", src)		; got "["?
	fine if fail			; nope, quit
	fail if !st_fnd ("]", src)	; invalid
	dst += (++src - src)		; position just past it

      repeat
	cha = *res++ = *src++		; get/copy next
	quit if !cha			; we don't report errors
	if cha eq ']'			; end of directory
	   ++src if *src eq '\\'	; ...[...]\...
	.. quit				;
					;
	next scn=1 if cha eq '.'	; scan new element
	next if !scn			; not scanning
	scn = 0				; not scanning next time
	next if !st_mem (cha, laAspc)

	src = lo_par (--src, lft)	; parse octal number
	next if *src ne ','		;
	src = lo_par (--src, rgt)	; parse octal number
	dst = st_cop (lft, dst)
	dst = st_cop (rgt, dst)
      forever
	reply len
  end

  func	lo_par
	src : * char
	fld : * char
  is	buf : [8] char
	res : * char = buf + 3
	wld : int = 0
	*len = 0
	st_cop ("000000", buf)
	while st_mem (*src, "01234567?%*")
	   fail if ++*len ge 3
	   wld += st_mem (*src, "?%*")
	   *res++ = *src++
	end
	*res = 0
	fil = "?"
	me_cop (buf+len, fld, 3)
	fld[3] = 0
	reply len
  end
