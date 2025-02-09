.if ne 0
file	split
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:rtcsi

;	%build
;	macro cus:split.r/object:cub:split.inf
;	rider cus:split/object:cub:
;	link cub:split(.inf,.obj)/exe:cub:/map:cub:,lib:crt/cross
;	%end

	csi    : csTcsi = {0}
	cuVhlf : WORD
	cuVhlp : WORD
	cuVbnd : WORD
	cuVfls : WORD
	cuAsrc : [16] char
	cuAdst : [16] char
	cuAbnd : [3] WORD

  func	start
  is 	swi : * csTswi
	opt : * csTspc~
	src : * FILE = <>
	dst : * FILE = <>
	ext : fxText
	tot : WORD
	bnd : int
	cnt : int
	err : int
	blk : int
	im_ini ("SPLIT")		; who we are
     repeat
	fi_prg (src, <>) if src		;
	fi_prg (dst, <>) if dst		;
	src = dst = <>			;
	cuVhlf = cuVbnd = cuVfls = 0	;
	opt = &csi.Aopt			;
					;
	csi.Pidt = "?SPLIT-I-SPLIT V1.0 (c) HAMMONDsoftware 2004"
	csi.Pnon = "2H"			; no value
	csi.Popt = <>			; optional value
	csi.Preq = "B"			; required value
	csi.Pexc = <>			; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
;PUT("a=%d b=%d c=%d\n", opt[0].Valc, opt[1].Valc, opt[2].Valc)
	swi = csi.Aswi
	err = 0
	me_clr (cuAbnd, #cuAbnd)
	cnt = 0
	while swi->Vcha
	   case swi->Vcha
	   of 'B'  ++cnt if cuVbnd++ eq
		   quit ++err if cuVbnd gt 2
		   opt++->Valc = swi->Vval
	   of '2'  ++cuVhlf, ++cnt
	   of 'H'  ++cuVhlp, ++cnt
	   end case
	   ++swi
	end
	opt = &csi.Aopt
	++err if cuVhlf && opt[2].Pspc
	next cs_inv () if err || (cnt ne 1)
	next cu_hlp () if cuVhlp
	next if !cs_val (&csi, 011, 017)	; required, permitted

	fi_def (csi.Aipt[0].Pspc, "dk:", cuAsrc); input file
	src = fi_opn (cuAsrc, "rb", "")		; open the file
	next if fail				;
	tot = fi_len (src) >> 9			; get total size
	if cuVhlf
	   opt[0].Valc = tot/2
	.. opt[1].Valc = 0

	next if !cu_bnd (opt, tot, bnd)
	blk = 0
	while opt->Valc
	   ext.Valc = opt->Valc
	   if opt->Pspc
	      fi_def (opt->Pspc, "dk:", cuAdst)	; input file
	      dst = fx_opn (cuAdst, "wb", "", &ext)
	      quit if fail
	      if !rt_trn (src, dst, blk, 0, opt->Valc)
	      .. quit im_rep ("E-Error transferring file", cuAdst)
	   .. quit if !fi_clo (dst, "")
	   blk += opt->Valc
	   ++opt
	end
     forever
  end

code	cu_bnd - check boundary conditions

  func	cu_bnd
	opt : * csTspc~
	tot : WORD	
	bnd : int
  is	al0 : int~ = opt[0].Valc
	al1 : int~ = opt[1].Valc
	tmp : int
;PUT("a=%d b=%d c=%d\n", opt[0].Valc, opt[1].Valc, opt[2].Valc)
	if al0 ge tot	; no way
	|| al1 ge tot
	.. fail im_rep ("E-Split exceeds file size", <>)
	if al1 && (al0 gt al1)
	.. tmp = al0, al0 = al1, al1 = tmp
	opt[0].Valc = al0
	if al1
	   opt[1].Valc = al1-al0
	   opt[2].Valc = tot-al1
	else
	   opt[1].Valc = tot-al0
	   opt[2].Valc = 0
	end
;PUT("a=%d b=%d c=%d\n", opt[0].Valc, opt[1].Valc, opt[2].Valc)
	fine
  end

  func	cu_hlp
  is	PUT("SPLIT\n")
	PUT("\n")
	PUT("If M is a file of 20 blocks, then:\n")
	PUT("\n")
	PUT("*A,B,C=M/B:5:10  A = M[0..4]\n")
	PUT("                 B = M[5..9]\n")
	PUT("                 C = M[10..19]\n")
	PUT("\n")
	PUT("*A,B=M/2         A = M[0..9]\n")
	PUT("                 B = M[10..10]\n")
	PUT("\n")
	PUT("Any output file may be omitted.\n")
	PUT("\n")
  end

end file
.endc
.title	split
.include "lib:rust.mac"

	$imgdef	SPLIT 1 0
	$imginf	fun=sav aut=ijh use=<RUST file split utility SPLIT.SAV>
	$imgham	yrs=<2008> oth=<>
;	%date
	$imgdat	<22-Dec-2008 02:11:42.22>
;	%edit
	$imgedt	<35   >

.end
                                                                                                             