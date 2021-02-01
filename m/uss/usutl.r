file	usutl - utilities
include	usb:usmod

code	cu_tit - write title

  proc	cu_tit
	ctx : * cuTctx
  is	PUT("%s [%s]", ctx->Pcmd, ctx->Ppth)
	if ctx->Pjoi
	.. PUT(" %s [%s]", ctx->Pjoi, ctx->P2)
	cu_new ()
  end

code	cu_opr - report operation

  func	cu_opr
	ctx : * cuTctx
  is	buf : [128] char
      repeat
	fine if quFqui && !quFque	; bare & noquery
	PUT(ctx->Phdr)			; the header
	fine cu_new () if !quFque	; just reporting
	cl_cmd ("? ", buf)		; ask them
	cu_abt ()			;
	st_trm (buf)			; dump spaces
	next if buf[0] eq		; nothing
	st_upr (buf)			;
	case buf[0]			;
	of 'A' fine quFque = 0		; all
	of 'J'				; ja
	or 'Y' fine			; yes
	of 'N' fail			; no
	of 'Q' fail ctx->Vqui = 1	; all over
	of other			;
	   PUT("Reply: Yes No All Quit"), NL
	end case			;
      end
  end

code	cu_que - query single operation

  func	cu_que	
	ctx : * cuTctx
	pth : * char
  is	buf : [128] char
	fine if quFqui && !quFque	; bare & noquery
	fine if quFnqr			; /noquery
	FMT(buf, "%s [%s]? ", ctx->Pcmd, pth)
	reply cu_ask (ctx, buf, <>)
  end

code	cu_ask - ask question

  func	cu_ask
	ctx : * cuTctx
	msg : * char
	obj : * char
  is	prm : [128] char
	buf : [128] char
	FMT(prm, msg, obj)		; make the prompt
      repeat
	cu_abt ()			;
	cl_cmd (prm, buf)		; ask them
	st_trm (buf)			; dump spaces
;	next if buf[0] eq		; nothing
	st_upr (buf)			;
	case buf[0]			;
	or 'Y' fine			; yes
	of 'N' fail			; no
	of 'Q' fail ctx->Vqui = 1	; all over
	of other			;
	   PUT("Reply: Yes,No,Quit"), NL
	end case			;
      end
  end

code	cu_siz - return size as text

  proc	cu_siz
	siz : long
	txt : * char
  is	FMT(txt, "%ld", siz)		; size of it
  end

code	cu_new - a newline

  proc	cu_new
  is	PUT("\n")
	++quVlin
	if quVlin ge 24			; enough
	   cl_cmd ("More? ", <>) if quFpau
	   quVlin = 0
	end
  end
code	cu_dts - make date string

  init	cuAmon : [] * char
  is	"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
	"Sep", "Oct", "Nov", "Dec", "Bad", "Bad", "Bad", "Bad"
  end

  func	cu_dts
	tim : * tiTval
	str : * char
	()  : * char
  is	plx : tiTplx
	ti_plx (tim, &plx)
	FMT(str, "%02d-%03s-%04d",	; date
	   plx.Vday,			; day
	   cuAmon[plx.Vmon],		; month
	   plx.Vyea)
	reply str + that		;
  end

code	cu_tms - make time string

  func	cu_tms
	tim : * tiTval
	str : * char
	()  : * char
  is	plx : tiTplx
	ti_plx (tim, &plx)
	FMT(str, "%02d:%02d:%02d",	; time
	   plx.Vhou,			; hour
	   plx.Vmin,			; minute
	   plx.Vsec)			; second
	reply str + that		;
  end

code	cu_tot - display totals

  proc	cu_tot
	ctx : * cuTctx
  is	txt : [mxIDT] char
	tot : LONG = ctx->Vtot
	cnt : int = ctx->Vcnt
	siz : drTsiz

	if !quFany && cnt eq		; no such file
	.. PUT("No such file %s", ctx->Ppth), NL
	exit if quFbar 			; nothing else for bare

	if quFlst			; listing
	   if cnt			; got some
	      PUT("%d files, ", cnt)	;
	      cu_siz (tot, txt)		;
	   .. PUT("%sk", txt)		; total
	   if quFfre			; want free space too
	      PUT(", ") if cnt		; had previous field
	      dr_fre (ctx->Ppth, &siz)	; get free space
	      cu_siz (siz / 1024L, txt)	;
	   .. PUT("%sk free", txt)	; total
	.. NL				;
					;
	if cnt && quFacc		; search, compare
	   PUT("%d files", cnt)		;
	   PUT(", %d matched", ctx->Vmat) if ctx->Vmat
	   PUT(", %d same", ctx->Vsam) if ctx->Vsam
	   PUT(", %d different", ctx->Vdif) if ctx->Vdif
	   PUT(", %d missing", ctx->Vmis) if ctx->Vmis
	   PUT(", %ld chars", ctx->Vcha) if ctx->Vcha
	   PUT(", %ld words", ctx->Vwrd) if ctx->Vwrd
	   PUT(", %ld lines", ctx->Vlin) if ctx->Vlin
	   PUT(", %ld pages", ctx->Vpag) if ctx->Vpag
	   NL
	end
  end
