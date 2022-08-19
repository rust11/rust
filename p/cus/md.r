;???;	CUS:MD - Add /NOPROTECT
;	Shouldn't fi_exs come before fi_opn
file	md - make directory
include	rid:rider
include	rid:dcdef
include	rid:dpdef
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:hodef
include	rid:mxdef
include	rid:rtdev
include	rid:rtcla
include	rid:rtdir
include	rid:rttim

;	%build
;	rider cus:md/object:cub:
;	link cub:md/exe:cub:/map:cub:,lib:crt/bot=2000/cross 
;	%end
;
;	md spc/...
;
;	/allocate:n	1000
;	/segments:n	1 per 1k blocks + 2
;	/extra:n	default is 3
;	/rt11
;	/rsx

	_cuABO := "I-RUST Make directory utility MD.SAV V2.0"

	dvFX := 0206

  type	mdTctl
  is	Aspc : [mxSPC] char
	Vqua : int
	Valc : int
	Vseg : int
	Vext : int
	Vrt  : int
	Vrst : int
	Vrsx : int 
	Vwin : int
  end

	mdALC  := 1		; qualifiers
	mdEXT  := 2
	mdSEG  := 3

	mdALC_ := BIT(1)
	mdEXT_ := BIT(2)
	mdSEG_ := BIT(3)

	mdIctl : mdTctl = {0}

	md_rst : (*mdTctl)
	md_rsx : (*mdTctl)

data	DCL processing

	A(x) := mdIctl.x
	V(x) := &mdIctl.x

	cu_mak : dcTfun

  init	cuAhlp : [] * char
  is   "MD path		Make directory path"
       ""
       "/RSX		Make RSX directory (RTX only)"
       "/RT		Make RT-11 directory"
       "/RUST		Make RUST directory"
       " /ALLOCATE=n	Block size" 
       " /EXTRA=n	Extra words per entry"
       " /SEGMENTS=n	Directory segments"
       "/ABOUT		Display image information"
       "/HELP		Display this help frame"
	<>
  end

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1	type|flags
  is 1,  <>,		dc_fld,A(Aspc),32,	dcSPC
     1,  <>,		cu_mak, <>, 	0, 	dcEOL_

     1, "/AL*LOCATE",	dc_atr,V(Valc),	0,	dcDEC|mdALC
     1, "/EX*TRA",	dc_atr,V(Vext),	0,	dcDEC|mdEXT
     1, "/SE*GMENTS",	dc_atr,V(Vseg),	0,	dcDEC|mdSEG
     1, "/RS*X",	dc_set,V(Vrsx),	1,	0
     1, "/RT",		dc_set,V(Vrt),	1,	0
     1, "/RU*ST",	dc_set,V(Vrst),	1,	0
     1, "/WI*NDOWS",	dc_set,V(Vwin),	1,	0

     1, "/AB*OUT",	dc_rep,_cuABO,	0,	dcEOL_|dcFIN_
     1, "/HE*LP",	dc_hlp, cuAhlp,	0,	dcEOL_|dcFIN_
     0,	 <>,		<>,	<>,	0, 	0
  end
code	md start

  func	start
  is	dcl : * dcTdcl = dc_alc ()
	im_ini ("MD")
	dcl->Venv |= dcNKW_|dcCLI_|dcCLS_  ;|dcSIN_
	dc_eng (dcl, cuAdcl, "MD> ")
  end

;	DCL action routine

  func	cu_mak
	dcl : * dcTdcl
  is	dst : rtTdst
	ctl : * mdTctl = &mdIctl
	ctl->Vqua = dcl->Vflg

;	fine if dc_con (dcl, dcRST_|dcRT_|dcRSX_)

	fine md_rst (ctl) if ctl->Vrst|ctl->Vrt
	fine md_rsx (ctl) if ctl->Vrsx

	fine if !rt_dst (ctl->Aspc, &dst, "")

	if !ctl->Vqua
	&& (dst.Vdsw &0377) eq dvFX
	.. fine md_rsx (ctl)
	fine md_rst (ctl)
  end
