;???;	DUMP - Use DCL to implement in Windows
;???;	CUS:DUMP - needs wildcards, DCL and windows support
;???;	CUS:DUMP - DUMP/INSTRUCTION gets relative addresses wrong
;
;	/IGNORE not implemented
;
;	file length wrong
;	/ASCII
;	/DETAB/TAB
;	/SIGNED/UNSIGNED/LONG
;	/LONG
;	/RECORD
;	/WINDOW;
;	/FORMAT=(ob,dw,rl,)
;
;	/SCRIPT=
;	/NOEIGHT_BIT	Strip bit 8
;	/SKIP[=n]	Skip nulls or value specified
;	/LOCATION=[OCT|DEC|HEX|NONE]
;	/INSTRUCTION
;	/MACRO
;	/LIBRARY
;	/RSX/RT11/RUST
;	/LDA
;	/OBJECT
;	/OBJECT/INST	As MACRO source
;	/VOLUME
;	/DIRECTORY
;
;	Cusp template. Input file, no wildcards.
.if ne 0
file	DUMP - RUST DUMP utility
include	rid:rider
include	rid:btmap
include	rid:ctdef
include	rid:eldef
include	rid:rvpdp
include	rid:fidef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include	rid:rtcsi
;	size := WORD

;	%build
;	macro cus:DUMP.r/object:cub:DUMP.inf
;	rider cus:DUMP/object:cub:DUMP
;	link cub:DUMP(.inf,.obj)/exe:cub:/map:cub:,lib:crt/bot:3000/cross
;	display "Copy DUMP"
;	copy cub:dump.sav sy:
;	%end

	DMP(s) := (fprintf(ctl.Hopt, s))
	DMP1(s,a) := (fprintf(ctl.Hopt, s, a))
	DMP2(s,a,b) := (fprintf(ctl.Hopt, s, a, b))
	DMP3(s,a,b,c) := (fprintf(ctl.Hopt, s, a, b, c))

	cuNUM := 0		; default numeric dump
	cuMAC := 1		; /macro .WORD dump
	cuINS := 2		; /instruction dump
	cuDIR := 3		; /directory 
	cuLDA := 4		; /lda
	cuTAP := 5		; /tape
	cuDIS := 6		; /disassemble
	cuASC := 7		; /ascii

  type	cuTctl 
  is	Hipt : * FILE		; input file
	Hopt : * FILE		; output file
	Aipt : [16] char
	Aopt : [16] char
	Vfmt : int		; cuNUM, cuMAC etc
	Vany : int		; switch
	Vbyt : int		; /BYTES
	Vdec : int		; /DECIMAL
	Vend : int		; /END=n
	Vfor : int		; /FOREIGN
	Vign : int		; /IGNORE
	Voct : int		; /NOOCTAL (0=default,1=/octal,-1=nooctal)
	Vske : int		; /SKELETON
	Vins : int		; /INSTRUCTION
	Vdis : int		; /DISASSEMBLE
	Vdir : int		; /DIRECTORY
	Vmac : int		; /MACRO
	Vlda : int		; /LDA
	Vasc : int		; /NOASCII
	Vonl : int		; /ONLY=n
	Vrsz : int		; /RECORD_SIZE=n
	Vsta : int		; /START=n
	Vwrd : int		; /WORDS
	Vhex : int		; /HEXADECIMAL
	Vr50 : int		; /RAD50
	Vtap : int		; /TAPE
	Vwin : int		; /WINDOW=n
				;
	Vlen : long		; file length
	Vfst : WORD		; first block/record
	Vlst : WORD		; last block/record
				;
	Vbeg : long		; start position
	Vcnt : long		; byte count
  end
	ctl    : cuTctl = {0}
	csi    : csTcsi = {0}

	cu_xxx : (*char, *char, int)
	cuVxxx : int

	cu_fwd : (long, *void, int) int
	cu_rea : (long, *void, size, int) int

  func	cu_inv
	str : * char
 	lst : * char
  is	*lst = 0
	im_rep ("?DUMP-W-Invalid command [%s]\n", str)
  end
