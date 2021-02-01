;
;	GO bit needs to be observed
;	Toggling enable when ready should cause an interrupt
file	eldsk - disk emulators
include	elb:elmod
include	rid:medef
include	rid:fidef
include	rid:cldef
include	rid:evdef
include	rid:imdef
include	rid:dbdef
include	rid:stdef
include	rid:mxdef
include	rid:ctdef
include rid:codef
include rid:tidef
include rid:wcdef
include rid:lndef
;nclude rid:shdef

data	devices

;	Accesses to device registers must be with el_fmw/el_smw.
;	Using el_fwd/el_swd can cause side-affects.
;
;	The clock only interrupts if a vector is present in location 100.
;
;	This list is also used for the reset instruction.

  init	elAvec : [] elTvec
  is;	Id	Csr	Enable,	Ready, Vector	Latency Count	Priority
	{elCON, 0,	0,	0,	0,	0,	0,	0}
	{elCLK, 0,	elENB_,	0,	veCLK,	0,	0,	6*32}
	{elKBD, elTKS,	elENB_,	elRDY_,	veKBD,	100,	0,	4*32}
	{elTER, elTPS,	elENB_,	elRDY_,	veTER,	0,	0,	4*32}
	{elHDD, hdCSR,	elENB_,	0,	hdVEC,	100,	0,	5*32}
	{elDLD, rlCSR,	elENB_,	0,	rlVEC, 	10,	0,	5*32}
	{elRKD, rkCSR,	elENB_,	0,	rkVEC, 	100,	0,	5*32}
;	{elDYD, dyCSR,	elENB_,	0,	dyVEC, 	100,	0,	5*32}
	{-1,0,0,0,0}				; terminator
  end
	elVvsz : int = #elAvec

data	generic disk list

  init	elAdsk : [] elTdev
  is	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
	{elHDD, 0, 0, 0, 0, 0, <>, ""}
  end
	elVdsz : int = #elAdsk

  init	elAopr : [] *char
  is	elRES: "Reset"
	elREA: "Read"
	elWRI: "Write"
	elSIZ: "Size"
	elSEE: "Seek"
	elNOP: "Nop"
  end

data	terminal

	elVtks : int = 0	; requesting character
	elVtkb : int = 0	; have character
	elVtpp : int = 0	; output pending

	el_hdx : (void) void
	el_rlx : (void) void
	el_dyx : (void) void
	el_rkx : (void) void
	el_hom : (*elTdev)
code	el_mnt - mount disk

  func	el_mnt
	dev : * elTdev
	uni : int
	nam : * char
  is 	fil : * FILE
	dsk : * elTdev = dev + uni		; dsk -> device unit
	dsk->Pfil = 0				;
	dsk->Vsts = 0				;
	dsk->Vuni = uni
	st_cop (nam, dsk->Aspc)			; remember the spec
	fi_trn (nam, dsk->Anam, 0)		; translated file spec
	PUT("LD%d:=[%s]\n", uni, dsk->Anam) if elFvrb ; verbose
	fil = fi_opn (nam, "r+b", "") 		; open it (with message)
	pass fail				; no such disk
	dsk->Pfil = fil				; save it
	dsk->Vext = dsk->Vsiz = fi_siz(nam)/512	; disk size
	if dsk->Vsiz gt 65535			; a little big
	&& elFsma				; and want smarts
	   PUT("?V11-W-LD%o: [%s] truncated from %d to 65535 blocks\n",
	      uni, dsk->Anam, dsk->Vsiz)
	.. dsk->Vsiz = 65500			; absolute limit
	el_hom (dsk)				; search for home block
	fine
  end

code	el_chg - check for disk changes

  proc	el_chg
  is	el_rmt () if ev_chk (evDEV)		; remount if changed
  end

code	el_rmt - remount disks

  proc	el_rmt
  is	uni : int = 0
	dev : * elTdev
	while uni le 7
	   dev = elAdsk + uni
	   fi_clo (dev->Pfil, <>) if dev->Pfil	; close it first
	   ++uni
	end
	el_aut ()
  end

code	el_aut - automount disks

  proc	el_aut
  is	uni : int = 0
	nam : [256] char
	trn : [256] char

 	while uni le 7
DMP("a")
	  fi_def (elAsys, "pdp:.dsk", nam) if !uni && elAsys[0]
	  FMT(nam, "LD%d", uni) otherwise
DMP("b")
	  fi_trn (nam, trn, 0)
