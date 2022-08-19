;+++;	CUS:LDA - Finish it (has good loader too)
;	/ANALYSE
;	/AUTODETECT
;	[/CONVERT]
;	/CONCATENATE
;	/DUMP/INSTRUCTION
;	/EXECUTE		; Formatted binary files only
;	/MERGE (multiple tapes)
;	/SEPARATE
;	/VALIDATE
;
;	READ/XXDP/LDA 
;	PATCH
;
;	LDA X Y/LDA
;	LDA X,Y/CONCATENATE Z
;	LDA X/MERGE Y
;	LDA X/SEPARATE Y[.1,.2.,3]
;
;	LDA in-out
;	XXDP in-out
;	IMAGE in-out
;	SAVE in-out
;
.if ne 0
file	LDA - RUST LDA utility
include	rid:rider
include	rid:ctdef
include	rid:eldef
include	rid:elrev
include	rid:fidef
include	rid:imdef
include	rid:mxdef
include	rid:rtcsi

;	%build
;	macro cus:LDA.r/object:cub:LDA.inf
;	rider cus:LDA/object:cub:LDA
;	link cub:LDA(.inf,.obj)/exe:cub:/map:cub:,lib:crt/bot:3000/cross
;	%end

	DMP(s) := (fprintf(ctl.Hopt, s))
	DMP1(s,a) := (fprintf(ctl.Hopt, s, a))
	DMP2(s,a,b) := (fprintf(ctl.Hopt, s, a, b))
	DMP3(s,a,b,c) := (fprintf(ctl.Hopt, s, a, b, c))

	cuEXE := 0		; execute directly
	cuMAP := 1		; output LDA map
	cuIMG := 2		; output raw image
	cuSAV := 3		; output RT-11 .SAV file
	cuLDA := 4		; output consolidate LDA file

	cuNUM := 1		; Vfmt

  type	cuTctl 
  is	Hipt : * FILE		; input file
	Hopt : * FILE		; output file
	Aipt : [16] char
	Aopt : [16] char
	Vopr : int		; cuMAP, cuIMG etc
	Vexe : int		; /EXECUTE
	Vmap : int		; /MAP
	Vimg : int		; /IMAGE
	Vsav : int		; /SAVE
	Vlda : int		; /LDA

	Vasc : int
	Vfmt : int
	Vbeg : long		;
	Vcnt : long		;
	Vlen : long		; file length
  end
	ctl    : cuTctl = {0}
	csi    : csTcsi = {0}

	cu_fwd : (long, *WORD, int) int

  func	cu_inv
	str : * char
 	lst : * char
  is	*lst = 0
	im_rep ("?LDA-W-Invalid command [%s]\n", str)
  end
