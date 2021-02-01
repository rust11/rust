file	uscnt - count/compare/search
include	usb:usmod

code	kw_cnt - count files

	cu_fnd	: (*char, *char) *char own

  func	kw_cnt
	ctx : * cuTctx
  is	fil : * FILE
	buf : [mxLIN*2] char
	nxt : * char
	byt : long = 0
	wrd : long = 0
	lin : long = 0
	pag : long = 1
	txt : int
	cha : int

	fail if (fil = cu_src (ctx)) eq	; no such file
	fail if quFque && !cu_opr (ctx)	; only for query mode
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it
					;
	repeat				;
	   quit if fi_get (fil, buf, mxLIN*2) eq EOF
	   ++lin			; another line
	   nxt = buf, txt = 0		;
	   while (cha = *nxt++ & 255) ne; got another
	      ++byt			;
	      if cha le 32		; spaces
	         txt = 0		;
	         ++pag if cha eq '\f'	;
	      else			;
	      .. ++txt, ++wrd if txt eq	;
	   end				;
	forever				;
	ctx->Vcha += byt
	ctx->Vlin += lin
	ctx->Vwrd += wrd
	ctx->Vpag += pag
;	exit if !cnt && !quFall		; not seen & not all
	exit if quFtot			; totals only
;	exit if quFful
PUT("%-14s %-5ld chars, %-4ld words, %-3ld lines, %-3ld sides, %-2ld pages",
	    ctx->Pnam, byt, wrd, lin, lin/60, pag), NL
  end
code	kw_cmp - compare files

;	Ignores file structure
;
;	quFall		reports all files (including missing)
;	quFful		details different, shorter, longer
;	quFbar		lists only different files
;	quFtot		lists only totals
;	quFbin		wants binary differences

	cuPcmp : * char = <>		; other directory
	cu_bin	: (int, int, long) int	; compare binary

  func	kw_cmp
	ctx : * cuTctx
  is	nam : [mxSPC] char
	src : * FILE
	dst : * FILE
	lft : int = 0
	rgt : int = 0
	dif : int = 0			;
	loc : long = 0
	msg : * char = <>		;
	fail if (src = cu_src (ctx)) eq	; no source file
	fail if quFque && !cu_opr (ctx)	; only for query mode
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it

	if (dst = cu_dst (ctx)) ne	; got destination file
	   if !quFful			; doesnt need details
	   && fi_len (src) ne fi_len (dst) ; different sizes
	      ++dif			; different
	   else				;
	      repeat			; compare them
	        lft = getc (src)	;
	        rgt = getc (dst)	;
	        if cu_bin (lft,rgt,loc)	; displaying binary differences
		.. next ++dif, ++loc	;
	        quit ++dif if lft ne rgt;
	        quit if lft eq EOF	; done
		++loc			;
	   .. forever			;
	   cu_clo (ctx, &ctx->Pdst, "")	; close the file
	end				;
	if dst eq <>			; a new file
	   ++ctx->Vmis			;
	   msg = ": missing"		;
	   exit if !(quFall | quFful)	; not interested
	elif !dif			; same
	   ++ctx->Vsam			;
	   msg = ": same"		;
	   exit if !quFall 		; not interested
	elif lft eq EOF			;
	   ++ctx->Vdif			;
	   msg = ": shorter" if !quFbar	;
	elif rgt eq EOF			;
	   ++ctx->Vdif			;
	   msg = ": longer" if !quFbar	;
	else				;
	   ++ctx->Vdif			;
	.. msg = ": different" if !quFbar;
	exit if quFtot			; totals only
	if msg eq <>			; no message
	|| !(quFful | quFall)
	.. msg = ""
	PUT("%-14s %s", ctx->Pnam, msg), NL
  end

code	cu_bin - display binary differences

  func	cu_bin
	lft : int
	rgt : int
	loc : long
  is	fail if !quFbin			; don't want binary differences
	fail if lft eq rgt		;
	fail if lft eq EOF		; hit end of file
	cu_abt ()			;
	PUT ("%-4ld %03x %02x %02x", 	;
	      loc/512, <int>loc&511, lft,rgt), NL
	fine				;
  end

code	su_cmp - init compare

  func	su_cmp
	ctx : * cuTctx
  is	nam : * char = ctx->P2
	if *nam eq			;
	.. cu_err ("E-No new file path", <>);
	if *st_lst (nam) ne '\\'	; needs directory \
	.. st_app ("\\", nam) 		; shove it in
	++ctx->Vtar			; has target
	fine
  end