DMP("c")
	  if fi_exs (trn, <>)
	     el_mnt (elAdsk, uni, nam)
	  elif !uni && elAsys[0]
	  .. im_rep ("F-No such system disk [%s]", trn)
DMP("c")
	  ++uni
	end
  end

code	el_chd - check disk

  func	el_chd
	uni : int
	msg : int
  is	dev : * elTdev = elAdsk + uni
	fine if dev->Pfil
	PUT("?V11-W-No such disk LD%d:=[%s]\n", uni, dev->Anam)
	fail
  end

code	el_lsd - list disks

  proc	el_lsd
  is	uni : int = 0
	dev : * elTdev
	PUT("\n")
	while uni le 7
	   dev = elAdsk + uni
	   if dev->Anam[0]
	      PUT("LD%d:=[%s]", uni, dev->Anam)
	      PUT(" (Unmounted)") if !dev->Pfil
	   .. PUT("\n")
	   ++uni
	end
  end

code	el_hom - search for home block

;	Some disk files have prefix blocks--skip them

  func	el_hom
	dsk : * elTdev
  is	fil : * FILE = dsk->Pfil
	buf : [512] char
	blk : int = 1
	fine if !elFsma

      while blk lt 20
	quit if !fi_see (fil, blk*512)
	quit if !fi_rea (dsk->Pfil, buf, 512)
	next ++blk if !me_cmp (buf+0760, "DEC", 3)
	fine if blk eq 1
	dsk->Vbas = blk - 1
	PUT("?V11-W-LD%o: [%s] home block is block %d.\n",
	   dsk->Vuni, dsk->Anam, blk)
	fine
      end

;	Boot blocks begin with NOP (0240)

	if fi_see (fil, 0)
	&& fi_rea (dsk->Pfil, buf, 512)
	&& buf[0] eq 0240
	&& buf[1] eq
	.. fine

	PUT("?V11-W-LD%o: [%s] DEC home block not located\n",
	   dsk->Vuni, dsk->Anam)
	fail
  end
code	el_dkx - generic disk dispatcher

 	dyVbuf : int
	rlRDY_ := 0200		; disk ready
	rkACT_ := 1		; go

	elPdev	: * char = "BO"

 proc	el_dkx
  is	el_hdx () if *MNW(hdCSR) & hdACT_	; HD:
	el_rlx () if !(*MNW(rlCSR) & rlRDY_)	; DL:
	el_rkx () if *MNW(rkCSR) & rkACT_	; RK:
;	el_dyx () if *MNW(dyCSR)&(dyACT_|dyINI_); DY:
;	el_dyx () if dyVbuf			; DY: buffer access
  end

code	el_trn - generic transfers

  proc	el_trn
	uni : int
	buf : LONG
	cnt : int
	blk : int
	fun : int
	hid : int				; hidden flag - internal I/O
	()  : * elTdev
  is	dev : * elTdev = elAdsk + uni
	fil : * FILE = dev->Pfil
	vir : size = blk + dev->Vbas
	err : int = 0
	rem : size
	siz : size
	cnt &= 0xffff
	el_chg ()				; check device changes
	if !fil
	   dev->Vsts = hdERR_
	.. reply dev
	if !hid && bgVdsk ;&& ((fun eq elREA) || (fun eq elWRI))
	   PUT("%o	", PC)
	   PUT ("%s	", elAopr[fun])
	   PUT("%s%d: ", elPdev, uni)
	   PUT("Blk=%o|%d. ", blk, blk)
	   PUT("Buf=%lo Wct=%d. ", buf, cnt/2)
	.. PUT("Bct=%o", cnt), el_new ()
	case fun
	of elRES
	   dev->Vsts = 0
	of elREA
	   quit ++err if !fi_see (fil, vir * 512)
	   quit ++err if !fi_rea (fil, PNB(buf), cnt)
	of elWRI
	   quit PUT("Disk write ignored\n") if !elFwri
	   quit ++err if !fi_see (fil, vir * 512)
	   quit ++err if !fi_wri (fil, PNB(buf), cnt)
	   quit if dev->Vtyp ne elHDD
	   quit if !(cnt & 511)
	   rem = 512 - (cnt & 511)
	   quit ++err if !fi_wri (fil, elAzer, rem)
	of elSIZ
	   quit if dev->Vtyp ne elHDD
	   el_swd (buf, dev->Vsiz)
	of elNOP
	   nothing
	end case
	dev->Vsts |= hdERR_ if err
	dev->Vsts &= (~hdERR_) otherwise
	reply dev
  end
code	el_hdx - HD: hard disk emulator

