;	detect and handle remote NF: directories
;
;	.SPFUN required to access BBR home blocks
;
;	Note: CRT needs to support .SPFUN Read/Write for access to
;	larger devices.
;
;	DL:	RL01/2	All blocks replaceable
;	DM:	RK06	Some replaceable
;	DU:	MSCP	
;
;	/rt11 /rsx /vms /unix /dos
;	/new	ignore existing info
;	/bad:n	max bad blocks
;	/clone=ddn:
;	/size=n	volume size override
;	/create	create container file
;	/boot=spec
;	/rd50
;		specify boot file
file	vuini - init volume
include	rid:rider
include	rid:imdef
include	rid:hodef
include	rid:medef
include rid:rddef
include rid:rtbad
include rid:rtboo
include rid:rtcla
include rid:rtcli
include rid:rtcst
include rid:rtrea
include	vub:vumod

;	/x=n	Specifies volume size in blocks
;		Select boot block template
;
;	Initialise RT-11 volume
;
;	*dev:*=/Z...
;
;/Z	/B	Replaces badblocks with FILE.BAD
;/Z	/B:RET	Retains badblock files
;/Z	/D	Restore
;/Z	/N:n	Number of directory segments (1:37)
;?Z	/R	Scans and creates bad block replacement table
;/Z	/R:RET	Retains existing replacement table
;/Z	/V	Init and write label
;/Z	/V:ONL	Write label only
;	/Z	Init device
;	/Z:n	Specifies extra words per directory entry

;	in_cmd	ask various questions
;	in_chk	check suitable device
;	in_get	get necessary components
;	in_val	validate components
;	in_scn	scan badblocks
;	in_tem	build template directory
;	in_sav	save directory
;	in_hom	write home block
;	in_dir	write directory
;	in_boo	write dummy boot

	in_hom : (int) int-
	in_chk : (*WORD) void-
	in_tot : (*rtTcla) int-
	in_res : (void) int-

	Vol : [14] char-
	Own : [14] char-
	hom : hoTdsk- = {0}
	hdr := hom.Ihdr

	dem : rdTdem- = {0}

	inIcla : rtTcla- = {0}

	btAtem : [] word+			; boot template
	rxV05 := 0107123			; homeblock version

	ipt := cmAspc[3]
	opt := cmAspc[0]
	dst := vuIdst
code	vu_ini - init volume

  func	vu_ini
	() : * bdTbad
  is	seg : * rdTseg				; segment
	cla : * rtTcla = &inIcla
	bad : * bdTbad = <>
	rta : int				; is RT-11 directory

	if !(cmVopt & cmRST_)			; not init/restore
	   if (cmVwrd gt 128)			; extra words
	   || (cmVseg gt 31)			; segments
	.. .. fail vu_inv ()			;
						;
	fail vu_inv () if !*opt.Pnam		; no device specified
	fail if !vu_opn (&dst, opt.Pnam, "rp+")	; access target device

	if cmVopt & cmREP_			; replacement blocks
	.. fail im_rep ("E-No bad block replacement yet %s", opt.Pnam)

;	Must be a disk volume, RT-11 directory or container file

	if !rt_cla (dst.Pfil, cla)		; get file class
	|| !in_cla (cla->Vflg)			; check file class
	.. im_rep ("F-Invalid device or file %s", dst.Anam)

	fail in_cas (dst.Pfil) if cla->Vflg & fcCAS_
	fail in_mag (dst.Pfil) if cla->Vflg & fcMAG_

	seg = rd_alc (<>, dst.Pfil)		; make segment structure
	rta = rd_det (seg)			; detect RT11A/RT11X
						;
	if cmVopt & cmRST_			; init/restore?
	   fail if !rta
	.. fail in_res ()			; yep

	if rta & (cmVopt & cmBAD_)		; wants bad blocks
	   bad = bd_alc (<>, dst.Pfil)		; setup for bad blocks
	.. bad->Iscn.Vlim = cla->Vsiz		; bad block scan

