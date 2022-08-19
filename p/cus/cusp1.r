file	cusp1
include rid:rider
include rid:dcdef
include rid:imdef
include rid:mxdef
include rid:dpdef

;	%build
;	rider	cus:cusp1/object:cub:cusp1
;	link	cub:cusp1/exe:cub:/map:cub:/cross,lib:crt/bott:2000
;	%end
	
	_cuABO := "?CUSP-I-RUST CUSP V1.0"

  type	cuTctl
  is	Pdcl : * dcTdcl
	Hfil : * FILE 
	Asp0 : [mxSPC] char
	Asp1 : [mxSPC] char
	Qbrf : int 		; /BRIEF
  end
	ctl : cuTctl = {0}

  init	cuAhlp : [] * char
  is   "ABOUT		Display image version information"
       "DIRECTORY [spec]Display directory"
       "EXIT		Return to system"
       "HELP		Display this help frame"
	<>
  end

	cu_dir : dcTfun
	cu_cop : dcTfun

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is
     1,	"AB*OUT",	dc_rep, _cuABO,	0, dcEOL_
     1,	"EX*IT",	dc_exi, <>,	0, dcEOL_
     1,	"HE*LP",	dc_hlp, cuAhlp,	0, dcEOL_

     1,	"DI*RECTORY",	dc_act, <>,	0, dcNST_
;
;	DIRECTORY action routines
;
      2,  <>,		dc_fld,ctl.Asp0,32,dcSPC|dcOPT_
      2,  <>,		cu_dir, <>, 	0, dcEOL_
;
;     Qualifiers are listed following the action routines
;
      2,  "BR*IEF",	dc_set,&ctl.Qbrf,1,dcOPT_
;
     1,	"CO*PY",	dc_act, <>,	  0,	dcNST_
      2,  <>,		dc_fld, ctl.Asp0, 32,	dcSPC
      2,  <>,		dc_fld, ctl.Asp1, 32,	dcSPC
;     2,  <>,		dc_fld, ctl.Asp0, 632,	dcSPC|dcLST_
      2,  <>,		cu_cop, <>, 	  0, 	dcEOL_
      2,  "/BR*IEF",	dc_set, &ctl.Qbrf,1, 	dcOPT_
     0,	 <>,		<>,	<>,	  0, 	0
  end
code	start

  func	start
  is	im_ini ("CUSP")
	ctl.Pdcl = dc_alc ()
;	ctl.Pdcl->Venv |= dcDBG_
	dc_eng (ctl.Pdcl, cuAdcl, "CUSP> ")
  end

	pth : dpTpth = {0}
	nam : dpTnam = {0}

  func	cu_dir
	dcl : * dcTitm
  is	spc : * char = ctl.Asp0
	fail if !dp_scn (&pth, spc, dpPER_, "")
	while dp_nam (&pth, &nam, "") 
	   PUT("%s\n", nam.Anam)
	end
  end

  func	cu_cop
	dcl : * dcTitm
  is	PUT("src=[%s]", ctl.Asp0)
	PUT("dst=[%s]", ctl.Asp1)
	PUT("brf=%d ", ctl.Qbrf)
	PUT("\n")
  end
