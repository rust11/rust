file	rsx
include rid:rider
include rid:dcdef
include rid:imdef
include rid:mxdef
include rid:rtdev

;	%build
;	rider	cus:rsx/object:cub:rsx
;	link	cub:rsx/exe:cub:/map:cub:/cross,lib:crt/bott:2000
;	%end
;
;	QUIT	
;	SHOW
;	SET
	
	_cuABO := "I-RUST/RTX RSX operations utility RSX V1.0"

  type	cuTctl
  is	Pdcl : * dcTdcl
	Hfil : * FILE 
	Asp0 : [mxSPC] char
  end
	ctl : cuTctl = {0}

  init	cuAhlp : [] * char
  is
       "EXIT		Exit to RTX"
       "QUIT    	Return to RSX"
;      "SET TIME    	Set system time"
;      "SHOW CONFIG   	Show configuration"
       "SHOW FEATURES	Show RSX installed features"
       "HELP		Display this help frame"
       "ABOUT		Display app information"
	<>
  end
	cu_qui : dcTfun
	cu_fea : dcTfun

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is
     1,	"AB*OUT",	dc_rep, _cuABO,	0, dcEOL_
     1,	"EX*IT",	dc_exi, <>,	0, dcEOL_
     1,	"HE*LP",	dc_hlp, cuAhlp,	0, dcEOL_

     1, "QU*IT",	cu_qui, <>,	0, dcEOL_

     1,	"SH*OW",	dc_kwd, <>,	0, dcNST_
      2, "FE*ATURES",	cu_fea, <>, 	0, dcEOL_
      2, <>,		cu_fea,	<>,	0, dcEOL_

     0,	 <>,		<>,	<>,	  0, 	0
  end
code	start

  func	start
  is	im_ini ("RSX")
	if !rs_det ()
	   im_rep ("E-Not running under RSX")
	.. im_exi ()
	ctl.Pdcl = dc_alc ()
	dc_eng (ctl.Pdcl, cuAdcl, "RSX> ")
  end

;	exit RSX app

  func	cu_exi
	dcl : * dcTitm
  is	im_exi ()
  end

;	quit RTX

  func	cu_qui
	dcl : * dcTitm
  is	rs_exi ()
  end
code	show features

  type	loTfea
  is	Vcod : int
	Pstr : * char
  end

  init	loAfea : [] loTfea
  is	1, "22-bit"
	2, "Multi-user protection"
	3, "Executive 20k support"
	4, "Loadable drivers"
	5, "PLAS"
	6, "Dynamic checkpoint allocation"
	7, "I/O packet preallocation"
	8, "Extend Task directive"
	9, "LSI-11"
	10, "Parent/offspring tasking"
	11, "Full-duplex terminal"
	12, "X.25 CEX loaded"
	13, "Dynamic memory allocation"
	14, "Comm Exec loaded"
	15, "MCR exits after each command"
	16, "Logins disabled"
	17, "Kernel data space enabled"
	18, "Supervisor mode libraries"
	19, "Multiprocessing"
	20, "Event trace feature"
	21, "CPU accounting"
	22, "Shadow recording"
	23, "Secondary pools"
	24, "Secondary pool windows"
	25, "Separate directive partition"
	26, "Install, run, remove"
	27, "Group global event flags"
	28, "Receive/send data packets"
	29, "Alternate headers"
	30, "Round-robin scheduling"
	31, "Executive level disk swapping"
	32, "TCB event flag mask"
	33, "Spontaneous system crash"
	34, "XDT system crash"
	35, "EIS required"
	36, "Set System Time directive"
	37, "User data space"
	38, "Secondary pool prototype TCBs"
	39, "External task headers"
	40, "ASTs"
	41, "RSX-11S system"
	42, "Multiple CLIs"
	43, "Separate terminal driver pool"
	44, "Pool monitoring"
	45, "Watchdog timer"
	46, "RMS record locking"
	47, "Shuffler"
	0, <>
  end

  init	loAemt : [] WORD
  is	(2*256)+177		; FEAT$
	0			; feature number
  end

code	rsx features

  func	cu_fea
	dcl : * dcTdcl
  is	fea : * loTfea = loAfea
	res : int
	while fea->Vcod
	   loAemt[1] = fea->Vcod
	   rs_emt (loAemt, &res)
	   if res eq
	   elif res eq 2
	      PUT("%s\n", fea->Pstr)
	   else
	   .. fine im_rep ("W-features not supported")
	   ++fea
	end
	fine
  end
