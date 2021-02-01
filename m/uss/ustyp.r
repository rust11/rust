file	ustyp - type/print/see/dump
include	usb:usmod

code	kw_typ - type file

	_eof	:= 26			; ctrl/z

  func	kw_typ
	ctx : * cuTctx
  is	fil : * FILE
	ter : * char			;
	cnt : int = 0			;
	cha : int			;
	mor : int = 0
	fail if (fil = cu_src (ctx)) eq	; open source
	fail if !cu_opr (ctx)		; check it
					;
	repeat				;
	   cu_abt ()			; check aborts
	   cha = fgetc (fil)		; read next
	   quit if cha eq EOF		; all over
	   quit if cha eq _eof		; eof character
	   NL, ++cnt if cha eq '\n'	;
	   PUT ("%c", cha) otherwise	; write it
	   quit if cnt gt 3 && quFvie	; just reviewing
	   quit cl_mor (&mor) if cha eq '\n'
	forever				;
	NL if cha ne '\n'		;
  end
code	kw_prn - print file

	epApag : [] char = { 27, 'C', 70, 0 } ; 70 lines per page
	epAnor : [] char = { 27, '!',  1, 0 } ; normal elite
	epAdou : [] char = { 27, '!', 17, 0 } ; doublestrike elite

  func	kw_prn
	ctx : * cuTctx
  is	buf : [mxLIN*2] char		;
	lin : [mxLIN*2] char		; expansion buffer
	src : * FILE			;
	dst : * FILE			;
	str : * char			;
	ter : * char			;
	ipt : * char			;
	opt : * char			;
	lft : int = quVlft		;
	top : int = quVtop		;
	cnt : int = 0			;
	lim : int = (mxLIN*2)-lft-8-2	; output limit
	cha : int			;
	col : int			;
					;
	fail if (src = cu_src (ctx)) eq	; open source
	fail if !cu_opr (ctx)		; check it
	if *ctx->P2 eq			; default
	.. st_cop ("LPT1", ctx->P2)	; voila
	dst = fi_opn (ctx->P2, "w", "")	; open output
	fail if null			;
	ctx->Pdst = dst			; for cleanup
					;
	if quFeps			; want epson setup
	   quFeps = 0			; once only
	   str = epApag			;
	   fputc (*str++,dst) while *str; 70 lines per page
	   str = (quFdou) ? epAdou ?? epAnor
	.. fputc (*str++,dst) while *str; elite or elite/doublestrike
					;
	cnt = 0				;
	lin[cnt++] = ' ' while cnt lt lft; setup indent
					;
	top = quVtop			; indent first top
	repeat				;
	   cu_abt ()			; check aborts
	   fi_put (dst,"\n") while top--; indent top
	   top = 0			; yuk
	   fi_get (src, buf, mxLIN)	; read one
	   quit if eof			; all over
	   col=0, ipt=buf, opt=lin+lft	; format tabs
	   while col lt lim		; still got space
	   && (cha = *ipt++) ne		; still got input
	      if cha ne '\t'		; not a tab
	         *opt++ = cha, ++col	; one more
	      else			; got a tab
		 repeat			; fill 
	            *opt++ = ' '	; with spaces
	      .. until (++col & 7) eq	; until tabstop
	   end				;
	   *opt = 0			; terminate output
	   fi_put (dst, lin)		; write it
	end				;
  end
code	kw_see - see file

  func	kw_see
	ctx : * cuTctx
  is	buf : [mxLIN] char
	ptr : * char = buf
	opt : * char			;
	col : int = 0			;
	asc : int = 0			; in ascii
	aln : int = 0			;
	prn : int = 0			;
	lst : int = 0			; remove multiple spaces
	cha : int 			;
	sep : *char = "~"		; separator
	mor : int = 0
	ptr = buf			;
	fail if !cu_src (ctx)		; open source
	fail if !cu_opr (ctx)		; check it
	sep = "\n" if quFful		; want single lines
	repeat				;
	   cu_abt ()			; check aborts
	   cha = fgetc (ctx->Psrc)	; read next
	   quit if cha eq EOF		; all over
	   cha &= 255			;
	   cha = '„' if cha eq 0xe4
	   cha = '”' if cha eq 0xf6
	   cha = '' if cha eq 0xfc
	   opt = ""			; assume no output
