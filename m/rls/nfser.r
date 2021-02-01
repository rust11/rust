updC := 1
dbgC := 1
file	nfser - nf server
include	rid:rider.h
include	rid:evdef
include	rid:medef
include	rid:mxdef
include	rid:stdef
include rid:drdef
include rid:eldef
include rid:lndef
include rid:nfdef
include rid:nfcab
include rid:rtdir
include rid:rtutl

	rxVX7 := 0106545
	rxDIR := 015172 
	rx_DR := 0262		; directory service
	rx_IF := 0556		; information services

 type	nfTfun : (*nfTvab) int

	nf_abo : nfTfun
	nf_rea : nfTfun
	nf_wri : nfTfun
	nf_clo : nfTfun
	nf_del : nfTfun
	nf_loo : nfTfun
	nf_ent : nfTfun
	nf_ren : nfTfun
	nf_siz : nfTfun
	nf_prg : nfTfun
	nf_inf : nfTfun
	nf_clz : nfTfun
	nf_trn : (*nfTvab, *char) int
	nf_wlk : nfTfun

	nf_sta : (*nfTvab, int) int
	STA(s) := nf_sta (vab, (s))

  type	nfTact
  is	Pfun : * nfTfun
	Vdir : int
  end

  init	nfAact : [] nfTact
  is	nf_abo, 0
	nf_rea, 0
	nf_wri, 0
	nf_loo, 1
	nf_ent, 1
	nf_clo, 0
	nf_del, 1
	nf_ren, 1
If updC
	nf_siz, 0
End
	nf_prg, 0
	nf_inf, 1
	nf_clz, 0
  end

	nf_vax : (*nfTvab)
	nf_rta : (*nfTvab, *cabTcab)
	nf_her : (*nfTvab) void
	nf_sho : (*nfTvab) int
	nf_dir : (*char) int

	nfAdum : [1024] char = {0}	; dummy device blocks
	nfApad : [512] char = {0}	; pad buffer
	nfPbuf : * char = <>		; user buffer
	nfFdbg : int = 0		;
	nfFdmp : int = 0		;
	nfFtra : int = 0		; trace

	el_dbg : (*char) int
code	nf_ser - nf server

;	Entry point for server packet
;
;	Handle sub-directory operations

  func	nf_ser
	vab : * nfTvab
  is	flg : int = vab->Vflg
	fun : int = vab->Vfun & 0xff
	PUT("\nRCV: "), nf_rep (vab, <>, 0) if nfFtra

	if flg & nfINI_			; init node
	   cab_eli (vab, cabNRS)	; node reset
	elif flg & nfINP_		; init process
	.. cab_eli (vab, cabIRS)	; image reset

	vab->Vflg &= (nfWLK_|nfSUB_)	; clean up flags
	vab->Vsta = 0
	vab->Vdbc = 0 ;if vab->Vfun ne nfWRI
	vab->Pcab = <>			; no cab yet

	if fun ge nfMAX			; invalid function
	.. exit nf_her (vab)		; yep

	if !nfAact[fun].Vdir		; needs directory
	|| !nf_wlk (vab)		; check for directory walk
	   nfAact[fun].Pfun(vab)	; execute request
	   if vab->Pcab			; got a hanging name cab
	.. .. cab_dlc (vab->Pcab,cabNRS); expunge it
	fi_flu (<>)			; flush everything
	PUT("SND: "), nf_rep (vab, <>, 1) if nfFdbg|nfFtra
  end

code	nf_abo - abort node

  func	nf_abo
	vab : * nfTvab
  is	cab_eli (vab, cabNRS)		; node reset
	fine
  end

code	nf_tra - set trace on or off

  proc	nf_tra
	flg : int
  is	nfFtra = flg
  end

code	nf_sta - set return status

  func	nf_sta
	vab : * nfTvab
	sta : int
  is	vab->Vsta = sta
	reply sta
  end

code	nf_eof - set end-of-file status

  proc	nf_eof
	vab : * nfTvab
  is	vab->Vsta = nfEOF
  end

code	nf_her - set hard error status

  proc	nf_her
	vab : * nfTvab
  is	vab->Vsta= nfIOX
  end

code	nf_siz - get device size

  func	nf_siz
	vab : * nfTvab
  is	PUT("Size\n")
	vab->Vblk = -1
  end
code	nf_loo - lookup

;	Check for non-file open and setup dummy directory
;	Check for printer etc and flag with size=ffff
;	Check for file too long and reject (vas:vrt.mar)
;
;	va.blk	seqnum
;	va.fmt	ch.use

	rxNF   := 054160
	rxNF0  := 054216

  func	nf_loo
	vab : * nfTvab
  is	cab : * cabTcab = <>
	buf : [mxSPC] char
	tmp : [mxSPC] char
 	spc : * char = buf
	fil : * FILE = <>
	typ : int = cabLOO
	len : int = 0
	fmt : int = vab->Vblk & 0xffff	

	if vab->Afna[0] eq rxNF		; NF:
	|| vab->Afna[0] eq rxNF0	; NF0:
	.. fine if !vab->Afna[1]	; ignore non-file lookups
					;