;	Called after a store to hdCSR
; ???	Should cleanup other things

  proc	el_hdx
  is  	csr : elTwrd = el_fmw (hdCSR)
	uni : int = (csr >> 9) & 7
	buf : LONG = el_fmw (hdBUF) & 0xffff
	cnt : int = el_fmw (hdCNT) & 0xffff
	blk : int = el_fmw (hdBLK) & 0xffff
	dev : * elTdev
	fun : int = (csr >> 1) & 7
	elPdev = "HD"
	exit if !(csr & hdACT_)			; not in go
	csr &= (~(hdACT_|hdRDY_|hdERR_))	; clear flags
	el_smw (hdBUF, buf + cnt)		; update buffer address 
	el_smw (hdCNT, 0)			; update word count
	buf = buf | ((csr&060)<<(16-4))		; get extended address
	dev = el_trn (uni, buf, cnt, blk, fun,0);
	csr |= hdRDY_				; operation complete
	csr |= hdERR_ if dev->Vsts & hdERR_	; some problem
	el_smw (hdCSR, csr)
	el_sch (elHDD) if csr & elENB_		; (not true in boot)
  end
code	el_rlx - RL01/RL02 DL: disk emulator

;	Supports XXDP and unmapped RT-11 systems so far.
;	Seek has loose ends.

;	rlCSR := 0174400
;	rlBUF := 0174402
;	rlBLK := 0174404
;	rlCNT := 0174406
;	rlVEC := 0160
;	rlPRI := 0240

	rlCYL := 256		; cylinders
	rlRL2 := 2		; RL02 factor
	rlSpT := 40		; sectors per track
	rlHDS := 2		; heads
	rlBpS := 256		; bytes per sector
	rlBpT := rlBpS * rlSpT	; bytes per track
	rlBpC := rlBpT * rlHDS	; bytes per cylinder
	rlS01 := rlBpC * rlCYL	; bytes per RL01
	rlSO2 := rlS01 * rlRL2	; bytes per RL01

	rlRL1 := 10240		; blocks per RL01
	rlRL2 := 20480		; blocks per RL02

	rlDKS  := rlCSR		;
	rlERR_ := 0100000	; csr flags
	rlUNI_ := 01400		; unit number
;	rlCHG_ := 0400		; disk changed flag
	rlRDY_ := 0200		; controller ready
	rlENB_ := 0100		; interrupt enabled
	rlEXT_ := 060		; extended address
	rlFUN_ := 016		; 8 function codes
	rlDRV_ := 01		; driver ready

	rlNOP := 0		; nop
	rlWTC := 1	; 2	; write check
	rlSTA := 2	; 4	; get status
	rlSEE := 3	; 6	; seek
	rlRHD := 4	; 10	; read header
	rlWRI := 5	; 12	; write data
	rlREA := 6	; 14	; read data
	rlRDX := 7	; 16	; read with no header check
	rlBH_ := 010

	rlMsec(x) := ((x) & 077)
	rlMtrk(x) := (((x) >> 6) & 01777)
	rlMcyl(x) := (((x)>>7) &0777)

;	status codes

;	rlBH_ := 010
;	rlHO_ := 020
;	rlCO_ := 040
;	rlLK_ := 05
;	rl02_ := 0200

  proc	el_rlx
  is  	csr : elTwrd = el_fmw (rlCSR)
	uni : int = (csr >> 8) & 3
	fun : int = (csr >> 1) & 7
	dev : * elTdev = elAdsk + uni
	fil : * FILE = dev->Pfil
	buf : LONG = el_fmw (rlBUF) & 0xffff
	wct : elTwrd = el_fmw (rlCNT)
	cnt : int = (-wct * 2) & 0xffff
	trk : elTwrd = el_fmw (rlBLK)
	ext : elTwrd = elFdlx ? el_fmw (rlEXT) ?? 0
	tmp : int = 0
	blk : int
	cyl : int
	hea : int
	sec : int
	opr : int = elNOP
	elPdev = "DL"
	csr &= (~(rlRDY_|rlDRV_|rlERR_)); clear flags
	opr = elRES			; default operation
	case fun
	of rlNOP 
	of rlWTC 		 
	of rlSTA if !fil
		    wct = 040 
	   	 else
		    wct = 035
	 	    wct |= BIT(6) if dev->V0 & BIT(6)
		 .. wct |= BIT(7) if dev->Vsiz gt rlRL1
		 el_smw (rlCNT, wct)
	of rlSEE 
	of rlRHD el_smw (rlBLK, 0) ; dev->V0
	of rlREA 
	or rlRDX 
	or rlWRI opr = (fun eq rlWRI) ? elWRI ?? elREA
	   cyl = (trk >> 7) 
	   hea = (trk >> 6) & 1
	   sec = trk & 077
	   blk = ((cyl * rlBpC) + (hea * rlBpT) + (sec * rlBpS)) / 512
	   if !ext
	     buf = buf | ((csr&rlEXT_)<<(16-4))	; get extended address
	   else
	     buf = buf | ((ext & 033) << 16)
	   end

	   dev = el_trn (uni, buf, cnt, blk, opr, 0) ; handle transfers

	   buf += cnt				; update registers
	   csr = (csr&~(rlEXT_)) |  ((buf>>(16-4))&rlEXT_)