;	fail in_mag () if 			; magtape init
						;
	if !cmVonl				; not /vol:only
	&& cla->Vflg & fcSYS_			; initializing SY:
	   PUT("Initializing SYSTEM volume!\n")	; Init/Kamakazi
	.. fail if !rt_qry ("SY:", "/Initialize", <>)

	if !cmVnoq				; not /noquery
	   cmVonl ? "/Volume ID change" ?? "/Initialize"
	.. fail if !rt_qry(dst.Anam,that,<>) 	; are you sure?

	fail if !in_hom (rta)			; process home block
	if cmVonl				; only writing home block?
	   if !rt_wri (dst.Pfil, 1, &hom, 512/2, rtWAI) ; yes - get out of here
	   .. im_rep ("E-Error writing home block %s", opt.Pnam)
	.. fail					;

	if rta					; RT-11 directory
	   if !rd_sav (seg, hom.Ares)		; save directory header
	   || !rd_dem (seg, &dem, bad)		; get volume demography
	   .. fail im_rep ("F-Error reading directory %s", dst.Anam)

	   if dem.Vpro && !cmVnoq
	.. .. fail if !rt_qry("", "Volume contains protected files",<>)

	if !rt_wri (dst.Pfil, 0, vuAboo+1, vuAboo[0], rtWAI) ; write boot
	.. fail im_rep ("E-Error writing boot block %s", opt.Pnam)

	in_chk (<*WORD>&hom)			; calculate checksum
	if !rt_wri (dst.Pfil, 1, &hom, 512/2, rtWAI) ; write home block
	.. im_rep ("E-Error writing home block %s", opt.Pnam)

	if !(cla->Vflg & fcNET_)
	   rd_ini (seg, in_tot (cla), cla->Vsiz, cmVwrd*2, 1) ; create directory
	.. pass fail				;

	reply bad				; return bad block context
						; root calls bd_map
  end

code	in_cla - check device/file class

 	CLA(x) := (flg & x)
  func	in_cla
	flg : int~
  is	if !CLA(fcDSK_)				; not a disk
	   fail if !CLA(fcDEV_)			; must be device
	.. reply CLA(fcCAS_|fcMAG_)		; magtape or cassette
						;
	fine if  CLA(fcDEV_) && inIcla.Vsiz	; opened as device
	fine if  CLA(fcDIR_) && !CLA(fcNET_)	; can do local RT-11 directories
	fine if  CLA(fcFIL_) &&  CLA(fcCON_)	; can do container files
	fine if  CLA(fcNET_) &&  CLA(fcDEV_)	; can do network disks
	fail
  end
code	in_hom - home block

;	Retain owner/label if system ID is "DECRT11A"
;	VUP additionally retains for "DECVMSEXCHNG"

  func	in_hom
	rta : int
  is	sys : [14] char
	cnt : int = 512
	ptr : * char = <*char>&hom
	rtm : * hoTrtm = &hom.Irtm

	rt_rea (dst.Pfil, 1, &hom, 512/2, rtWAI)
	fail im_rep ("E-Error reading home block %s", dst.Anam) if fail

	me_clr (&hom, 512) if !rta		; non-RT11A volume
						;
	me_mov ("RT11A       ", Vol, 12)	; template
	me_mov ("            ", Own, 12)	;
						;
	me_mov (hdr.Asys, sys, 12)		;
	sys[12] = 0				; terminate that one

	if st_sam (sys, "DECRT11A    ")		; if we understand the volume
	|| st_sam (sys, "DECVMSEXCHNG")		;
	   me_mov (hdr.Avol, Vol, 12)		; use existing labels
	.. me_mov (hdr.Aown, Own, 12)		;
						;
	if !((cmVopt & cmREP_) && cmVret)	; not /REP:RETAIN
	.. me_clr (&hom, hoREP)			; clear replacement table
						;
	in_lab (&Vol, &Own) if cmVopt & cmVOL_	; prompt for volume label 
						;
	rtm->Vsig  = 0177777			; not RTEM
	rtm->Vblk = 0				; first user block
						;
	hdr.Vclu = 1				; cluster size
	hdr.Vseg = 6				; first segment
	hdr.Vver = rxV05			; V5 signature
	me_mov (Vol, hdr.Avol, 12)		; volume ID
	me_mov (Own, hdr.Aown, 12)		; owner ID
	me_mov ("DECRT11A    ", hdr.Asys, 12)	; system ID
  end

code	in_chk - compute checksum

  proc	in_chk
	blk : * WORD
  is	cnt : int = 255
	chk : int = 0
	chk += *blk++ while cnt--
	*blk = chk
  end
code	in_tot - get total segment count

