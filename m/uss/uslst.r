;???;	USLST - listings have "2:50: 6" space
file	uslst - list/directory
include	usb:usmod
include	rid:iminf

code	kw_lst - list directory

	cu_det	: (*cuTctx) void
	cu_use	: (*cuTctx) void
	cu_img	: (*cuTctx) void

  func	kw_lst
	ctx : * cuTctx
  is	ent : * drTent = ctx->Pent	; directory entry
	txt : [mxLIN] char		; output buffer
	nam : * char = ent->Pnam	; the filename
	atr : int = ent->Vatr		; this files attributes

	cu_rew (ctx)			; rewind buffer
	if atr & drDIR_			; is a directory
	   fail if !(ctx->Vatr & drDIR_); dont want them anyway
	   if quFbar			; bare
	      OPT("\\%s", nam)		;
	   else				;
	      OPT("\\%-12s", nam)	; the name
	      if !quFwid && quFsiz	; wants sizes
	   .. .. OPT("     ", <>)	; account for it
	else				;
	   if quFbar			; bare
	      OPT("%s", nam)		;
	   else				;
	      OPT("%-12s", nam)		; the name
	      if !quFwid && quFsiz	; wants sizes
	         cu_siz (ctx->Vsiz, txt); get normal size
	.. .. .. OPT(" %4s  ", txt)	; display the size
					;
	if quFbar			;
	   if quFful || quFdat || quFtim;
	   || quFpee || quFtit		;
	.. .. OPT (" ", <>)		; bare listing with details
	if quFdat || quFtim || quFful	; wants the date
	   cu_dts (&ent->Itim, txt)	; get the date
	.. OPT("%s  ", txt)		; write it
	if quFtim || quFful		; wants the time
	   cu_tms (&ent->Itim, txt)	; get the time
	.. OPT("%s  ", txt)		; write it
					;
	if quFpee || quFtit		; details
	   cu_det (ctx)			;
	elif quFuse
	   cu_use (ctx)
	elif quFimg
	   cu_img (ctx)
	elif quFful			; full information
	   APP("Dir ") if atr & drDIR_	;
	   APP("Hid ") if atr & drHID_	;
	   APP("Sys ") if atr & drSYS_	;
	   APP("Arc ") if atr & drARC_	;
	   APP("Ron ") if atr & drRON_	;
	   APP("Vol ") if atr & drVOL_	;
	   APP("Dev ") if atr & drPER_	; peripheral
	.. APP("Shr ") if atr & drSHR_	; shareable
	cu_flu (ctx)			; flush the buffer
	fine				;
  end
code	cu_det - details

	cu_anl	: (*char, *char, int) int own
  proc	cu_det
	ctx : * cuTctx
  is	ent : * drTent = ctx->Pent	; directory entry
	fil : * FILE			; the file
	ipt : [mxLIN*3] char		; short buffer
	opt : [mxLIN*3] char		;
	src : * char = ipt		;
	dst : * char = ctx->Popt	;
	len : int = st_len (ctx->Pobf)+2;
	cnt : int
	*dst++ = ' '			; separator
     repeat
	quit APP("Directory")    if ent->Vatr & drDIR_
	quit APP("Volume label") if ent->Vatr & drVOL_
	quit APP("Hidden file")  if ent->Vatr & drHID_
	quit APP("Inaccessible") if (fil = cu_src (ctx)) eq
	quit APP("Empty") 	 if (cnt = fi_ipt (fil, ipt, 128)) eq
	quit APP("Binary") if !cu_anl (ipt, opt, cnt) && !(quFful|quFhex)
	st_cln (opt, dst, 80-len)
     never
  end

code	cu_anl - analyse file

  func	cu_anl
	ipt : * char			; 128 bytes
	opt : * char			;
	cnt : int			; maximum
  is	dum : [mxLIN*3] char		; dummy buffer
	src : * char = ipt		;
	dst : * char = opt		;
	prn : int = 0			; printing
	spc : int = 0			; spaces
	bin : int = 0			; binary
	lst : int = -4			;
	wid : int = cnt
	cha : int			;
	*opt = 0			; terminate that 
	if quFhex			; wants hex dump
	   wid = (cnt lt 16) ? cnt ?? 16;
	   while wid--			;
	      FMT(dst, "%-2X ", *src & 0xff)	;
	   .. dst += 3, ++src		;
	.. src = ipt, dst = dum		; use dummy buffer for rest
					;
	while cnt--			; got more
	   cha = *src++ & 255		;
	   if cha ge 32 && cha ne 127	;
	   && cha lt 255		;
	      ++prn			;
	      if cha ne ' ' || cha ne lst; reduce spaces
	      .. *dst++ = cha		;
	   elif cha eq '\r'		; ignore these
	     || cha eq '\n'		;
	      ++spc, cha = -3		; a space
	      next if lst eq cha	; two in a row
	      *dst++ = 0  if quFtit	; just want first line
	      *dst++ = '|' otherwise	;
	   elif cha ge 9		;
	   && cha le 13			;
	      ++spc, cha = -2		;
	      *dst++ = ' ' if lst ne cha; spaces
	   else				;
	      ++bin, cha = -1		; binary
	   .. *dst++ = '~' if lst ne cha;
	   lst = cha			;
	end				;
	*dst = 0			;
	fine if bin eq			; no binary
	reply prn gt ((bin*2) + spc)	; check binary
  end
