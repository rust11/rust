;???;	WUS:WIFF - Conversion to Windows in-progress
file	wiff - wiki file formatter
include rid:rider
include rid:imdef
include rid:fidef
include rid:stdef
include rid:chdef
include rid:ctdef
include rid:dcdef
include rid:medef
include rid:mxdef

;	%build
;	!memac$ := macro mes:(memac+^1+mefin) /object:meb:^1
;	!memac$ mehyp
;	!memac$ medic
;	!memac$ medig
;	rider tos:wiff/object:tob:
;	link tob:wiff/exe:tob:/map:tob:,lib:crt/bot=2000/cross/prompt
;	meb:mehyp,meb:medic,meb:medig
;	//
;	%end
data	description

;	`x		escape x
;
;	= header	== sub-header	=== sub-sub-header
;	> indent	>> double indent >> triple indent
;	o bullets	oo sub-bullets	ooo sub-sub-bullets
;	# numbered	##...
;
;	**...**	bold	//...// italic	__...__ underline
;
;	----		horizontal line
;	\\		insert line terminator
;
;	{{\n...\n}}\n	no format
;	[[\n...\n]]\n	boxed
;	{{[no]hyphenate, [no]justify}}
code	types

	wkBUF := 4000
	wkEMT := 64
	wkSTO := wkWID+2

	wkWID := 79 - wkLFT
	wkLFT := 2
	wkIDT := 2
	wkTAB := 2
	wkNMB := 3

	wkPAG := 82*26
	wkBOX := 8		; # boxes

  type	wkTdim
  is	Vx   : int
	Vy   : int
	Vwid : int
	Vhgt : int
  end

  type	wkTbox
  is	Ipos : wkTdim		;
	Vlin : int 		; line count
	Vbld : int		; bold
	Vita : int		; italic
	Vund : int		; underline
	Vmon : int		; monospace
	Vbul : int		; bullets
	Vnmb : int		; numbers
	Vitm : int		; numbering item
	Vtab : int		; tab character count
	Vlft : int		; left margin
	Vpre : int		; prespacing
	Vidt : int		; indent
	Vcol : int		; column
	Vwid : int		; width
	Vhyp : int		; hyphenate
	Vjus : int		; justify
	Vsid : int		; left/right side (justification)
	Vwrp : int		; wrap
	Vblk : int		; block quote
	Vbxd : int		; boxed
  end


  type	wkTwik
  is	Hipt : * FILE		; input file
	Pbuf : * char		; input buffer base
	Pipt : * char		; input buffer pointer
	Hopt : * FILE		; output file

	Vpee : int		; peek character
	Veof : int		; EOF seen
	Vhyp : int		; enable hyphenation
	Vjus : int		; enable justification
				;
	Aemt : [wkEMT] char	; emit and break buffer
	Vemt : int		; Aemt count
	Asto : [wkSTO] char	; store
	Vsto : int		; store count
	Apag : [wkPAG] char	; display page
	Vpag : int		;

	Abox : [wkBOX] wkTbox	;
	Vbox : int		;
	Pbox : * wkTbox		;
  end

	c$malp : WORD = 0

	wk_txt : (*FILE, *FILE)
	wk_ipt : (*wkTwik)
	wk_get : (*wkTwik)
	wk_pee : (*wkTwik)
	wk_blk : (*wkTwik)
	wk_pre : (*wkTwik)
	wk_sol : (*wkTwik)
	wk_tra : (*wkTwik)
	wk_hdr : (*wkTwik)
	wk_ctl : (*wkTwik)
	wk_hdr : (*wkTwik)
	wk_dir : (*wkTwik)
	wk_par : (*wkTwik)
	wk_fmt : (*wkTwik)
	wk_pee : (*wkTwik, int)
	wk_ins : (*wkTwik, int)
	wk_emt : (*wkTwik)
	wk_hyp : (*wkTwik, *char, int, int)
	wk_dec : (*wkTwik, *char, int) *char
	wk_dsh : (*wkTwik, *char, int) *char
	wk_dec : (*wkTwik *char, int) *char
	wk_sto : (*wkTwik, *char)
	wk_jus : (*wkTwik, *char, int)
	wk_idt : (*wkTwik)
	wk_lft : (*wkTwik *char, int)
	wk_spc : (*wkTwik, int)
	wk_hor : (*wkTwik)
	wk_dis : (*wkTwik, int)
code	dcl

	_cuABO := "I-RUST Wiki formatter WIFF.SAV V1.0"

  init	cuAhlp : [] * char
  is   "WIFF src dst	Format .WIF file as a .TXT file"
       "/HYPHENATE	Hyphenate the text"
       "/JU*STIFY	Right justify the text"
;      "/ABOUT		Display image information"
;      "/HELP		Display this help frame"
	<>
  end

  type	cuTctl
  is	Pdcl : * dcTdcl
	Hfil : * FILE 
	Asrc : [mxSPC] char
	Adst : [mxSPC] char
	Vhyp : int
	Vjus : int
  end
	ctl : cuTctl = {0}

	cu_wif : dcTfun

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is   2,  <>,		dc_fld,	ctl.Asrc,32,	dcSPC
       2,  <>,		dc_fld,	ctl.Adst,32,	dcSPC
       2, "/HY*PHENATE",dc_set,&ctl.Vhyp,1,	dcSET
       2, "/JU*STIFY",	dc_set,&ctl.Vjus,1,	dcSET
       2,  <>,		cu_wif,	<>, 	0, 	dcEOL_
     0,	 <>,		<>,	<>,	0, 	0
  end

;      1, "*/HE*LP",	dc_hlp,	cuAhlp,	0, 	dcEOL_
;      1, "*/AB*OUT",	dc_rep,	_cuABO,	0, 	dcEOL_
;      1,  "*",		dc_act, <>,	0,	dcNST_
code	start and messages

  func	start
  is	im_ini ("WIFF")
	ctl.Pdcl = dc_alc ()
	ctl.Pdcl->Vflg |= dcNKW_|dcSIN_
	dc_eng (ctl.Pdcl, cuAdcl, "WIFF> ")
  end

  func	cu_wif
	dcl : * dcTdcl 
  is	ipt : * FILE~
	opt : * FILE~
	src : * char = ctl.Asrc
	dst : * char = ctl.Adst
	fi_def (src, "dk:.wif", src)
	fi_def (dst, "dk:.txt", dst)
	ipt = fi_opn (src, "r", "")
	exit if fail
	opt = fi_opn (dst, "w", "")
	exit if fail
	wk_txt (ipt, opt)
	fi_clo (opt, "")
  end

  func	wk_war
	wik : * wkTwik
	msg : * char
  is	im_rep (msg, <>)
	fail
  end
code	wk_txt - convert wiki to text file

  func	wk_txt
	ipt : * FILE
	opt : * FILE
  is	wik : * wkTwik~ = me_acc (#wkTwik)
	box : * wkTbox

	wik->Vhyp = ctl.Vhyp
	wik->Vjus = ctl.Vjus
PUT("%d %d\n", wik->Vjus, wik->Vhyp)

	wik->Hipt = ipt
	wik->Hopt = opt
	wik->Pbuf = me_acc (wkBUF)
	wik->Pbox = wik->Abox		; primary box
	box = wik->Pbox			;
	box->Vwid = wkWID
	box->Vlft = 0
	box->Vjus = wik->Vjus
	box->Vtab = wkTAB
     repeat
	quit if !wk_ipt (wik)
	next wk_new (wik) if !*wik->Pipt
	next if wk_hdr (wik)
	next if wk_ctl (wik)
	next if wk_blk (wik)
	wk_pre (wik)
	if !wk_sol (wik)
	   wk_lft (wik) if *wik->Pipt
	.. wk_tra (wik)
	wk_par (wik)
     forever
	wk_emt (wik)
  end
code	wk_ipt - input next paragraph

  func	wk_ipt
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pbuf
	cha : int~
	cnt : int = 0
	wik->Pipt = ptr
      repeat
	cha = wk_get (wik)
	quit if fail
	if cha eq '\n'
	|| cha eq '\f'
	.. quit *ptr++ = 0
	quit if cha eq '\n'
	wk_war (wik, "W-Paragraph truncated") if cnt eq wkBUF-2
	next if cnt ge wkBUF-2
	if (cha eq '\\') && (wk_pee (wik) eq cha)
	   wk_get (wik), cha = '\r'
	.. wk_get (wik), cha = ' ' if (wk_pee (wik) eq '\n')
	*ptr++ = cha, ++cnt
      forever
	*ptr = 0
	fail if ptr eq wik->Pbuf
	fine
  end

  func	wk_get
	wik : * wkTwik
  is	cha : int
	cha = wik->Vpee if wik->Vpee
	cha = wk_pee (wik) otherwise
	wik->Vpee = 0
	reply cha
  end

  func	wk_pee
	wik : * wkTwik
  is	cha : int
	fail if wik->Veof
	cha = fi_gch (wik->Hipt)
	cha = 0, ++wik->Veof if cha eq EOF
	wik->Vpee = cha
	reply cha
  end
code	wk_sol - parse start-of-line 

;	Process blank line

  func	wk_blk
	wik : * wkTwik
  is	ptr : * char~ = wik->Pipt
	cnt : int~
	++cnt, ++ptr while *ptr && (*ptr ne ' ')
	fail if cnt
	wk_new (wik)
	fine
  end

;	Prespacing -- redundant

  func	wk_pre
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pipt
	cnt : int~ = 0
	cha : int = 0
	box->Vpre = 0
	fail if box->Vblk	; unformatted
	++cnt, ++ptr while *ptr && (*ptr eq  '>')
	fail if !cnt
	fail if *ptr++ ne ' '
	wik->Pipt = ptr
	box->Vpre = box->Vtab * cnt
	fine
   end

;	Parse start of line

  func	wk_sol
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pipt
	cha : int = *ptr++
	str : [8] char
	spc : int = 1
	cnt : int~ = 1
	nmb : int = 0
	itm : int = box->Vitm
	wid : int

	box->Vitm = 0 if !box->Vnmb
	box->Vidt = 0
	box->Vbul = 0
	fail if box->Vblk	; unformatted

	case cha
	of 'o' 
	or '*'  box->Vbul = 1
	of '#'	box->Vnmb = 1
	of other
	   fail
	end case

	while *ptr && (*ptr eq cha)
	   fail wk_war (wik, "W-Too many chars") if cnt ge 3
	   ++ptr
	   ++cnt
	end

	fail if *ptr++ ne ' '
	wik->Pipt = ptr
	box->Vidt = cnt * box->Vtab

	wk_lft (wik)
	wk_spc (wik, box->Vtab * (cnt-1))
	if box->Vbul
	   wk_str (wik, "o")
	   wk_spc (wik, box->Vtab-1)
	   box->Vbul = 0
	elif box->Vnmb
	   --box->Vitm if box->Vitm ge 99
	   FMT(str, "%-4d", ++box->Vitm)
	   *st_fnd (" ", str) = '.'
	   *st_fnd (" ", str) = ' '
	   wk_str (wik, str)
	   if (wid = st_len (str)) lt box->Vtab
	   .. wk_spc (wik, box->Vtab-wid)
	end
	fine
  end

code	wk_tra - trailing paragraph

  func	wk_tra
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pipt
	par : * char~
	fine if !(ptr = st_fnd ("  ", ptr))
	while *ptr
	   next if *ptr++ ne ' '
	   par = ptr if *ptr eq ' '
	end
	box->Vidt = (par+1)-wik->Pipt
  end
code	wk_hdr - parse headers

  func	wk_hdr
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
  	ptr : * char~ = wik->Pipt
	hdr : int = 0
	cha : int
	len : int

	while *ptr && (*ptr eq '=')
	   fail if ++hdr gt 3
	   ++ptr
	end
	fail if !hdr
	fail if *ptr++ ne ' '

	fail wk_war (wik, "W-Heading too long") if st_len (ptr) ge 64

	box->Vitm = 0
	box->Vnmb = 0
	box->Vidt = 0
	box->Vbul = 0
	box->Vpre = 0

	box->Vlft = (hdr - 1) * wkIDT
	wk_lft (wik)
	wk_str (wik, ptr)
	wk_new (wik)
	box->Vlft += wkIDT
	*wik->Pipt = 0
	fine
  end
code	wk_ctl - control sequences

  func	wk_ctl
	wik : * wkTwik
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pipt

	if st_sam (ptr, "----")
	   wk_hor (wik)
	elif st_sam (ptr, "{{", 2)
	   box->Vblk = 1
	elif st_sam (ptr, "}}", 2)
	   box->Vblk = 0
	elif st_sam (ptr, "[[", 2)
	   box->Vbxd = 2
	elif st_sam (ptr, "]]", 2)
	   box->Vbxd = 0
	elif st_sam (ptr, "[{", 2)
	   box->Vbxd = 2
	   box->Vblk = 1
	elif st_sam (ptr, "]}", 2)
	   box->Vbxd = 0
	   box->Vblk = 0
	else
	.. reply wk_dir (wik)

	fine *wik->Pipt = 0
  end

code	wk_dir - directives

;	\n{{hyphenate, justify}}\n

  type	wkTdir
  is	Vopr : int
	Pdir : * char
  end
	wkHYP := 1
	wkJUS := 2
	wkNHY := 3
	wkNJS := 4
	wkWTH := 5

  init	wkAdir : [] wkTdir
  is	wkHYP, "hyphenate"
	wkJUS, "justify"
	wkNHY, "nohyphenate"
	wkNJS, "nojustify"
	wkWTH, "width"
	0, <>
  end

  func	wk_dir
	wik : * wkTwik
  is	box : * wkTbox = wik->Pbox
	ptr : * char~ = wik->Pipt
	dir : * wkTdir
	lin : [mxLIN] char

	fail if st_len (wik->Pipt) gt (mxLIN-1)
	st_cop (wik->Pipt, lin)
	st_low (lin)
	fail if !st_rem ("{{", lin)
      repeat
	quit if st_sam ("}}", lin)
	dir = wkAdir
	repeat
	   fail wk_war (wik, "W-Invalid directive line") if !dir->Vopr
	   if st_rem (dir->Pdir, lin)
	      case dir->Vopr
	      of wkHYP box->Vhyp = 1 
	      of wkJUS box->Vjus = 1 
	      of wkNHY box->Vhyp = 0 
	      of wkNJS box->Vjus = 0 
	      of wkWTH wk_val (wik, lin, &box->Vwid, 1, 132)
	      end case
	      st_rem (",", lin)
	      st_rem (" ", lin)
	   .. quit
	   ++dir
	forever
      forever
	fine *wik->Pipt = 0
  end

code	wk_val - pickup directive value

  func	wk_val
	wik : * wkTwik
	lin : * char
	val : * int
	low : int
	hgh : int
  is	cnt : int = 0
      repeat
	quit if !st_rem ("=", lin)
	st_val (lin, 10, val, &cnt)
	quit if cnt le
	quit if *val lt low
	quit if *val ge hgh
	fine st_mov (lin+cnt, lin)
      never
	fail wk_war (wik, "W-Invalid value")
  end
code	wk_rul - rulers

;	+....+....

code	wk_tab - tables

;	| 

code	wk_box - boxed tables

;	%

code	wk_par - paragraphs

;	Stream paragraph

  func	wk_par
	wik : * wkTwik~
  is	ptr : * char~ = wik->Pipt
	while *ptr
	  ++ptr if (*ptr eq '`') && ptr[1]
	  wk_stm (wik, *ptr++)
	end
	wk_stm (wik, '\n')
  end