code	md_rst - make RUST/RT-11 directory

	btAtem : [] word+			; boot template

	hdr : rtThdr = {0}
	ent : rtTent = {0}
	wrd : WORD = 0
	fex : fxText = {0}
	cla : rtTcla = {0}
	ter : WORD = (rtEND_)

	rx_EM := 0325
	rxPTY := 063471
	rxFIL := 023364

	QUA(x) := (ctl->Vqua & x)

  func	md_rst
	ctl : * mdTctl
  is	fil : * FILE = <>
	spc : [mxSPC] char
	dis : * char = ctl->Aspc
	tmp : [84] char
	tim : tiTplx
	ftm : rtTftm
	alc : int
	seg : int
	cnt : int
	siz : int
	ext : int = 0		; extra words

	alc = 1024		; default block count
	alc = ctl->Valc if QUA(mdALC_)

	seg = (alc / 512) + 2	; default directory segments
	seg = ctl->Vseg if QUA(mdSEG_)
	seg = 31 if seg gt 31
	seg = 1 if seg eq

	siz = rtRTA*2
	if QUA(mdEXT_)			; want extra words
	   if (ctl->Vrst)		; not with /RUST
	   .. fail im_rep ("E-Incompatible options: /RUST/EXTRA", "")
	   ext = ctl->Vext		; extra words
	else
	   siz += rtRTX*2 if !ctl->Vrt
	end

	if alc lt (6 + (seg*2) + 1)
	.. fail im_rep ("E-Directory file too small %s", dis)

	if !dp_ter (dis, spc, dpMHT_|dpRMT_)
	.. fail im_rep ("E-Invalid directory specification %s", dis)

	fi_def (spc, "DK:.DSK", spc)
	if !st_fnd (".DSK", spc)
	.. fail im_rep ("E-Directories must have file type .DSK %s", dis)

	if !rt_dst (spc, <>)
	.. fail im_rep ("E-Invalid device %s", dis)

	fs_ext (spc, tmp, fsDEV_)
	fil = fi_opn (tmp, "rb", <>)
	if fail 
	|| !rt_cla (fil, &cla)
	   fi_prg (fil)
	.. fail im_rep ("E-Error accessing device %s", dis)

	fi_prg (fil)
	if !(cla.Vflg & fcDSK_)
	.. fail im_rep ("E-Invalid device for operation %s", dis)

	if cla.Vflg & fcNET_
	.. fail im_rep ("E-Can't create network directory %s", dis)

	fex.Valc = alc
	fil = fx_opn (spc, "wb", <>, &fex)
	if fail
	   if fex.Verr eq 1
	      im_rep ("E-Insufficient space for directory %s", dis)
	   else
	   .. im_rep ("E-Error creating directory %s", dis)
	.. fail

	if fi_exs (spc, <>)
	.. fail im_rep ("E-Directory already exists %s", dis)

;	zero the first six blocks and the directory

	cnt = (6 + (seg*2)) * 512
	fi_pch (fil, 0) while cnt--

;	write a boot block

	fi_see (fil, <long>(0))
	fi_wri (fil, btAtem+1, btAtem[0])
	im_rep ("W-Error writing boot block %s", dis) if fail

;	write a home block

	md_hom (fil, spc)

;	back to the directory

	fi_see (fil, <long>(6*512))

;	create the header & first two entries

	hdr.Vtot = seg
	hdr.Vnxt = 0
	hdr.Vlst = 1
	hdr.Vext = rtRTX*2 if not ctl->Vrt
	hdr.Vext = ext*2 otherwise
	hdr.Vblk = 6 + (seg*2)
	fi_wri (fil, &hdr, #rtThdr)

	tm_clk (&tim)				; wall clock time
	rt_tpf (&tim, &ftm)			; RT-11 file time

	ent.Vsta = rtEMP_			; directory entry
	ent.Vlen = alc-6-(seg*2)
	ent.Anam[0] = rx_EM
	ent.Anam[1] = rxPTY
	ent.Anam[2] = rxFIL
	ent.Vdat = ftm.Vdat
	ent.Vtim = ftm.Vsec | 0100000
	ent.Vctl = ftm.Vext			; only written for /rust
						;
	fi_wri (fil, &ent, siz)			; write entry
	fi_wri (fil, &wrd, 2) while ext--	; write extra words
	fi_wri (fil, &ter, 2)			; rtEND_
	fx_clo (fil, "", &fex)			; close, setting size
	fi_prt (spc, "")			; protect the directory
  end

	rxV05 := 0107123			; homeblock version

  func	md_hom
	fil : * FILE
	spc : * char
  is	hom : * hoTdsk~ = me_acc (#hoTdsk)
	hdx : * hoThdr~ = &hom->Ihdr
	vol : * char~ = &hdx->Avol
	len : int
	hdx->Vclu = 1
	hdx->Vseg = 6
	hdx->Vver = rxV05
	fs_ext (spc, vol, fsNAM_)
	len = st_len (vol)
	me_mov ("            ", vol+len, 12-len)
	me_mov (vol, hdx->Aown, 12)
	me_mov ("RT11A       ", hdx->Asys, 12)
	me_mov ("DECRT11A    ", hdx->Asys, 12)
	md_chk (<*WORD>hom)

	fi_see (fil, <long>(512))
	fi_wri (fil, hom, 512)
	im_rep ("W-Error writing home block %s", spc) if fail
	me_dlc (hom)
  end

  func	md_chk
	blk : * WORD
  is	cnt : int = 255
	chk : int = 0
	chk += *blk++ while cnt--
	*blk = chk
  end
code	md_rsx - make an RSX directory

;	Directory name must be explicit (not a logical name)

	dvFX := 0206

  func	md_rsx
	ctl : * mdTctl
  is	dis : * char = ctl->Aspc
	spc : [mxSPC] char
	dst : rtTdst
	lst : * char
	fil : * FILE
	buf : WORD

	dp_rsx (dis, spc)
	dp_ter (dis, spc, dpMHT_|dpRMT_)

	fi_def (spc, "DK:.DIR", spc)
	if !st_fnd (".DIR", spc)
	.. fail im_rep ("E-Directories must have file type .DIR %s", dis)

	if !rt_dst (spc, &dst)
	.. fail im_rep ("E-Invalid device %s", spc)

	if (dst.Vdsw & 0377) ne dvFX
	.. fail im_rep ("E-Not an RSX-11 volume %s", dis)

	if fi_exs (spc, <>)
	.. fail im_rep ("E-Directory already exists %s", dis)

	if (fil = fi_opn (spc, "wb", "")) eq
	|| !fi_clo (fil, "")
	.. fail im_rep ("E-Error creating directory %s", dis)
	fine
  end
