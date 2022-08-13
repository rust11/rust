file	exdcl - DCL interface
include rid:rider
include	exb:exmod

  func	ex_dcl
  is	dcl : * dcTdcl

	dcl = ctl.Pdcl = dc_alc ()	; allocate DCL control block
	dcl->Venv = dcCLI_|dcCLS_	; DCL as CLI and single line command 
					;
	dc_eng (dcl, cuAdcl, "EXPAT> ")	; DCL does all command processing
  end

  func	ex_dco
  is	nothing
  end

;	DCL command syntax
;
;	/OWNER

  init	cuAdat : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
      2,  "/BE*FORE",	dc_fld, &ctl.Abef, 32,	dcSPC|dcASS_
      2,  "/DA*TE",	dc_fld, &ctl.Adat, 32,	dcSPC|dcASS_
      2,  "/NE*WFILES",	dc_set, &ctl.Qnew, 1,	0
      2,  "/SI*NCE",	dc_fld, &ctl.Asin, 32,	dcSPC|dcASS_
      2,  "/EX*CLUDE",	dc_fld, &ctl.Aexc, 32,	dcSPC|dcASS_
      2,  "/LO*G",	dc_set, &ctl.Qlog, 1,	0
      2,  "/PA*USE",	dc_set, &ctl.Qpau, 1,	0
      2,  "/PA*GE",	dc_set, &ctl.Qpau, 1,	0
      2,  "/QU*ERY",	dc_set, &ctl.Qque, 1,	0
      2,  <>,		<>, <>, 	   0,	dcRET_
  end

  init	cuAdcl : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
     1,	"HE*LP",	dc_hlp, cuAhlp,	   0, 	dcEOL_
  
;    1,	"IN*DEX",	dc_act, <>,	   0,	dcNST_
;     2,  <>,		dc_fld, ctl.Astr,  32,	dcSTR
;     2,  <>,		cm_idx, <>, 	   0, 	dcEOL_

     1,	"CO*PY",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
      2,  <>,		dc_fld, Idst.Aspc, 32,	dcSPC
;     2,  <>,		dc_fld, ctl.Asp0,  632,	dcSPC|dcLST_
      2,  <>,		cv_cop, <>, 	   0, 	dcEOL_
      2,  "/AS*CII",	dc_set, &ctl.Qasc, 1,	0
      2,  "/SE*TDATE",	dc_set, &ctl.Qdat, 1,	0
      2,  "/SE*VENBIT",	dc_set, &ctl.Q7bt, 1,	0
      2,  <>,		<>, 	cuAdat,	   0,	dcCAL_

;    1,	"DE*LETE",	dc_act, <>,	   0, 	dcNST_
;     2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
;     2,  <>,		cv_del, <>, 	   0, 	dcEOL_

     1,	"DI*RECTORY",	dc_act, <>,	   0, 	dcNST_
      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC|dcOPT_
      2,  <>,		cv_dir, <>, 	   0, 	dcEOL_
      2,  "/BR*IEF",	dc_set, &ctl.Qbrf, 1,	0
      2,  "/FU*LL",	dc_set, &ctl.Qful, 1,	0
      2,  "/LI*ST",	dc_set, &ctl.Qlst, 1,	0
      2,  "/OC*TAL",	dc_set, &ctl.Qoct, 1,	0
      2,  "/OU*TPUT",	dc_fld, Idst.Aspc, 32,	dcSPC|dcASS_
If Win
      2,  "/EX*ECUTE",	dc_fld, &ctl.Aexe, 64,	dcSPC|dcASS_
End
      2,  "/XX*DP",	dc_set, &ctl.Qxdp, 1,	0
      2,  "/AN*ALYSE",	dc_set, &ctl.Qana, 1,	0
      2,  "/EM*T",	dc_set, &ctl.Qemt, 1,	0
      2,  "/DR*S",	dc_set, &ctl.Qdrs, 1,	0
      2,  "/PA*SS",	dc_set, &ctl.Qpas, 1,	0
      2,  "/SE*ARCH",	dc_fld, &ctl.Asch, 64,	dcSTR|dcASS_
      2,  "/XM*",	dc_set, &ctl.Qxmx, 1,	0
      2,  <>,		<>, 	cuAdat,	   0,	dcCAL_

;    1,	"RE*NAME",	dc_act, <>,	   0,	dcNST_
;     2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
;     2,  <>,		dc_fld, Idst.Aspc, 32,	dcSPC
;     2,  <>,		cv_ren, <>, 	  0, 	dcEOL_
;      2,  <>,		<>, 	cuAdat,	   0,	dcCAL_

     1,	"TY*PE",	dc_act, <>,	   0, 	dcNST_
      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
      2,  <>,		cv_typ, <>, 	   0, 	dcEOL_
      2,  "/SE*VENBIT",	dc_set, &ctl.Q7bt, 1,	0
      2,  <>,		<>, 	cuAdat,	   0,	dcCAL_

;    1,	"XX*RT",	dc_act, <>,	   0, 	dcNST_
;     2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC|dcOPT_
;     2,  <>,		cm_xdp, <>, 	   0, 	dcEOL_

     0,	 <>,		<>,	<>,	   0, 	0
  end
