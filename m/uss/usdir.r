file	usdir - directory operations
include	usb:usmod
include	rid:dsdef

	cu_dsp : (*cuTctx, *char, *char)
 
code	kw_chg - change directory

  func	kw_chg
	ctx : * cuTctx
  is	dir : * char = ctx->P1	
	buf : [mxLIN] char
	dep : int = 0
	rep : int = 0
	cnt : int
	aut : int = 0
	reply kw_sho (ctx) if !*dir	; really a show
	while dep lt 4			; got more depth
	   cu_abt ()			;
	   buf[0] = 0			;
	   while cnt in 1..dep		; got more
	      ++rep			;
	   .. st_app ("..\\", buf)	; back a directory
	   st_app (dir, buf)		; add the directory
	   if dr_set (buf, 0)		;
	       kw_sho (ctx) if rep	;
	   .. fine			;
	   ++dep			;
	end
	fail
  end

code	kw_sho - show default directory

  func	kw_sho
	ctx : * cuTctx
  is	dir : [mxSPC] char
	drv : int
	dr_sho (dir, drPTH)		; current path
	st_upr (dir)
	PUT("%s\n", dir)		; display it
  end

code	kw_mak - make directory

  func	kw_mak
	ctx : * cuTctx
  is	dir : * char = ctx->P1
	buf : [128] char
	cu_dsp (ctx, ctx->P1, buf)

;	st_cop (dir, buf)
;	if *st_lst (buf) ne '\\'
;	.. st_app ("\\", buf)
;	if dr_avl (buf)
;	.. fail im_rep ("E-Directory already exists [%s]", dir)
	fi_loc (buf, buf)
	fine if !cu_que (ctx, buf)
	fine if dr_mak (buf)
	im_rep ("E-Error making directory [%s]", buf)
	fail
  end

code	kw_rem - remove directory

  func	kw_rem
	ctx : * cuTctx
  is	buf : [128] char
	dir : * char = ctx->P1
	cu_dsp (ctx, ctx->P1, buf)

	if !dr_avl (buf)
	.. fail im_rep ("E-No such directory [%s]", buf)
	st_upr (buf)
	fine if !cu_ask (ctx, "Remove directory [%s]? ", buf)
	fine if dr_rem (buf)
	im_rep ("E-Error removing directory [%s]", buf)
	fail
  end

code	kw_trd - show directory tree

  func	kw_trd
	ctx : * cuTctx
  is	
  end

code	cu_dsp - construct directory specification

  func	cu_dsp
	ctx : * cuTctx
	dir : * char
	buf : * char
  is	*buf = 0

	if !st_fnd (":", dir)
	   dr_sho (buf, drPTH)
	   if *dir ne '\\'
	   && *st_lst(buf) ne '\\'
	.. .. st_app ("\\", buf)

	st_app (dir, buf)
	if *st_lst (buf) ne '\\'
	.. st_app ("\\", buf)
	st_upr (buf)
  end
