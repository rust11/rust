file	uskwd - delete/truncate/create/attr/touch
include	usb:usmod
code	kw_del - delete file

  func	kw_del
	ctx : * cuTctx
  is	fail if !cu_opr (ctx)		; asketh
	fi_del (ctx->Pspc, "")		; delete it
	quFque = 1 if !that		; some error
	fine				;
  end

code	kw_tru - truncate file

  func	kw_tru
	ctx : * cuTctx
  is	fil : * FILE
	fail if !cu_opr (ctx)		; asketh
	fil = fi_opn (ctx->Pspc, "wb", "")
	fi_clo (fil, "") if fil		;
	fine				;
  end

code	su_cre - create a file (preprocessor operation)

  func	su_cre
	ctx : * cuTctx
  is	fil : * FILE
	fail if !fi_mis (ctx->P1, "")	; already exists
	fail if !cu_opr (ctx)		; asketh
	fil = fi_opn (ctx->P1, "wb", ""); attempt create
	fi_clo (fil, "") if fil		; close it
	fail				; done
  end

code	kw_atr - alter file attributes

  func	kw_atr
	ctx : * cuTctx
  is	fail if !cu_opr (ctx)		; whoopie
	fi_sat (ctx->Pspc, quVcat, quVsat, "") ; alter attributes
	fine				;
  end

code	kw_tou - touch file

  func	kw_tou
	ctx : * cuTctx
  is	fail if !cu_opr (ctx)		; check it
;	PUT("%s\n", spc) if quFver	; want verify
	fi_stm (ctx->Pspc, &ctx->Itim, "") ; set date & time
  end
code	kw_zap - zap directory

  func	kw_zap
	ctx : * cuTctx
  is	fail if quFque && !cu_opr (ctx)	; asketh
;	fi_unp (ctx->Pspc, "")		; unprotect it first
	fi_del (ctx->Pspc, "")		; delete it
	quFque = 1 if !that		; some error
	fine				;
  end

code	su_zap - setup for zap

	_suZAP := "Delete all files and directory [%s]? "
  func	su_zap
	ctx : * cuTctx
  is	pth : * char = ctx->P1		; the path
	fail if !cu_ask (ctx,_suZAP,pth); must be sure
  end

code	pu_zap - post process zap

  func	pu_zap
	ctx : * cuTctx
  is	cur : [mxSPC] char
	pth : * char = ctx->P1 ;ctx->Pdir->Apth	; directory path
	dir : * char = pth		;
	st_upr (pth)			; normalize it
	if *dir && dir[1] eq ':'	; has device
	.. dir += 2			;
					;
      repeat				;
	fail if !cu_ask (ctx, "Remove directory [%s]? ", pth)
;	quit if !ds_GtCDir (dir, cur)	; get current directory
	quit if !dr_sho (cur, drPTH)	; get current directory
	if st_sam (cur, dir)		; same directory
;	.. quit if !ds_ChgDir ("..")	; up a directory
	.. dr_set ("..", 0)		; go up one
;	quit if !ds_RemDir (pth)	;
	quit if !dr_rem (pth)		;
	fine				;
      end				;
	cu_err ("E-Error removing directory [%s]", pth)
  end