;PUT("buf=%o cnt=%o add=%o ext=%o\n", buf, cnt, buf+cnt, ((buf>>(16-4))&rlEXT_))
	   el_smw (rlBUF, buf)			; update buffer address 
	   el_smw (rlCNT, 0)			; update word count
	   el_smw (rlEXT, 0)

	   csr |= rlERR_ if dev->Vsts & hdERR_	; some problem
	end case
	csr |= rlRDY_ |rlDRV_			; operation complete
	el_smw (rlCSR, csr)			; setup CSR
	el_sch (elDLD) if csr & rlENB_		; schedule interrupt
  end
code	el_rkx - RK05 RK: disk emulator

;	rkSTA := 0177400
;	rkERR := 0177402
;	rkCSR := 0177404
;	rkCNT := 0177406
;	rkBUF := 0177410
;	rkADR := 0177412
;	rkDAT := 0177414
;	rkVEC := 0220
;	rkPRI := 0240
;	rkRK5_ := 04000
;	rkRDY_ := 0100
				; rkSTA - drive status
	rkSOK_ := BIT(8)	; sector okay flag
	rkDRD_ := BIT(7)	; drive ready
	rkRWR_ := BIT(6)	; read/write/seek ready
	rkHIP_ := BIT(4)	; heads in position
	rkSTA_ := rkSOK_|rkDRD_|rkRWR_|rkHIP_ ; combined status
	rkSEC_ := 017		; sector counter
				; rkERR
	rkDER_ := BIT(15)	; drive error
	rkSEE_ := BIT(12)	; seek error
				; rkCSR
	rkERR_ := BIT(15)	; some error
	rkRDY_ := BIT(7)	; controller ready
	rkENB_ := BIT(6)	; interrupt enable
	rkFUN_ := 016		; function mask
	rkACT_ := BIT(0)	; go
	 rkRES := 0		; controller reset
	 rkWRI := 1		; write
	 rkREA := 2		; read
	 rkWCK := 3		; write check
	 rkSEE := 4		; seek
	 rkRCK := 5		; read check
	 rkDRS := 6		; drive reset
	 rkWLK := 7		; write lock
	
	rkCYL := 203		; 203 cylinders per drive
	rkSEC := 12		; 12 sectors per cylinder

;	status codes

;	rkBH_ := 010
;	rkHO_ := 020
;	rkCO_ := 040
;	rkLK_ := 05
;	rk02_ := 0200

	el_rka : (*elTdev, int, LONG)

;	Don't accept a new command while one is pending.

	el_rk5 : (void) void

  proc	el_rkx
  is  	csr : elTwrd = el_fmw (rkCSR)
	exit if !(csr & elACT_)			; not in go
	el_rk5 ()  
  end

  proc	el_rk5
  is  	csr : elTwrd = el_fmw (rkCSR)
	adr : elTwrd = el_fmw (rkADR)
	uni : int = (adr >> 13) & 7	; unit
	fun : int = (csr >> 1) & 7	; function
	trk : int = (adr >> 4) & 0777	; track (0..203.)
	sec : int = (adr & 017)		; sector (0..12.)
	blk : int = (trk*12) + sec	; block
	buf : LONG = el_fmw (rkBUF) & 0xffff
	wct : elTwrd = el_fmw (rkCNT)
	cnt : int = (-wct * 2) & 0177777 
	opr : int
	dev : * elTdev
	upd : int = 0
	elPdev = "RK"

	csr &= ~(rkRDY_|rkERR_|rkACT_)	; clear flags
	opr = elREA			; default operation
	case fun
	of rkRES opr = elRES
	of rkDRS opr = elRES		; drive reset
	of rkWLK opr = elNOP		; write lock
	of rkSEE opr = elSEE
	of rkWRI 		 
	or rkWCK
	   opr = elWRI
	or rkREA 
	or rkRCK 
	   buf = buf | ((csr&060)<<(16-4))	; get extended address
	   upd = 1
	end case
	el_smw (rkSTA, rkSTA_)			; update status
	el_smw (rkBUF, buf + cnt)		; update buffer address 
	el_smw (rkCNT, 0)			; update word count
	dev = el_trn (uni, buf, cnt, blk, opr,0); handle transfers
	csr |= rkRDY_				; operation complete
	csr |= rkERR_ if dev->Vsts & hdERR_	; some problem
	el_smw (rkCSR, csr)			; setup CSR
	if upd
	   blk = blk+((cnt+511)/512)
	   trk = blk/12
	   sec = blk-(trk*12)
	   adr = (trk<<4)|sec
	.. el_smw (rkADR, adr)
	if fun eq rkRES
