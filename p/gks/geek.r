;&&&;	ITS:LOGICA
;&&&;	KANDR declar
;&&&;	GEEK processes must return to engine when possible
;
;	SETUP CONSOL
;	SETUP DATIME
;	SETUP CLOCK
;	MORPH SPLIT
;
;	Some need kernel vector
;
;	PSECT in-file [out-file]
;	GLOBALS in-file [out-file]
;
;	add MOUSE
;	flakey return
;	config text
;	rmon text and move offset
;	check for XM required
;	devices
;	baud needs csr
;	rmon config|devices|etc
file	GEEK - programmer tool box
include	rid:rider
include	rid:dcdef
include	gkb:gkmod
include rid:imdef

	_cuABO := "I-RUST toolbox GEEK.SAV V1.0"	; ABOUT string

	ctl : cuTctl = {0}

code	cuAdcl - DCL processing

  init	cuAhlp : [] * char
  is   "ABOUT       Show GEEK info"
       "EXIT        Return to system"
       "HELP        Show this help"
       "ASCII       Show ASCII chart"
       "BAUD csr    Show baud rate"
       "BPT         Force a bpt trap"
       "BUS         Force a bus trap"
       "CONFIG      RT-11 CONFIG states"
;      "CONSOLE     Set console I/O addresses"
       "CONTROL     Show control keys"
       "CPU         Force a cpu trap"
       "FLAKEY      Test process memory"
       "DISPLAY     Display string"
       "DLV csr     Report DLV11 input"
       "HALT        Halt the processor"
       "HRESET      Issue RT-11 .HRESET"
       "KEYBOARD    Show input codes"
       "LOWMAP      Show protected vectors"
       "MACHINE     Show PDP-11 machine"
       "MEMORY      Show I/O addresses"
       "MSCP        Issue MSCP reset"
       "PQ          Show PQ pattern"
       "PDP         Show PDP-11 opcodes"
       "RADIX       Convert octal, decimal etc."
       "RESET       Issue hardware reset"
       "RMON        Show RMON state"
       "RTX file    Show RTX context"
       "SLOTS       Display device slots"
       "SNAIL       Snail-walk memory test"
       "VECTOR adr  Check vector"
;	0	8	16	24	32	40	
	<>
  end

	en$sta : ()+

	cu_bau : dcTfun
	cu_hlp : dcTfun
	cu_mem : dcTfun

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is 1,	"AB*OUT",	dc_rep, _cuABO,	0, dcEOL_
     1,	"HE*LP",	cu_hlp,	<>,	0, dcEOL_
     1,	"EX*IT",	dc_exi, <>,	0, dcEOL_

     1, "AS*CII",	gk_asc, <>,	0, dcEOL_
     1,	"BA*UD",	dc_act, <>,	0, dcNST_
     2,  <>,		dc_val,&ctl.V1, 0, dcOCT|dcOPT_
     2,  <>,		cu_bau, <>,	0, dcEOL_
     1,	"BP*T",		gk_bpt, <>,	0, dcEOL_
     1,	"BU*S",		gk_bus, <>,	0, dcEOL_
     1,	"CONF*IG",	gk_cfg, <>,	0, dcEOL_
     1,	"CONT*ROL",	gk_ctl, <>,	0, dcEOL_
     1,	"CP*U",		gk_cpu, <>,	0, dcEOL_
     1,	"DI*SPLAY",	dc_act,	<>,	0, dcNST_
      2,  <>,		dc_fld,&ctl.Astr,64,dcSTR
      2,  <>,		gk_dis, <>, 	0, dcEOL_
     1,	"DL*V",		dc_act,	<>,	0, dcNST_
      2,  <>,		dc_val,&ctl.Vcsr,0, dcOCT
      2,  <>,		gk_dlv, <>, 	0, dcEOL_
     1,	"FL*AKEY",	gk_flk, <>,	0, dcEOL_
     1,	"HA*LT",	gk_hlt, <>,	0, dcEOL_
;    1,	"HR*ESET",	gk_hrs, <>,	0, dcEOL_
     1,	"HR*ESET",	dc_act, <>,	0, dcNST_
      2,  <>,		dc_fld,&ctl.Aspc,64,dcSPC|dcOPT_
      2,  <>,		gk_hrs, <>, 	0, dcEOL_
     1,	"KE*YBOARD",	dc_act,	<>,	0, dcNST_
      2,  <>,		gk_kbd, <>, 	0, dcEOL_
      2, "/CO*MMENT",	dc_set,&ctl.Qcmt,1,0
     1,	"LO*WMAP",	gk_low, <>,	0, dcEOL_
     1,	"MA*CHINE",	gk_mch, <>,	0, dcEOL_
     1,	"ME*MORY",	cu_mem, <>,	0, dcEOL_