;	if vab->Afna[0] eq rxVX7	; VX7:
;	&& vab->Afna[2] eq rxDIR	; VX7:xxxDIR
;	   vab->Afna[0] = vab->Afna[1]	;
;	.. vab->Afna[1] = 0		;

	if vab->Pcab			; got a name cab
	   cab = vab->Pcab		;
	   spc = cab->Aspc		;
	else				;
	   rt_unp (vab->Afna, spc, -4)	; unpack the name

	   if st_sam (spc, "nf0:PIP.SAV") ; is pip being silly?
	   .. st_cop ("sy:pip.sav", spc) ; yes
	   fail if !nf_trn (vab, spc)	; translate it
					;
;	   fine if nf_vax (vab)		; check VAX directory
	end
	vab->Vfmt = 0			; assume no format

	if !vab->Afna[1]		; non-file lookup
	   if !fi_gat (spc, <>, <>)	;
	   .. fail STA(nfFNF)		;

;	   if !dr_val (spc)		; see if it's a directory
;	   .. fail STA(nfFNF)		; no such directory
	   typ = cabDEV			; open as a device
	   vab->Vlen = 0xffff		;
	else				;
	   fil = cab_acc (spc)		; actually open file
	   fail vab->Vsta = nfFNF if !fil ;
	   len = fi_len (fil)		; get file size
	   vab->Vlen = (len+511)/512	; round up to block size
	.. vab->Vfmt = len&511		; remainder in last block

	cab = cab_cre (vab, fil, spc, cabLOO, 0)

;	st_cop (spc, cab->Aspc)
;	st_cop (spc, cab->Atmp)
	vab->Vcid = cab->Vcid		; channel handle
	if fmt eq nfMNT			; mounting file?
	.. cab->Vflg |= cabPER_		; yep - flag permanent file
	if typ eq cabDEV		;
	.. cab->Vtyp = cabREP		;

;	vab->Vfmt = 
	fine
  end
;	purge files on channel
code	nf_ent - enter
	tmp_ten : (*char, *char, *char) void

  func	nf_ent
	vab : * nfTvab
  is	buf : [mxSPC] char
 	ten : [mxSPC] char
	spc : * char = buf
	fil : * FILE = <>
	len : int = 0
	cab : * cabTcab
	ptr : * char

	vab->Vfmt = 0			; assume no format
	if vab->Pcab			;
	   cab = vab->Pcab		;
	   spc = cab->Aspc		;
	else				;
	   rt_unp (vab->Afna, spc, -4)	; unpack the name
	.. fail if !nf_trn (vab, spc)	; translate it

	cab = cab_cre (vab, fil, spc, cabENT, 0)
;PUT("spc=[%s] tmp=[%s]\n", spc, cab->Atmp) if dbgC
	tmp_ten (spc, ".ten", cab->Atmp)
;	cab_ten (spc, ten, ".ten")	; get the tentative spec
;	tmp_spc (cab, ten, ".ten")	; get the tentative spec
;	fil = fi_opn (ten, "wb+", <>)	;
	fil = fi_opn (cab->Atmp, "wb+", <>)	;
	if fail				; oops
	   cab_dlc (cab, 0)		;
	.. fail STA(nfFNF)		;

	cab->Pfil = fil
	vab->Vcid = cab->Vcid		;

If 0
	cab_ten (spc, ten, ".ten")	; get the tentative spec
	fil = fi_opn (ten, "wb+", <>)	;
	fail STA(nfFNF) if !fil		;

	cab = cab_cre (vab, fil, spc, cabENT, 0)
	vab->Vcid = cab->Vcid		;
End
	if !vab->Vlen
	   vab->Vlen = 10000
	elif vab->Vlen eq 65535
	   vab->Vlen = 65000
	end
;	else
;	   fi_see (fil, (vab->Vlen*512)-1)
;	   fi_wri (fil, nfApad, 1)
;	   fi_flu (fil)
;	.. ;cab->Vhgh = vab->Vlen
;	vab->Vfmt = 
;	cab->Vlen = len
	fine
  end
code	nf_rea - read

;	Files entered with indefinite size are auto-extended.
;	This occurs where the last byte read exceeds the last
;	byte written to the channel.
;
;	old	read	new
;	0:0	0:1	1:0

  func	nf_rea
	vab : * nfTvab
  is	cab : * cabTcab
	fil : * FILE
	buf : * char = nfPbuf		;
	blk : int = vab->Vblk & 0xffff	;
	cnt : int = vab->Vtwc*2 	;
	fst : int = blk * 512		; fst  first to read
	lst : int = fst + cnt		; lst  last to read
	hgh : int =(lst+511)/512	; highest block referenced
	fine if nf_sho (vab)		; info channel

;	fine vab->Vlen = 0 if !cnt	; nothing to read
	vab->Vlen = vab->Vdbc = 0	; assume nothing read
					;
	cab = cab_opn (vab->Vcid)	; get the cab
fail PUT("cid=%x ", vab->Vcid), nf_her (vab) if !cab ; is none
	blk += cab->Vblk		; account for offset
	nf_rta (vab, cab)		; check RT-11 directory
					;
	if cab->Vtyp eq cabREP		; replacement cab
	   cnt = cab_rea (cab, buf, blk, cnt)
	   fail nf_eof (vab) if fail	; no such file
	   vab->Vlen = cnt		;
	   vab->Vdbc = cnt		;
	.. fine 		 	; all transferred

	fil = cab->Pfil			;
	fail nf_her (vab) if !fil	; no such file

	if cab->Vtyp eq cabENT		; new file
	&& hgh gt cab->Vhgh		; need to extend file?