code	kw_dif - list text file differences

;	quFall		reports all files (including missing)
;	quFful		details different, shorter, longer
;	quFbar		lists only different files
;	quFtot		lists only totals
;
;	cuPcmp : * char = <>		; other directory

  func	kw_dif
	ctx : * cuTctx
  is	nam : [mxSPC] char
	old : [mxLIN*2] char
	new : [mxLIN*2] char
	src : * FILE
	dst : * FILE
	lft : int = 0
	rgt : int = 0
	dif : int = 0			;
	msg : * char = <>		;
	fail if (src = cu_src (ctx)) eq	; no source file
	fail if quFque && !cu_opr (ctx)	; only for query mode
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it

	if (dst = cu_dst (ctx)) ne	; got destination file
	   repeat			; compare them
	      lft = fi_get (src, old, (mxLIN*2)-2)
	      rgt = fi_get (dst, new, (mxLIN*2)-2)
	      if st_cmp (old, new)	; different
		 ++dif			; different
		 PUT("[%s]", old), NL	;
	         PUT("[%s]", new), NL	;
	      .. quit			;
	      quit if lft eq EOF	; done
	   forever			;
	.. cu_clo (ctx, &ctx->Pdst, "")	; close the file
					;
	if dst eq <>			; a new file
	   ++ctx->Vmis			;
	   msg = ": missing"		;
	   exit if !(quFall | quFful)	; not interested
	elif !dif			; same
	   ++ctx->Vsam			;
	   msg = ": same"		;
	   exit if !quFall 		; not interested
	elif lft eq EOF			;
	   ++ctx->Vdif			;
	   msg = ": shorter" if !quFbar	;
	elif rgt eq EOF			;
	   ++ctx->Vdif			;
	   msg = ": longer" if !quFbar	;
	else				;
	   ++ctx->Vdif			;
	.. msg = ": different" if !quFbar;
	exit if quFtot			; totals only
	if msg eq <>			; no message
	|| !(quFful | quFall)
	.. msg = ""
	PUT("%-14s %s", ctx->Pnam, msg), NL
  end
code	kw_var - check directory variations

;	compare/directories
;
;	name		d1			d2
;	a.a		missing
;			new
;	a.a		before
;			after
;			longer
;			shorter
;
;	Must be sorted on name or type

	dfNON	:= 0
	dfEXT	:= 1
	dfMIS	:= 2
	dfLON	:= 3
	dfSHO	:= 4
	dfOLD	:= 5
	dfNEW	:= 6
	dfDIF	:= 7
	dfOLF	:= 8
	dfORT	:= 9
	dfSAM	:= 10

	SKP(m,s) := (dif = m, skp = s)
	LFT := (-1)
	RGT := 1
	df_cmp : (*char, *char) int own

  func	kw_var
	ctx : * cuTctx
  is	src : * cuTctx = ctx
	dst : * cuTctx = cuPdst
	lft : * drTent
	rgt : * drTent
	ltp : * char
	rtp : * char
	skp : int
	dif : int
	srt : int				;
	cmp : int				;
	pos : int				;
	cri : int				;
	tim : int				;
	siz : long				;
	msg : [128] char			;
	st_cop (src->Pcmd, dst->Pcmd)		; copy command
	st_cop (src->P2, dst->P1)		; get dest string
						;
	if quVsrt eq drSIZ			; size sort 
	|| quVsrt eq drTIM			; and date sort
	.. quVsrt = drNAM			; fail 
	quFrev = 0				; ignore reverse
						;
	fail if !us_scn (src)			; scan source
	fail if !us_scn (dst)			; and destination
	srt = src->Vsrt				;

	skp = 0					; skip both first time
   repeat					;
	lft = us_nxt (src) if skp le		; get next
	rgt = us_nxt (dst) if skp ge		;
	skp = 0					; assume skip both
	quit if !lft && !rgt			; no more
     repeat					;
	dif = dfNON				; no difference
	tim = 0					;
	cmp = 0

	; End of directory on one side

;PUT("end ")
	quit SKP (dfEXT, RGT) if lft eq		; extra on right
	quit SKP (dfMIS, LFT) if rgt eq		; missing on right

	;  Directory vs File

;PUT("dir ")
	if !(lft->Vatr & drDIR_)		; left not directory
	   if (rgt->Vatr & drDIR_)		; but right is
	   .. quit SKP (dfEXT, RGT)		;
	elif !(rgt->Vatr & drDIR_)		; right is not direcory
	.. quit SKP (dfMIS, LFT)		;

