;+++;	WUS:XXDP in translation to RUST
;???;	WUS:XXDP has test code
;???	els:ellda.r in limbo
;???	Can't ignore input error for linked files. Should count errors.
file	xxdp
include rid:rider
include rid:stdef
include rid:medef
include rid:imdef
If !Pdp
include rid:codef
End
include rid:fidef
include rid:mxdef
include rid:ctdef
include rid:chdef
include rid:cldef
include rid:xxdef

;	%build
;	goto 'p1'
;	rider wus:xxdp/object:wub:
;	link:
;	link wub:xxdp,lib:crt/bottom=6000/exe:wub:xxdp/map:wub:xxdp
;	%end

If Pdp
	_xxTER := "tt:"
Else
	_xxTER := "con"
End

	xxFemp : int = 0	; show empty entries
	xxFmap : int = 1	; map disk
	xxFanl : int = 0	; /analyse
	xxFasc : int = 0	; /ascii - special ascii mode
	xxFcop : int = 0	; copy files
	xxFdet : int = 0	; /detailed (analysis)
	xxFdir : int = 0	; /directory
	xxFdos : int = 0	; dos/batch
	xxFtap : int = 0	; dosbatch dectape
	xxFhlp : int = 0	; /help
	xxFver : int = 1	; display stuff
	xxFpau : int = 0	; pause
	xxFign : int = 0	; /ignore
	xxFnrp : int = 0	; /noreplace

;  Disk image: XXXXX
;  Disk length: 10000. blocks;
;  Deleted files: none.
;  Contiguous files: none.
;  Files with version info: xxx
;  Files with P-Tables: xxx
;  Empty areas: 1
;  Unlinked blocks: none
;  Multiply linked blocks: none
;  Bootstrap: yes
;  Bitmap: start=2 length=12
;  Directory: start = length
;  Data: start:  length.
;
;	Expand filenames 
;	Recognise contiguous files
;	Validate disk structure

	PRT0(s) := fprintf(xxPout, s)
	PRT1(s,a) := fprintf(xxPout, s,a)
	PRT2(s,a,b) := fprintf(xxPout, s,a,b)
	PRT3(s,a,b,c) := fprintf(xxPout, s,a,b,c)

If 0
  type	xxTent
  is	Anam : [3] WORD		; rad50 name
	Vdat : WORD		; programmer/c number
	Vnfb : WORD		; unknown
	Vsta : WORD		; first block
	Vlen : WORD		; length in blocks
	Vtop : WORD		; last block of file (not end)
	Vprt : WORD		;
  end
;;;	xxDAT_ := BIT(15)
End

  type	xxTseg
  is	Vnxt : WORD		; block of next directory segment
	Aent : [255/9] xxTent	; entries
  end

	xxPfil : * FILE
	xxPout : * FILE
	xxVdir : int = 030

	xx_hom : () int
	xx_dsk : () int
	db_hom : () int
	xx_dir : (int)
	xx_seg : (int)
 	xx_get : (*void, int)
	xx_blk : (int)
	xx_see : (LONG)
	xx_new : ()
	db_dat : (int)
	lk_unp : (*WORD, *char, int) void
	xx_cop : (*char, int, int, int)
	xxCON_ := 0100000

	xxAout : [128] char = {0}

	xxAmap : [10240*2] char = {0}
	xx_map : (int, int)
	xxMRK_ := BIT(0)
	xxFIN_ := BIT(1)
;;;	xxCTG_ := BIT(3)
	xxMUL_ := BIT(4)
	xxSKP_ := BIT(5)
	xxFIX_ := BIT(6)
	xxREV_ := BIT(7)
	xxREP_ := BIT(8)
	xx_ent : (*xxTent, *char)
code	main

   func	main
	cnt : int
	vec : ** char
  is	ipt : [mxSPC*2] char
	opt : [mxSPC*2] char
	cmd : * char
	im_ini ("XXDP")
If !Pdp
	co_ctc (coENB)				;