;PUT("rea blk=%o cnt=%o hgh=%o old=%o\n", blk,cnt,hgh,cab->Vhgh)
	   fi_see (fil, lst-1)		;
	   fi_wri (fil, nfApad, 1)	;
	   fail nf_her (vab) if fail	; extend failed
	   fi_flu (fil)			;
	   fail nf_her (vab) if fail	; extend failed
	.. cab->Vhgh = hgh		; reset high

	case fi_prd (fil, buf, fst, cnt, <>)
	of fiERR  fail nf_her (vab)
	of fiEOF  fine nf_eof (vab)
	of fiPAR  
	or fiSUC  vab->Vlen = cnt
		  vab->Vdbc = cnt
		  fine
	end case
  end
code	nf_wri - write

  func	nf_wri
	vab : * nfTvab
  is 	cab : * cabTcab
	fil : * FILE
	buf : * char = nfPbuf
	blk : int = vab->Vblk
	cnt : int = vab->Vtwc*2
	rem : LONG
	hgh : int
	cab = cab_opn (vab->Vcid)

	fail nf_her (vab) if !cab	; no cab, no service

	if cab->Vtyp eq cabREP		; replacement cab
	   cnt = cab_wri (cab, buf, blk, cnt)
	   pass fine			;
	.. fail nf_eof (vab)		; out of bounds

	if cab->Vflg & cabRON_		; read only channel
	.. fail nf_her (vab)		; hard times

	fil = cab->Pfil			;
	blk += cab->Vblk		; account for offset
	fail nf_her (vab) if !fil	; no such file
	fi_see (fil, blk*512)		; seek to it
	fail nf_eof (vab) if fail	;
	fi_wri (fil, buf, cnt)		; write
	fail nf_her (vab) if fail	;
	fi_flu (fil)			;
	fail nf_her (vab) if fail	;
	vab->Vlen = cnt			; all transferred
					;
	if (rem = cnt & 511) ne		; got any residue
	   fi_wri (fil, nfApad, 512-rem); pad out with zero
	   fail nf_her (vab) if fail	;
	   fi_flu (fil)			; pad out with zero
	.. fail nf_her (vab) if fail	;
	hgh = blk + ((cnt+511)/512)	; high block
;PUT("wri blk=%o cnt=%o hgh=%o\n ", blk,cnt,hgh) if hgh gt cab->Vhgh
	cab->Vhgh = hgh if hgh gt cab->Vhgh
	fine
  end
code	nf_clo - close

;	Purge is not passed to server

  func	nf_prg
	vab : * nfTvab
  is	cab_pur (vab->Vcid)
  end

; ???	.CLOSZ is implemented as Close with vab->Vlen ne
; ???	Existing drivers, such as magtape, won't recognise .CLOSZ

  func	nf_clz
	vab : * nfTvab
  is	nf_clo (vab)
  end

  func	nf_clo
	vab : * nfTvab
  is	fil : * FILE
	if !vab->Vlen || (vab->Vlen eq -1)
	   cab_pur (vab->Vcid)
	else
	   cab_ext (vab->Vcid, vab->Vlen)
	   cab_clo (vab->Vcid)
	.. fail STA(nfFNF) if fail
	fine
  end
code	nf_del - delete

;	Add "protected file" error code

;	May need to see if file is currently open
;
;	VX7:JRESET.JOB
;	VX7:SRESET.JOB

  func	nf_del
	vab : * nfTvab
  is	cab : * cabTcab
	buf : [mxSPC] char
 	fil : * FILE = <>
	spc : * char = buf
	len : int = 0

	rt_unp (vab->Afna, spc, -4)	; unpack the name
	if st_sam (spc,"VX7:SRESET.JOB"); process reset
	|| st_sam (spc,"VX7:JRESET.JOB"); (old style)
	.. fine cab_eli (vab, cabIRS)	; process reset

	if vab->Pcab			; got a name block
	   cab = vab->Pcab		; 
	   spc = cab->Aspc		;
	else				;
	.. fail if !nf_trn (vab, spc)	; translate it

	vab->Vfmt = 0			; assume no format
	cab_del (spc)			; delete it
	fail STA(nfFNF) if fail		;
	fine
  end
code	nf_ren - rename

  func	nf_ren
	vab : * nfTvab
  is	nam : * nfTnam = <*nfTnam>vab
 	cab : * cabTcab
	src : [mxSPC] char
	dst : [mxSPC] char
	tmp : [mxSPC] char
	bak : int = 0
 	fil : * FILE = <>		;
	len : int = 0			;

	if vab->Pcab			; got a name block
	   cab = vab->Pcab
	   st_cop (cab->Aspc, src)
	   rt_unp (vab->Afna+1, st_end (src), -3)
	   st_cop (cab->Aspc, dst)
	   rt_unp (nam->Afnb+1, st_end (dst), -3)
	else
	   rt_unp (vab->Afna, src, -4)	; source
	   fail if !nf_trn (vab, src)	; translate it
	   nam->Afnb[0] = vab->Afna[0]
	   rt_unp (nam->Afnb, dst, -4)	; destination
	.. fail if !nf_trn (vab, dst)	; translate it
	vab->Vfmt = 0			; assume no format
	cab_ren (src, dst)		; do rename
	pass fine			;
	PUT("Rename failed: src=[%s] dst=[%s]\n", src, dst) if nfFtra
	fail STA(nfFNF)			;
  end