;	RT-11 utility guides specify most of these figures
;	Cross-checked with PUTR.ASM 

  type	inTdev
  is	Vcod : int			; RT-11 device code
	Vcnt : int			; default count
	Valt : int			; alternate count
	Vthr : WORD			; alternate threshold
  end

  init	inAdev : [] inTdev 
  is   ;cod	cnt	alt	thr	; dev
	034,	1,	0,	0	; DD:	
	005,	16,	31,	10240	; DL: (single, double)
	023,	31,	0,	0	; DM:
	021,	31,	0,	0	; DP:
	016,	4,	0,	0	; DS:
	001,	4,	0,	0	; DT:
	053,	16,	31,	9792	; DW: (RD50, RD51)	
	022,	1,	0,	0	; DX:
	006,	1,	4,	494	; DY:
	052,	0,	0,	0	; DZ:	
	012,	4,	0,	0	; RF:
	000,	16,	0,	0	; RK:

;	Variable size devices
;
;		?,	?,	????	; HD:
;	046,	?,	?,	????	; LD:
;	047,	?,	?,	????	; VM:
;	050,	1,	31,	1024	; DU: (floppy, disk)
	-1,	0,	0	
  end

  func	in_tot
	cla : * rtTcla
  is	dev : * inTdev~ = inAdev
	siz : WORD~ = cla->Vsiz		; device size from rt_cla
	cnt : int~ 

	reply cmVseg if cmVseg		; count is explicit
					;
	if !cla->Vflg & fcCON_		; not a container file
	   while dev->Vcod ne -1	; find device, if any
	      if dev->Vcod eq (cla->Vdsw&255) ; found the device
	         cnt = dev->Vcnt	; assume normal
	         if dev->Vthr gt siz	; above threshold?
	         .. cnt = dev->Valt	; yep - use alternate
	      .. reply cnt		; done
	      ++dev			; next 
	.. end				;

;	Use RT-11 algorithm to determine directory segment count

	cnt = 31			; start at the top
	cnt = 16 if siz le 12288	; and whittle down
	cnt = 4 if siz le 2048		;
	cnt = 1 if siz le 512		;
	reply cnt
  end
code	in_res - restore directory

	rxV3A := 0107251
	rxV4A := 0107321
	rxV05 := 0107123

  func	in_res
  is	seg : * rdTseg~
	ver : int~

	if !(inIcla.Vflg & fcDSK_)
	.. fail im_rep ("E-Invalid restore device %s", dst.Anam)

;???	Can't restore tapes

	if !rt_rea (dst.Pfil, 1, &hom, 512/2, rtWAI)
	.. fail im_rep ("E-Error reading home block %s", dst.Anam)

	ver = hom.Ihdr.Vver

	if !rd_chk ((hom.Ares), 1)
	|| ((ver ne rxV3A) && (ver ne rxV4A) && (ver ne rxV05))
	.. fail im_rep ("E-Invalid or corrupt home block [%s]", dst.Anam)

	seg = rd_alc (<>, dst.Pfil)		; setup segments

	if !rd_det (seg)			; not RT11A/RT11X
	|| !rd_blk (seg)			; must be blank directory
	.. fail im_rep ("E-Uninitialized directory [%s]", dst.Anam)

	if !rd_res (seg, hom.Ares, 1)		; restore directory header
	.. fail im_rep ("E-Directory restore failed [%s]", dst.Anam)
	fine
  end
code	in_lab - prompt for volume label

  func	in_lab
	vol : * char
	usr : * char
  is	lin : [84] char
	rt_prm ("Volume ID? ", lin, rtGLN_)
	lin[12] = 0
	st_cop ("            ", vol)
	me_cop (lin, vol, st_len (lin))

	rt_prm ("Owner?     ", lin, rtGLN_)
	lin[12] = 0
	st_cop ("            ", usr)
	me_cop (lin, usr, st_len (lin))
  end
code	in_cas - init cassette

  func	in_cas
	fil : * FILE
  is	fail im_rep ("E-No cassette support yet %s", fi_spc (fil))
  end

  func	in_mag
	fil : * FILE
  is	fail im_rep ("E-No magtape support yet %s", fi_spc (fil))
  end

end file
code	in_cas - init cassette

  func	in_cas
	fil : * FILE
  is	spc : [16] 

	fi_clo (fil)			; close the channel
	if !fi_del (spc)		; delete null spec inits it
	|| (fil = fi_opn (spc)) eq	; open it again
	|| !rt_spf (fil,sfCRW,0,<>,0)	; rewind it
	|| !fi_prg (fil)		; purge it
	.. im_rep ("E-Error initializing cassette %s", spc)
  end
code	in_mag - init magtape


  func	in_mag
	fil : * FILE
	boo : * WORD
  is	spc : [16] char 
  end

end file

  func	in_sys
	flg : int~
  is	fine if !(flg & fcSYS_)			; not system device
	cl_prm (
  end
code	in_mag - init magtape