code	start dump

  func	start
  is	ext : fxText			; allocation
 	swi : * csTswi
	lst : [32] char			; switch characters
	ptr : * char
	res : int
	im_ini ("DUMP")			; who we are
     repeat
	fi_prg (ctl.Hipt, <>) if ctl.Hipt ; purge hanging input
	fi_prg (ctl.Hopt, <>) if ctl.Hopt ; purge hanging output
	ctl.Hipt = ctl.Hopt = 0		;
					;
	me_clr (&ctl, #cuTctl)		; no switches
	*(ptr=lst) = 0			; no switch list
	csi.Pidt = "?DUMP-I-RUST binary image dump utility DUMP.SAV V2.0"
	csi.Pnon = "BDFTGHIKLMNPWUVX"	; no value
	csi.Popt = ""			; optional values
	csi.Preq = "EORS"		; required value
	csi.Pexc = "IFLMPU"		; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
	swi = csi.Aswi
	ctl.Vasc = 1			; assume ascii
	ctl.Vfmt = cuNUM		; default dump
	while swi->Vcha
	   case swi->Vcha
	   of 'B'   ++ctl.Vbyt		; /BYTES
	   of 'C'   ++ctl.Voct		; /OCTAL
	   of 'D'   ++ctl.Vdec		; /DECIMAL
		      ctl.Voct = 0	;
	   of 'E'     ctl.Vlst=swi->Vval; /END=n
		    ++ctl.Vend		;
	   of 'F'   ++ctl.Vlda		; /LDA (formatted binary)
		      ctl.Vfmt = cuLDA	;
	   of 'G'   ++ctl.Vign		; /IGNORE
	   of 'H'     ctl.Voct = -1	; /NOOCTAL
	   of 'I'   ++ctl.Vins		; /INSTRUCTION
		      ctl.Vfmt = cuINS	;
	   of 'K'   ++ctl.Vske		; /SKELETON
	   of 'L'   ++ctl.Vdir		; /DIRECTORY
		      ctl.Vfmt = cuDIR	;
	   of 'M'   ++ctl.Vmac		; /MACRO
		      ctl.Vfmt = cuMAC	;
	   of 'N'     ctl.Vasc = 0	; /NOASCII
	   of 'O'     ctl.Vfst=swi->Vval; /ONLY=n
	              ctl.Vlst=swi->Vval;
		    ++ctl.Vonl		;
	   of 'P'   ++ctl.Vtap		; /TAPE (SimH)
		      ctl.Vfmt = cuTAP	;
	   of 'R'     ctl.Vrsz=swi->Vval; /RECORD_SIZE=n
	   of 'S'     ctl.Vfst=swi->Vval; /START=n
		    ++ctl.Vsta		;
	   of 'T'   ++ctl.Vfor		; /FOREIGN
	   of 'W'   ++ctl.Vwrd		; /WORDS
	   of 'U'   ++ctl.Vdis		; /DISASSEMBLE
		      ctl.Vfmt = cuDIS	;
	   of 'V'   ++ctl.Vhex		; /HEXADECIMAL
	   of 'X'   ++ctl.Vr50		; /RAD50
	   of 'Y'     ctl.Vwin=swi->Vval; /WINDOW=n
	   end case
	   ++swi
	end
	next if !cs_val (&csi, 010, 011); required, permitted files

	ctl.Voct = 1 if !(ctl.Vdec|ctl.Voct)
	ctl.Voct = 0 if ctl.Voct eq -1

	fi_def (csi.Aipt[0].Pspc, "DK:.SAV", ctl.Aipt); input file
	ctl.Hipt = fi_opn (ctl.Aipt, "rb", "")	; open the file
	next if fail			; input file open failed
	next if !cu_geo ()		; handle file geometry
	fi_see (ctl.Hipt, ctl.Vbeg)	; position us (read will catch errors)

	csi.Aopt[0].Pspc = "TT:" if !csi.Aopt[0].Pspc	; default output to TT:
	fi_def (csi.Aopt[0].Pspc, "DK:.DMP", ctl.Aopt)	; output file
	ext.Valc = csi.Aopt[0].Valc			;
	ctl.Hopt = fx_opn (ctl.Aopt, "w", "", &ext)	; open the file
	next if fail				

	case ctl.Vfmt			; dispatch dump operation
	of cuNUM res = cu_num ()	; default numeric dump
	of cuMAC res = cu_mac ()	; /macro
	of cuINS res = cu_ins ()	; /instruction
	of cuDIS res = cu_dis ()	; /disassemble
	of cuDIR res = cu_dir ()	; /directory
	of cuLDA res = cu_lda ()	; /LDA
	of cuTAP res = cu_tap ()	; /TAPE
	of cuASC res = cu_asc ()	; /ASCII
	end case

	fi_clo (ctl.Hopt) if res	; make output permanent
     forever
  end

code	cu_geo - handle input file geometry

;	The END or LAST block is the last block output.
;	Thus the range 0:3 outputs four blocks, 0, 1, 2 and 3.
;	This approach allows all possible 2^16 blocks to be dumped.

  func	cu_geo
  is
	ctl.Vlen = fi_len (ctl.Hipt)	; get file length
;PUT("len=%ld\n", ctl.Vlen)
	ctl.Vlen = (ctl.Vlen+511)/512	; round up to block
	if ctl.Vlen eq			; zero-length file
	.. fail im_rep ("E-Zero-length file %s", csi.Aipt[0].Pspc)
;PUT("len=%ld\n", ctl.Vlen)

	if !(ctl.Vonl|ctl.Vend)		; default last block
	|| ctl.Vlst ge ctl.Vlen		; silently truncate last block
	.. ctl.Vlst = (ctl.Vlen-1) 	;

	if ctl.Vfst gt ctl.Vlst		;
	.. fail im_rep ("E-Invalid start block", <>)

	ctl.Vbeg = ctl.Vfst		; convert from word to long
	ctl.Vbeg *= 512			;
					;
	ctl.Vcnt = ctl.Vlst-ctl.Vfst	; convert from words to long
	ctl.Vcnt = (ctl.Vcnt+1) * 512	;
	fine
  end
code	cu_num - numeric dump

;SY:DUMP.SAV LBN 1 of 12 (01 of 014) 12-Oct-2008 12:34:45 VMS style
;Block number 1 (1)	SY:DUMP.SAV		RT-11
;SY:DUMP.SAV 1/12				RUST
;000/ 012345 012345 ... 012345 *abcdefgehg*	RT-11
;000: 012345 012345 ... 012345 |abcdefgehg|	RUST

  func	cu_num
  is	spc : * char = csi.Aipt[0].Pspc
	dat : [10] WORD
	asc : [18] char
	ptr : * char
	blk : WORD = ctl.Vfst
	lst : WORD = ctl.Vlst
	adr : long = blk * 512
	idx : int
	loc : WORD
	val : WORD
	cnt : int

     repeat
	DMP3("%s Block %d (0%o)\n", spc, blk, blk)
	loc = 0
	while loc lt 512
	   DMP1("%03o: ", loc)			; block 
	   loc += 16				; 16 bytes per line
	   idx = 0, cnt = 0, ptr = asc
	   while cnt++ lt 8
	      fail if !cu_fwd (adr, &val, 0)
	      adr += 2
	      dat[idx++] = val			; save value
	      if ctl.Voct
	         DMP1("%06o ", val) if !ctl.Vbyt
	         DMP2("%03o %03o ", val&255, (val>>8)&255) if ctl.Vbyt
	      elif ctl.Vdec
	         DMP1("%6d ", val) if !ctl.Vbyt
	      .. DMP2("%3d %3d ", val&255, (val>>8)) if ctl.Vbyt
	      cu_asc (val, ptr++), cu_asc (val>>8, ptr++)
	   end

	   if (!ctl.Vbyt) && ctl.Vasc
	   .. DMP1("|%16s|", asc)
	   DMP("\n")

	   if ctl.Vbyt && ctl.Vasc
	      DMP("     ")
	      cnt = 16, ptr = asc
	      DMP1("  %c ", *ptr++) while cnt--
	   .. DMP("\n")

	   if ctl.Vr50
	      DMP("     ")
	      idx = 0, cnt = 0
	      while cnt++ lt 8
	         rx_unp (dat[idx++], asc)
	         DMP1("%3s    ", asc)
	      end
	      DMP("\n")
	   end

	   if ctl.Vhex
	      DMP("     ")
	      idx = 0, cnt = 0
	      while cnt++ lt 8
	           val = dat[idx++]
		   DMP1("  %4X ", val) if !ctl.Vbyt
		   DMP2(" %2X  %2X ", val&255, (val>>8)) otherwise
	      end
	      DMP("\n")
	   end
	end
	DMP("\n")
	quit if blk++ eq lst
      forever
	fine
  end
code	cu_ins - instruction dump

;	Address	Asc R50	Octal	Instruction
;	000000	XX XXX	000000	Inst	Src,Dst
;
;???	Addresses are truncated to 16-bits

	cu_tit : ()-		; display .title and header

  func	cu_ins
  is	rev : rvTpdp
	adr : long = ctl.Vbeg
	cnt : long = ctl.Vcnt
	asc : * char = "..."
	hlt : long = 0
	loc : WORD
	val : WORD
	len : int
	dat : * WORD
	itm : int
	ske : int = 0 ;ctl.Vske
	skl : int = ctl.Vske
;	rev.Vflg = rvSKE_ if ske
;	rev.Vflg = 0 otherwise

	me_clr (&rev, #rvTpdp)
	rev.Vtab = 1			; hard tabs
	cu_tit ()

      while cnt gt 
	loc = adr
	hlt = 0
	while (cnt - (hlt*2)) gt
	   cu_fwd (adr, &val, 0)	; look for zeroes
	   quit if fail
	   quit if val
	   ++hlt, adr += 2
	end
	if hlt gt 1
	   DMP1("%-23s;", "") if ske
	   DMP2("%06o\t000000\t.blkw\t%lo\n", loc, hlt) if skl
	   DMP2("%06o\t\t000000\t.blkw\t%ld.\n", loc, hlt) otherwise
	   cnt -= (hlt * 2)
	.. quit if cnt eq

	adr -= 2 if hlt eq 1

	loc = rev.Vloc = adr
	len  = cu_fwd (adr, &rev.Vopc, 0)	; get opcode
	rev.Adat[0] = rev.Vopc			; for output
;	abort if fail
	len += cu_fwd (adr+2, rev.Adat+1, 1)	; get instruction data
	len += cu_fwd (adr+4, rev.Adat+2, 1)	;
	rv_pdp (&rev)				;

	len = rev.Vlen if rev.Vlen lt len	; minimize length
	itm = 0, dat = &rev.Adat
	while itm lt len
	   DMP1("%-23s;", rev.Astr) if ske && !itm
	   DMP1("%-23s;", "")       if ske && itm 

	   DMP1("%06o\t", loc+(itm*2))		; location

	   if !skl
	      cu_asc (dat[itm], asc)		; ascii
	      cu_asc (dat[itm]>>8, asc+1)
	      asc[2] = 0
	      DMP1("%s", asc)

	      rx_unp (dat[itm], asc)		; rad50
	      DMP1(" %3s\t", asc)			;
	   end

	   DMP1("%06o", dat[itm])		; octal

	   DMP1("\t%s", rev.Astr) if !ske && !itm
	   DMP("\n"), ++itm
        end
	   adr += (rev.Vlen * 2)		; want reverse assemble
	   cnt -= (rev.Vlen * 2)
      end
	fine
  end

code	cu_tit - display title and header

  func	cu_tit
  is	DMP1(".title\t%s\n\n", ctl.Aipt)
	DMP(".asect\n\n")
	DMP("\t.macro psh adr\n\tmov\tadr,(sp)+\n\t.endm\n\n")
	DMP("\t.macro pop adr\n\tmov\t(sp)+,adr\n\t.endm\n\n")
  end
code	cu_dis - disassemble

;???	Addresses are truncated to 16-bits

	cuPcal : * btTmap
	cuPloc : * btTmap
	cuPacc : * btTmap
	cuPmod : * btTmap

  func	cu_dis
  is	rev : rvTpdp
	adr : long = ctl.Vbeg
	cnt : long = ctl.Vcnt
	asc : * char = "..."
	hlt : long = 0
	loc : WORD
	val : WORD
	len : int
	dat : * WORD
	itm : int
	lab : int

	me_clr (&rev, #rvTpdp)
	rev.Vrel = 0
	cu_mrk ()
	cu_tit ()
	rev.Vtab = 1			; hard tabs

      while cnt gt 
	loc = adr
	hlt = 0
	while (cnt - (hlt*2)) gt
	   cu_fwd (adr, &val, 0)	; look for zeroes
	   quit if fail
	   quit if val
	   ++hlt, adr += 2
	end
	if hlt gt 1
	   cu_lab (loc)
	   DMP1(".blkw\t%ld.\n", hlt)
	   DMP1("\t\t\t       ;%06o\n", loc)
	   cnt -= (hlt * 2)
	.. quit if cnt eq

	adr -= 2 if hlt eq 1

	loc = rev.Vloc = adr
	len  = cu_fwd (adr, &rev.Vopc, 0)	; get opcode
	rev.Adat[0] = rev.Vopc			; for output
;	abort if fail
	len += cu_fwd (adr+2, rev.Adat+1, 1)	; get instruction data
	len += cu_fwd (adr+4, rev.Adat+2, 1)	;
	rv_pdp (&rev)				;

	len = rev.Vlen if rev.Vlen lt len	; minimize length
	itm = 0, dat = &rev.Adat
	while itm lt len
	   lab = cu_lab (loc) if !itm
	   DMP1("%s\n", rev.Astr) if !itm

	   lab ? DMP("\t") ?? cu_lab (loc)
	   lab = 0
	   DMP1("\t\t       ;%06o\t", loc) 	; location
	   DMP1("%06o\t", dat[itm])		; octal

	   cu_asc (dat[itm], asc)		; ascii
	   cu_asc (dat[itm]>>8, asc+1)
	   asc[2] = 0
	   DMP1("%s", asc)

	   rx_unp (dat[itm], asc)		; rad50
	   DMP1(" %3s", asc)			;

	   DMP("\n"), ++itm, loc += 2
        end
	   adr += (rev.Vlen * 2)		; 
	   cnt -= (rev.Vlen * 2)
      end
	DMP("\t.end\n")
	DMP1("\t\t       ;%06o\t", loc)		; location
	me_dlc (cuPloc)
	me_dlc (cuPcal)
	me_dlc (cuPacc)
	me_dlc (cuPmod)
	fine
  end
code	cu_mrk - mark label locations

  func	cu_mrk
  is	rev : rvTpdp
	adr : long = ctl.Vbeg
	cnt : long = ctl.Vcnt
	asc : * char = "..."
	loc : WORD
	val : WORD
	len : size
	dat : * WORD
	itm : int
	if cnt ge 65536L
	.. im_rep ("W-Image truncated for operation %s", ctl.Aipt)

	val = <size>cnt/2			; 1 bit per word
	cuPloc = bt_alc (val)			; local label
	cuPcal = bt_alc (val)			; call label
	cuPacc = bt_alc (val)			; access label
	cuPmod = bt_alc (val)			; modify label

	if !cuPloc || !cuPcal || !cuPacc || !cuPmod
	.. im_rep ("F-Insufficient memory", <>)

      while cnt gt 
	loc = adr

	loc = rev.Vloc = adr
	len  = cu_fwd (adr, &rev.Vopc, 0)	; get opcode
	rev.Adat[0] = rev.Vopc			; for output
;	abort if fail
	len += cu_fwd (adr+2, rev.Adat+1, 1)	; get instruction data
	len += cu_fwd (adr+4, rev.Adat+2, 1)	;
	rv_pdp (&rev)				;

	len = rev.Vlen if rev.Vlen lt len	; minimize length
	itm = 0, dat = &rev.Adat		; 
	case rev.Vtyp
	of rvSOB
	or rvBRA  bt_map (cuPloc, rev.Vdst/2, btSET)
;		  PUT("BRA=%o\n", rev.Vdst)
	of rvUOP
	   if (rev.Vopc eq 04767) || (rev.Vopc eq 04737)
	   .. bt_map (cuPcal, rev.Vdst/2, btSET);, PUT("CAL=%o\n", rev.Vdst)
        end case
	adr += (rev.Vlen * 2)
	cnt -= (rev.Vlen * 2)
      end
	fi_see (ctl.Hipt, 0L) 
	fine
  end

  func	cu_lab
	loc : size
  is	lab : int = 0
	if bt_map (cuPloc, loc/2, btTST)
	    DMP1("$%o:", loc)
	.. ++lab
	if bt_map (cuPcal, loc/2, btTST)
	    DMP("\n") if lab
	    DMP1(".%o:", loc)
	.. ++lab
	DMP("\t")
	reply lab
  end
code	cu_mac - macro .word dump

;	.word	...

  func	cu_mac
  is	dat : [8] WORD
	blk : WORD = ctl.Vfst
	lst : WORD = ctl.Vlst
	adr : long = blk * 512
	val : WORD
	maj : long
	idx : int
	act : int
	zer : int = 0

	maj = ((lst-blk)+1) * (256/8)

      while maj-- ne
	idx = act = 0
	while idx lt 8
	   fail if !cu_fwd (adr, &val, 0)
	   adr += 2
	   ++act if val ne
	   dat[idx++] = val
	end
	next zer += 8 if act eq
	cu_zer (zer), zer = 0
	DMP(".word   ")
	idx = 0
	while idx lt 8
	   DMP(", ") if idx
	   DMP1("%d.", dat[idx++])
	end
	DMP("\n")
      end
	cu_zer (zer)
	fine
  end

  func	cu_zer
	zer : int
  is	fine if !zer
	DMP1(".blkw   %d.\n", zer)
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
;***;	CUS:DUMP - Dump analyses SimH tape structures
code	cu_tap - dump SimH tape structure

;	This code analyses an SimH tape structure

	tpERR := 0
	tpGAP := 1
	tpEOM := 2
	tpDEL := 3
	tpCNT := 4

	tp_nxt : (*long, *long, *long) int

  func	cu_tap
  is	adr : long = ctl.Vbeg
	nxt : long = adr
	lst : long = adr + ctl.Vcnt
	val : long
	len : long
	cas : int
	pnd : int = 0
	gap : int = 0
	rec : int = 0
	cnt : long = 0

      repeat
	adr = nxt
	cas = tp_nxt (&adr, &nxt, &val)
	if pnd && (cas ne tpCNT)
	   next ++gap if !rec && (cas eq tpGAP)
	   PUT("gap") if gap
	   PUT("(%d)", gap) if gap gt 1
	   PUT(" cnt=%ld\n", cnt)
	.. pnd = gap = rec = 0, cnt = 0L

	case cas
	of tpERR fail PUT("Format error\n")
	of tpGAP next pnd=1, ++gap
	of tpEOM next PUT("eom\n")
	of tpDEL next PUT("del\n")
	end case
	adr = nxt + val
	len = val
	tp_nxt (&adr, &nxt, &val)
	fail PUT("Format error\n") if that ne tpCNT
	fail PUT("Length error\n") if val ne len
	cnt += len, ++rec, ++pnd
      end
  end

  func	tp_nxt
	adr : * long
	nxt : * long
	val : * long
  is	hdr : * WORD = <*WORD>val

	fail if !cu_fwd (*adr, hdr+1, 0)
	fail if !cu_fwd (*adr+2, hdr, 0)

	*nxt = *adr + 4
	reply tpGAP if *val eq
	reply tpEOM if *val eq -1
	reply tpDEL if *val eq -2
	fail if *val lt
	fail if *val gt 8194L
	reply tpCNT
  end
code	cu_dir - dump directory

  func	cu_dir
  is
  end


  func	cu_rta
  is

  end

  func	cu_f11
  is

  end
code	cu_fwd - fetch word

  func	cu_fwd
	adr : long
	buf : * void
	mut : int
  is	reply cu_rea (adr, buf, 2, mut)
  end

code	cu_rea - read bytes

  func	cu_rea
	adr : long
	ptr : * void
	cnt : size
	mut : int
	()  : int
  is	fi_see (ctl.Hipt, adr)
	if fail
	   fail if mut
	.. fail im_rep ("W-Error seeking image %s", ctl.Aipt)
	fi_rea (ctl.Hipt, ptr, cnt)
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
.endc
.title	DUMP
.include "lib:rust.mac"

	$imgdef	DUMP 3 0
	$imginf	fun=sav use=<RUST dump utility DUMP.SAV V3.0>
	$imgham	yrs=<2011> oth=<>
;	%date
	$imgdat	<03-Jul-2022 05:21:38>   
;	%edit
	$imgedt	<86   >

.end
;code	dump directory
;include	dmmod
;
;	RT-11/RUST
;	RSX/VMS
;	DOS/XXDP
;	FAT
;
;	ANSII
;	DOS
;	FOREIGN
;
;  func	dm_dir
;  is
;	must be rt-11 file structured device
;
;  end
                                                                                                                                                                                                          