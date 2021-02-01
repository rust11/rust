file	uscop - copy/rename/move/sort
include	usb:usmod

;	Copy	dir:name.typ	dir:name.typ
;	Rename	dir:name.typ	dir:name.typ
;	Move	rename or copy
;
;	Copy	Handle multi-volume floppy transfers

code	kw_tra - transfer one file

  func	kw_tra
	ctx : * cuTctx
  is	src : * FILE
	dst : * FILE
	ent : * drTent = ctx->Pent
	len : LONG
	if st_sam (ctx->Pspc, ctx->Ptar)	; DOS goes crazy here
	.. cu_err ("E-Can't copy file to self: %s", ctx->Pobj)
						;
	fail if (src = cu_src (ctx)) eq		; no source file
	fail if !cu_rpl (ctx)			; don't replace file
	fail if !cu_opr (ctx)			; no go
	fail if (dst = cu_tar (ctx)) eq		; no target file

	if quFren
	   if fi_ren (ctx->Pspc, ctx->Ptar, "")	; whoopee do
	   && fi_stm (ctx->Ptar, &ent->Itim, "");
	   .. fine				;
	   im_rep ("E-Error renaming file %s", ctx->Pobj)
	.. fail

	if quFsiz				; specified a size
	   len = quFsiz				; get the size
	   len *= 1024 if !quFbyt		; not /bytes
	   if cu_kop (src, dst, len)		; transfer file
	   && cu_cln (ctx)			; cleanup files
	   && fi_stm (ctx->Ptar, &ent->Itim, "");
	   .. fine				;
	else
	   if fi_kop (src, dst, 0)		; transfer file
	   && cu_cln (ctx)			; cleanup files
	   && fi_stm (ctx->Ptar, &ent->Itim, "");
	.. .. fine				;
	im_rep ("E-Error transferring file %s", ctx->Pobj)
	fail
  end

code	su_tra - init transfer

  func	su_tra
	ctx : * cuTctx
  is	nam : * char = ctx->P2
	if *nam eq			;
	.. cu_err ("E-No new file path", <>);
					;
	if st_fnd ("*.*", nam)		; thats o.k.
	elif st_fnd ("*", nam)		; wrong
	|| st_fnd ("?", nam)		;
	|| st_fnd (".", nam)		;
	.. cu_err ("E-Invalid kopy destination [%s]", nam)
	st_rep ("*.*", "", nam)		; thats o.k.
	if *st_lst (nam) ne '\\'	; needs directory \
	.. st_app ("\\", nam) 		; shove it in
					;
	fi_buf (<>, 60*1024)		; big transfer buffer
	++ctx->Vtar			; has target spec
	fine
  end
code	kw_srt - sort file(s)

 	cu_srt	: (*void const, *void const) int own ; compare
  func	kw_srt
	ctx : * cuTctx
  is	buf : [mxLIN+2] char		; the buffer
	vec : ** char = <>		; vector
	opt : ** char			; output pointer
	src : * FILE			;
	dst : * FILE			;
	wid : size = #<*char>		; pointer width
	idx : int = 0			;
	rem : int = 0			; remaining pointers
	tot : int = 0			; total pointers
	cnt : int			;
	fail if (src = cu_src (ctx)) eq	; no source file
	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it
	fail if quFque && !cu_opr (ctx)	; only for query mode
					;
	repeat				;
	   cnt = fi_get (src,buf,mxLIN)	;	
	   quit if EOF			;
	   next if cnt eq		; skip empty lines
	   if quFtrm			; trim outer spaces
	      st_trm (buf)		;
	   .. next if !buf[0]		; reduced to empty
	   if idx ge tot		; need more pointers
	      tot += 128		; get another 128 pointers
	   .. vec = realloc (vec, (tot*wid))
	    vec[idx++] = st_dup (buf)	;
	end				;
	fail if idx eq			; nothing to do
	qsort (vec, idx, wid, &cu_srt)	; sort them
	opt = vec			; output them
	while idx--			;
	   cu_abt ()			; check aborts
	   PUT("%s\n", *opt)		;
	   me_dlc (*opt++)		; deallocate string
	end				;
	me_dlc (vec)			; deallocate vector
  end

