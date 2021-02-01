file	hlmod - help support
include rid:rider
include	rid:cldef
include	rid:medef
include	rid:stdef
include	rid:fidef
include	rid:imdef
include	rid:mxdef
include	rid:hldef

	hl_beg : (*hlThlp)
	hl_end : (*hlThlp)
	hl_rgt : (*hlThlp)
	hl_lft : (*hlThlp)
	hl_idt : (*hlThlp)
	hl_prt : (*hlThlp, *char)
	hl_fmt : (*hlThlp, *char, *char)
	hl_wri : (*hlThlp, *char)
	hl_new : (*hlThlp)

	hl_rew : (*hlThlp)
	hl_nxt : (*hlThlp) *char
	hl_prv : (*hlThlp) int
	hl_fnd : (*hlThlp, *char) int
	hl_loc : (*hlThlp, *char) int
	hl_top : (*hlThlp) int
	hl_def : (*hlThlp, *char) int
	hl_cmd : (*hlThlp, *char) int
code	hl_cmd - help command

  func	hl_cmd
	hlp : * hlThlp
	top : * char
  is	cmd : [mxLIN] char
	hl_hlp (hlp, top)
	fine if *top
	repeat
	   cl_cmd ("Topic? ", cmd)
	   quit if !cmd[0]
	   hl_hlp (hlp, cmd)
	forever
  end

code	hl_hlp - provide help

  func	hl_hlp
	hlp : * hlThlp
	str : * char
  is	ctl : [mxLIN] char
	cnt : int = 0
	hl_rew (hlp)			; rewind first
	hlp->Vlin = 0			; start new page
	st_fit (str, ctl, mxLIN)	; get a copy
	st_trm (ctl)			; strip it
	fine hl_con (hlp) if !*str	; blank string
	fine hl_con (hlp) if st_sam ("?", str)
	fine hl_brf (hlp) if st_sam ("*", str)
	if *str eq '?'			; want a new help file?
	   fail if !hl_ini (hlp, str+1, <>)
	.. fine hl_con (hlp)		;
	while hl_fnd (hlp, str)
	   ++cnt
	   hl_top (hlp)
	end
	fine if cnt
	fail im_rep ("No help for [%s]\n", str)
  end

