file	usscn - scan files
include	usb:usmod

code	cu_scn - scan directory

	cu_txt : (*cuTctx) void own
  proc	cu_scn
	ctx : * cuTctx
  is	dir : * drTdir 			;
	ent : * drTent			;
	pth : * char			; current directory path
	spc : * char = ctx->Pspc	;
	atr : int = quVatr		;
	srt : int = quVsrt		;
	col : int = 0			; column
	mor : int = 1			; (header first)
					;
	if !quVcol			;
	   quVcol = 6			; default wide
	   quVcol = 4   if quFsiz	; want sizes
	   quVcol = 2   if quFdat	; want dates
	   --quVcol 	if quFimg	; image type
	.. quVcol = 1   if quFtim	; want time
	if quFlst			; doing a listing
	   atr = drALL_ if !atr		;
	.. srt = drTYP  if !srt && quVcol ge 4
	ctx->Vatr = atr			;
	ctx->Vsrt = srt			;
	exit if !us_scn (ctx)		; scan it

	dir = ctx->Pdir			; get the directory

	PUT("%s\n", ctx->Ppth) if quFlst; display directory path
     while (ent = us_nxt (ctx)) ne 	; got another
	if quFlst			;
	   next if !kw_lst (ctx)	;
	   if ++col ge quVcol		;
	      cu_new (), col = 0	; next line
	   .. exit if !cl_mor (&mor)	;
	else				;
	   next if ent->Vatr & drDIR_	; ignore directories
	   cu_txt (ctx)
	   (*ctx->Pfun)(ctx)		; call the function
	.. exit if ctx->Vqui		; quit time
	cu_cln (ctx)			; cleanup files
	ctx->Vcnt += 1			; another file
	ctx->Vtot += ctx->Vsiz		; more size
     end				; all files done
	cu_new () if col ne		; listing ended midline
	cu_tot (ctx)			; show totals
	dr_dlc (dir)			; deallocate storage
  end

code	cu_don - scan done -- deallocate directory

  proc	cu_don
	dir : * drTdir
  is	dr_dlc (dir)
  end

code	cu_avl - check directory available

  func	cu_avl
	pth : * char
  is	reply dr_avl (pth)
  end

code	cu_spc - get full spec

  func	cu_spc
	pth : * char
	nam : * char
	spc : * char
	()  : * char
  is	reply dr_spc (pth, nam, spc)
  end

code	cu_txt - setup text objects for operation

  proc	cu_txt
	ctx : * cuTctx
  is	spc : * char = ctx->Pspc
	tar : * char = ctx->Ptar
	dst : * char = ctx->Phdr	; header
	dst = st_cop (ctx->Pcmd, dst)	; the command
	*ctx->Phdr = ch_upr (*ctx->Phdr); uppercase the first letter
	*dst++ = ' '			;
	ctx->Pobj = dst			; object
	st_trm (spc)			; dump trailing spaces
	dst = st_cop (spc, dst)		; primary
	if ctx->Vtar			; has target spec
	.. dr_spc (ctx->P2, ctx->Pnam, tar) ; 
;	.. dst = st_cop (tar, dst)	;
	if ctx->Pjoi			;
	   dst += FMT(dst, " %s ", ctx->Pjoi)
	   (tar && *tar) ? tar ?? ctx->P2 ; target
	.. st_cop (that, dst)		;
  end
code	us_scn - scan directory

  func	us_scn
	ctx : * cuTctx
  is	dir : * drTdir 			;
	pth : * char			; current directory path
	atr : int = ctx->Vatr		;
	srt : int = ctx->Vsrt		;
	ti_clk (&ctx->Itim)		; current time
	ti_msk (&ctx->Itim, &ctx->Idat, tiDAT_) ; mask to date only
					;
	atr = drNOR_    if !atr		; remainder
	srt = drNAM     if !srt		;
	srt |= drREV_   if quFrev	; reverse sort
	ctx->Vatr = atr			;
	ctx->Vsrt = srt			;
					;
	dr_scn (ctx->P1, atr, srt)	; scan directory
	ctx->Pdir = dir = that		; the directory 
	fail cu_err ("E-File not found [%s]", ctx->P1) if fail
	st_cop (dir->Ppth, ctx->Ppth)	; get the path
;;;	ctx->Ppth = dir->Ppth		; the directory path
	st_upr (that)			; uppercase for title
  end
					;
code	us_nxt - get next directory entry

  func	us_nxt 
	ctx : * cuTctx
	()  : * drTent
  is	dir : * drTdir = ctx->Pdir	;
	ent : * drTent			;
	atr : int = ctx->Vatr		;
      repeat				;
	cu_abt ()			; check aborts
	ent = dr_nxt (dir)	 	; got another
	pass null			; are no more
					;
;	if ent->Vdat lt ctx->Vdat	; not todays file 
	if ti_cmp (&ent->Itim, &ctx->Idat) lt
	   next if quFnew		; new files only
	else				;
	.. next if quFold		; old files only
					;
	if ent->Vsiz lt 65537L		; not big
	   next if quFbig		; big only
	else				;
	.. next if quFsma		; small files only
					;
	ctx->Pent = ent			; save that
	ctx->Pnam = ent->Pnam		;
	 (ent->Vsiz+1023L) / 1024L	; kilobyte size
	ctx->Vsiz = that		;
					;
	if atr ne			; specific attributes
	&& atr ne drALL_		; and not all
	&& (atr & ent->Vatr) eq		; and this not ours
	.. next				; find another
					;
	if !quFall && !quFdir		; not all and directories
	&& atr & drDIR_			; and is a directory
	   next if st_sam (ent->Pnam, ".."); skip these
	.. next if st_sam (ent->Pnam, ".")
					;
	dr_spc (ctx->Ppth, ent->Pnam, ctx->Pspc) ; setup file spec
	reply ent			;
     forever				;
  end