code	start

  func	start
  is	ext : fxText			; allocation
 	swi : * csTswi
	lst : [32] char			; switch characters
	ptr : * char
	res : int
	opr : int
	def : * char
	im_ini ("LDA")			; who we are
     repeat
	def = ""
	fi_prg (ctl.Hipt, <>) if ctl.Hipt ; purge hanging input
	fi_prg (ctl.Hopt, <>) if ctl.Hopt ; purge hanging output
	ctl.Hipt = ctl.Hopt = 0		;
					;
	me_clr (&ctl, #cuTctl)		; no switches
	*(ptr=lst) = 0			; no switch list
	csi.Pidt = "?LDA-I-RUST binary image LDA utility LDA.SAV V2.0"
	csi.Pnon = "ELIMS"		;
	csi.Popt = ""			; optional values
	csi.Preq = ""			; required value
	csi.Pexc = "ELIMS"		; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
	swi = csi.Aswi
	ctl.Vasc = 1			; assume ascii
	ctl.Vfmt = cuNUM		; default dump
	while swi->Vcha
	   case swi->Vcha
	   of 'E' ++ctl.Vexe, opr=cuEXE, def=""         ; /EXECUTE
	   of 'I' ++ctl.Vimg, opr=cuIMG, def="DK:.IMG"  ; /IMAGE
	   of 'L' ++ctl.Vlda, opr=cuLDA, def="DK:.LDA"  ; /LDA
	   of 'M' ++ctl.Vmap, opr=cuMAP, def="DK:.MAP"  ; /MAP
	   of 'S' ++ctl.Vsav, opr=cuSAV, def="DK:.SAV"  ; /SAVE
	   end case
	   ++swi
	end
	next if !cs_val (&csi, 010, 011); required, permitted files

	fi_def (csi.Aipt[0].Pspc, "DK:.LDA", ctl.Aipt); input file
	ctl.Hipt = fi_opn (ctl.Aipt, "rb", "")	; open the file
	next if fail			; input file open failed
	ctl.Vcnt = fi_len (ctl.Hipt)	; get file length
	if ctl.Vcnt eq			; zero-length file
	.. next im_rep ("E-Zero-length file %s", csi.Aipt[0].Pspc)

	csi.Aopt[0].Pspc = "TT:" if !csi.Aopt[0].Pspc	; default output to TT:

	fi_def (csi.Aopt[0].Pspc, def, ctl.Aopt)	; output file
	ext.Valc = csi.Aopt[0].Valc
	ctl.Hopt = fx_opn (ctl.Aopt, "wb", "", &ext)	; open the file
	next if fail				

cu_lda ()
	case ctl.Vopr
;	of cuEXE res = cu_exe ()	; /EXECUTE (default)
	of cuLDA res = cu_lda ()	; /LDA
;	of cuIMG res = cu_img ()	; /IMAGE
;	of cuMAP res = cu_map ()	; /MAP
;	of cuSAV res = cu_sav ()	; /SAVE
	end case

	fi_clo (ctl.Hopt) if res	; make output permanent
     forever
  end
code	cu_lda - formatted binary .LDA dump

;	This code analyses an LDA file rather than dumping it.
;	To dump an LDA file it should first be converted using SAVE.SAV.

  type	cuTlda
  is	Vsig : WORD	; 1
	Vcnt : WORD	; byte count, including 
	Vadr : WORD	; load address
	Adat : [1] WORD	; data
  end

  func	cu_lda
  is	lda : cuTlda
	adr : long = ctl.Vbeg
	lst : long = adr + ctl.Vcnt
	res : int = 1
	val : WORD
	prv : WORD = 0
	pnd : int = 0

      while (adr + 6) le lst
	res = 1
	quit if !cu_fwd (adr, &val, 0)
	next adr += 2 if !val
	next adr += 1, DMP(".") if val ne 1
	res = 0
	quit if !cu_fwd (adr+2, &lda.Vcnt, 0)
	quit if !cu_fwd (adr+4, &lda.Vadr, 0)
	res = 1

	if lda.Vcnt eq 6
	   DMP("\n") if pnd
	   pnd = 0
	   DMP1("%06lo:  ", adr)
	   DMP1("Start:%o\n", lda.Vadr) 
	else
	   if pnd && (lda.Vadr lt prv)
	   .. DMP("\n"), pnd = 0

	   if pnd && (lda.Vadr ne prv)
	   .. DMP1(" Gap=%o", lda.Vadr-prv)

	   DMP("\n"), pnd = 0 if pnd

	   DMP1("%06lo:  ", adr)
	   DMP1("Area=%o:", lda.Vadr)
	   DMP1("%o", lda.Vadr+(lda.Vcnt-6))
	   DMP1(" Count=%o", lda.Vcnt-6)
	.. pnd = 1

	prv = lda.Vadr + (lda.Vcnt-6)
	adr += lda.Vcnt + 1
      end
	DMP("\n") if pnd
	fine
  end
code	cu_fwd - fetch word

  func	cu_fwd
	adr : long
	wrd : * WORD
	mut : int
	()  : int
  is	fi_see (ctl.Hipt, adr)
	if fail
	   fail if mut
	.. fail im_rep ("W-Error seeking image %s", ctl.Aipt)
	fi_rea (ctl.Hipt, wrd, 2)
	if fail
	   fail if mut
	.. fail im_rep ("W-Error reading image %s", ctl.Aipt)
	fine
  end

code	cu_asc - store ascii printable

;	/8BIT for upper 128 characters
;	Could do control codes for full-line ascii

  func	cu_asc
	cha : int
	ptr : * char
  is	if (cha&255) ge 32
	&& (cha&255) lt 127
	   *ptr++ = cha
	else
	.. *ptr++ = '.'
	*ptr = 0
  end
end file
code	cu_img - convert to binary image

  type	cuTlda
  is	Vsig : WORD	; 1
	Vcnt : WORD	; byte count, including 
	Vadr : WORD	; load address
	Adat : [1] WORD	; data
  end

  func	cu_img
  is	lda : cuTlda
	adr : long = ctl.Vbeg
	lst : long = adr + ctl.Vcnt
	res : int = 1
	val : WORD
	prv : WORD = 0
	loc : WORD

      while (adr + 6) le lst
	res = 1
	quit if !cu_fwd (adr, &val, 0)
	next adr += 2 if !val
	next adr += 1 if val ne 1
	res = 0
	quit if !cu_fwd (adr+2, &lda.Vcnt, 0)
	quit if !cu_fwd (adr+4, &lda.Vadr, 0)
	res = 1

	if lda.Vcnt eq 6
;	   DMP("\n") if pnd
;	   pnd = 0
;	   DMP1("%06lo:  ", adr)
;	   DMP1("Start:%o\n", lda.Vadr) 
	else
	   while loc lt lda.Vadr
	   .. WRT(0), ++loc
	   while 

	prv = lda.Vadr + (lda.Vcnt-6)
	adr += lda.Vcnt + 1
      end
	DMP("\n") if pnd
	fine
  end
code	dump directory
include	dmmod

;	RT-11/RUST
;	RSX/VMS
;	DOS/XXDP
;	FAT
;
;	ANSII
;	DOS
;	FOREIGN

  func	dm_dir
  is
;	must be rt-11 file structured device

  end
end file
.endc
.title	LDA
.include "lib:rust.mac"

	$imgdef	LDA 3 0
	$imginf	fun=sav use=<RUST LDA utility LDA.SAV V3.0>
	$imgham	yrs=<2011> oth=<>
;	%date
	$imgdat	<22-Dec-2008 02:11:42.22>
;	%edit
	$imgedt	<54   >

.end