code	cu_rew - rewind output

  proc	cu_rew
	ctx : * cuTctx
  is	ctx->Popt = ctx->Pobf		; output buffer
	*that = 0			; terminate it
  end

code	cu_flu - flush buffer

  proc	cu_flu
	ctx : * cuTctx
  is	PUT("%s", ctx->Pobf)		; write it
	cu_rew (ctx)			; rewind it
  end

code	cu_typ - unformatted string output

  proc	cu_typ
	str : * char
  is	ctx : * cuTctx = cuPsrc
	ctx->Popt = st_cop (str, ctx->Popt)
  end

code	cu_opt - string to output buffer

  proc	cu_opt
	ctl : * char
	obj : * char
  is	ctx : * cuTctx = cuPsrc
	FMT(ctx->Popt, ctl, obj)	; make it
	ctx->Popt += that		; no problems
  end
code	cu_src - open source file

  func	cu_src
	ctx : * cuTctx
	()  : * FILE
  is	cu_opn (ctx->Ppth, ctx->Pnam, "rb", ctx->Pspc)
	reply ctx->Psrc = that
  end

code	cu_dst - open destination file

  func	cu_dst
	ctx : * cuTctx
	()  : * FILE
  is	if *st_lst (ctx->P2) ne '\\'	; make sure we have a directory
	.. st_app ("\\", ctx->P2)	;
	cu_opn (ctx->P2, ctx->Pnam, "rb", ctx->Ptar)
	reply ctx->Pdst = that
  end

code	cu_clo - close

  func	cu_clo
	ctx : * cuTctx
	fil : **FILE
	msg : * char
  is	sts : int = 1 
	sts = fi_clo (*fil, "") if *fil
	*fil = 0
	reply sts
  end

code	cu_tar - open target for writing

  func	cu_tar
	ctx : * cuTctx
	()  : * FILE
  is	if *st_lst (ctx->P2) ne '\\'	; make sure we have a directory
	.. st_app ("\\", ctx->P2)	;
	cu_opn (ctx->P2, ctx->Pnam, "wb", ctx->Ptar)
	reply ctx->Pdst = that
  end

code	cu_opn - open a file

	cuIfil : FILE = {0}
  func	cu_opn
	pth : * char			; the directory
	nam : * char			; file name part
	mod : * char			;
	spc : * char			; result name
	()  : * FILE			;
  is	cu_spc (pth, nam, spc)		; get the filespec
	reply &cuIfil if quFren		;
	(quFlst) ? <> ?? ""		; list has no message
	reply fi_opn (spc, mod, that)	; open the file
  end

code	cu_cln - cleanup files

  func	cu_cln
	ctx : * cuTctx
  is	fil : * FILE			;
	sta : int = 1			;
	sta = cu_clo (ctx,&ctx->Psrc,""); close source
	sta&= cu_clo (ctx,&ctx->Pdst,""); close destination
	reply sta			; status
  end

code	cu_wld - check wildcards

  proc	cu_wld
	ctx : * cuTctx
	per : int			; wildcards permitted
  is	if st_fnd ("*", ctx->P1)	;
	|| st_fnd ("?", ctx->P1)	;
	|| !st_fnd (".", ctx->P1)	; no type defaults to wild
	|| *ctx->P1 eq '.'		; no name
	|| st_fnd (":.", ctx->P1)	;
	|| st_fnd ("\\.", ctx->P1)	;
	   cu_err (E_InvWld, ctx->P1) if !per
	.. quFque = 1			; force query
  end

code	cu_rpl - check /replace & /noreplace

  func	cu_rpl
	ctx : * cuTctx
  is	tar : * char = ctx->Ptar	;
	if quFrep			; replace only
	   fine if fi_exs (tar, <>)	; exists
	   fail if quFqui		; quiet
	   fail im_rep ("I-File missing [%s]", tar)
	elif quFnrp			; noreplace only
	   fine if fi_mis (tar, <>)	; missing
	   fail if quFqui		; quiet
	.. fail im_rep ("I-File exists [%s]", tar)
	fine
  end

code	cu_err - report error

  proc	cu_err
	msg : * char
	str : * char
  is	im_rep (msg, str)
	im_exi ()
  end
end file
code	cu_opt - parse output spec

	copy/rename etc

  proc	cu_opt
	ctx : * cuTctx
	flg : int			;
  is	spc : [mxSPC] char		;
	if st_fnd ("*", spc)		; *
	|| st_fnd ("?", spc)		; ?
	.. ++wld			; is wildcard spec

	cla = fn_cla (ctx->P2, "*.*")	; categorise output spec
	case cla			;
	of fnDEV			; got a device
	of fnDIR			; a directory
	of fnSPC			; full spec
	of fnWLD			; wildcard spec
	end case			;
  end
