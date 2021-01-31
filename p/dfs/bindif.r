;minrite errors???
file	bindif - compare binary files
include	rid:rider
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include	rid:rtcla
include	rid:rtcsi
include	rid:rtdir

ULONG := LONG

;	%build
;	goto 'P1'
;	@@dfs:bininf
;	rider dfs:bindif/obj:dfb:
;	link:
;	link dfb:bindif/exe:dfb:/map:dfb:,dfb:bininf,lib:crt/bot:2000
;	%end

	dbg_c : int = 0

  type	sdTsid			; left/right side
  is	Psid : * char		; side name
	Pmod : * char		; side model spec
	Icla : fsTcla		; filespec class
	Pspc : * char		; side file spec
	Pfil : * FILE		; side file
	Veof : int		; eof seen
				;
	Vfst : WORD		; first block
	Vlst : WORD		; last block
				;
	Vloc : LONG		; location
	Vval : WORD		; value at location
				;
	Vblk : int		;
	Vwrd : int		;
	Popp : * sdTsid		; opposite side pointer
  end

  type	sdTopt
  is	Pspc : * char		; terminal if null
	Pfil : * FILE		; file
	Iext : fxText		; extension block for allocation
  end

  type	sdTctl
  is	Vbyt : int		; /bytes
	Vqui : int		; /quiet
	Vdev : int		; /dev
	Vsip : int		; /sipp

	Vsta : int		; /start
	Vend : int		; /end
	Valw : int		; /always

	Vver : int		; /verify
	Vlog : int		; /log
	Vmax : int		; /maximum=n
	Vhea : int		; header

	Vmis : int		; verify missing files
	Vopt : int		; output
				;
	Vdif : int		; difference count
	Vtot : int		; total differences
 	Vabt : int 		; abort pass

	Vnti : int		; new title pending
	Vnhd : int		; new header required
	Vnbl : int		; new block number required
	Vblk : int		; block number
	Voff : int		; offset in block
 end

	lft : sdTsid = {0}
	rgt : sdTsid = {0}
	ctl : sdTctl = {0}
	csi : csTcsi = {0}
	opt : sdTopt = {0}

	sdImem : meTctx = {0}
	sdIpas : meTctx = {0}
	sdIimg : imTctx = {0}
	sdPscn : * rtTscn = {0}

  func	sd_ovr
  is	im_res (&sdIimg, -1)
  end