code	cu_use - usage

;	/desc
;	/usage
;	/company
;	/product

  proc	cu_use
	ctx : * cuTctx
  is	ent : * drTent = ctx->Pent
	img : * imTinf = &ctx->Iimg
	buf : [mxLIN*2] char
	loc : [mxLIN*2] char
	dsc : * char = loc 
	sta : int
	col : int = st_len (ctx->Pobf)	; left column
	rem : int = 79-col
	top : * char
	cnt : int 
	exit if ent->Vatr & drDIR_

	exit if !im_dsc (img, ctx->Pspc, &sta)
	FMT(dsc, "%s (%s)", img->Adsc, img->Aidt)
	while st_len (dsc) gt rem
	   top = dsc+rem-4
	   while top gt dsc
	      quit if *top eq ' '
	      --top
	   end
	   if (cnt = top-dsc) ne 
	      st_cln (dsc, buf, cnt)
	      cu_opt ("%s", buf)
 	      cu_flu (ctx)
	      NL
	      dsc += cnt
	      ++dsc if *dsc eq ' '
	   else
	   .. quit
	   cnt = col
	   cu_opt (" ", "") while cnt--
	end
	cu_opt ("%s", dsc)
  end
code	cu_img - image format
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:nedef

  	img_rea : (*FILE, *void, nat, nat)

;	FFFF FFFF and .SYS
;	MZ .... FFFF FFFF and .SYS

  proc	cu_img
	ctx : * cuTctx
  is	ent : * drTent = ctx->Pent
	fil : * FILE
	buf : [512] char
	ptr : * char = buf
	dos : * mzThdr = <*void>buf
	cof : * neThdr = <*void>buf
	bas : nat
	off : nat
	val : int
	sig : nat
	mag : WORD = 0
	def : * char = "        "
	exit cu_typ (def) if ent->Vatr & drDIR_
	def = "COM?    " if st_fnd (".com", ent->Pnam)
	def = "SYS?    " if st_fnd (".sys", ent->Pnam) 

      repeat
	fil = cu_src (ctx)
	quit cu_typ ("Open?   ") if fail
	quit cu_typ (def) if fi_len (fil) le mzDOS

	img_rea (fil, dos, 0, mzDOS)
	quit cu_typ ("Read?   ") if fail

	if (buf[0] ne 'M') || (buf[1] ne 'Z')
	   def = "        "
 	   if st_fnd (".sys", ent->Pnam)
	      sig = *<*long>ptr
	      if (sig eq 0xffffffff) || !(sig & 0xffff0000)
	      .. def = "ComSYS  "
	   elif st_fnd (".com", ent->Pnam)
	   .. def = "COM     "
	.. quit cu_typ (def)
	def = "DosSYS  " if st_fnd (".sys", ent->Pnam)
	def = "DOS     " otherwise

	img_rea (fil, dos, 0, mzWIN)		; Read the long version
	quit cu_typ (def) if fail		; to get Vhdr offset

	img_rea (fil, buf, dos->Vhdr, 2)	; just get a signature
	quit cu_typ (def) if fail
	mag = *<*WORD>buf
	if (buf[0] eq 'N') && (buf[1] eq 'E')
	   img_rea (fil, buf, dos->Vhdr, #neThdr)
;	   fi_rea (fil, buf+2, #neThdr-2)
	   quit cu_typ ("Win16?  ") if fail
	   quit cu_typ ("Win16p  ") if cof->Vctl & nePRO_
	   quit cu_typ ("Win16p  ") if cof->Vflg & nePRT_
	   quit cu_typ ("Win16   ")
	elif (buf[0] eq 'L') && (buf[1] eq 'E')
	   cu_typ ("VxD     ")
	elif (buf[0] eq 'L') && (buf[1] eq 'X')
	   cu_typ ("OS/2    ")
	elif (buf[0] eq 'P') && (buf[1] eq 'E')
	   cu_typ ("Win32   ")
	elif (buf[0] eq 'W') && (buf[1] eq '3')
	   cu_typ ("VxD/W3  ")
	elif (buf[0] eq 'W') && (buf[1] eq '4')
	   cu_typ ("VxD/W4  ")
	elif (buf[0] eq 'S') && (buf[1] eq 'Z')
	   cu_typ ("Compres ")
	else
	.. cu_typ (def)
     never
	exit if !quFful
	FMT(buf, "(%04X) ", mag)
	cu_typ (buf)
  end

code	img_rea - read from file

  func	img_rea
	fil : * FILE
	buf : * void
	pos : nat
	cnt : nat
  is	fi_see (fil, pos) if pos ne (~0)
	fi_rea (fil, buf, cnt)
	reply that
  end