;	   el_smw (rkSTA, 0)
	   el_smw (rkERR, 0)
	   el_smw (rkCSR, elRDY_)
;	   el_smw (rkCNT, 0)
	   el_smw (rkBUF, 0)
	.. el_smw (rkADR, 0)
;	.. el_smw (rkDAT, 0)
	el_sch (elRKD) if csr & rkENB_		; schedule interrupt
  end
end file
code	el_dyx - RX02 DY: floppy emulator

; dyCSR
	dyACT_ := BIT(0)	; go
	dyFUN_ := 016		; function mask
	 dyFIL := 0		; fill silo
	 dyEMP := 1		; empty silo
	 dyWRI := 2		; write
	 dyREA := 3		; read
	 dyFMT := 4		; format
	 dySTA := 5		; read status
	 dyWDD := 6		; write with deleted data
	 dyERR := 7		; read error status
	dyRDY_ := BIT(5)	; controller ready
	dyENB_ := BIT(6)	; interrupt enable
	dySTP_ := BIT(7)	;
	dyDEN_ := BIT(8)	; double density
	dyHEA_ := BIT(9)	; head 2
	dyRX2_ := BIT(11)	; RX02 flag
	dyEXT_ := 030000	; 18-bit extended address
	dyINI_ := BIT(14)	; init
	dyERR_ := BIT(15)	; some error

	el_dya : (*elTdev, int, LONG)
	dyAbuf : [256] elTwrd = {0}
	dyVblk : elTwrd = -1

	dyIGN := 0
	dyRBA := 1
	dyRWC := 2
	dyRSC := 3
	dyRTK := 4

  proc	el_dyx
  is  	csr : elTwrd = el_fmw (dyCSR)
	buf : elTwrd = el_fmw (dyBUF)
;	elPdev = "DY"

     if csr & dyINI_			;

     elif dyVstp && dyVbuf 
	case dyVstp
	of dyRBA  dyVbuf = val
		  dyVstp = dyRWC
		  csr |= dySTP_
	of dyRWC  dyVcnt = val
		  dyVstp = dyIGN
		  dy_mem ()
		  csr |= dyRDY_
	of dyRSC  dyVsec = val
		  dyVstp = dyRTK
		  csr |= dySTP_
	of dyRTK  dyVtrk = val
		  dyVstp = dyIGN
		  dy_dev (csr)
		  csr |= dyRDY_
	end case
     elif csr & dyACT_

	csr &= (~(dyRDY_|dyERR_))	; clear flags
	case fun
	of dyFIL
	or dyEMP  dyVstp = dyRBA
		  dyVfun = fun
		  csr |= dySTP_
	of dyREA
	or dyWRI
	or dyWDD  dyVstp = dyRSC
		  dyVfun = fun
		  csr |= dySTP_
	of dyFMT  nothing
	of dySTA  *MNW(dyBUF) = 
	of dyERR  *MNW(dyBUF) = 
	end case
     else
	exit
     end
	dyVbuf = elNAC				; turn off buffer access
	buf = dyVsta

	if csr & dyRDY_				; operation complete
	   dyVstp = dyIGN			;
	   buf = dyVsta				;
	.. el_sch (elDYD) if csr & dyRDY_	; schedule interrupt
	el_smw (dyCSR, csr)			; setup CSR
	el_smw (dyBUF, buf)			; setup buffer