;	Character formatting ???

  func	wk_fmt
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	cha : int~
	snd : int~

	cha = wik->Pipt[0]
	snd = wik->Pipt[1]
	if cha eq snd
	   case cha
	   of '*'  box->Vbld = ~box->Vbld
	   of '/'  box->Vita = ~box->Vita
	   of '_'  box->Vund = ~box->Vund
	   of '{'  box->Vmon = 1
	   of '}'  box->Vmon = 0
	   of other
		   fine
	   end case
	   wik->Pipt += 2
	end
	fine
  end
code	wk_stm - stream output

  func	wk_stm
	wik : * wkTwik~
	cha : int~
  is	if cha eq ' ' || cha eq '\n'
	   wk_emt (wik)
	   wk_ins (wik, cha)
	   wk_emt (wik)
	elif cha eq '\r'
	   wk_emt (wik)
	   wk_jus (wik, 0)
	   wk_new (wik)
	   wk_idt (wik)
	else
	   wk_ins (wik, cha)
	end
	wk_jus (wik, 0) if cha eq '\n'
  end

code	wk_ins - insert char in output stream

;	tabs???

  func	wk_ins
	wik : * wkTwik~
	cha : int
  is	if wik->Vemt ge wkEMT-1
	.. wk_emt (wik)
	wik->Aemt[wik->Vemt++] = cha
  end