code	start - bindif

  func	start
  is 	swi : * csTswi
	val : WORD
	sig : int = 0			; memory overflow

	im_ini ("BINDIF")		; who we are
	im_clr ()			; clear status

	sdPscn = me_acc (#rtTscn)	; permanent memory objects

	me_sav (&sdImem)		; save memory context
     repeat
	sig = im_sav (&sdIimg)		; save image context
					; non-zero result is signal
	fi_zap ()			; zap all channels
	me_res (&sdImem)		; restore memory context
	if sig 				; memory overflow
	.. im_rep ("E-Insufficient memory", <>)
	me_sig (&sd_ovr)		; memory overflow routine
					;
	me_clr (&ctl, #sdTctl)		;
	ctl.Vlog = 1			; /LOG
	ctl.Vopt = 1			; /OUTPUT default
					;
	me_clr (&lft, #sdTsid)		;
	lft.Psid = "Lft"		;
	me_clr (&rgt, #sdTsid)		;
	rgt.Psid = "Rgt"		;
	lft.Pmod = me_acc (mxSPC)	;
	rgt.Pmod = me_acc (mxSPC)	;
	me_clr (&opt, #sdTopt)		;
					;
	csi.Pnon = "BDGOQ"		; no value
	csi.Popt = "H"			; optional value
	csi.Preq = "ESX"		; required value
	csi.Pexc = <>			; mutually exclusive
	csi.Pidt = "?BINDIF-I-RUST binary differences utility BINDIF.SAV V1.0"
	csi.Ptyp = "SAVLSTCOM   "	; default filetypes
					;
	cs_par (&csi, <>)		; parse command
	next if fail			;
	cs_val (&csi, 0030, 0031)	; req: 2*int, opt: 1*ou
	next if fail			;
	lft.Pspc = csi.Aipt[0].Pspc	; file specs
	rgt.Pspc = csi.Aipt[1].Pspc	; 
	opt.Pspc = csi.Aopt[0].Pspc	; output file, if any
	opt.Iext.Valc = csi.Aopt[0].Valc;
					;
	swi = csi.Aswi			; process switchs
	while swi->Vcha			;
	   val = swi->Vval		;
	   case swi->Vcha		;
	   of 'B'  ctl.Vbyt = 1		; /BYTES
	   of 'D'  ctl.Vdev = 1		; /DEVICE
	   of 'E'  ctl.Vend = val	; /END=n
	   of 'G'  ctl.Vlog = 0		; /NOLOG
	   of 'H'  ctl.Vver = val	; /VERIFY
		   ctl.Vver = 1 if eq	; default for /h
	   of 'O'  ctl.Valw = 0		; /ALWAYS
	   of 'Q'  ctl.Vqui = 1		; /QUIET
	   of 'S'  ctl.Vsta = val	; /START=n
	   of 'X'  ctl.Vmax = val	; /MAXIMUM=n
	   end case			;
	   ++swi			; next switch
	end				;

	if ctl.Vopt			; want output
	   if opt.Pspc && !rt_ter (opt.Pspc)
	      opt.Pfil = fx_opn (opt.Pspc, "w", "", &opt.Iext)
	      next if fail
	   else
	.. .. opt.Pfil = stdout

	sd_wld ()			; do files

	if ctl.Vtot && ctl.Vopt
	   fi_clo (opt.Pfil, "") if opt.Pspc
	else
	.. fi_prg (opt.Pfil, "") if opt.Pspc
     forever
  end
code	sd_wld - wildcard driver

  func	sd_wld
  is	src : * sdTsid~ = &lft
	dst : * sdTsid~ = &rgt
	scn : * rtTscn = sdPscn
	pth : [mxPTH] char
	nam : [mxNAM+mxTYP] char
	cnt : int = 0

	fs_cla (lft.Pspc, &lft.Icla)	; get wildcard flags
	fs_cla (rgt.Pspc, &rgt.Icla)	;

	if (lft.Icla.Vwld & fsPTH_)	; device/directory wildcards
	.. fail im_rep ("E-Invalid wildcards %s", lft.Pspc)
	if (rgt.Icla.Vwld & fsPTH_)	; 
	.. fail im_rep ("E-Invalid wildcards %s", rgt.Pspc)

	if !(lft.Icla.Vwld & fsFIL_)	; no wildcards
	&& !(rgt.Icla.Vwld & fsFIL_)	; also none
	   ctl.Vmis = 1			;
	   exit if !sd_opn (&lft) || !sd_opn (&rgt)
	.. exit sd_eng ()		; simple file to file
					;
;	Choose a side which has wildcard
;	If both have wildcards, choose the with the least

	if !(lft.Icla.Vwld & fsFIL_)	; right wild cards only
	|| (lft.Icla.Vwld gt rgt.Icla.Vwld)
	.. src = &rgt, dst = &lft	; so right drives

	if dst->Icla.Vmix & fsFIL_	; output can't be mixed
	.. fail im_rep ("E-Invalid wildcard combination %s", dst->Pspc)

	st_cop (lft.Pspc, lft.Pmod)	; specs become the models
	st_cop (rgt.Pspc, rgt.Pmod)	;

	fs_ext (src->Pmod, pth, fsPTH_)	; extract the path for scanning
	scn = rt_scn (<>, pth, rtPER_, "") ; scan directory
	if fail				; no such file
	   im_rep ("E-No such file [%s]", lft.Pmod)
	.. exit				; nothing doing
					; shouldn't come back for errors
	fs_ext (src->Pmod, nam, fsFIL_)	; extract name for matching
	if ctl.Vver			; wants verification
	   PUT("?BINDIF-I-Scanning [%s%s] for matching [%s]\n",
	   pth, nam, dst->Pmod)
	end

      repeat
	fi_prg (lft.Pfil, <>)		; release files
	fi_prg (rgt.Pfil, <>)		;
	rt_wld (scn,nam,src->Pspc,"")	; scan another
	quit if fail			; no more or error
	st_ins (pth, src->Pspc)
	fs_res (src->Pspc, dst->Pmod, dst->Pspc)

	next if !sd_opn (&lft) || !sd_opn (&rgt)
	if ctl.Vver
	   PUT("?BINDIF-I-Comparing [%s] with [%s]\n", 
	      lft.Pspc, rgt.Pspc)
	end
	++cnt
	quit if !sd_eng ()		; engine failed
      end
	if !cnt
	.. im_rep ("E-No matching file for %s", lft.Pmod)
  end

  func	sd_opn
	sid : * sdTsid~
  is	fine if (sid->Pfil = fi_opn (sid->Pspc, "rb", <>))
	if ctl.Vmis
	.. PUT("?BINDIF-I-File not found %s\n", sid->Pspc)
	fail
  end
code	sd_eng - difference engine

  func	sd_eng
  is	me_sav (&sdIpas)		; save memory
	ctl.Vnti = 1			; new title pending
	ctl.Vnhd = 1			; new header pending
	ctl.Vnbl = 1			; new block pending
	ctl.Vblk = 0			;
	ctl.Voff = 0			;
	ctl.Vdif = 0			; reset difference flag
	ctl.Vabt = 0			; abort off
	lft.Veof = 0			;
	lft.Vloc = 0			;
	rgt.Vloc = 0			;
	rgt.Veof = 0			;

	sd_byt () if ctl.Vbyt		;
	sd_wrd () otherwise		;

	ctl.Vtot += ctl.Vdif		; accumulate differences

	sd_tit () if ctl.Vlog		; title pending

	if lft.Veof && !rgt.Veof
	   ctl.Vdif++
	.. sd_log ("W-File is longer %s", rgt.Pspc)
	if rgt.Veof && !lft.Veof
	   ctl.Vdif++
	.. sd_log ("W-File is longer %s", lft.Pspc)
	if ctl.Vdif
	   sd_log ("W-Files are different", <>)
	else
	.. sd_log ("I-No differences found", <>)

	me_res (&sdIpas)		; restore memory
	fine				;
  end
code	sd_wrd - compare words

  func	sd_wrd
  is
      repeat
	sd_gtw (&lft, &lft.Vval)
	sd_gtw (&rgt, &rgt.Vval)
	quit if (lft.Veof | rgt.Veof)
	if lft.Vval ne rgt.Vval 
	   ++ctl.Vdif
	   quit if ctl.Vmax && (ctl.Vdif ge ctl.Vmax)
	   if !ctl.Vqui
	      sd_hdr ()
	      PUT("%06o	%06o	%06o	%06o	%06o\n",
	      lft.Vval, rgt.Vval, lft.Vval^rgt.Vval,
	      lft.Vval-rgt.Vval, rgt.Vval-lft.Vval)
	   end
	end
	sd_adv (2)
      end
  end

  func	sd_byt
  is	lft.Vval = rgt.Vval = 0
      repeat
	sd_gtb (&lft, &lft.Vval)
	sd_gtb (&rgt, &rgt.Vval)
	quit if (lft.Veof | rgt.Veof)
	if lft.Vval ne rgt.Vval 
	   ++ctl.Vdif
	   quit if ctl.Vmax && (ctl.Vdif ge ctl.Vmax)
	   if !ctl.Vqui
	      sd_hdr ()
	      PUT("%03o	%03o	  %03o	  %03o	  %03o\n",
	      lft.Vval, rgt.Vval, lft.Vval^rgt.Vval,
	      (lft.Vval-rgt.Vval)&255, (rgt.Vval-lft.Vval)&255)
	   end
	end
	sd_adv (1)
      end
  end

  func	sd_gtw
	sid : * sdTsid
	dst : * char
  is	sd_gtb (sid, dst)
	sd_gtb (sid, dst+1)
	reply !sid->Veof
  end

  func	sd_gtb
	sid : * sdTsid
	dst : * char
  is	val : WORD
	fail if sid->Veof
	val = fi_gch (sid->Pfil)
	fail sid->Veof = 1 if val eq EOF
	fine *dst = val
  end

  func	sd_adv
	wid : int
  is	ctl.Voff += wid
	if ctl.Voff & 512
	   ctl.Voff = 0
	   ++ctl.Vblk
	.. ++ctl.Vnbl
	lft.Vloc += wid
	rgt.Vloc += wid
  end

  func	sd_hdr
  is	sd_tit ()
	if ctl.Vnhd
	   PUT("Block\tOffset\tOld\tNew\tOld^New\tOld-New\tNew-Old\n")
	.. ctl.Vnhd = 0
	if ctl.Vnbl
	   PUT("%06o", ctl.Vblk)
	.. ctl.Vnbl = 0
	PUT("	%03o	", ctl.Voff)
  end

  func	sd_log
	msg : * char
	obj : * char
  is	sd_tit () if ctl.Vlog
	im_rep (msg, obj) if ctl.Vlog
	im_war () if *msg eq 'W'
	im_err () if *msg eq 'E'
  end

  func	sd_tit
  is	if ctl.Vnti
 	   PUT("?BINDIF-I-Comparing %s with %s\n", lft.Pspc, rgt.Pspc)
	.. ctl.Vnti = 0
  end