;	bg_dsk () if bgVdsk			; want them reported
  end


  proc	dy_dev
	csr : elTwrd
  is 	sec : int = dyVsec
	trk : int = dyVtrk
	uni : int = (adr >> 13) & 7	; unit
	fun : int = dyVfun
	blk : int = 
	opr : int
	dev : * elTdev

	trk -= 1			; all starts at 1
	sec -= 1			;
	sec -= (trk % 6)		; take out the skew
	sec += 6 if sec lt		;
	sec /= 2			; take out interleave
	sec += 13 if sec lt		;
	sec += trk * 26			; add in the track
	seg = dyAbuf +  

	dev = el_trn (uni, buf, cnt, blk, opr,0); handle transfers
	csr |= dyRDY_ |dyACT_			; operation complete
	csr |= dyERR_ if dev->Vsts & dyERR_	; some problem
  end

  proc	dy_mem
  is	ext : int = (csr >> 12) & 3	;
	buf : = dyVadr + (ext << 16)	; get the extended address
	seg : 				;
	me_mov (src, dst, 128*2)	; move them
  end
code	el_mcp - mscp device

  type	elTmcp
  is	Vctl : int		; current control state
	Vcnt : int		;
	Vpat : int		; pattern for matching
  end

  func	el_msc
  is  	csr : elTwrd = el_fmw (mcCSR)
	adr : elTwrd = el_fmw (mcADR)

	case mcp.Vstp		; this step
  end


end file
end file

code	el_tmx - TM: TU10 magtape

	tmSTS  := 0172520
	tmDON_ := 1

	tmCMD  := 0172522
	tmERR_ := 0100000
	tmUNI_ := 03400		; unit number
	tmRDY_ := 0200
	tmENB_ := 0100
	tmEXT_ := 060		; extended address
	tmFUN_ := 017		; function
	tmOFF  := 000		; offline and rewind
	tmREA  := 002		; read
	tmWRI  := 004		; write
	tmWTM  := 006		; write tape mark
	tmFOR  := 010		; forward space
	tmBCK  := 012		; backward space
	tmWXT  := 014		; write with extended gap
	tmRWD  := 016		; backward space
	tmGO_  := 01		

  proc	el_tmx
  is  	csr : elTwrd = el_fmw (hdCSR)
	uni : int = (csr >> 9) & 7
	buf : LONG = el_fmw (hdBUF) & 0xffff
	cnt : int = el_fmw (hdCNT) & 0xffff
	blk : int = el_fmw (hdBLK) & 0xffff
	dev : * elTdev
	fun : int = (csr >> 1) & 7
	elPdev = "HD"
	exit if !(csr & hdACT_)			; not in go
	csr &= (~(hdACT_|hdRDY_|hdERR_))	; clear flags
	el_smw (hdBUF, buf + cnt)		; update buffer address 
	el_smw (hdCNT, 0)			; update word count
	buf = buf | ((csr&060)<<(16-4))		; get extended address
	dev = el_tap (uni, buf, cnt, 0, fun, 0)	;
	csr |= hdRDY_				; operation complete
	csr |= hdERR_ if dev->Vsts & hdERR_	; some problem
	el_smw (hdCSR, csr)
	el_sch (elHDD) if csr & elENB_		; (not true in boot)
  end
code	el_ddx - TU58 DD: DECtape II emulator

end file


If 0
code	el_rla - RL disk address logic

;	This routine deals with the arcane RL seek.
;	Seek supplies an offset to the current cylinder.
;	Read/write specify the sector only.
	
  func	el_rla
	dev : * elTdev
	fun : int
	cnt : LONG
  is	cur : LONG = dev->V0	; current address
	cyl : LONG = (cur >> 7) 
	hea : LONG = (cur >> 6) & 1
	sec : LONG = cur & 077
	dar : LONG = el_fwd (rlBLK)
	dif : LONG

	case fun
	of rlSTA el_swd (rlCNT, dev->Pfil ? 035 ?? 040)
	of rlSEE hea = (dar>>4) & 1
		 dif = dar >> 7
		 dif = -dif if dar & BIT(2)
		 cyl = (cyl + dif) & 0777
		 dev->V0 = sec | (hea<<6) | (cyl<<7)
	of rlRHD el_swd (rlBLK, cur), dev->V1 = 3
	of rlWRI 
	or rlREA 
	or rlRDX cur = el_fwd (rlBLK)
		 cyl = (cur>>7) & 0777
		 hea = (cur>>4) & 1
		 sec = cur & 077
		 dev->V0 = (cur &~(077)) | ((sec + (cnt/256)) % 40)
		 reply ((cyl*rlBpC)+(hea*rlBpT)+(sec*rlBpS)) / 512
	end case
  end
End