;    1,	"MS*CP",	gk_mrs, <>,	0, dcEOL_
     1,	"MS*CP",	dc_act, <>,	0, dcNST_
      2,  <>,		dc_fld,&ctl.Aspc,64,dcSPC|dcOPT_
      2,  <>,		gk_mrs, <>, 	0, dcEOL_
     1,	"PD*P*",	gk_pdp, <>,	0, dcEOL_
     1,	"PQ*",		gk_pqt, <>,	0, dcEOL_
     1,	"RA*DIX",	gk_rad, <>,	0, dcEOL_
;    1,	"RE*SET",	gk_res, <>,	0, dcEOL_
     1,	"R*ESET",	dc_act, <>,	0, dcNST_
      2,  <>,		dc_fld,&ctl.Aspc,64,dcSPC|dcOPT_
      2, "/NU*LL",	dc_set,&ctl.Qnul,1,0
      2,  <>,		gk_res, <>, 	0, dcEOL_
     1,	"RT*X",		gk_rtx, <>,	0, dcEOL_
     1,	"RM*ON",	gk_rmn, <>,	0, dcEOL_
     1,	"SL*OTS",	gk_slo, <>,	0, dcEOL_
     1,	"SN*AIL",	gk_sna, <>,	0, dcEOL_
     1,	<>,		<>, 	<>,	0, dcEOL_
     0,	 <>,		<>,	<>,	0, dcEOL_
  end

  func	start
  is	im_ini ("GEEK")
	ctl.Pdcl = dc_alc ()
	dc_eng (ctl.Pdcl, cuAdcl, "GEEK> ")
  end

  func	cu_hlp
	dcl : * dcTdcl
  is	im_hlp (cuAhlp, 2)
	PUT("\nSome tests require [ctrl/c] to terminate\n\n")
	fine
  end

  func	cu_map
	str : * char
  is	fine if !rt_xmm ()
	im_rep ("E-RUST/SJ required for %s", str)
	fine
  end

  func	cu_mem
	dcl : * dcTdcl
  is	fine if rt_xmm ()
	gk_mem (dcl)
	fine
  end

  func	cu_bau
	dcl : dcTdcl
  is	cu_map ("BAUD")
	gk_bau (ctl.V1)
	fine
  end

  func	gk_dis
	dcl : dcTdcl
  is	str : * char = ctl.Astr
	st_eli ("\"", str, str)

	PUT("%s\n", ctl.Astr)
	fine
  end
code	gktmo - timeout test
include	rid:tidef

	Ibef : tiTval = {}
	Isee : tiTval = {}
	Hfil : * FILE = <>

  func	gk_bef
  is	fil : * FILE = &Hfil
	buf : [2] char

	if ctl.Aspc[0]		; specified a device?
	   fil = Hfil = fi_opn (ctl.Aspc, "r+", "")
	   im_exi () if fail	; oops
	.. ;fi_rea (fil, buf, 2); seek to block zero

	gk_wai ()		; wait for terminal inactive
	ti_clk (&Ibef)		; store before clock time
	fail ti_wai (3000L) if ctl.Qnul
	fine
  end

  func	gk_aft
  is	fil : * FILE = Hfil
	aft : tiTval
	elp : tiTval
	see : tiTval
	plx : tiTplx
	buf : [2] char

;	ti_wai (1000L)
	ti_clk (&aft)		; store after clock time

	if fil ne		; got a file
	   fi_see (fil, 2048L, "") ; seek to block 4
	   fi_rea (fil, buf, 2)	; read
;	   ti_wai (1000L)
	   ti_clk (&see)	; store the time
	.. fi_clo (fil)		;

	ti_sub (&Ibef, &aft, &elp) ; get difference (elapsed time)
	ti_plx (&elp, &plx)
	PUT("%02d:%02d:%02d ", 
	   plx.Vhou, plx.Vmin, plx.Vsec)

	fine if !fil

	ti_sub (&Ibef, &see, &elp) ; get difference (seek time)
	ti_plx (&elp, &plx)
	PUT("%02d:%02d:%02d ", 
	plx.Vhou, plx.Vmin, plx.Vsec)
	gk_zap ()
  end