code	nf_trn - fully translate logical names

;	Translation first attempted with "rt_" prefix.

  func	nf_trn
	vab : * nfTvab
	spc : * char
  is	log : [20] char
	trn : [128] char
	col : * char
	src : * char = spc
	dst : * char
	st_cop ("rt_", log)
	st_app (spc, log)
	col = st_fnd (":", log)
	fail if null			; shouldn't happen
	*col = 0			; just the device
	if ln_trn (log, trn, 0)		; prefixed name translated
	.. fine st_ins ("rt_", spc)	; insert prefix
					;
	fine if ln_trn (log+3, trn, 0)	; base name translated
	fail STA(nfFNF)			; no such logical name
  end
code	nf_inf - get/set file info

; ???	Should exclude files that exceed 64kb
;
;	.SPFUN ->	NFx.SYS ->	NF.EXE ->	NFx.SYS -> .SPFUN
;	iq.buf->dblk	Vblk=val	Vblk=val	ch.len=val
;		val	Vrwc=opr/off
;		opr/off
;
;	GET works for all values
;	Must eventually work with all ACPs
;
;		GET	SET	BIC	BIS
;	Status	y	y*	y*	y*	*Protection only, always perm.
;	Spec	Y	N	N	N	Use rename
;	Date	Y	Y	N	N
;	Time	Y	Y	N	N
;	Length	Y	Y	N	N
;	Control	Y*	Y*	N	N	Only low-order time & era
;	UIC	Y*	Y*	N	N	Only if ACP supports	
;	Prot.	Y*	Y*	N	N	Only if ACP supports
;
;	N* = except for local RT11A/RT11X
;	Y* = local RT11X only, and with rights
;
;	Return previous value in vab->Vblk

	ifFNF := 1		; file not found error status
	ifIOP := 2		; invalid operation
	ifIOF := 3		; invalid offset
	ifIDT := 4		; invalid data

	ifGET := 0		; get operation
	ifBIC := 1		; bic
	ifBIS := 2		; bis
	ifMOV := 3		; move

	ifSTA := 0		; status
	ifFIL := 2		; filespec
	ifNAM := 4		; 
	ifTYP := 6		; 
	ifLEN := 8		; length
	ifTIM := 10		; RT-11 time (if bit15 set)
	ifDAT := 12		; RT-11 date
	ifCTL := 14		; RT11X control
	ifUIC := 16		; RT11X UIC
	ifPRO := 18		; RT11X protection mask

  type	ifTfab			; info block
  is	Pspc : * char		; filespec
	Vcur : int		; current value
	Vnew : int		; new value
  end

 type	ifTfun : (*nfTvab, *ifTfab) int	; info function

	if_gst : ifTfun		; get status 
	if_gdt : ifTfun		; get date 
	if_gtm : ifTfun		; get time 
	if_gln : ifTfun		; get length 
	if_unp : ifTfun		; set status - unprotect
	if_sdt : ifTfun		; set date 
	if_stm : ifTfun		; set time 
	if_sln : ifTfun		; set length 

  func	nf_inf
	vab : * nfTvab
  is	fab : ifTfab = {0}
	cab : * cabTcab
	buf : [mxSPC] char
	spc : * char = buf
	opr : int
	off : int

	fab.Vnew = vab->Vlen & 0xffff	; new value
	if vab->Pcab			; got a name block
	   cab = vab->Pcab		; 
	   spc = cab->Aspc		;
	   opr = cab->Vinf&255
	   off = cab->Vinf>>8
	else				;
	   opr = vab->Vblk&255
	   off = vab->Vblk>>8
	   rt_unp (vab->Afna, spc, -4)	; unpack the name
	   if !nf_trn (vab, spc)	; translate it
	.. .. fail STA(ifFNF)		;

	   opr = vab->Vblk&255
	   off = vab->Vblk>>8

	fab.Pspc = spc
	if (off&1) || (off gt ifPRO )	; validate arguments
	|| (opr gt ifMOV)		;
	.. fail STA(ifIOF)		; invalid offset

;	Get current value

	case off
	of ifSTA if_gst (vab, &fab)
	of 2
	or 4
	or 6 fab.Vcur = vab->Afna[off/2]
	of ifDAT if_gdt (vab, &fab) 
	of ifTIM if_gtm (vab, &fab)
	of ifLEN if_gln (vab, &fab) 
	of other fail STA(ifIOP)
	end case
	vab->Vblk = fab.Vcur			; return previous value

	case opr
	of ifGET
	of ifBIC				; only unprotect supported
	   if (off eq 0) && (fab.Vnew eq rtPRO_);
	   .. if_unp (vab, &fab)
	of ifBIS
	of ifMOV
	   case off
	   of ifDAT if_sdt (vab, &fab)		; set date
	   of ifTIM if_stm (vab, &fab)		; set time
	   of ifLEN if_sln (vab, &fab) 		; set length
	   of other nothing
	   end case
	of other fail STA(ifIOP)
	end case
	fine
  end