;	File name or type sort

	pos = 0					;
	if srt eq drTYP				; by type
	   ltp = st_fnd (".", lft->Pnam)	;
	   ltp = "" if null			;
	   rtp = st_fnd (".", rgt->Pnam)	;
	   rtp = "" if null			;
	.. pos = st_cmp (ltp, rtp)		; compare types
	if pos eq				;
	.. pos = st_cmp (lft->Pnam,rgt->Pnam)	; compare names

;PUT("%s %s %d ", lft->Pnam, rgt->Pnam, pos)
	quit SKP (dfEXT, RGT) if pos gt		; extra right
	quit SKP (dfMIS, LFT) if pos lt		; missing right

;	Same file - check size/date

	if (siz = rgt->Vsiz - lft->Vsiz) ne	; check size
	   dif = dfLON if siz gt		;
	.. dif = dfSHO otherwise		;
						;
	if ti_cmp (&rgt->Itim, &lft->Itim)	; check time
	   tim = dfOLD if cmp lt		;
	.. tim = dfNEW otherwise		;
						;
	quit if siz ne				; have a real difference
	dif = df_cmp (src->Pspc, dst->Pspc)	; compare content
     never					;
						;
	next if !(dif | tim) && !quFall		; no difference
	st_cop (":", msg)			;

	case tim
	of dfOLD
	   st_app (" older", msg)
	of dfSAM
	   st_app (" same ", msg)
	of dfNEW
	   st_app (" newer", msg)
	end case

	case dif				;
	of dfMIS				; missing
	   st_app (" missing", msg)		;
	   ++ctx->Vmis				; some missing
	of dfEXT				; extra
	   st_app (" new", msg)			;
	of dfLON				; longer
	   FMT (st_end (msg), " +%ld", siz)	;
	of dfSHO				; shorter
	   FMT (st_end (msg), " %ld ", siz)	;
	of dfOLF				; error on left
	   st_app (" left error", msg)		;
	of dfORT				; right error
	   st_app (" right error", msg)		;
	of dfDIF				; different
	   st_app (" different", msg)		;
	of dfNON
	   st_app (" same", msg)		;
	end case

	(skp ne RGT) ? lft->Pnam ?? rgt->Pnam 
	PUT("%-14s %s", that, msg), NL		;
    forever
	cu_don (src->Pdir)			; deallocate directories
	cu_don (dst->Pdir)			;
	fail					; that was all
  end

code	df_cmp - compare two files

  func	df_cmp
	src : * char
	dst : * char
	()  : int own
  is	lft : * FILE = <>
	rgt : * FILE = <>
	dif : int = 0
	cha : int
	lft = fi_opn (src, "rb", <>)
	reply dfOLF if <>		; no hope
	rgt = fi_opn (dst, "rb", <>)	;
	reply fi_clo (lft,<>), dfORT if <>
	cha = 0				; prime condition
	while cha ne EOF		; got more
	   cha = getc (lft)		;
	   next if getc (rgt) eq cha	;
	   quit dif = dfDIF		;
	end				;
	fi_clo (lft, "")		; close that
	fi_clo (rgt, "")		; close that
	reply dif
  end
code	kw_sea - search file

	cu_fnd	: (*char, *char) *char own

  func	kw_sea
	ctx : * cuTctx
  is	fil : * FILE
	lin : [mxLIN*2] char
	str : * char
	cnt : int = 0
	fst : int = 0
	fail if (fil = cu_src (ctx)) eq	; no such file
	fail if quFque && !cu_opr (ctx)	; only for query mode
	str = ctx->P2			; the model
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it
					;
	if !st_fnd ("?", str)		; no wildcards
	   repeat			;
	      quit if fi_get (fil, lin, mxLIN*2) eq EOF
	      next if !st_fnd (str, lin); not in this line
	      if quFful			;
		 PUT("%-14s", ctx->Pnam), NL if !cnt 
	         st_cop ("...", lin+68)	; shorten long lines
	      .. PUT("	%s", lin), NL	; display the line
	      ++cnt			; got another
	   forever			;
	else				; got wildcards
	   repeat			;
	      cu_abt ()			; check aborts
	      quit if fi_get (fil, lin, mxLIN*2) eq EOF
	      if cu_fnd (str, lin) ne	; found it
	      .. ++cnt			; got another
	   forever			;
	end				;
	++ctx->Vmat if cnt		; matched this one
	ctx->Vlin += cnt		; accumulate 
	exit if !cnt && !quFall		; not seen & not all
	exit if quFtot			; totals only
	PUT("%-14s %d", ctx->Pnam, cnt), NL if !quFful
  end