code	cu_srt - sort two members

  func	cu_srt
	src : * void const
	dst : * void const
	()  : int
  is	off : int = quVfro
	cmp : int 
	lft : * char = *<**char>src
	rgt : * char = *<**char>dst
	if off				; no offset
	   lft += off if st_len (lft) ge off
	   lft = "" otherwise		;
	   rgt += off if st_len (rgt) ge off
	.. rgt = "" otherwise		;
	cmp = st_cmp (lft, rgt)		; order one pair
	reply (quFdwn) ? -cmp ?? cmp	; handle descending sort
  end

code	su_srt - init compare

  func	su_srt
	ctx : * cuTctx
  is	nam : * char = ctx->P2
fine
	if *nam eq			;
	.. cu_err ("E-No new file path", <>);
	if *st_lst (nam) ne '\\'	; needs directory \
	.. st_app ("\\", nam) 		; shove it in
	fine
  end
code	kw_edt - edit file

	cu_dtb : (*char, *char)		; detab
;	cu_etb : (*char, *char)		; entab
;	cu_upr : (*char, *char)		; upper 
;	cu_lwr : (*char, *char)		; lower
;	cu_lft : (*char, *char)		; slide left
;
;	kETB	convert spaces to tabs
;	kDTB	convert tabs to spaces

;	Note, a line could be a paragraph.
;	Which makes it kind of difficult to work out the tabs.
;	So, we assume that any line with a tab is a short line.

	mxPAR := 1000			; max paragraph

  func	kw_edt
	ctx : * cuTctx
  is	ipt : * char = me_acc (mxPAR)
	opt : * char = me_acc (mxPAR)
	src : * FILE			;
	dst : * FILE			;

	if st_sam (ctx->Pspc, ctx->Ptar)	; DOS goes crazy here
	.. cu_err ("E-Can't copy file to self: %s", ctx->Pobj)
						;
	fail if (src = cu_src (ctx)) eq		; no source file
	fail if !cu_rpl (ctx)			; don't replace file
	fail if !cu_opr (ctx)			; no go
	fail if (dst = cu_tar (ctx)) eq		; no target file


	if !quFqui && !ctx->Vcnt	; counted afterwards
	.. cu_tit (ctx)			; title it
	fail if quFque && !cu_opr (ctx)	; only for query mode
					;
	repeat				;
	   fi_get (src,ipt,mxPAR)	;	
	   quit if EOF			;
	   cu_dtb (ipt, opt) if quFdtb	;
	   fi_put (dst, opt)		;
	end				;
	fine
  end

code	cu_dtb -- detab function

  func	cu_dtb
	src : * char
	dst : * char
  is	pos : int = 0
     while *src
	quit *dst++ = '~' if pos ge (mxPAR-7)
	if *src ne '\t'
	.. next ++pos, *dst++ = *src++
	++src
	++pos, *dst++ = ' '
	++pos, *dst++ = ' ' while pos & 7
     end
	*dst = 0
  end


code	su_edt - init edit

  func	su_edt
	ctx : * cuTctx
  is	nam : * char = ctx->P2
	if *nam eq			;
	.. cu_err ("E-No new file path", <>);
					;
;	if st_fnd ("*.*", nam)		; thats o.k.
;	elif st_fnd ("*", nam)		; wrong
;	|| st_fnd ("?", nam)		;
;	|| st_fnd (".", nam)		;
;	.. cu_err ("E-Invalid destination [%s]", nam)
;	st_rep ("*.*", "", nam)		; thats o.k.
;	if *st_lst (nam) ne '\\'	; needs directory \
;	.. st_app ("\\", nam) 		; shove it in
	++ctx->Vtar			; has target spec
	fine
  end
code	cu_kop - kopy files (handle)