code	if_gxx - get current value

  func	if_gst
	vab : * nfTvab
	fab : * ifTfab
  is	sta : int = rtPER_
	atr : int
	fi_gat (fab->Pspc, &atr, <>)
	fail STA(nfFNF) if fail
	sta |= rtPRO_ if (atr & fiRON_)
	fab->Vcur = sta
	fine
  end

  func	if_gdt
	vab : * nfTvab
	fab : * ifTfab
  is	tim : tiTval
	plx : tiTplx
	fi_gtm (fab->Pspc, &tim, <>)
	fail STA(nfFNF) if fail
	ti_plx (&tim, &plx)
;PUT("[%d-%d-%d]\n", plx.Vday,plx.Vmon,plx.Vyea)
	rt_dat (&tim, &fab->Vcur, 1)		; y2k date
  end

  func	if_gtm
	vab : * nfTvab
	fab : * ifTfab
  is	tim : tiTval
	plx : tiTplx
	rem : int
	fi_gtm (fab->Pspc, &tim, <>)
	fail STA(nfFNF) if fail
	ti_plx (&tim, &plx)
;PUT("[%d-%d-%d]\n", plx.Vday,plx.Vmon,plx.Vyea)
	rt_tim (&tim, &fab->Vcur, &rem)
	fine
  end

  func	if_gln
	vab : * nfTvab
	fab : * ifTfab
  is	len : size
	if !fi_exs (fab->Pspc, <>)
	.. fail STA(nfFNF)
	fab->Vcur = (fi_siz (fab->Pspc) + 511) / 512
	fine
  end

code	if_sxx - set new value

;	Unprotect is the only file status operation permitted.
;	Unprotect removes the FATxx Read-Only attribute.

  func	if_unp
	vab : * nfTvab
	fab : * ifTfab
  is	fi_sat (fab->Pspc, drRON_, 0, <>)
	fail STA(nfFNF) if fail
	fine
  end

  func	if_sdt
	vab : * nfTvab
	fab : * ifTfab
  is	val : tiTval
	plx : tiTplx
	dat : tiTplx

	fi_gtm (fab->Pspc, &val, <>)
	fail STA(nfFNF) if fail
	ti_plx (&val, &plx)
	rt_udt (fab->Vnew, 1, &dat)
;PUT("[%d-%d-%d]\n", dat.Vday,dat.Vmon,dat.Vyea)
	plx.Vyea = dat.Vyea
	plx.Vmon = dat.Vmon
	plx.Vday = dat.Vday
	ti_val (&plx, &val)
	fi_stm (fab->Pspc, &val, <>)
	reply that
  end

  func	if_stm
	vab : * nfTvab
	fab : * ifTfab
  is	val : tiTval
	plx : tiTplx
	tim : tiTplx

	fi_gtm (fab->Pspc, &val, <>)
	fail STA(nfFNF) if fail
	ti_plx (&val, &plx)
	rt_utm (fab->Vnew, 0, &tim)
	plx.Vhou = tim.Vhou & 0xff
	plx.Vmin = tim.Vmin & 0xff
	plx.Vsec = tim.Vsec & 0xff
	ti_val (&plx, &val)
	fi_stm (fab->Pspc, &val, <>)
	reply that
  end

  func	if_sln
	vab : * nfTvab
	fab : * ifTfab
  is	fil : * FILE
	res : int
	atr : int
	atr = fi_gat (fab->Pspc, &atr, <>)
	fail STA(nfFNF) if fail
	fail if atr & (drRON_|drSYS_|drHID_)
	fil = fi_opn (fab->Pspc, "rwb", <>)
	fail STA(nfFNF) if fail
	res = fi_lim (fil, (fab->Vnew & 0xffff) * 512)
	fi_clo (fil, <>)
	reply res
  end
code	nf_wlk - directory walk

; ???	nf_dir test below is nopped
;
;	fail:	pass vab to server function
;	fine:	we did it, go away

  func	nf_wlk
	vab : * nfTvab
  is	buf : [mxSPC] char
	spc : * char = buf
	cab : * cabTcab = <>
	flg : int = vab->Vflg & (nfSUB_|nfWLK_)
	ptr : * char = spc

     case flg
     of nfWLK_				; initial: device and first directory
	rt_unp (vab->Afna, spc, 1)	; get the device or logical name
	ptr = st_end (spc)		; past it
	*ptr++ = ':'			;
	*ptr = 0			;
	nf_trn (vab, spc)		; translate it to RT_xxx if necessary
	quit if fail			; bye la bomba
	ptr = st_end (spc)		;
					;
	quit if !nf_dir (spc)		; must be a native directory
					;
	*ptr++ = '\\'			; \
	rt_unp (vab->Afna+1, ptr, 2)	; \subdir
	ptr = st_end (spc)		;
	quit if !nf_dir (spc)		; it must exist
	*ptr++ = '\\'			; \subdir\
	*ptr = 0			;
					; store result in a cab
	cab = cab_cre (vab, <>, spc, cabLOO, 0)
	cab->Vinf = vab->Vblk		; retain for nf_inf
	vab->Vcid = cab->Vcid		; and retain channel id reference
	if vab->Vfun eq nfLOO		; lookup
	&& (vab->Vblk & 0xffff) eq nfMNT; mounting file?
	.. cab->Vflg |= cabPER_		; yep - flag permanent file
	fine				;

     of nfWLK_|nfSUB_			; additional sub-directories
	cab = cab_map (vab->Vcid)	; find the cab
	quit if fail			; hopeless
 	spc = cab->Aspc			; use that as the spec
	ptr = st_end (spc)		;
	rt_unp (vab->Afna+1, ptr, 2)	; append new sub-directory
	ptr = st_end (spc)		;
	*ptr++ = '\\'			;
	*ptr = 0			;
	fine if nf_dir (spc)		; it must exist
	quit				;

     of nfSUB_				; finalise with filename and type
	cab = cab_map (vab->Vcid)	; get the cab
	quit if fail			;
	tmp_hng (cab->Aspc)		; clean up hanging stuff
	if vab->Vfun eq nfREN		; rename does own name stuff
 	.. fail vab->Pcab = cab		;
	spc = cab->Aspc			; use accumulated spec
	ptr = st_end (spc)		;
	if vab->Afna[1]			; not device mode
	&& vab->Afna[3] ne rx_DR	; and not old-style directory
	   rt_unp (vab->Afna+1, ptr, -3); add file name and type
	else				;
	.. vab->Afna[1] = 0		; device-mode
	vab->Pcab = cab			; vab now gets cab
	fail				;
     of other				;
	fail				; not a directory walk
     end case
	cab_dlc (cab, cabNRS) if cab	
	fine nf_eof (vab)
  end

  func	nf_dir
	spc : * char
  is	atr : int
	fi_gat (spc, &atr, <>)
	pass fail
