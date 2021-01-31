;+++;	KANDR declar
;+++;	GEEK processes must return to engine when possible
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
;
;	add MOUSE
;	flakey return
;	config text
;	rmon text and move offset
;	check for XM required
;	devices
;	baud needs csr
;	rmon config|devices|etc
;
file	GEEK - programmer tool box
include	rid:rider
include	rid:dcdef
include	gkb:gkmod
include rid:imdef

	_cuABO := "I-RUST toolbox GEEK.SAV V1.0"	; ABOUT string

  type	cuTctl
  is	Pdcl : * dcTdcl
	V1   : int
  end
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
       "CPU         Force a cpu trap"
       "FLAKEY      Test process memory"
       "HALT        Halt the processor"
       "KEYBOARD    Show input codes"
       "LOWMAP      Show protected vectors"
       "MACHINE     Show PDP-11 machine"
       "MEMORY      Show I/O addresses"
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
     2,  <>,		dc_val,&ctl.V1,0,dcOCT|dcOPT_
     2,  <>,		cu_bau, <>,	0, dcEOL_
     1,	"BP*T",		gk_bpt, <>,	0, dcEOL_
     1,	"BU*S",		gk_bus, <>,	0, dcEOL_
     1,	"CO*NFIG",	gk_cfg, <>,	0, dcEOL_
     1,	"CP*U",		gk_cpu, <>,	0, dcEOL_
     1,	"FL*AKEY",	gk_flk, <>,	0, dcEOL_
     1,	"HA*LT",	gk_hlt, <>,	0, dcEOL_
     1,	"KE*YBOARD",	gk_kbd, <>,	0, dcEOL_
     1,	"LO*WMAP",	gk_low, <>,	0, dcEOL_
     1,	"MA*CHINE",	en$sta, <>,	0, dcEOL_
     1,	"ME*MORY",	cu_mem, <>,	0, dcEOL_
     1,	"PD*P*",	gk_pdp, <>,	0, dcEOL_
     1,	"PQ*",		gk_pqt, <>,	0, dcEOL_
     1,	"RA*DIX",	gk_rad, <>,	0, dcEOL_
     1,	"RE*SET",	gk_res, <>,	0, dcEOL_
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
