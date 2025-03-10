;???;	CUS:TOUCH.R - Add /QUIET and DCL
;	Cusp3 template. Input file, with wildcards.
.if ne 0
file	Touch - Touch
include	rid:rider
include	rid:ctdef
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:mxdef
include	rid:rtcla
include	rid:rtcsi
include	rid:rtscn
include	rid:tidef

;	%build
;	macro cus:touch.r/object:cub:touch.inf
;	rider cus:touch/object:cub:touch
;	link cub:touch(.inf,.obj)/exe:cub:/map:cub:,lib:crt/bot:3000/cross
;	%end

  type	cuTctl 
  is	Hipt : * FILE		; input file
	Hopt : * FILE		; output file
	Aipt : [16] char
	Aopt : [16] char
	Vany : int		; switch
;	Vver : int		; /verify
  end

  type	cuTipt			; input
  is	Pspc : * char		; file spec
	Icla : fsTcla		; filespec class
	Pfil : * FILE		; file
  end

  type	cuTopt
  is	Pspc : * char		; terminal if null
	Pfil : * FILE		; file
	Iext : fxText		; extension block for allocation
  end

	ctl    : cuTctl = {0}
	csi    : csTcsi = {0}
	ipt    : cuTipt = {0}
	opt    : cuTopt = {0}

	cuPscn : * rtTscn = {0}

	cu_tou : ()
	cuVxxx : int

  func	cu_inv
	str : * char
 	lst : * char
  is	*lst = 0
	PUT("?TOUCH-W-Invalid command [%s]\n", str)
  end
code	start

  func	start
  is	ext : fxText			; allocation
 	swi : * csTswi
	im_ini ("TOUCH")		; who we are
	cuPscn = rt_alc ()		; permanent memory objects
     repeat
	fi_prg (ctl.Hipt, <>) if ctl.Hipt
	me_clr (&ctl, #cuTctl)		; no switches
				;
	csi.Pidt = "?TOUCH-I-RUST file time utility TOUCH.SAV V2.0"
	csi.Pnon = ""			; no value
	csi.Popt = ""			; optional values
	csi.Preq = ""			; required value
	csi.Pexc = <>			; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
;???	cs_val (&csi, 0010, 0771)	; req: 1*ipt+0*opt: 6*ipt+1*opt
;	next if fail			;
	ipt.Pspc = csi.Aipt[0].Pspc	; file specs
	opt.Pspc = csi.Aopt[0].Pspc	; output file, if any
	opt.Iext.Valc = csi.Aopt[0].Valc;
					;
	swi = csi.Aswi
;	while swi->Vcha
;	   case swi->Vcha
;	   of 'A'   ++ctl.Vany		; /A
;	   end case
;	   ++swi
;	end
	next if !cs_val (&csi, 010, 010)	; required, permitted files

;	if ctl.Vopt				; want output
;	   if opt.Pspc && !rt_ter (opt.Pspc)
;	      opt.Pfil = fx_opn (opt.Pspc, "w", "", &opt.Iext)
;	      next if fail
;	   else
;	.. .. opt.Pfil = stdout

	cu_wld ()				; CUSPX it
     forever
  end
code	cu_wld - wildcard driver

; ??	Implement multiple input files

  func	cu_wld
  is	scn : * rtTscn = cuPscn
	pth : [mxPTH] char
	nam : [mxNAM+mxTYP] char
	cnt : int = 0

	fs_cla (ipt.Pspc, &ipt.Icla)	; get wildcard flags
;PUT("ipt=[%s]\n", ipt.Pspc)

	if (ipt.Icla.Vwld & fsPTH_)	; device/directory wildcards
	.. fail im_rep ("E-Invalid wildcards %s", ipt.Pspc)

	if !(ipt.Icla.Vwld & fsFIL_)	; no wildcards
;	   exit if !cu_opn ()		; single file
	.. exit cu_tou ()		;
					;
	fs_ext (ipt.Pspc, pth, fsPTH_)	; extract the path for scanning
	rt_scn (scn, pth, rtPER_, "")	; scan directory
	exit if fail			; nothing doing
					; shouldn't come back for errors
	fs_ext (ipt.Pspc, nam, fsFIL_)	; extract name for matching
;	if ctl.Vver			; wants verification
;	   PUT("?SEARCH-I-Scanning [%s%s]\n", pth, nam)
;	end

      repeat
	fi_prg (ipt.Pfil, <>)		; release files
	rt_wld (scn, nam, ipt.Pspc, "")	; scan another
	quit if fail			; no more or error
	st_ins (pth, ipt.Pspc)		; insert path

	next if !cu_opn ()
	++cnt				;
;	if ctl.Vver
	   PUT("%s\n", ipt.Pspc)
;	end
	quit if !cu_tou ()		; operation failed
      end
	rt_fin (scn)			; finish scan
	if !cnt
	   im_rep ("E-No %s", ipt.Pspc)
	else
	.. im_suc ()			; report success
  end

  func	cu_opn
  is	fine if (ipt.Pfil = fi_opn (ipt.Pspc, "rb", <>))
;	if ctl.Vmis
;	.. PUT("?TOUCH-I-File not located %s\n", ipt.Pspc)
	fail
  end
code	cu_tou - TOUCH

  func	cu_tou
  is	val : tiTval
	ti_clk (&val)
	fi_stm (ipt.Pspc, &val, "")
  end
end file
.endc
.title	TOUCH
.include "lib:rust.mac"

	$imgdef	TOUCH 1 0
	$imginf	fun=sav use=<RUST file time utility TOUCH.SAV V1.0>
	$imgham	yrs=<2008> oth=<>
;	%date
	$imgdat	<25-Jun-2021 00:41:53>   
;	%edit
	$imgedt	<20   >

.end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                           