code	wk_emt - emit segment

  func	wk_emt
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	cnt : int~ = wik->Vemt
	lim : int~ = box->Vwid - box->Vcol

	wik->Vemt = 0
	wik->Aemt[cnt] = 0
	if cnt gt lim
	   fine if wk_hyp (wik, wik->Aemt, cnt, lim)
	   wk_jus (wik, 1)
	   wk_new (wik)
	   wk_idt (wik)
	   box->Vwrp = box->Vjus
	   fine if st_sam (wik->Aemt, " ")
	end
;	wk_dec (wik, wik->Aemt, st_len (wik->Aemt) - 3)
	wk_sto (wik, wik->Aemt)
  end
code	wk_hyp - hyphenate word

  func	wk_hyp
	wik : * wkTwik
	wrd : * char~
	len : int
	lim : int
  is	box : * wkTbox
	brk : * char~
	dsh : * char
	skp : int = 2
	fail if !box->Vhyp
	fail if lim lt 3
	brk = wk_dec (wik, wrd, lim-3)
	dsh = wk_dsh (wik, wrd, lim-3)
	brk = dsh, ++skp if dsh gt brk
	fail if brk eq
;PUT("\nbrk->%d %o -", brk-wrd, brk)
	st_ins ("- ", brk)
	brk[1] = 0