End
	if vec[2] eq
	   PUT("RUST XXDP & DOSBatch file utility XXDP.EXE\n")
	   PUT("\n")
	   PUT("xxdp    infile.typ [out.lst] [/options]\n")
	   PUT("xxdp    infile.typ out-dir /COPY[/options]\n")
	   PUT("\n")
	   PUT("Options:\n")
	   PUT(" /ANalyse    Analyse volume structure\n")
	   PUT(" /AScii      Filter 7-bit ascii\n")
	   PUT(" /COpy       Copy files\n")
	   PUT(" /DEtailed   Detailed analysis\n")
	   PUT(" /DIrectory  List files. Default.\n")
	   PUT(" /DOs        DOSBatch device\n")
	   PUT(" /IGnore     Ignore input errors\n")
	   PUT(" /NOREplace  Don't replace existing files\n")
	   PUT(" /PAuse      Pause every 24 lines\n")
	   PUT(" /TApe       DECtape\n")
	.. exit					;

	fi_def (vec[2], ".dsk", ipt)
	st_cop (vec[3], opt) if vec[3] ;&& !(st_fnd ("/", vec[2]))
	st_cop (_xxTER, opt) otherwise
	st_low (opt)

	cmd = vec[1]
	st_low (cmd)

	++xxFanl if st_fnd ("/an", cmd)		; /analyse
	++xxFasc if st_fnd ("/as", cmd)		; /ascii specials
	++xxFcop if st_fnd ("/co", cmd)		; /copy
	++xxFdet if st_fnd ("/de", cmd)		; /detailed
	++xxFdir if st_fnd ("/di", cmd)		; /directory
	++xxFdos if st_fnd ("/do", cmd)		; /dos
	++xxFpau if st_fnd ("/pa", cmd)		; /pause
	++xxFtap if st_fnd ("/ta", cmd)		; /tape
	++xxFign if st_fnd ("/ig", cmd)		; /ignore
	++xxFnrp if st_fnd ("/nore", cmd)	; /noreplace

	if xxFcop
	   st_cop (opt, xxAout)
	   st_cop (_xxTER, opt)
	   xxFver = 0
	else
	   st_app (".lst", opt) if !st_fnd (".", opt)
	end

	xxPfil = fi_opn (ipt, "rb", "")		; open input
	im_exi () if null			; failed
	xxPout = fi_opn (opt, "w", "")		; open output
e
	xx_dsk ()				; analyse it
f
	xx_map (0, xxREP_) if xxFanl		; report
g
	fi_clo (xxPout, "")
	im_exi ()
  end
code	xx_dsk - analyse disk
	
  func	xx_dsk
  is	reply db_hom () if xxFdos
	reply xx_hom ()
  end

  func	xx_hom
  is	blk : [256] word
	dos : * xxTdos = <*void>blk
	mfd : * xxTmfd = <*void>blk
	xdp : * xxTxdp = <*void>blk
	ufd : * xxTufd = <*void>blk
	seg : word

	xx_blk (0)
	xx_get (blk, 512)
	xx_blk (1)
	xx_get (blk, 512)

	seg = blk[02/2]
	if xxFanl
	   PRT2("Directory: start=%d, length=%d\n", blk[02/2], blk[04/2])
	   PRT2("Bitmap:    start=%d, length=%d\n", blk[06/2], blk[010/2])
	   PRT3("Disk:      size=%d, data=%d/0%o\n", blk[016/2], blk[020/2], 
	         blk[020/2])
	.. PRT2("Monitor:   start=%d./0%o\n", blk[026/2], blk[026/2]) 
	xx_dir (seg)
  end

code	db_hom - dos/batch home

  type	dbTmfd
  is	Vuic : WORD
	Vufd : WORD
	Vsiz : WORD
	Vunk : WORD
  end

  type	dbTblk
  is	Vlnk : WORD
	Adat : [255] WORD
  end

  func	db_hom
  is	blk : dbTblk
	mfd : * dbTmfd

	xx_blk (1) if !xxFtap
	xx_blk (64) otherwise
	xx_get (<*void>&blk, 512)
	repeat
	  PRT2 ("MFD: start=%d/0%o\n", blk.Vlnk, blk.Vlnk) if xxFanl
	  xx_blk (blk.Vlnk)
	  xx_get (<*void>&blk, 512)
	  mfd = <*dbTmfd>&blk.Adat
	  while mfd->Vuic
	     PRT1 ("UFD=%o\n", mfd->Vuic)
	     xx_dir (mfd->Vufd)
	     ++mfd
	     quit if xxFtap
	  end
	  quit if !blk.Vlnk
	end
  end
;???;	WUS:XXDP - xx_dir/xx_seg have debug code
code	xx_dir - xxdp/dos directory

  func	xx_dir
	seg : int
  is	while seg
	   seg = xx_seg (seg)
quit
	end
  end
	WW := 0xffff

  func	xx_seg
	seg : int
  is	nxt : WORD
	ent : xxTent
	cnt : int = 255/9	; number of entries
	nam : [24] char		;
	dat : int
	byt : LONG = seg * 512
	xx_blk (seg)		;

	xx_see (byt)		;
	xx_get (&nxt, 2)	; get next segment
	if xxFanl && xxFdet
	   PRT2("Segment=%o Next=%o", seg, nxt)
	.. xx_new ()
	byt = byt + 2
     while cnt--		; get another