code	cu_fnd - find wildcard substring

  func	cu_fnd
	mod : * char			; model substring to find
	str : * char			; string to search
	()  : * char			; pointer to found or null
  is	src : * char			; for substring match
	dst : * char			;
					;
	while *mod eq '?'		; remove leading wildcards
	   ++mod			;
	   reply <> if !*str++		;
	end				;
	reply str if !*mod		; done leading match
					;
      repeat				; big loop
	while *mod ne *str		; find the first matching character
	.. reply <> if *str++ eq	; exhausted string, not found
	src = mod, dst = str		; found first
	repeat				; compare remainder
	   reply str if *src eq		; done, found
	   if *src eq '?' && *dst	; wildcard
	   .. next ++src, ++dst		;
	until *src++ ne *dst++		; got another
	++str				; again, just past remainder
      forever				;
  end

code	su_sea - init search

  func	su_sea
	ctx : * cuTctx
  is	mod : * char = ctx->P2
	lst : * char
	if *mod eq			;
	.. cu_err ("E-No search string", <>)
	st_trm (mod)			; trim it
	if *mod eq '"'			; quoted
	   st_del (mod, 1)		; delete it
	   if *(lst = st_lst (mod)) eq '"' ; got terminating "
	.. .. *lst = 0			; skip it
	if *mod eq			;
	.. cu_err ("E-Empty search string", <>)
	fine
 end
end file
code	vr_rep - report differences

  func	vr_rep
	lft : * drTent
	rgt : * drTent
	cri : int
	pos : int
	cmp : int
  is	dif : int = pos | cmp		; get difference
	nam : * char = lft->Pnam	; assume left name
	msg : * char = <>		;
      repeat				;
	if !dif				; same babies
	   ++ctx->Vsam			;
	   msg = ": same"		;
	   exit if !quFall 		; not interested
	.. quit				;
					;	
	case cri			;
	of vrEND			;
	or vrNAM			;
	   ++ctx->Vmis			; something missing
	   exit if !(quFall | quFful)	; not interested
	   msg = ": missing" if cmp gt	;
	   msg = ": extra"   otherwise	;
	   nam = rgt->Pnam if cmp lt	; extra needs right name
	of vrSIZ			; the size
	   ++ctx->Vdif			;
	   exit if !(quFall | quFful)	; not interested
	   if !quFbar			; not bare
	      msg = ": shorter" if cmp lt
	   .. msg = ": longer" otherwise
	of vrTIM			;
	   ++ctx->Vdif			;
	   ++ctx->Vdif			;
	   exit if !(quFall | quFful)	; not interested
	   if !quFbar			; not bare
	      msg = ": older" if cmp lt	;
	   .. msg = ": newer" otherwise	;
	else				;
	   ++ctx->Vdif			;
	.. msg = ": different" if !quFbar;
      never				;
	exit if quFtot			; totals only
	if msg eq <>			; no message
	|| !(quFful | quFall)		;
	.. msg = ""			;
	PUT("%-14s %s", nam, msg), NL	;
  end
code	kw_fin - find string in binary file

;	cu_fnd	: (*char, *char) *char own

  func	kw_fin
	ctx : * cuTctx
  is	fil : * FILE
	lin : [mxLIN*2] char
	str : * char
	cnt : int = 0
	fst : int = 0
	fail if (fil = cu_src (ctx)) eq	; no such file
	fail if quFque && !cu_opr (ctx)	; only for query mode
	str = ctx->P2			; the model
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it
					;
	if !st_fnd ("?", str)		; no wildcards
	   repeat			;
	      quit if su_get (fil, lin, mxLIN) eq EOF
	      next if !st_fnd (str, lin); not in this line
	      if quFful			;
		 PUT("%-14s", ctx->Pnam), NL if !cnt 
	         st_cop ("...", lin+68)	; shorten long lines
	      .. PUT("	%s", lin), NL	; display the line
	      *lin = 0			; done with this one
	      ++cnt			; got another
	   forever			;
	else				; got wildcards
	   repeat			;
	      cu_abt ()			; check aborts
	      quit if fi_get (fil, lin, mxLIN*2) eq EOF
	      if cu_fnd (str, lin) ne	; found it
	      .. ++cnt			; got another
	   forever			;
	end				;
	++ctx->Vmat if cnt		; matched this one
	exit if !cnt && !quFall		; not seen & not all
	exit if quFtot			; totals only
	PUT("%-14s %d", ctx->Pnam, cnt), NL if !quFful
  end
