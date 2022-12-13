file	ddt - DD: test
include	rid:rider
include	rid:dcdef
include	rid:fidef
include	rid:mxdef
include	rid:stdef
include	rid:rtdev

;	%build
;	rider cus:ddt/obj:cub:ddt
;	link cub:ddt,lib:crt/exe:cub:ddt/map:cub:ddt/bot=3000
;	%end

data	ddTrep - report structure

	ddLEN := 4*1024
	ddNOP := 0
	ddASC := 1
	ddIPT := 2
	ddOPT := 3

  type	ddTrep
  is	Vcnt : int
	Abuf : [ddLEN] char
  end

	Irep : ddTrep = {0}

  init	cuAhlp : [] * char
  is   "DD: report DDT.SAV"
	""
       "EXIT       Return to system"
       "HELP       Display help"
       "CLEAR      Clear report"
       "REPORT     Display report"
       "SAVE file  Write report to file"
	<>
	<>
  end

	cm_clr : dcTfun
	cm_rep : dcTfun
	cm_sav : dcTfun
	cu_rep : (*char)
	cu_get : (*<>)
	cu_dis : (*FILE, *char, *char)

	cuAopt : [mxSPC] char

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is 1,	"HE*LP",	dc_hlp,	cuAhlp,	0, dcEOL_
     1,	"EX*IT",	dc_exi,	<>,	0, dcEOL_
     1,	"CL*EAR",	cm_clr,	<>,	0, dcEOL_
     1,	"RE*PORT",	cm_rep,	<>,	0, dcEOL_
     1,	"SA*VE",	dc_act, <>,	0, dcNST_
      2,  <>,		dc_fld, cuAopt,32, dcSPC
      2,  <>,		cm_sav, <>, 	0, dcEOL_
     0,	 <>,		<>,	<>,     0, 0
  end

  func	start
  is	dcl : * dcTdcl
	im_ini ("DDT")
	dcl = dc_alc ()
	dcl->Venv = dcCLI_|dcCLS_
	dc_eng (dcl, cuAdcl, "DDT> ")
  end
code	cm_clr - clear command

  func	cm_clr
	dcl : * dcTdcl
  is	cu_get (&Irep, 0)
	fine
  end

code	cm_rep - report command

  func	cm_rep
	dcl : * dcTdcl
  is	fine cu_rep (<>)
  end

code	cm_sav - save command

  func	cm_sav
	dcl : * dcTdcl
  is	fine cu_rep (cuAopt)
  end

code	cu_rep - report utility

	DIS(fmt,str) := cu_dis (opt, fmt, str)

  func	cu_rep
	spc : * char
  is	opt : * FILE = <>
	rep : * ddTrep = &Irep
	nxt : * char
	cnt : int
	dir : int = -1
	col : int = 0

	fail if !cu_get (rep)

	if !rep->Vcnt
	.. fine im_rep ("I-Report buffer is empty", <>)

	if spc ne
	   opt = fi_opn (spc, "wb", "")
	.. pass fail

	cnt = rep->Vcnt/2
	nxt = rep->Abuf

	DIS("DDT: %d entries\n", cnt)

	while cnt--
	   case *nxt++
	   of ddNOP
	   of ddASC
	      DIS("\n", <>) if *nxt eq 'S'
	      DIS("\n", <>) if *nxt eq 'a'
	      DIS("{%c}", *nxt++)
	      col += 2
	   of ddIPT
	      DIS("=", <>), ++col if dir ne ddIPT
	      col += cu_wid (*nxt & 255)
	      DIS("%o ", *nxt++ & 255)
	      dir = ddIPT
	   of ddOPT
	      DIS(">", <>), ++col if dir ne ddOPT
	      col += cu_wid (*nxt & 255)
	      DIS("%o ", *nxt++ & 255)
	      dir = ddOPT
	   of other
	      fi_prg (opt, "")
	      fail im_rep ("E-Report buffer is garbage", <>)
	   end case
	   DIS("\n", <>), col = 0 if col gt 75
 	end
	DIS("\n", <>) if col ne
	fi_clo (opt, "")
 	fine
  end

  func	cu_wid
	val : int
  is	reply 2 if val lt 10
	reply 3 if val lt 100
	reply 4
  end
code	cu_get - read DD: buffer

	fil : * FILE = <>

  func	cu_get
	buf : * void
  is
	if !fil
	   if (fil = fi_opn ("DD:", "r", "")) eq
	      im_rep ("E-DD: not available", <>)
	.. .. im_exi ()

	me_clr (buf, ddLEN+2)
	rt_rea (fil, -1, buf, ddLEN/2, 1)
	reply that
  end

code	cu_dis - display

  func	cu_dis
	opt : * FILE
	fmt : * char
	str : * char
  is	if opt ne
	   fprintf (opt, fmt, str)
	else
	.. PUT(fmt, str)
  end
end file