a
	xx_see (byt)		;
	xx_get (&ent, #xxTent)	; get an entry
b
	byt = byt + #xxTent	; skip it
	next if !ent.Anam[0] && !xxFemp
c
	lk_unp (ent.Anam, nam, -3)
d
	xx_ent (&ent, nam) if xxFdir
e
	xx_cop (nam, ent.Vsta, ent.Vlen, ent.Vdat & xxCON_) if xxFcop
f
     end
	reply nxt
  end
code	xx_get - read file

  func	xx_get
	adr : * void
	cnt : int
  is	fi_rea (xxPfil, adr, cnt) 
	reply that
  end

  func	xx_blk
	blk : int
  is	seg : LONG = blk*512
	fi_see (xxPfil, seg)
  end

  func	xx_see
	byt : LONG
  is	fi_see (xxPfil, byt)
  end

code	xx_new - print newline

	xxVlin : int = 0

  func	xx_new
  is	cmd : [80] char
	PRT0("\n")
	fine if ++xxVlin lt 23
	xxVlin = 0
	fine if !xxFpau
	cl_cmd ("More? ", cmd)
	im_exi () if ch_upr (cmd[0]) eq 'X'
  end

code	lk_unp - unpack rad50

  init	lkAunp : [41] char
  is	" ABCDEFGHIJKLMNOPQRSTUVWXYZ$.*0123456789"
  end

  proc	lk_unp
	rad : * WORD		; pointer to rad50 input
	asc : * char		; pointer to ascii output
	maj : int		; number of words to convert
				; -4 => file spec
  is	div : WORD
	wrd : WORD
	spc : int = 0
	rem : WORD
	maj = 4, spc = 1 if maj eq -4
	maj = 3, spc = 1 if maj eq -3
	while maj--
	   wrd = *rad++
	   div = 40 * 40
	   while div ;&& wrd
	      rem = wrd / div
	      wrd -= rem * div
	      *asc++ = lkAunp[rem] ;if rem
	      div /= 40
	   end
;	   next if !spc
	   *asc++ = ':' if maj eq 3
	   *asc++ = '.' if maj eq 1
	end
	*asc++ = 0
  end
code	xx_cop - copy file

;	The first two bytes of each block are a link
;	to the succeeding block.
;	Only copy if a destination file
;	However, scan the disk for errors

	xx_asc : (*char, *int)
	xx_rev : (*WORD)

  func	xx_cop
	nam : * char
	blk : int
	len : int
	con : int
  is	opt : * FILE
	spc : [128] char
	buf : [256] WORD
	err : int = 0
	flg : int = 0
	cnt : int
	pad : int = len * 2		; number of bytes to pad out
	lnk : int = !con		; linked file
	tot : int = 0			; count blocks
	rev : int = 0			; reverse read

	if xxFcop ;wrt
	   st_cop (xxAout, spc)		; setup the spec
	   st_app (nam, spc)		;
	   fail if xxFnrp && !fi_mis (spc, "W-File already exists %s")
	   opt = fi_opn (spc, "wb", "W-Error creating file %s")
	.. fail if !opt			; no such file

;	PRT1("I-Copied [%s]", spc)
      while len--
	rev = 0
	if (blk & BIT(15))&& xxFtap
	   rev = 1
	.. blk = -blk & 0177777

	xx_map(blk,flg|xxMRK_) if xxFanl; mark it
	xx_blk (blk)			; get first
	fi_rea (xxPfil, buf, 512)	; read the next
	quit err=1 if fail && !xxFign	;
;??? can't ignore incorrect link
;??? must count errors

	xx_rev (buf) if rev		; reverse it
	++tot				;
	flg = xxREV_ if buf[0] lt blk	;
	flg = 0      otherwise		;
	++blk        if !lnk		; contiguous file
	blk = buf[0] otherwise		; linked file
	next if !xxFcop
	cnt = 512-(lnk*2)		; data count
	xx_asc (<*char>(buf+lnk), &cnt)	; reduce ascii?
	fi_wri (opt,buf+lnk,cnt)	; write output
	quit err=1 if fail		;
      end
;PUT("Copied=%d\n", tot)
	fine if !xxFcop
	PRT2("W-Error copying [%s] from block %d", spc, blk) if err 
;	if lnk				; linked files need padding
;	   me_clr (buf, 512)		; 2 bytes per block
;	   while pad			;
;	      cnt = pad if pad lt 512	;	
;   	      cnt = 512 otherwise	;
;	      fi_wri (opt, buf, cnt)	; pad it out
;	      pad -= cnt		;
;	.. end
	fi_clo (opt, "")
	fine
  end

  func	xx_asc
 	src : * char
	len : * int
  is	cnt : int = *len
	cha : int
	dst : * char = src
	fine if !xxFasc
	*len = 0
	while cnt--
	   cha = *src++
	   if ((cha lt 32) || (cha ge 127))
	      case cha
	      of '\t'
	      or '\n'
	      or '\r'
	      or '\f'  nothing
	      of other next
	   .. end case
	   *dst++ = cha
	   ++*len
	end
  end
code	xx_map - handle disk map

  func	xx_map
	blk : int
	atr : int
  is	map : * char = xxAmap
	fst : int
	flg : int
	top : int = (10*1024*1024) / 512

	if !(atr & xxREP_)
	   flg = xxAmap[blk]
	   if flg & xxMRK_
	   && atr & xxMRK_
	   .. flg |= xxMUL_
	   flg |= atr
	..  fine xxAmap[blk] = flg
	blk = 0
	while blk lt top
	   flg = map[blk]
	   fst = blk++
	   ++blk while (blk lt top) && (map[blk] eq flg)
	   atr = map[blk]
	   if xxFver
	      PRT3("Block=%o|%d. Count=%d ", fst, fst, blk-fst)
	      PRT0("Mark ") if flg & xxMRK_
	      PRT0("Multiple ") if flg & xxMUL_
	      PRT0("Unlinked ") if !(flg & xxMRK_)
	   .. xx_new ()
	end
   end
code	xx_ent - display an entry

	xx_sys : (*xxTent, *char)
	xx_bin : (*xxTent, *char)
	xx_uni : (*xxTent, *char)
	xx_dev : (*char)
	xx_cpu : (*char)

  func	xx_ent
	ent : * xxTent
	nam : * char
  is	ann : int = 1
	txt : [4] char
	
	PRT1("%10s ", nam)
;	PRT1("%o ", ent->Vdat)
;	PRT0("C") if ent->Vdat & xxDAT_	
	if xxFanl
	   PRT1("%6d", ent->Vlen)
	   PRT0("C ") if ent->Vdat & 0100000
	   PRT0("  ") otherwise
	   db_dat (ent->Vdat)
; 	   PRT2(" dat=%o, nfb=%o] ", ent->Vdat&077777, ent->Vnfb&WW)
;	   PRT2(" sta=%o len=%o ", ent->Vsta&WW, ent->Vlen&WW)
;	   PRT2("lst=%o prt=%o ", ent->Vtop&WW, ent->Vprt&WW)
	else
	.. PRT1("%6d. ", ent->Vlen)

     repeat
	quit if !ann
	if st_len (nam) eq 8
	&& st_fnd ("DP.BIN", nam)
	.. quit PRT0("Boot "), xx_dev (nam+2)

	quit if st_len (nam) ne 10

	quit xx_sys (ent, nam) if st_fnd (".SYS", nam) ; got a system file
	if ct_dig(nam[5])
	.. quit xx_bin (ent, nam) if st_fnd (".BI", nam)
	quit xx_bin (ent, nam) if st_fnd (".MPG", nam)
	if (nam[5] eq '0')
	.. quit xx_bin (ent, nam) if st_fnd (".OBJ", nam)
	if ct_dig (nam[5])
	.. quit xx_bin (ent, nam) if st_fnd (".PAT", nam)
     never
	xx_new ()
  end

  func	xx_sys
	nam : * xxTent
	sig : * char
  is	buf : [4] char ;= {0}
	fine if *sig++ ne 'H'
	case (*sig++)
	of 'M' PRT0("Monitor ")
	of 'D' PRT0("Driver ")
	of 'U' PRT0("Utility ")
	of 'S' PRT0("Supervisor ")
	of 'Q' PRT0("Other ")
	of other
	       PRT0("Unknown")
	end case
	me_cop (sig, buf, 2)
	if st_sam (buf, "AA")
	   PRT0("XXDP Monitor ")
	elif st_sam (buf, "AB") 
	   PRT0("PT/AMS Monitor ")
	elif st_sam (buf, "DI")
	   PRT0("Directory ")
	elif st_sam (buf, "SA")
	   PRT0("User manual ")
	elif st_sam (buf, "SU")
	   PRT0("Setup utility ")
	else
	.. xx_dev (buf)
   end

  func	xx_bin
	nam : * xxTent
	sig : * char
  is	fine xx_uni (nam, ++sig) if *sig eq 'D'
	xx_cpu (sig++)
	xx_dev (sig), sig+=2
	PRT1(" %c ", *sig)
  end

  func	xx_uni
	nam : * xxTent
	sig : * char
  is	PRT0("Unibus test ")
	xx_cpu (sig++)
	PRT1(" %c ", *sig)
  end

  func	xx_cpu
	cpu : * char
  is	case *cpu
	of 'A' PRT0("11/05-11/20 ")
	of 'B' PRT0("11/40 ")
	of 'C' PRT0("11/45 ")
	of 'D' PRT0("GT40 ")
	of 'E' PRT0("11/70 ")
	of 'F' PRT0("11/34 ")
	of 'G' PRT0("11/04 ")
	of 'H' PRT0("(system) ")
;	    I
	of 'J' PRT0("11/23-11/24 ")
	of 'K' PRT0("11/44 ")
;	    L
	of 'M' PRT0("Minc-11 ")
	of 'N' PRT0("SI9400 ")
;	    O
	of 'P' PRT0("PDT-11 ")
	of 'Q' PRT0("11/60 ")
	of 'R' PRT0("LPA-11 ")
;	    S
	of 'T' PRT0("MPG ")
;	    U
	of 'V' PRT0("11/03 ")
;	    W
	of 'X' PRT0("Object ")
;	    Y
	of 'Z' PRT0("All ")
	of other
	       PRT0("(Unknown device) ")
	end case
  end

  func	xx_dev
	dev : * char
  is	buf : [4] char ;= {0}
	me_cop (dev, buf, 2)
	buf[2] = 0
	PRT1("%s ", buf)
	fine PRT0("KIT11 ") if st_sam (buf, "BB")
	fine PRT0("CP ") if st_sam (buf, "DEC/X11 CPU")
	fine PRT0("IC ") if st_sam (buf, "ICR11 ")
	fine PRT0("KA ") if st_sam (buf, "KA")
	fine PRT0("KB ") if st_sam (buf, "KB")
	fine PRT0("KC ") if st_sam (buf, "KC")
	fine PRT0("PDT11-11/24 ") if st_sam (buf, "KD")
	fine PRT0("KE ") if st_sam (buf, "KE")
	fine PRT0("KG ") if st_sam (buf, "KG")
	fine PRT0("Cache ") if st_sam (buf, "KK")
	fine PRT0("MMU ") if st_sam (buf, "KT")
  end
code	date

  type	dbTplx
  is	Vday : int
	Vmon : int 
	Vyea : int
  end

  type	dbTmon 
  is	Vmon : byte
	Vlen : byte
  end

  init	dbAmon : [] dbTmon
  is	0, 31
	1, 28
	2, 31
	3, 30
	4, 31
	5, 30
	6, 31
	7, 31
	8, 30
	9, 31
	10, 30
	11, 31
  end

  init	dbAstr : [] *char
  is	"Jan"
	"Feb"
	"Mar"
	"Apr"
	"May"
	"Jun"
	"Jul"
	"Aug"
	"Sep"
	"Oct"
	"Nov"
	"Dec"
	"Bad"
  end

	db_plx : (int, *dbTplx)

  func	db_dat
	val : int
  is	plx : dbTplx
	db_plx (val, &plx)
	PRT1("%2d-", plx.Vday)
	PRT1("%s-", dbAstr[plx.Vmon])
	PRT1("%d ", plx.Vyea)
  end

  func	db_plx
	val : int
	plx : * dbTplx
  is	lst : * dbTmon = dbAmon
	yea : int
	mon : int
	day : int
	val &= 077777		; take out sign bit
	yea = val/1000		; thats the year
	val -= yea*1000		;
	yea += 1970		;
	(yea & 3) ? 28 ?? 29	; leap year stuff
	lst[1].Vlen = that 	;
	while val ge lst->Vlen	;
	   val -= lst->Vlen	;
	   lst++
	end
	day = val
	mon = lst->Vmon
	mon = 12 if mon gt 12
	plx->Vyea = yea
	plx->Vmon = mon
	plx->Vday = day
  end
code	dectape

;	DOS DECtape reads some blocks in reverse
;	Data is read a word at a time going backwards
;	This routine unreverses a block

  func	xx_rev
	buf : * WORD
  is	low : * WORD = buf
	hgh : * WORD = buf + 256
	cnt : int = 128
	tmp : int
	while cnt--
	   tmp = *--hgh
	   *hgh = *low
	   *low++ = tmp
	end
  end


end file

