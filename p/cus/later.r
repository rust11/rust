.if ne 0
file	LATER - RUST LATER utility
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:mxdef
include	rid:rtcsi
include	rid:qddef
include	rid:tidef

;	%build
;	macro cus:later.r/object:cub:later.inf
;	rider cus:later/object:cub:later
;	link cub:later(.inf,.obj)/exe:cub:/map:cub:,lib:crt/bot:3000/cross
;	%end

  type	cuTctl 
  is	Hlft : * FILE		; left file
	Hrgt : * FILE		; right file
	Alft : [16] char
	Argt : [16] char
	Vmai : int		; /maintenance
	Vqui : int		; /quiet
	Vsel : int		; /selective
	Vver : int		; /verify
  end
	ctl    : cuTctl = {0}
	csi    : csTcsi = {0}

	cu_lat : ()
	cu_put : (*char)

  func	cu_inv
	str : * char
 	lst : * char
  is	*lst = 0
	PUT("?LATER-W-Invalid command [%s]\n", str)
  end
code	start

  func	start
  is	ext : fxText			; allocation
 	swi : * csTswi
	im_ini ("LATER")		; who we are
     repeat
	fi_prg (ctl.Hlft, <>) if ctl.Hlft
	me_clr (&ctl, #cuTctl)		; no switches
				;
	csi.Pidt = "?LATER-I-RUST LATER utility LATER.SAV V1.0"
	csi.Pnon = "MQSV"		; no value
	csi.Popt = ""			; optional values
	csi.Preq = ""			; required value
	csi.Pexc = <>			; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
	swi = csi.Aswi
	while swi->Vcha
	   case swi->Vcha
	   of 'M'   ++ctl.Vmai		; /Maintenance
	   of 'Q'   ++ctl.Vqui		; /Quiet
	   of 'S'   ++ctl.Vsel		; /Selective
	   of 'V'   ++ctl.Vver		; /Verify
	   end case
	   ++swi
	end
	next if !cs_val (&csi, 030, 030)	; required, permitted files

	fi_def (csi.Aipt[0].Pspc, "DK:.", ctl.Alft); left file
	ctl.Hlft = fi_opn (ctl.Alft, "rb", "")	; open the file
	next if fail				;
	fi_clo (ctl.Hlft)			;
;	csi.Aopt[0].Pspc = "TT:" if !csi.Aopt[0].Pspc

	fi_def (csi.Aipt[1].Pspc, "DK:.", ctl.Argt); right file
;	ctl.Hlft = fi_opn (ctl.Argt, "rb", "")	; open the file
;	next if fail				;

;	fi_def (csi.Aopt[0].Pspc, "DK:.", ctl.Aopt); input file
;	ext.Valc = csi.Aopt[0].Valc
;	ctl.Hopt = fx_opn (ctl.Aopt, "wb", "", &ext)  ; open the file
;	next if fail				;

	im_clr ()				; clear status
	cu_lat ()				; later test
     forever
  end
code	cu_lat - later test

  func	cu_lat
  is	lft : tiTval
	rgt : tiTval
	cnd : * char
	snd : * char = ""
	plx : tiTplx
	str : [32] char
	dif : int = 2
	mis : int = 0

	mis |= 1 if !fi_gtm (ctl.Alft, &lft, <>)
	mis |= 2 if !fi_gtm (ctl.Argt, &rgt, <>)

	dif = ti_cmp (&lft, &rgt) if !mis

	if ctl.Vver|ctl.Vmai
	   case mis
	   of 1  cu_put ("W-Left file is missing [%s]")
	   of 2  cu_put ("rI-Right file is missing [%s]")
	   of 3  cu_put ("W-Both files are missing [%s] [%s]")
	   end case

	   case dif
	   of -1  cu_put ("I-%s is earlier than %s")
	   of 0	  cu_put ("I-%s is same age as %s")
	   of 1	  cu_put ("I-%s is later than %s")
	   of 2   nothing
	   end case
	end

	if ctl.Vmai
;	   qd_dmp ("Left: ", <*void>&lft)
;	   qd_dmp (" Right: ", <*void>&rgt)
;	   PUT("\n")
	   ti_plx (&lft, &plx)
	   ti_str (&plx, str)
	   PUT("Left*: %s ", str)
	   ti_plx (&rgt, &plx)
	   ti_str (&plx, str)
	   PUT("Right: %s\n", str)
	end

	if !ctl.Vqui && !ctl.Vmai && !ctl.Vver && (mis & 1)
	.. im_rep ("E-Left file is missing %s", ctl.Alft)

	dif = 0 if ctl.Vsel && (cnd eq 2)
	im_suc () if (mis eq 2) || (dif eq 1)
	im_war ()
  end

  func	cu_put
	str : * char
  is	PUT("?LATER-")
	PUT(str, ctl.Alft, ctl.Argt) if *str ne 'r'
	PUT(++str, ctl.Argt)         otherwise
	PUT("\n")
  end
end file
.endc
.title	LATER
.include "lib:rust.mac"

	$imgdef	LATER 1 0
	$imginf	fun=sav use=<RUST file date compare utility LATER.SAV V1.0>
	$imgham	yrs=<2012> oth=<>
;	%date
	$imgdat	<22-Oct-2012 02:11:42.22>
;	%edit
	$imgedt	<60   >

.end
;	Cusp template. Input file, no wildcards.
;
;	input	output
;	-----	------
;	absent	*		error
;	*	absent		first time, compile
;	nodate 	*		recompile, warn
;	*	nodate		recompile, warn
;	same	same		up to date, do not recompile unless /ALL
;	earlier	later		up to date, ditto
;	later	earlier		new source, recompile
;				or reverted to earlier source
;
;	update input,output,"command"
;	update/changes "command"
;	
;	/all		update all
;	/changes	if any changes
;	/nochanges	if no changes
;	/clear		clear cumulative changed state
;	/info		display information messages
;	/log		log all operations
;	/query		query operations
;	/report		report only
;	/touch		change file date
;	/nowarnings	no warning messages
;
;	$update := goto skip	! initial state
;	$update := $update:	! if changed
