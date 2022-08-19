file	rd - remove directory
include	rid:rider
include	rid:dcdef
include	rid:dpdef
include	rid:fidef
include	rid:imdef
include	rid:mxdef
include	rid:rtcsi
include	rid:rtdev

;	%build
;	rider cus:rd/object:cub:
;	link cub:rd/exe:cub:/map:cub:,lib:crt/bot=2000/cross 
;	%end
;
;	rd path
;
;	/rt/rust/rsx
;	/noquery
;
;	spc	must end with "...\xxx\"

	_cuABO := "I-RUST Remove directory utility RD.SAV V2.0"

	dvFX := 0206

  type	rdTctl
  is	Aspc : [mxSPC] char
	Vqua : int
	Vmrk : int
	Vrt  : int
	Vrst : int
	Vrsx : int 
	Vwin : int
	Vnoq : int
	Vdel : int
	Vunp : int
	Vsys : int
  end

	CTL : rdTctl- = {0}

	rd_rst : (*rdTctl)
	rd_rsx : (*rdTctl)

data	DCL processing

	A(x) := CTL.x
	V(x) := &CTL.x

	cu_rem : dcTfun

  init	cuAhlp : [] * char
  is   "RD path		Remove directory path"
       ""
       "/RSX		Remove RSX directory (RTX only)"
       "/RT		Remove RT-11 directory"
       "/RUST		Remove RUST directory"
;      "/WINDOWS	Remove Windows directory (V11 only)"
;      "/DELETE		Display image information"
;      "/NOQUERY	Display image information"
;      "/SYSTEM		Deletes .SYS files"
;      "/UNPROTECT	Unprotects files for deletion"

       "/ABOUT		Display image information"
       "/HELP		Display this help frame"
	<>
  end

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1	type|flags
  is 1,  <>,		dc_fld,A(Aspc),32,	dcSPC
     1,  <>,		cu_rem, <>, 	0, 	dcEOL_

     1, "/RS*X",	dc_set,V(Vrsx),	1,	0
     1, "/RT",		dc_set,V(Vrt),	1,	0
     1, "/RU*ST",	dc_set,V(Vrst),	1,	0
;    1, "/WI*NDOWS",	dc_set,V(Vwin),	1,	0
;    1, "/NOQ*UERY",	dc_set,V(Vnoq),	1,	0

     1, "/AB*OUT",	dc_rep,_cuABO,	0,	dcEOL_|dcFIN_
     1, "/HE*LP",	dc_hlp, cuAhlp,	0,	dcEOL_|dcFIN_
     0,	 <>,		<>,	<>,	0, 	0
  end
code	rd start

  func	start
  is	dcl : * dcTdcl = dc_alc ()
	im_ini ("RD")
	dcl->Venv |= dcNKW_|dcCLI_|dcCLS_
	dc_eng (dcl, cuAdcl, "RD> ")
  end

;	DCL action routine

  func	cu_rem
	dcl : * dcTdcl
  is	dst : rtTdst
	ctl : * rdTctl = &CTL
	ctl->Vqua = dcl->Vflg

;	fine if dc_exc (dcl, dcRST_|dcRT_|dcRSX_)

	fine rd_rst (ctl) if ctl->Vrst|ctl->Vrt
	fine rd_rsx (ctl) if ctl->Vrsx

	fine if !rt_dst (ctl->Aspc, &dst, "")

	if (dst.Vdsw & 0377) eq dvFX
	.. fine rd_rsx (ctl)
	fine rd_rst (ctl)
  end
code	rd_rst - remove RUST directory

  func	rd_rst
	ctl : * rdTctl
  is	spc : [mxSPC] char
	dis : * char = ctl->Aspc

	dp_rsx (dis, spc)
	dp_ter (spc, spc, dpMHT_|dpRMT_)
	fi_def (spc, "DK:.DSK", spc)
	if !st_fnd (".DSK", spc)
	.. fail im_rep ("E-Directories must have file type .DSK [%s]", dis)
	if !fi_exs (spc, <>)
	.. fail im_rep ("E-No such directory [%s]", dis)

; ???	Should check directory for files, system files, protection

	if !ctl->Vnoq
	   st_upr (spc)
	.. fail if !rt_qry (spc, "/Remove", <>)

	if !fi_unp (spc, <>)		; unprotect
	||!fi_del (spc, <>)		; delete
	.. fail im_rep ("Error removing directory [%s]", dis)
	fine
  end
code	rd_rsx - remove RSX directory

	dvFX := 0206

  func	rd_rsx
	ctl : * rdTctl
  is	dis : * char = ctl->Aspc
	spc : [mxSPC] char
	dst : rtTdst
	lst : * char
	fil : * FILE
	buf : WORD

	dp_rsx (dis, spc)
	dp_ter (spc, spc, dpMHT_|dpRMT_)

	fi_def (spc, "DK:.DIR", spc)
	if !st_fnd (".DIR", spc)
	.. fail im_rep ("E-Directories must have file type .DIR %s", dis)

	if !rt_dst (spc, &dst)
	.. fail im_rep ("E-Invalid device %s", spc)

	if (dst.Vdsw & 0377) ne dvFX
	.. fail im_rep ("E-Not an RSX-11 volume %s", dis)

	if fi_mis (spc, <>)
	.. fail im_rep ("E-No such directory %s", dis)

	if (fil = fi_opn (spc, "wb", "")) eq
	|| fi_rea(fil, buf, 2) eq
	|| fi_clo (fil, "") eq
	.. fail im_rep ("E-Error accessing directory %s", dis)

	if buf
	.. fail im_rep ("E-Directory must be empty %s", dis)

	if !ctl->Vnoq
	   st_upr (spc)
	.. fail if !rt_qry (spc, "/Remove", <>)

	if fi_del (spc, "") eq
	.. fail im_rep ("E-Error deleting directory %s", dis)
	fine
  end

end file

