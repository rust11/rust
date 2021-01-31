;	/g:N can't be required to be positional
;	/predelete
file	vucre - create file
include	rid:rider
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:medef
include	rid:rddef
include	rid:rtcla
include	rid:rtdir
include	vub:vumod

code	cm_cre	create file

;	CREATE	spec/ALLOC=n/START=blk
;	VUP	spec[n]/C=/G:blk
;
;	CREATE	spec/EXTENSION=ext /TRUNCATE=tru /SIZE= 
;	VUP	spec=/T:ext
;
;	SET FILE/SIZE=n spec
;
;	DEV:	DUP defaults DEV: to the system device.
;		VUP issues a message "no output device specified".
;
;		DUP requires that DEV: be an RT11A volume.
;		VUP accepts a device, RT-11 directory or container.
;
;	SYS: 	Defaults to DK:*.SYS
;
;		DUP requires that SYS: be an RT11A volume (because
;		it does the directory scan internally).
;		VUP uses native directory operations unless the target
;		is a container file or a start block is specified.
;
;	/EXT=N	VUP supports only extend.

	ext : fxText = {0}

	crIcla : rtTcla- = {0}
	cr_cla : (int) int
code	cm_cre - create file

	ipt := cmAspc[3]
	opt := cmAspc[0]
	dst := vuIdst

  proc	cm_cre
  is	fil : * FILE
	seg : * rdTseg
	tem : * rtTent
	nam : [64] char
	len : int = opt.Valc
	blk : int = cmIst1.Vval
	cla : * rtTcla = &crIcla
	buf : * char
	sta : int

	len = 1 if !len

	exit vu_inv () if !*opt.Pnam
;	exit if !dv_val (nam, dvDSK_, "")

	exit if !fi_mis (opt.Pnam, "")

	fs_ext (opt.Pnam, nam, fsPTH_)		; get the path
	fil = fi_opn (nam, "rb", "")		;
	pass fail

	if !rt_cla (fil, cla)			; get file class
;	|| !cr_cla (cla->Vflg)			; check file class
	.. im_rep ("F-Invalid device or file %s", opt.Pnam)
	fi_clo (fil)

	if !blk					; no start block
	   ext.Vseq = 0				;
	   ext.Valc = len			;
	   exit if (fil = fx_opn (opt.Pnam, "wb", "", &ext)) eq
	   ext.Valc = len
	   if len && (cla->Vflg & fcNET_)	; network file
	      buf = me_alc (512)		; get a buffer 
	      sta = rt_wri (fil, len-1, buf, 512/2, rtWAI) ; write last block
	      me_dlc (buf)			; deallocate buffer
	   .. im_rep ("F-Error writing file %s", opt.Pnam) if !sta
	   fx_clo (fil, "", &ext)
	.. fine

	if cla->Vflg & fcNET_			; can't specify net start block
	.. im_rep ("F-Device does not support start blocks %s", opt.Pnam)

	fs_ext (opt.Pnam, nam, fsPTH_)		; get the path
	vu_opn (&dst, nam, "rp+")		; open target device
	exit if fail				;
	seg = rd_alc (<>, dst.Pfil)		; make segment structure
	fs_ext (opt.Pnam, nam, fsFIL_)		; extract file name/type
	tem = rd_tem (seg, <>, nam, len)	; make a template entry
	rd_cre (seg, tem, blk, 1)		; create the file
	im_rep ("E-Create file failed [%s]", opt.Pnam) if fail
	rd_upd (seg) otherwise			;
	rd_dlc (seg)				; cleanup
  end

code	cr_cla - check device/file class

 	CLA(x) := (flg & x)

  func	cr_cla
	flg : int~
  is
	if !CLA(fcDSK_)				; not a disk
	   fail if !CLA(fcDEV_)			; must be device
	.. reply CLA(fcCAS_|fcMAG_)		; magtape or cassette
						;
;	fail if  CLA(fcDEV_) && inIcla.Vsiz	; opened as device
	fine if  CLA(fcDIR_) && !CLA(fcNET_)	; can do local RT-11 directories
	fine if  CLA(fcFIL_) &&  CLA(fcCON_)	; can do container files
	fine if  CLA(fcNET_) &&  CLA(fcDEV_)	; can do network disks
	fail
  end
code	cm_siz - alter file size

;	CREATE/EXTENSION=n
;	SET FILE/SIZE=n /TRUNCATE=n /EXTENSION=n
;
;	/T:n	/extension=n
; ???	/T/X:n	/truncate=n
;		cmLST_, cmVlst
; ???	/T/N:n	/size=n
;		cmSEG_ cmVseg

  proc	cm_siz
  is	spc : * char = opt.Pnam
	nam : * char
	ent : * rtTent
	tem : * rtTent
	fil : * FILE
	seg : * rdTseg
	cla : rtTcla
	cur : WORD
	siz : WORD = 0
	err : WORD = 0

	exit vu_inv () if !*spc

	fil = fi_opn (spc, "rb", "")
	exit if fail

	rt_cla (fil, &cla)			; get file class
	fail im_rep ("E-Error accessing [%s]", spc) if fail
	if !((cla.Vflg & fcDSK_) && (cla.Vflg & fcFIL_))
	|| (cla.Vflg & fcNET_)
	.. exit im_rep ("E-Can't alter size of [%s]", spc)
	fi_clo (fil)

	cur = cla.Vsiz				; get file size
	if cmVopt & cmSEG_			; explicit size
	   siz = cmVseg				;
	elif cmVopt & cmLST_			; truncate
	   siz = cur - cmIlst.Vval		;
	   ++err if siz ge cur			;
	else					;
	   siz = cur + cmVext			; extend
	.. ++err if siz lt cur			;
	exit im_rep ("E-Invalid size specified [%s]", spc) if err
	exit if cur eq siz			; no change
						;
	fs_ext (spc, nam, fsPTH_)		; get the path
	fil = fi_opn (nam, "rb", "")		;
	exit if fail				;
      repeat					;
	seg = rd_alc (<>, fil)			; make segment structure
	fs_ext (spc, nam, fsFIL_)		; extract file name/type
	tem = rd_tem (seg, <>, nam, 0)		; cheap name conversion
	ent = rd_fnd (seg, tem->Anam)		; find the file
						;
	rd_siz (seg, ent, siz)
	quit im_rep ("E-File size operation failed [%s]", spc) if fail
	rd_upd (seg)			;
      never
	rd_dlc (seg)				; cleanup
  end