fine
	reply atr & fiDIR_
  end
code	nf_sho - read server info
include	rid:tidef

;	Called by read to return date/time

  type	nfTsho
  is	Vgua : elTwrd
	Vtok : elTwrd
	Vlen : elTwrd

	Vyea : elTwrd
	Vmon : elTwrd
	Vday : elTwrd
	Vhou : elTwrd
	Vmin : elTwrd
	Vsec : elTwrd
	Vmil : elTwrd
	Vzon : elTwrd
	Vdst : elTwrd

	Vcpu : elTwrd
	Vops : elTwrd
	Aser : [12] char
  end

	nfSHO = (cabFST|cabSHO)<<cabSHF

  func	nf_sho
	vab : * nfTvab
  is	sho : * nfTsho = <*void>nfPbuf
	val : tiTval
	clk : tiTplx
	fail if vab->Vcid ne nfSHO
	sho->Vgua = -1
	sho->Vlen = #nfTsho
	ti_clk (&val)
	ti_plx (&val, &clk)
	sho->Vyea = clk.Vyea
	sho->Vmon = clk.Vmon + 1
	sho->Vday = clk.Vday
	sho->Vhou = clk.Vhou
	sho->Vmin = clk.Vmin
	sho->Vsec = clk.Vsec
	sho->Vmil = clk.Vmil
	sho->Vdst = clk.Vdst

	sho->Vcpu = 0
	sho->Vops = 0
	st_cop ("ANON", sho->Aser)
	vab->Vlen = 128
	vab->Vdbc = 128
	fine
  end
code	nf_rta - rt-11 directory crack

;???	Add RT11X, byte size remainder and time remainder (and era)
;???	Directory limited to 31 segments (2201 files). Why not extend?
;	No warning given of directory that is too long

  func	nf_rta
	vab : * nfTvab
	cab : * cabTcab
  is	rep : * cabTrep
	dir : * drTdir
	ent : * drTent
	buf : [1024] elTwrd = {0}
	seg : * elTwrd
	spc : * char
	fna : [4] elTwrd
	len : int = 0
	blk : int = 6
	nxt : int = 1			; next directory segment
	nth : int = 0			; entry in this segment
	tim : int
	rem : int
	dat : int
	era : int
	siz : LONG
	acc : LONG

	if vab->Vblk gt 6		;
	|| cab->Vtyp ne cabREP		;
	|| cab->Vflg & cabDIR_		; already is a directory
	.. fail

	fi_flu (<>)			; flush everything
	dir = dr_scn (cab->Aspc, drNOR_,drNAM); scan the directory
	pass fail			; no such directory
	cab->Vflg |= cabRON_|cabRTA_|cabDIR_ ;

	vab->Vcid = cab->Vcid		;
	vab->Vlen = 100			;

	acc = 6 + (31 * 2)		; block accumulator 
	seg = buf, nth = 0		;
	while (ent = dr_nxt (dir)) ne	;		
;	   next if ent->Vatr & drDIR_	; skip directories
	   next if st_fnd ("/", ent->Pnam)
	   spc = rt_spc (ent->Pnam, fna+1, 1, 3) 
	   next if *spc			;
	   fna[3] = rxDIR if ent->Vatr & drDIR_

	   if nth eq			; first entry of segment
	      *seg++ = 31		; total number of segments
	      quit if nxt eq 32	;!!!	; no more space
	      *seg++ = ++nxt		; link to next segment
	      *seg++ = 31		; highest segment
	      *seg++ = 6		; extra bytes
	   .. *seg++ = acc		; first block of segment
