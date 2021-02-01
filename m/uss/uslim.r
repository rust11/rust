end file
code	cu_txt - extract text

  proc	cu_txt
	qua : * char
	fld : ** char
	txt : * char
	lim : int
  is	str : * char = *fld		;
	if *str++ ne '='		; missing =
	|| !ct_aln (*str)		; no digit
	.. cu_err (E_InvVal, qua)	; no value
	while ct_aln (*str)		;
	   *txt++ = *str++		;
	end				;
	*txt = 0, txt[lim] = 0		; limit it 
	*fld = str			;
  end
code	kw_dif - list text file differences
end file
limbo

;	quFall		reports all files (including missing)
;	quFful		details different, shorter, longer
;	quFbar		lists only different files
;	quFtot		lists only totals
;
;
;	Resync on two lines same
;
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
		 PUT("[%s]\n", old)	;
	         PUT("[%s]\n", new)	;
	      .. quit			;
	      quit if lft eq EOF	; done
	   forever			;
	.. fi_clo (dst, "")		; close that
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
	PUT("%-14s %s\n", ctx->Pnam, msg)
  end
data	types

  type	dfTlin
  is	Psuc : * usTlin
	Vcnt : int			; size of line
	Plin : * char			; the data
  end

  type	dfTsec
  is	Pnam : * char			; the filename
	Pfil : * FILE			; the file
	Veof : int			; seen EOF
	Vcnt : int			; number of lines
	Pfst : * usTlin			; first in file
	Plst : * usTlin			; last in file
	Pbeg : * usTlin			; beginning of section
	Pend : * usTlin			; end of section
  end

  type	dfTctx
  is	Psrc : * char			; left filename
	Pdst : * char			;
	Plft : * dfTsec			;
	Prgt : * dfTsec			; right file
	Vdif : int			; difference count
	Slft : usTsec			; left section
	Srgt : usTsec			; right section
  end

code	df_alc - allocate difference block

  func	df_alc
	()  : * dfTctx
  is	ctx = me_alc (#dfTctx)		;
	ctx->Plft = &ctx->Slft		; init pointers
	ctx->Prgt = &ctx->Srgt		;
	reply ctx
  end

code	df_beg - go

  func	df_beg
	ctx : * dfTctx
	src : * FILE
	dst : * FILE
  is	lft : * dfTsec = ctx->Plft
	rgt : * dfTsec = ctx->Prgt