;PUT("\nbrk=%d wrd=[%s] rem=[%s]\n", brk-wrd, wrd, brk+2)
	wk_sto (wik, wrd)
	st_cop (brk+2, wrd)
	wik->Vemt = st_len (wrd)
 	fine
  end

code	wk_dec - decus hyphen

  func	wk_dec
	wik : * wkTwik
	wrd : * char
	lim : int
	()  : * char
  is	ptr : * char = wrd
	brk : int = 0
	col : int = 0
	st_hyp (ptr)
	*ptr &= 0177
	while *ptr
	  if *ptr & 0200
	     if col lt lim
	     && col gt brk
	     .. brk = col
	  .. *ptr &= 0177
;	  .. *ptr = st_upr (*ptr)
 
	  ++ptr, ++col
	end
	fail if !brk
;PUT("brk:%d %o", brk, wrd+brk)
	reply wrd+brk
 end

code	wk_dsh - dots and dashes

  func	wk_dsh
	wik : * wkTwik
	wrd : * char
	lim : int
	()  : * char
  is	ptr : * char = wrd
	brk : int = 0
	col : int = 0
	while *ptr && (col lt lim)
	  if (*ptr eq '-') || (*ptr eq '.')
	  && col gt && ct_alp (ptr[-1])
	  .. brk = col if col gt brk
 	   ++ptr, ++col
	end
	fail if !brk