; handle overflow

	   rt_tim (&ent->Itim,&tim,&rem); file time
	   rt_dat (&ent->Itim, &dat, 1)	; y2k date
	   rt_era (&ent->Itim, &era)	; y2m era
	   siz = (ent->Vsiz + 511) >> 9	;
	   acc += siz			;

	   *seg++ = 0102000 if ent->Vatr & drRON_ ; protected
	   *seg++ = 02000   otherwise	; permanent
	   *seg++ = fna[1]		; filename 
	   *seg++ = fna[2]
	   *seg++ = fna[3]
	   *seg++ = siz			; file size
	   *seg++ = tim			; file creation info
	   *seg++ = dat			; date
	   *seg++ = (era<<2)|(rem&3)	; era and time remainder
	   *seg++ = 0			; protection
	   *seg++ = 0			; uic
	   next if ++nth ne 50 ;71	; more to go
	   *seg = 04000			; end segment
	   cab_rep (cab, buf, blk, 1024); store them
	   me_clr (buf, 1024)		;
	   seg = buf, blk += 2, nth = 0 ;
	end

;	Create last entry

	if nth eq			; first entry of segment
	   seg = buf			; create new segment
	   *seg++ = 31			; total number of segments
	   *seg++ = 0			; link to next segment
	   *seg++ = nxt			; highest segment
	   *seg++ = 0			; extra bytes
	   *seg++ = acc			; first block of segment
					;
	   *seg++ = 01000		; empty
	   *seg++=0, *seg++=0, *seg++=0	; no file name
	   *seg++=0, *seg++=0, *seg++=0	; zero blocks, no job, no date
					;
	   *seg = 04000			; end segment
	else
	   buf[1] = 0			; no next segment
	.. *seg = 04000			; end segment

	cab_rep (cab, buf, blk, 1024)	; store them

	rep = cab_loc (cab, 6)		; get the first block
	rep->Abuf[4] = nxt		; last segment in use
	dr_dlc (dir)			; dump the directory
	fine
  end
code	nf_rep - report vab

	rpNOP	:= 0
	rpTRN	:= 1
	rpDIR	:= 2
	rpCLO	:= 3

  type	nfTrep
  is	Vcas : int
	Pdsc : * char
  end

  init	nfArep : [] nfTrep
  is	rpNOP,	"Abort"
	rpTRN,	"Read"
	rpTRN,	"Write"
	rpDIR,	"Lookup"
	rpDIR,	"Enter"
	rpCLO,	"Close"
	rpDIR,	"Delete"
	rpDIR,	"Rename"
	rpNOP,  "Size"
	rpCLO,  "Purge"
	rpDIR,  "Info"
	rpCLO,  "Cloze"
	rpDIR,	"Invalid"
  end

  proc	nf_rep
	vab : * nfTvab
	buf : * BYTE
	snd : int 
  is	cab : * cabTcab
	spc : [16] char
	ptr : * BYTE
	cnt : int
	cas : int

	if (vab->Vfun&0xFF) ge nfMAX	; invalid function
	   cas = nfMAX
	else
	.. cas = nfArep[vab->Vfun].Vcas
	PUT("%s ", nfArep[vab->Vfun].Pdsc)
	PUT("fun=%d. ", vab->Vfun&0xFF) if cas eq nfMAX
	PUT("flg=0%o ", vab->Vflg & 0xff) if vab->Vflg
	PUT("vid=%d ", vab->Vvid) if vab->Vvid
	PUT("cid=0%o ", vab->Vcid) if vab->Vcid
	PUT("sta=0%o ", vab->Vsta) if vab->Vsta

	if cas eq rpDIR
	   if vab->Afna[0] || vab->Afna[1] || vab->Afna[2] || vab->Afna[3]
	      rt_unp (vab->Afna, spc, -4)	; unpack the name
	   .. PUT("fna=[%s] ", spc)
	   if vab->Vfun eq nfREN
	   && (vab->Afna[4] || vab->Afna[5] || vab->Afna[6] || vab->Afna[7])
	      rt_unp (vab->Afna+4, spc, -4)	; unpack the name
	   .. PUT("fnb=[%s] ", spc)
;	   PUT("fmt=%o ", vab->Vblk) if vab->Vblk
	end

	if cas eq rpTRN
	&& (cab = cab_opn (vab->Vcid)) ne
	.. PUT("%s ", cab->Aspc)

	PUT("blk=%d ", vab->Vblk) if vab->Vblk

	if cas eq rpTRN
	   PUT("rwc=") if vab->Vrwc
	   if vab->Vrwc ne vab->Vtwc
	   .. PUT("%d ", vab->Vrwc) if vab->Vrwc
	   PUT("twc=%d ", vab->Vtwc) if vab->Vtwc
	end

	if vab->Vlen ne vab->Vdbc
	.. PUT("len=%d ", vab->Vlen) if vab->Vlen
	PUT("dbc=%d ", vab->Vdbc) if vab->Vdbc

	if cas eq rpDIR
	   PUT("fmt=0%o ", vab->Vfmt) if vab->Vfmt
	   if !snd
	      PUT("prc=%d ", vab->Vjid & 0xff) if vab->Vjid
	   .. PUT("chn=%d ", vab->Vjcn & 0xff) if vab->Vjcn
	end

	if cas eq rpCLO
	   PUT("act=%d", cabVact)
	end