code	hl_ini - init help file

  func	hl_ini
	hlp : * hlThlp
	spc : * char
	txt : * char
	()  : * hlThlp
  is	def : [mxSPC] char
	hlp = me_acc (#hlThlp) if !hlp
	if !txt
	   fi_def (spc, "hlp:.hlb", def)
	   fi_loa (def, <*void>&txt, <>, <>, "")
	.. pass fail
	me_dlc (hlp->Pspc) if hlp->Pspc
	me_dlc (hlp->Ptxt) if hlp->Ptxt
	hlp->Pspc = st_dup (spc)
	hlp->Ptxt =txt
	hl_rew (hlp)
	reply hlp
  end

code	hl_dlc - deallocate help 

  func	hl_dlc
	hlp : * hlThlp
  is	me_dlc (hlp->Pspc)
	me_dlc (hlp->Ptxt)
	me_dlc (hlp)
  end

code	hl_rew - rewind file

  func	hl_rew
	hlp : * hlThlp
  is	hlp->Pnxt = hlp->Ptxt
	hlp->Pprv = hlp->Ptxt
	hlp->Alin[0] = 0
	hl_beg (hlp)
  end

code	hl_prv - backup to previous line

  func	hl_prv
	hlp : * hlThlp
  is	hlp->Pnxt = hlp->Pprv
  end

code	hl_nxt - get next line

  func	hl_nxt
	hlp : * hlThlp
 	()  : * char
 is	txt : * char = hlp->Pnxt
	ptr : * char
	cha : int 
	cnt : int
     repeat
	hlp->Pprv = txt
	ptr = hlp->Alin
	cnt = 0
	while *txt
	   cha = *txt++ & 0xff
	   next if cha eq '\f'
	   next if cha eq '\r'
	   quit if cha eq '\n'
	   next if ++cnt ge (mxLIN-1)
	   *ptr++ = cha
	end
	*ptr = 0
	hlp->Pnxt = txt
	fail if !cnt && !*txt
	next if hlp->Alin[0] eq ';'
	reply hlp->Alin
     forever
  end
code	hl_beg - begin new topic

  func	hl_beg
	hlp : * hlThlp
  is	hlp->Vcol = 0
	hlp->Vidt = 0
  end

code	hl_rgt - indent in

  func	hl_rgt
	hlp : * hlThlp
  is	hlp->Vidt += 2
  end

code	hl_lft - indent out

  func	hl_lft
	hlp : * hlThlp
  is	hlp->Vidt -= 2
  end

code	hl_fmt - format text

  func	hl_fmt
	hlp : * hlThlp
	fmt : * char
	obj : * char
  is	buf : [mxLIN] char
	FMT(buf, fmt, obj)
	hl_prt (hlp, buf)
	fine
  end

code	hl_prt - print

  func	hl_prt
	hlp : * hlThlp
	str : * char
  is	buf : [mxLIN] char
	cnt : int
	top : * char
	rem : int
	ret : int = 0
;PUT("[")
	if *(top = st_lst (str)) eq '\n'
	.. ++ret, *top = 0
	hl_idt (hlp) if !hlp->Vcol && *str
	repeat
;PUT("<")
	   rem = hlWID - hlp->Vcol
	   quit if st_len (str) lt rem
	   top = str+rem-1
	   while top gt str
	      quit if *top eq ' '
	      --top
	   end
	   if (cnt = top-str) ne 
	      st_cln (str, buf, cnt)
	      hl_wri (hlp, buf)
	      str += cnt
	     ++str if *str eq ' '
	   else
;PUT(">")
	   .. quit if rem ge (hlWID/2)
;PUT("|")
	   hl_new (hlp)
	   hl_idt (hlp)
	forever
	hl_wri (hlp, str)
	hl_new (hlp) if ret
;PUT("]")
  end

code	hl_idt - write ident

  func	hl_idt
	hlp : * hlThlp
  is	idt : int = hlp->Vidt
	hl_wri (hlp, " ") while idt--
  end

  func	hl_end
	hlp : * hlThlp
  is	hl_new (hlp) if hlp->Vcol 
  end

  func	hl_new
	hlp : * hlThlp
  is	hl_wri (hlp, "\n")
  end

  func	hl_wri
	hlp : * hlThlp
	str : * char
  is	PUT(str)
	hlp->Vcol += st_len (str)
	fine if !st_fnd ("\n", str)
	hlp->Vcol = 0
	fine if ++hlp->Vlin lt 24
	hlp->Vlin = 0
	cl_cmd ("More? ", <>)
	fine
  end
code	hl_con - contents

  func	hl_con
	hlp : * hlThlp
  is	txt : * char
	col : int = 0
	hl_top (hlp) if hl_loc (hlp, "i\t")
	hl_rgt (hlp)
	hl_new (hlp)
	repeat
	   txt = hl_nxt (hlp)
	   quit if !txt
	   next if !st_scn ("t	", txt)
	   col += st_len (txt+2) + 1
	   hl_fmt (hlp, "%s ", txt+2)
	end
	hl_lft (hlp)
	hl_end (hlp)
  end

code	hl_brf - brief help

  func	hl_brf
	hlp : * hlThlp
  is	txt : * char
	col : int = 0
	hl_rew (hlp)
	repeat
	   txt = hl_nxt (hlp)
	   quit if !txt
	   next if !st_scn ("t	", txt)
	   col += st_len (txt+2) + 1
	   hl_fmt (hlp, "%-14s ", txt+2)
	   txt = hl_nxt (hlp)
	   hl_fmt (hlp, "%s", txt+1)
	   hl_new (hlp)
	forever
;	hl_end (hlp)
  end
code	hl_top - show help on topic

  func	hl_top
	hlp : * hlThlp
  is	txt : * char
	lin : * char
	ctl : * char
	cha : int
	hlp->Vidt = 0
	txt = hl_nxt (hlp)
	if !st_scn ("t	", txt)
	&& !st_scn ("i	", txt)
	.. fail

	hl_fmt (hlp, "%s\n", txt+2)
	hl_rgt (hlp)
	repeat
	   txt = hl_nxt (hlp)
	   if !*txt || (*txt eq '\t')	; just text
	      ++txt if *txt		; skip tab
	   .. next hl_fmt (hlp, "%s\n", txt)
	   ctl = txt			; control part
	   lin = st_fnd ("\t", txt)	; get the tab
	   quit if null			; none present
	   ++lin			; that's the data
	   cha = *txt++			; get the first
	   case cha			; 
	   of 'd' next hl_def (hlp, lin); show definition
	   end case			;
	never
	hl_lft (hlp)
	hl_prv (hlp)
	hl_end (hlp)
  end

code	hl_def - display definition

  func	hl_def
	hlp : * hlThlp
	def : * char
  is	nam : [mxLIN] char
	buf : [mxLIN] char
	lft : * char
	rgt : * char
	ptr : * char
	st_fit (def, nam, #nam)		; get a copy
	ptr = st_fnd ("\t", nam)	; locate the end of it
	ptr = st_fnd (" ", nam) if fail; locate the end of it
	fail hl_fmt (hlp, "%s\n", def) if !ptr
	*ptr++ = 0			;
	++ptr while st_mem (*ptr, " \t") ; skip white stuff
	lft = nam, rgt = ptr		;
	++lft if *lft eq '-'		; skip place holder
	++rgt if *rgt eq '-'		; 
	FMT(buf, "%-16s", lft)		; the name
	st_app (rgt, buf)		; the definition
;PUT("[%s]\n", buf)
	hl_fmt (hlp, "%s\n", buf)	;
	fine
  end

code	hl_fnd - find topic

  func	hl_fnd
	hlp : * hlThlp
	top : * char
  is	txt : * char
	repeat
	   txt = hl_nxt (hlp)
	   pass fail
	   next if !st_scn ("t	", txt)
	   st_low (txt)
	   next if !st_scn (top, txt+2)
	   fine hl_prv (hlp)
	end
  end

code	hl_loc - locate prefix

  func	hl_loc
	hlp : * hlThlp
	pre : * char
  is	txt : * char
	repeat
	   txt = hl_nxt (hlp)
	   pass fail
	   next if !st_scn (pre, txt)
	   fine hl_prv (hlp)
	end
  end
