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

	ddSG0 := 0176761
	ddSG1 := 0066666
	ddLEN := 1024
	ddASC := 1
	ddIPT := 2
	ddOPT := 3

  type	ddTrep
  is	Vsg0 : int		; signature #1
	Vsg1 : int		; signature #2
	Pbas : * char		; buffer pointer
	Pnxt : * char		; next byte in buffer
	Plim : * char		; buffer end pointer
	Vlen : int		; buffer length
	Abuf : [ddLEN] char	; buffer
  end

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
	cu_fnd : () *rtTdst

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
  is	rep : * ddTrep
	if (rep = cu_fnd()) ne
	.. rep->Pnxt = rep->Pbas
	fine
  end

code	cm_rep - report command

  func	cm_rep
	dcl : * dcTdcl
  is	fine cu_rep ("TT:")
  end

code	cm_sav - save command

  func	cm_sav
	dcl : * dcTdcl
  is	fine cu_rep (cuAopt)
  end

code	cu_rep - report utility

	DIS(fmt,str) := fprintf (opt,fmt,str)

  func	cu_rep
	spc : * char
  is	opt : * FILE
	rep : * ddTrep
	nxt : * char
	lim : * char
	dir : int = -1

	fail if (rep = cu_fnd()) eq

	if rep->Pnxt eq rep->Pbas
	.. fine im_rep ("I-Report buffer is empty", <>)

	opt = fi_opn (spc, "wb", "")
	pass fail

	nxt = rep->Pbas
	lim = rep->Pnxt

	while nxt ne lim
	   case *nxt++
	   of ddASC
	      DIS("%c ", *nxt++)
	   of ddIPT
	      DIS("=", <>) if dir ne ddIPT
	      DIS("%o ", *nxt++ & 255)
	      dir = ddIPT
	   of ddOPT
	      DIS(">", <>) if dir ne ddOPT
	      DIS("%o ", *nxt++ & 255)
	      dir = ddOPT
	   of other
	      fi_prg (opt, "")
	      fail im_rep ("E-Report buffer is garbage", <>)
	   end case
 	end
	DIS("\n", <>)
	fi_clo (opt, "")
 	fine
  end

code	cu_fnd - find the DD: report buffer

  func	cu_fnd
	()  : * ddTrep
  is	drv : * WORD
	dst : rtTdst
	cnt : int = 2000

	if !rt_dst ("DD:", &dst)
	|| (drv = <*WORD>dst.Vent) eq
	.. fail im_rep ("W-DD: not loaded", <>)

	while cnt--
	   if drv[0] eq ddSG0 && drv[1] eq ddSG1
	   .. reply <*ddTrep>drv
	   ++drv
	end

	fail im_rep ("DD: report buffer not found", <>)
  end