;	PUT("hck=0%o ", vab->Vhck) if vab->Vhck
;	PUT("dck=0%o ", vab->Vdck) if vab->Vdck

	if nfFdmp 
	   PUT("\n     ")
	   ptr = buf + 14 , cnt = 16
	   PUT("%2x ", *ptr++ & 0xff) while cnt--
	   cnt = 16
	   PUT("\n     ")
	   PUT("%2x ", *ptr++ & 0xff) while cnt--
	   cnt = 16
	   PUT("\n     ")
	.. PUT("%2x ", *ptr++ & 0xff) while cnt--
	PUT("\n")
  end
end file
code	nf_vax - vms directory crack

; ???	Not currently in use
;
;	Native (VAX) and RT-11 directories are supported.
;	Each is stored as a chain of segment/block#/byte count
;	Enter and Lookup are handled identically.
;	However, the channel is opened Read-Only.
;	Read calls a common routine which detemines the response.
;
;	VX7:xxxDIR.	Opens a native directory on xxx
;
;	We assume the directory name has been checked in advance.

  func	nf_vax
	vab : * nfTvab
  is	cab : * cabTcab
	rep : * cabTrep
	dir : * drTdir
	ent : * drTent
	buf : [256] elTwrd = {0}
	seg : * elTwrd
	spc : [20] char
	len : int = 0
	alc : int 
	sum : int
	blk : int = 0
	nth : int = 0
	rem : int
	if vab->Afna[0] eq rxVX7	;
	&& vab->Afna[2] eq rxDIR	; got a directory request?
	else 
	.. fail if vab->Afna[3] ne rx_DR	; not

	rt_unp (vab->Afna+1, spc, 1)	; unpack the name
	st_app (":", spc)
	fail if !nf_trn (vab, spc)	; translate it
;PUT("spc=[%s]\n", spc)
	dir = dr_scn (spc, drNOR_,drNAM); scan the directory
	pass fail			; no such directory
	cab = cab_cre (vab, <>, spc, cabREP, cabRON_|cabVAX_)
	vab->Vcid = cab->Vcid		;

	seg = buf, rem = 512		; remaining bytes
	while (ent = dr_nxt (dir)) ne	;		
	   len = st_len (ent->Pnam)	; name length
	   next if ent->Vatr & drDIR_	; skip directories
	   alc = (len + 1) & ~(1)	; mysteries of the temple
	   sum = 6 + alc + 8		; sum of fields
	   if sum ge (rem - 2)		; not enough
	      *seg++ = -1, rem -= 2 while rem ; terminate this one
	      cab_rep (cab,buf,blk,512)	; store them
	      ++blk
	      me_clr (buf, 512)		;
	   .. seg = buf, rem = 512 
	   rem -= sum			; count down	      
	   *seg++ = 4 + alc + 8		; record size
	   *seg++ = 0, *seg++ = len<<8	;
	   st_upr (ent->Pnam)		; needs it in upper case
	   me_cop (ent->Pnam, seg, len)	;
	   seg += alc / 2		; skip all that
	   *seg++ = 1, *seg++ = 0	; not worth knowing
	   *seg++ = 0, *seg++ = 0	;
	end				;
	if rem lt 512			; stuff to write out
	      *seg++ = -1, rem -= 2 while rem ; terminate this one
;	   *seg = -1			; terminate this one
	.. cab_rep (cab,buf,blk,512)	; store them
	vab->Vlen = blk + 1		;
	dr_dlc (dir)			; dump the directory
	fine
  end
code	nf_dsk - disk operations

;	Not currently in use

	nfAdsk : [8] *FILE
	nfAzer : [512] char = {0}
	nf_mnt : (int, int) * FILE

  func	nf_dsk
	vab : * nfTvab
  is	uni : int = 1
	blk : LONG = vab->Vblk
	buf : * char = nfPbuf
	cnt : LONG = vab->Vtwc*2
	fil : * FILE = nf_mnt (1, 0)
	rem : LONG
	err : int = 0

	exit nf_her (vab) if !fil
	
	case vab->Vfun
	of nfREA
	   quit ++err if !fi_see (fil, blk * 512)
	   quit ++err if !fi_rea (fil, buf, cnt)
	   vab->Vlen = cnt 
	   vab->Vdbc = cnt
	of nfWRI
	   quit ++err if !fi_see (fil, blk * 512)
	   quit ++err if !fi_wri (fil, buf, cnt)
	   quit if !(cnt & 511)
	   rem = 512 - (cnt & 511)
	   quit ++err if !fi_wri (fil, nfAzer, rem)
;	of nfSIZ
;	   quit if dev->Vtyp ne elHDD
;	   el_swd (buf, dev->Vsiz)
	end case
	fail nf_her (vab) if err
	fine
  end

  func	nf_mnt
	uni : int
	upd : int
	()  : * FILE 
  is	spc : [mxLIN] char
	dsk : ** FILE
	idx : int

	if ev_chk (evDEV)	
	   PUT("%NF-I-Disk change\n") if nfFdbg|nfFtra
	.. ++upd

	dsk = nfAdsk, idx = 0
	while upd && idx ne 8
	   fi_clo (*dsk, <>) if *dsk
	   ++idx, ++dsk
	end

	if !nfAdsk[uni]
	   FMT(spc, "ND%c:", '0'+uni)
	   nfAdsk[uni] = cab_acc (spc)	; open file
	   if fail && (nfFdbg|nfFtra)
	.. .. PUT("%%NF-W-Disk volume not found [%s]\n", spc)
	reply nfAdsk[uni]
  end