;PUT("brk:%d %o", brk, wrd+brk)
	reply wrd+brk
 end

code	wk_brk - local breaks

  init	wkAbrk : [] * char
  is	"imple-ement"
	"imple-emen-tation"
	"so-phisti-cation"
	<>
  end
code	wk_jus - justify line and output



;	Store line

  func	wk_sto
	wik : * wkTwik~
	str : * char~
  is	box : * wkTbox = wik->Pbox
	while *str
	   wik->Asto[wik->Vsto++] = *str++
	   ++box->Vcol
	end
  end

;	Justify line

  func	wk_jus
	wik : * wkTwik~
	wrp : int
  is	box : * wkTbox = wik->Pbox
	sto : * char~ = wik->Asto
	len : int = wik->Vsto
	ptr : * char~
	dif : int
	red : int
	wik->Vsto = 0
	sto[len] = 0

	fine wk_str (wik, sto) if !wrp || !box->Vwrp

	ptr = st_end (sto)
	--ptr while (ptr ne sto) && (ptr[-1] eq ' ')
	*ptr = 0
	len = st_len (sto)

	dif = box->Vwid - len
	st_rev (sto+box->Vidt) if box->Vsid

	while dif 
	   ptr = sto + box->Vidt
	   red = dif
	   while dif
	      ++ptr while *ptr && (*ptr ne ' ')
	      quit if !*ptr
	      st_ins (" ", ptr)
	      --dif
	      ++ptr while *ptr && (*ptr eq ' ')
	   end
	   quit if dif eq red
	end
	st_rev (sto+box->Vidt) if box->Vsid
	wk_str (wik, sto)
	box->Vsid = !box->Vsid
  end