;	Custom routine to set size of final file

  func	cu_kop
	src : * FILE			; source file 
	dst : * FILE			; desination file
	alc : long			; transfer size
	()  : int			; fine/fail
  is	tra : [1024] char		; emergency buffer
	buf : * char			;
	dlc : int = 0			; must deallocate
	len : long			; input file size
	rem : long			; remainder size
	siz : long			;
	cnt : long			;
	res : int = 1			; assume o.k.

	buf = tra, siz = 1024		; use emergency buffer	
					;
	len = fi_len(src)-fi_pos(src)	; get file size from position
	if alc				; got allocation
	   len = alc if alc lt len	; truncate it
	.. rem = alc - len		; remainder to fill in
      repeat				;
	cnt = (siz lt len) ? siz ?? len	; minimize it
	if !fi_drd (src, buf, <size>cnt); read it
	|| !fi_dwr (dst, buf, <size>cnt); write it
	.. quit res = 0			; some error
	quit if (len -= cnt) eq		;
      end				;
	me_clr (buf, 1024)		; a clear buffer
      repeat				;
	quit if !res			; previous failed
	cnt = (siz lt rem) ? siz ?? len	; minimize it
	quit if !cnt			; some error
	if !fi_dwr (dst, buf, <size>cnt); write it
	.. quit res = 0			; some error
	quit if (rem -= cnt) eq		;
      end				;
	fail if fi_err (src, <>)	; check errors
	fail if fi_err (dst, <>)	;
	reply res			; status
  end
end file
code	cu_res - assemble result spec
include	rid:fsdef

;	copy P1 P2

  func	cu_res
	ctx : * cuTctx
	ent : * drTent			; directory entry
  is	fs_res (ctx->P1, ctx->P2, ent->Pnam, res, 0)
  end
end file
file	uscnt
include	usb:usmod

code	cu_ren - rename file

  type	cuTren
  is	Arep : [mxLIN] char
	Adir : [mxSPC] char
	Anam : [14] char
	Atyp : [3] char
  end

	cuPsch : * char = <>
	cu_fnd	: (*char, *char) *char own

  proc	cu_ren
	fil : * FILE
	spc : * char
	siz : long
  is	ren : cuTren
	src : [mxSPC] char
	dst : [mxSPC] char
	str : * char
	cnt : int = 0
	iu_ren (&ren) if cuVfst
	str = cuPsch

	if !st_fnd ("?", str)		; no wildcards
	   repeat			;
	      quit if fi_get (fil, lin, mxLIN*2) eq EOF
	      if st_fnd (str, lin) ne	; found it
	      .. ++cnt			; got another
	   forever			;
	else				; got wildcards
	   repeat			;
	      quit if fi_get (fil, lin, mxLIN*2) eq EOF
	      if cu_fnd (str, lin) ne	; found it
	      .. ++cnt			; got another
	   forever			;
	end				;
	++ctx->Vmat if cnt		; matched this one
	exit if !cnt && !quFall		; not seen & not all
	exit if quFtot			; counts only
	PUT("%-14s %d\n", ctx->Pnam, cnt) 
  end

	cuSren : fnTfnb = {0}

code	iu_ren - init rename

  func	iu_sch
 	ren : * cuArep
  is	rep : * char = ren->Arep
	str : * char
	lst : * char
	cur : fnTfnb
	rep : fnTfnb
	def : fnTfnb
	if *cuPp2 eq	
	   cu_err ("E-No replacement name", <>)
	st_cop (cuPp2, rep)		; get the string
	st_trm (rep)			; trim it

	fn_par (&cur, cuPp1)		;
	fn_par (&rep, cuPp2)		;
	fn_par (&def, "*.*")		; setup defaults
	fn_mrg (&rep, &def, &rep)	; merge them
	if st_cmp (cur.Adev, rep.Adev)	; different devices
	.. cu_err ("E-Rename across devices", <>)
	if st_cmp (cur.Adir, rep.Adir)	; different directories
	   if !cu_avl (rep.Aspc)	; 
	   .. cu_err ("Invalid destination path [%s]", rep.Aspc)
	   if !(rep.Vwld & (fnNAM_|fnTYP_)) ; not wild
	   && dir->Vtot ge 2		; multiple to one
	.. .. cu_err ("Renaming many to one [%s]", rep.Aspc)
	*cuPren = rep			; setup replacement block

	cuVfst = 0
 	fine if quFbar			; bare listing
	PUT("Rename [%s] to [%s]\n", 	;
	   cuPdir->Pdir, cuPsch)
 end