;	   cha = ~(cha) if quFcom	; complemented
;	   cha &= 127 if quFmsk		; mask
	   if cha lt 31 || cha ge 128	;
	   && st_mem (cha, "„”Ž™šá") eq; german
	      opt = sep if prn		; we were printing
	      asc = 0, aln = 0		;
	      prn = 0, ptr = buf	; rewind it all
	   else				;
	      *ptr++ = cha, *ptr = 0	; save it
	      if ct_aln (cha)		; alphanumeric
	      || st_mem (cha, "„”Ž™šá"); german
	      .. ++aln 			; got an alpha
	      if ++asc ge 6		; not quite enough yet
	      || aln gt 3		;
	         opt = ptr = buf	; show it
	   .. .. asc=aln=prn=6		; paranoia
	   while *opt ne		; got more
	      if (cha eq '\n')
		 if col ge 2		;
		    fine if !cl_mor (&mor)
	         .. next col = 0
	      .. cha = '\\' 
	      cha = *opt++		; get it
	      if cha eq ' ' && cha eq lst
	      .. next			;
	      if col ge 79		; end of line
	      && quFful eq		; and not full
	         quit if !cl_mor (&mor)
 	      .. NL, col = 0		;
	      printf ("%c", cha)	;
	      ++col,  lst = cha		;
	   end				;
	forever				;
	cu_new () if col		; odd column
  end
code	kw_dmp - dump file

;filespec: block 12
; xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx  bbb  1234567812345678	
;-dddddd dddddd dddddd dddddd dddddd dddddd dddddd dddddd bbb  1234567812345678

;	/byte (D) /word /long
;	/hex (D) /octal /decimal

	usBYT := 1
	usWRD := 2
	usLNG := 4
	usOCT := 8
	usDEC := 10
	usHEX := 16

	DMP (fmt, obj) := str += sprintf (str, fmt, (obj))

  func	kw_dmp
	ctx : * cuTctx
  is	buf : [512] char		; the buffer
	lin : [134] char		; output line
	fil : * FILE			;
	ptr : * char			;
	str : * char			;
	top : * char			;
	blk : int = 0			;
	bls : int			;
	byt : int			;
	idx : int			;
	rem : int			; remainder
	cnt : int			;
	rad : int = usHEX
	wid : int = usBYT
	mor : int = 0
	rad = usOCT if quFoct
	rad = usDEC if quFdec
	wid = usWRD if quFwrd
	wid = usLNG if quFlng

	fail if (fil = cu_src (ctx)) eq	; open source file
	fail if !cu_opr (ctx)		; check it
	bls = (ctx->Pent->Vsiz + 511L) / 512L ; block size
					;
   repeat				;
	rem = fi_ipt (fil, buf, 512)	;
	quit if eq			; all over
	PUT("%s: block %d (%x) of %d\n",;
	    ctx->Pspc, blk, blk, bls)	;
	ptr = buf			;
	byt = 0				; byte in block
     while rem gt			;
	cu_abt ()			; check aborts
	str = lin			; reset that
	top = ptr + 16			;
	cnt = (rem ge 16) ? 16 ?? rem	; segment length
	idx = 16			;
	while idx gt			;
	   idx -= wid, top -= wid	;
	   if idx gt cnt		; out of data
	   .. next DMP("   ", <>)	;
	   case wid			;
	   of usBYT 
	      case rad
	      of usOCT  DMP("%03o ", *top & 255)
	      of usDEC  DMP("%4d ", *top & 255)
	      of usHEX  DMP("%02X ", *top & 255)
	      end case
	   of usWRD 
	      case rad
	      of usOCT  DMP("%06o ", *<*word>top & 0xffff)
	      of usDEC  DMP("%6d ", *<*word>top & 0xffff)
	      of usHEX  DMP("%04X ", *<*word>top & 0xffff)
	      end case
	   of usLNG 
	      case rad
	      of usOCT  DMP("%011o ", *<*long>top)
	      of usDEC  DMP("%11d ", *<*long>top)
	      of usHEX  DMP("%08X ", *<*long>top)
	      end case
	   end case
	end				;
	case rad
	of usOCT DMP("%03o ", byt)
	of usDEC DMP("%3d ", byt)
	of usHEX DMP("%03X ", byt)
	end case
	str = st_end (str)
	idx = 0				;
	case rad
	of usDEC  ;quit if wid lt usLNG
	or usOCT  quit if wid lt usWRD
	or usHEX
	   while idx lt cnt		;
	      if ptr[idx] gt 32 && ptr[idx] le 127
	         *str++ = ptr[idx]	; store it
	      else			;
	      .. *str++ = '.'		;
	      ++idx			;
	   end				;
	end case
	*str = 0			; terminate it
	PUT("%s", lin), NL		;
	fine if !cl_mor (&mor)		; pause
	byt += 16, ptr += 16, rem -= 16	;
     end				;
	++blk				; next block
	quit if quFfst			; only the first block
   end					;
	PUT("\n")			;
 end