code	wk_idt - put indent

  func	wk_idt
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	idt : int = box->Vidt
	wk_lft (wik)
	wk_spc (wik, box->Vidt)
  end

code	wk_lft - put left margin

  func	wk_lft
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	wk_spc (wik, box->Vlft + box->Vpre - box->Vbxd)
	wk_str (wik, "  |") if box->Vbxd
  end

code	wk_spc - put spaces

  func	wk_spc
	wik : * wkTwik
	cnt : int
  is	wk_put (wik, ' ') while cnt--
  end

code	wk_hor - put horizontal line

  func	wk_hor
	wik : * wkTwik~
  is	box : * wkTbox = wik->Pbox
	while box->Vcol ne box->Vwid
	   wk_put (wik, '-')
	end
	wk_new (wik)
  end

code	wk_put - put character

;	New line

  func	wk_new
	wik : * wkTwik
  is	wk_put (wik, '\n')
  end

;	Put string

  func	wk_str 
	wik : * wkTwik
	str : * char
  is	wk_put (wik, *str++) while *str
  end

;	Put character

  func	wk_put 
	wik : * wkTwik~
	cha : int
  is	box : * wkTbox = wik->Pbox
PUT("%c", cha)
	wk_dis (wik, cha)
	++box->Vcol
	if cha eq '\n'
	   box->Vcol = 0
	.. ++box->Vlin 
  end
code	wk_dis - display character

;	Write character to display area or output

  func	wk_dis
	wik : * wkTwik
	cha : int
  is	fi_pch (wik->Hopt, cha)
  end
end file
;	Box output
;
;	Output is written to boxes in a character matrix
;	Trailing spaces are removed from lines during raw output
;	Nested boxes are not supported
;	Merged boxes are supported
;	Use box library--useful for spread sheets and editor
;
;	Wiki style table specification, however,
;	Rulers are used to define dimensions

  type	wiTbox
  is	Ppar : * wiTpar		; parent box
	Vcol : int		; box column
	Vwid : int		; width of box
	Vdep : int		; depth of box

	Vbeg : * char		; first character
;	Plin : * char		; current line
	Pcha : * char		;

+------------------+-----------------+-------------+



;	";" etc in left column for source comments
;	Space for change bar in left columns
;
; HELP indenting for heading levels
;	Fix hyphen
;	Finish // stuff
;
;	o---------o
;	+---------+.......~..+...........+
;	| sssss | 
;	% ssss  %
;	+--
;
;	+---------+
;
;	|...
;	+---
;
;	text
;	html
;	VT100
;	wiki
;
;	Ordinary text is wrapped
;
;	blot /width=n in-file out-file
;
;	/width=n	document width
;	/font=		bold, italic, underline 
;
;

;	**x**	bold
;	//x//	italic
;	__x__	underline
;	{{x}}	monospace
;	
;	=x=	heading 1
;	==x==	heading 2
;	* x	list 1
;	** x	list 2
;	# x	numbered
;	> x	indented
;	----	horizontal line
;	``x``	escape
layout boxes
tabs
menu items

