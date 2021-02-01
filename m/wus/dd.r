;***;	DD - TU58 boot
;+++;	DD - V11 adaption to provide TU58 device
;+++;	DD - RUST adaption to provide TU58 host
file	dd - windows tu58 dd: server
include rid:rider
include rid:abdef
include rid:cldef
include rid:codef
include rid:dbdef
include rid:dddef
include rid:evdef
include rid:fidef
include rid:imdef
include rid:medef
include rid:mxdef
include rid:stdef
include <windows.h>

;	TU58 DD: emulator for Windows
;
;	o  Implements only TU58 features required by RUST driver
;	o  I have no TU58 hardware so there's a lot of guessing
;
;	Extended features available with RUST DD: driver:
;
;	o  NOP command returns ^rT59 in status summary
;	o  NOP command returns disk size in block number entry
;	o  Block numbers above 512 accepted
;	o  Seven units (0:6)
;	o  Unit seven used for control and status purposes
;
;	0-100	invalid for read/write
;	100	read	date/time
;	110..7	read	volume specs
;		write	mount volume
;
;	dd/bo[ot] supports the following bootstrap:
;	rust.ini [rust][boot] reserve=11 stops it being overwritten
;
;	boot:	clr	r1
;		mov	#1000,r0
;	10$:	tstb	@#176500
;		bpl	10$
;		movb	@#176502,(r1)+
;		dec	r0
;		bne	10$
;		jmp	(r0)

	ddFvrb : int = 0
	ddFlog : int = 0
	ddFmnt : int = 0
	ddFdet : int = 0
	ddFhid : int = 0
	ddFboo : int = 0
	ddFlda : int = 0
	ddFech : int = 0
	ddFhlp : int = 0
	ddFlst : int = 0
	ddVbau : int = 9600

	ddAdev : [mxLIN] char

  type	ddTdsk
  is	Pfil : * FILE
	Vlen : WORD
  end

	ddAdsk : [8] ddTdsk
	dsk    : * ddTdsk

  type	ddTchn
  is	Vtrn : int 		; bytes transferred (internal)
	Vchk : int		; checksum
	Vodd : int		; odd byte
  end

	ddVerr : int = 0	; error count
	ddVrea : int = ddTRN	; error reason (transmission is default)

	dd_cmd : (**char, *char) int
	dd_con : (*char) int
	dd_opn : (*char, int) int
	dd_mnt : (int) int
	dd_err : (int) int
	dd_sho : (*char) int
	dd_lst : ()
	dd_hlp : ()

	sl_opn : (*char) int
	sl_brk : (void) int
	sl_rdy : (void) int
	sl_err : (void) int
	slRDY := 1
	slERR := -1
	sl_get : (void) int
	sl_put : (int) int
	sl_prg : (int) int
	slIPT := 0
	slOPT := 1
	sl_flu : (void) int

	tu_clr : (void) int
	tu_zap : (void) int
	tu_brk : (void) int
	tu_rdy : (void) int
	tu_get : (void) int
	tu_put : (int) int
	tu_ptw : (int) int
	tu_rcv : (int) int
	tu_sta : (int, int) int
	tu_snd : (*ddTpkt) int

	ck_zap : (void) int
	ck_rcv : (void) int
	ck_snd : (void) int
	ck_add : (*ddTchn, int) int

	dd_eng : (void) int
	dd_dat : (void) int
	dd_ctl : (void) int
	dd_ini : (void) int
	dd_boo : (void) int
	dd_lda : (void) int
	dd_ech : (void) int

	dd_ack : (int, int) int
	dd_snd : (int) int
	dd_rcv : (int) int
	dd_uni : (int) int

	pkt    : ddTpkt = {0}
	ack    : ddTpkt = {0}
	get    : ddTchn = {0}
	put    : ddTchn = {0}

 func	dd_hlp
  is
   PUT("RUST Windows DD server DD.EXE\n")
   PUT("\n")
   PUT(".dd [device]/switches\n")
   PUT("\n")
   PUT("Device:\n")
   PUT("  Optional comm port device name\n")
   PUT("\n")
   PUT("Switches:\n")
   PUT("  /  \n")
   PUT("  /4800	    Operate at 4800 baud\n")
   PUT("  /19200    Operate at 19200 baud\n")
   PUT("  /BOot	    Send bootstrap to client\n")
   PUT("  /DEtach   Run DD in detached process\n")
   PUT("  /ECho	    Echo characters received (loopback test)\n")
   PUT("  /HElp     Display this help\n")
   PUT("  /HIde     Run without a terminal\n")
;  PUT("  /INfo     Display information and warning messages\n")
   PUT("  /LDA	    Send paper tape LDA format bootstrap to client\n")
   PUT("  /LIst     List available comm ports\n")
   PUT("  /LOg      Log operations\n")
;  PUT("  /Maint    \n")
;  PUT("  /SIlent   \n")
   PUT("  /VErbose  Log operations in detail\n")
  end
code	main

  func	main
	cnt : int
	vec : ** char
  is	spc : [mxLIN] char
	con : int = 0
	spc[0] = 0

	co_ctc (coENB)
	im_ini ("DD")

	if !dd_cmd (vec, spc)
	|| !dd_con (spc)
	.. im_exi ()

	dd_hlp (), im_exi () if ddFhlp
	dd_lst (), im_exi () if ddFlst

	FreeConsole () if ddFhid || ddFdet
	AllocConsole () if ddFdet
;	AttachConsole (ATTACH_PARENT_PROCESS)

	dd_mnt (1)
	tu_zap ()
	dd_ech () if ddFech
	dd_boo () if ddFboo
	dd_lda () if ddFlda
;	dd_odt () if ddFodt
;	tu_brk () otherwise
	dd_eng ()
  end

code	dd_cmd - parse command

  func	dd_cmd
	vec : ** char
	spc : * char
  is	cmd : [mxLIN] char
	par : int = 0
	ptr : * char
	cnt : int = 0
	fine if !vec[1]
	cl_lin (cmd)			; reconstruct command line
	ptr = cmd			
	while *ptr
	   next ++cnt, ++ptr if *ptr eq '/' ; count options
	   next if *ptr++ ne ' '	; not a space
	   next if *ptr eq ' '		; and another
	   next if *ptr eq '/'		; got an option
	   st_cop (ptr, spc)		; the spec
	   quit *--ptr = 0		; terminate options
	end
	st_low (cmd)
	st_trm (cmd)
;	nfFlst=1, --cnt if st_fnd ("/li", cmd)
	ddFlog=1, --cnt if st_fnd ("/lo", cmd)
	ddFvrb=1, --cnt if st_fnd ("/ve", cmd)
	ddFmnt=1, --cnt if st_fnd ("/ma", cmd)
;	ddFodt=1, --cnt if st_fnd ("/od", cmd)
	ddFhid=1, --cnt if st_fnd ("/hi", cmd)
	ddFdet=1, --cnt if st_fnd ("/de", cmd)
	ddFboo=1, --cnt if st_fnd ("/bo", cmd)
	ddFlda=1, --cnt if st_fnd ("/ld", cmd)
	ddVbau = 4800, --cnt if st_fnd ("/48", cmd)
	ddVbau = 19200, --cnt if st_fnd ("/19", cmd)
	ddFech=1, --cnt if st_fnd ("/ec", cmd)
	ddFlst=1, --cnt if st_fnd ("/li", cmd)
	ddFhlp=1, --cnt if st_fnd ("/he", cmd)
	ddFlog = 1 if ddFvrb	
	ddFlog = 1 if ddFmnt
	fine if !cnt
	fail im_rep ("E-Invalid command", <>) if cnt
  end

  func	dd_con
	spc : * char
  is	if spc[0]
	   fine if dd_opn (spc, 0)
	.. fail im_rep ("F-Port open failed [%s]", spc)

	if !dd_opn ("Com1", 1)
	&& !dd_opn ("Com2", 1)
	&& !dd_opn ("Com3", 1)
	&& !dd_opn ("Com4", 1)
	.. fail im_rep ("F-No port located", <>)
	im_rep ("I-Port located [%s]", ddAdev) if ddFlog
	fine
  end

  func	dd_lst
  is	uni : int = 0
	spc : [16] char
	cnt : int = 0
	while uni le 4
	   FMT(spc, "Com%d", uni)
	   if dd_opn (spc, 1)
	      im_rep("I-Ports available:", <>) if !cnt
	      PUT("%s\n", spc)
	   .. ++cnt
	   ++uni
	end
	im_rep("I-No ports located\n", <>) if !cnt
  end

  func	dd_opn
	spc : * char
	rep : int
  is	fail if !sl_opn (spc)
	fine st_cop (spc, ddAdev)
  end

  func	dd_mnt
	upd : int
  is	spc : [mxLIN] char
	dsk : * ddTdsk
	uni : int
	loc : int = 0
	if ev_chk (evDEV)	
	   im_rep ("I-Disk change", <>) if ddFlog
	.. ++upd

	dsk = ddAdsk, uni = 0
	while upd && uni ne 8
	   fi_clo (dsk->Pfil, <>) if dsk->Pfil
	   ++uni, ++dsk
	end

	dsk = ddAdsk, uni = 0
	while upd && uni ne 8
	   FMT(spc, "dd%c:", '0'+uni)
	   dsk->Pfil = fi_opn (spc, "rb+", <>)
	   if ne
	      ++loc
	   .. dsk->Vlen = fi_len (dsk->Pfil) /512
	   ++uni, ++dsk
	end

	if !ddAdsk[0].Pfil
	.. im_rep("W-DD0: disk file not found", <>)

	if !loc
	.. im_rep ("W-No disk unit files located", <>)

	fine
  end
code	command packets

;??	Wait for INIT after transmission errors

  func	dd_err
	cod : int
  is	PUT("?DD-W-Invalid command packet [%d]\n", cod) if ddFlog
  end

  func	dd_eng
  is	cha : int~
     repeat
	ck_zap ()
	ddVerr = 0
	ddVrea = ddTRN
	cha = tu_get ()			;	; get first byte
	case cha			;	;
	of ddDAT tu_get ()		; <->	; data packet
	of ddCTL dd_ctl ()		; <->	; control packet
					;	;
	of ddINI dd_ini ()		;  ->	; init command 
	of ddBOO dd_boo ()		;  ->	; boot command
	of ddCON nothing		; <-	; continue command
	of ddXON nothing		;  ->	; XON command
	of ddXOF nothing		;	; XOF command
	of ddLOO dd_ech ()		;	; loop back test
	of other nothing
	end case
     forever
  end

  func	dd_ini
  is	cha : int
	sl_prg (slOPT)			; purge output
	cha = sl_get ()			; get raw character
	PUT("?DD-I-Init\n") if ddFvrb	;
	sl_prg (slIPT)			; purge input
	dd_boo () if cha eq ddBOO	; boot 
	fail if cha ne ddINI		; init or die
	sl_put (ddCON)			; protocol response
	sl_flu ()			; flush all
  end

  func	dd_boo
  is	cnt : int = 512
	PUT("?DD-I-Boot\n") if ddFlog	;
	fail if !dd_uni (0)		; need unit zero
	put.Vtrn = 0			; 
	fi_see (dsk->Pfil, 0)		;
	tu_put (fi_gtb (dsk->Pfil)) while cnt--
	fi_chk (dsk->Pfil, "") if ddFvrb; check for file errors
  end

  func	dd_lda
  is	cnt : int = 512+6
	seg : int = 4
	PUT("?DD-I-Boot Loader\n") if ddFlog
	fail if !dd_uni (0)		; must have unit zero
	put.Vtrn = 0			;
	fi_see (dsk->Pfil, 0)		;
	put.Vchk = 0			; init checksum
	tu_ptw (1)			; lda signature
	tu_ptw (512+6)			; ldb byte count
	tu_ptw (0)			; lda buffer address
	while cnt--			;
	.. tu_put (fi_gtb (dsk->Pfil))	; transfer bootstrap
	tu_put (put.Vchk)		; single byte checksum
					;
	put.Vchk = 0			; reset checksum
	tu_ptw (1)			; lda signature
	tu_ptw (6)			; lda byte count
	tu_ptw (0)			; lda transfer address
	tu_put (put.Vchk)		; single byte checksum
	fi_chk (dsk->Pfil, "") if ddFlog;
  end

  func	dd_ech
  is	val : int
	sta : int
      buf : "|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n"
	ptr : * char = buf
	cha : int
	PUT("?DD-I-Echo Loop\n") if ddFlog	;
	repeat				;
	   ddVerr = 0			;
	   sta = sl_rdy ()
	   if sta eq slERR
	      PUT("?")
	   elif sta eq slRDY
	      cha = sl_get ()
	      PUT("%c", cha) if (cha gt 32) & (cha lt 128)
	   .. PUT(".") otherwise
	   tu_put (*ptr++)		;
	   ptr = buf if !*ptr		;
	forever				;
  end
code	control packets

  func	dd_ctl
  is	cha : int
	len : WORD

	if !tu_rcv (1)			; get the rest
	|| pkt.Vcnt ne #ddTpkt-4	; incorrect length
	.. dd_ack (ddEND, 0)		; fail
					;
	if !dd_uni (pkt.Vuni)		; get the unit file
	.. fail dd_ack (ddEND, 0)	; is none - bad stuff
					;
	case pkt.Vopr			;
	of ddNOP dd_ack (ddNOP,1)	; Nop     
	of ddRST if pkt.Vseq eq ddCXT	; our extensions?
		 .. pkt.Vblk = dsk->Vlen; supply disk length
 		 dd_ack (ddNOP,1)	; Reset (INIT)   
	of ddREA dd_snd (0)		; Read
	of ddWRI dd_rcv (0)		; Write
	of ddPOS dd_ack (ddEND,1)	; Position
	of ddDIA dd_ack (ddEND,1)	; Diagnose
	of ddGST nothing		; Get Status
	of ddSST nothing		; Set Status
	of ddXOF nothing		;
	of other nothing		;
	end case
  end

  func	dd_ack
	opr : int
	sts : int
  is	PUT("?DD-W-Transmission error\n") if !sts && ddFlog
	ack.Vtyp = ddCTL
	ack.Vcnt = #ddTpkt - 4
	ack.Vopr = opr
	ack.Vsts = sts ? 0 ?? -17
	ack.Vuni = pkt.Vuni
	ack.Vbct = pkt.Vbct
	ack.Vblk = pkt.Vblk		; disk length for reset
	ack.Vseq = ddSXT		; send the signature
	tu_snd (&ack)
  end

code	dd_rcv - respond to client write requests

;	Accumulate input into a local buffer and write that to disk.
;	This helps avoid disk corruption in case of aborts.
;	Use a two-block buffer to avoid incomplete directory segments.
;	(Also handles zero padding of incomplete blocks).

  func	dd_rcv
	ext : int 
  is	cnt : int = pkt.Vbct
	seg : int  
	buf : [1024] char
	ptr : * char
	acc : int = 0
	sho : int = 0
	err : int = 0
	sts : int = 0
	sho = 1, cnt = 0 if pkt.Vuni eq 7

	PUT("?DD-I-Write DD%d: block=%d words=%d\n",
	  pkt.Vuni, pkt.Vblk, cnt/2) if ddFlog
	fi_see (dsk->Pfil, pkt.Vblk*512)
	while cnt
;	   err = ddTRX
	   ptr = buf, me_clr (buf, 1024) if !acc
	   seg = (cnt lt 128) ? cnt ?? 128
	   cnt -= seg
	   acc += seg
	   tu_put (ddCON)
	   ck_zap ()
	   quit if tu_get () ne ddDAT
	   quit if tu_get () ne seg
	   PUT(".") if ddFmnt
	   while seg--
	      quit if tu_sta (0,1)
	      *ptr++ = tu_get ()
	   end
	   quit if !ck_rcv ()
	   if !cnt || (acc eq 1024)
	      acc = (acc + 511) & ~(511)
	      fi_wri (dsk->Pfil, buf, acc)
	      quit if fail
	   .. acc = 0
	   sts = 1
	end
	sts = 0 if !sho && !fi_chk (dsk->Pfil, "")
	PUT("?") if ddFmnt && !sts
	dd_ack (ddEND, sts)
  end

code	dd_snd - respond to client read requests

;	Do null-segments if extended handshake done

	dd_nul : (*char, int) int

  func	dd_snd
	ext : int
  is	cnt : int = pkt.Vbct
	seg : int  
	sts : int = 0
	buf : [128] char
	ptr : * char
	sho : int = 0

	PUT("?DD-I-Read  DD%d: block=%d words=%d\n",
	  pkt.Vuni, pkt.Vblk, cnt/2) if ddFlog

	if pkt.Vuni eq 7
	   ++sho
	   cnt = dd_sho (buf)
	   cnt = 0 if pkt.Vblk ne 8
	else
	.. fi_see (dsk->Pfil, pkt.Vblk*512)

	while cnt
	   sts = 0
	   seg = (cnt lt 128) ? cnt ?? 128
	   cnt -= seg
	   fi_rea (dsk->Pfil, buf, seg) if !sho ; read the segment data
	   ck_zap ()

	   ptr = buf
	   if pkt.Vseq eq ddCXT		; extended client
	   && dd_nul (ptr, seg)
	      quit if !tu_put (ddNUL)
	      quit if !tu_put (seg)
	      PUT("0") if ddFmnt
	   else
	      PUT(".") if ddFmnt
	      quit if !tu_put (ddDAT)
	      quit if !tu_put (seg)
	      while seg--
	   .. .. quit if !tu_put (*ptr++)
	   ck_snd ()
	   sts = 1
	end
	sts = 0 if !sho && !fi_chk (dsk->Pfil, "")
	PUT("?") if ddFmnt && !sts
	dd_ack (ddEND, sts)
  end

  func	dd_nul
	ptr : * char
	cnt : int
  is	while cnt--			; test segment for all nulls
	   fail if *ptr++		; not null
	end				;
	fine				; null segment
  end

  func	dd_uni
	uni : int
  is	fine if uni eq 7		; nothing physical
	fail if uni & ~(7)		; invalid unit
	dsk = ddAdsk+uni		; setup the pointer
	reply dsk->Pfil ne		;
  end
code	dd_sho - return system information
include	rid:tidef

;	called by read

  type	elTwrd : WORD

  type	vxTsho
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

  func	dd_sho
	buf : * char
	()  : int
  is	sho : * vxTsho = <*void>buf
	val : tiTval
	clk : tiTplx
	sho->Vgua = -1
	sho->Vlen = #vxTsho
	ti_clk (&val)
	ti_plx (&val, &clk)
	sho->Vyea = clk.Vyea
	sho->Vmon = clk.Vmon
	sho->Vday = clk.Vday
	sho->Vhou = clk.Vhou
	sho->Vmin = clk.Vmin
	sho->Vsec = clk.Vsec
	sho->Vmil = clk.Vmil
	sho->Vdst = clk.Vdst

	sho->Vcpu = 0
	sho->Vops = 0
	st_cop ("ANON", sho->Aser)
;	reply #vxTsho
	reply 128
  end
code	TU58 utilities

	ckVwrd : int = 0

;	EV_BREAK
;	EV_RX80FULL
;	EV_TXEMPTY
;	EV_RXFLAG

  func	tu_zap
  is	msk : LONG
	tu_rdy ()
  end

  func	tu_brk			; send break
  is	cnt : int 
      repeat
;	sl_brk ()		; force an error
	cnt = 132		; enough to break a packet
	while cnt--		;
	   fine if sl_err ()	; something is available
	   tu_put (ddINI)	; keep sending #4
	end			;
	ti_wai (2000)		; wait two seconds
      forever			;
  end

  func	tu_sta
	rdy : int
	err : int
  is	sta : int = sl_rdy ()	;  get serial line status
	fail if !sta		; nothing doing
	ddVerr |= rdy if sta gt	; character available
	ddVerr |= err otherwise	; some error
	reply ddVerr	
  end

If 0
  func	tu_err
	err : int 
  is	tuVerr = err
	fail
  end
End

  func	tu_rdy
  is	reply sl_rdy ()
  end

  func	tu_get
  is	cha : int
	fail if ddVerr		; error seen
	++get.Vtrn		; count it
	cha = sl_get ()		; get it
	cha &= 255		; clean it up
	ck_add (&get, cha)	; apply to checksum
	reply cha		; return it
  end

  func	tu_ptw
	wrd : int
  is	fail if !tu_put (wrd)	; put first byte
	reply tu_put (wrd>>8)	; put second
  end

  func	tu_put
	cha : int
  is	rdy : int = tu_rdy ()	; check for input
	fail if ddVerr		; some error
	++put.Vtrn		; count it
	cha &= 255		; isolate it
	ck_add (&put, cha)	; add to checksum
	fail if !sl_put (cha)	; send it
	reply !rdy		;
  end

  func	tu_rcv			; receive packet
	mod : int		; number of bytes already received
  is	ptr : * char = <*char>&pkt+mod
	cnt : int = #ddTpkt-2-mod ; packet size
	while cnt--		; get the rest
	   fail if sl_err ()	; some error
	   *ptr++ = tu_get ()	;
	end			;
	fail if !ck_rcv ()	; check checksum
	fail if pkt.Vcnt ne #ddTpkt-4 ; wrong count
	fine			;
  end

  func	tu_snd			; send packet
	pkt : * ddTpkt		;
  is	ptr : * char = <*char>pkt
	cnt : int = #ddTpkt-2	; count
	ck_zap ()		; init checksum
	while cnt--		;
	  fail if !tu_put (*ptr++)
	end			;
	reply ck_snd ()		;
  end
code	checksums

  func	ck_zap 
  is	get.Vchk = get.Vodd = get.Vtrn = 0
	put.Vchk = put.Vodd = put.Vtrn = 0
	tu_zap ()
  end

  func	ck_rcv
  is	chk : int = get.Vchk
	get.Vchk = 0
	tu_get (), tu_get ()
	fine if chk eq get.Vchk
	PUT("?DD-W-Receive checksum error (%o,%o)\n", chk, get.Vchk) if ddFvrb
	fail
  end

  func	ck_snd
  is	chk : int = put.Vchk
	tu_put (chk)
	tu_put (chk>>8)
	reply that
  end


  func	ck_add
  	chn : *ddTchn
  	val : int
  is	if !chn->Vodd
	   ckVwrd = val
	   chn->Vchk += val
	else
	   ckVwrd |= (val<<8)
	   chn->Vchk += val<<8
	   ++chn->Vchk if chn->Vchk gt 0xffff
	.. chn->Vchk &= 0xffff
	chn->Vodd = !chn->Vodd
  end
code	windows serial line

	prt : HANDLE = <>	; Comm port

  func	sl_opn
	nam : * char
  is	dcb : DCB = {0}
	tim : COMMTIMEOUTS = {0}

	CloseHandle (prt), prt = <> if prt
	prt = CreateFile (nam, GENERIC_READ|GENERIC_WRITE, 0,
	      NULL, OPEN_EXISTING, 0, NULL)
	fail if prt eq INVALID_HANDLE_VALUE

	case ddVbau
	of 4800	dcb.BaudRate = CBR_4800
	of 9600 dcb.BaudRate = CBR_9600
	of 19200 dcb.BaudRate = CBR_19200		; 38400/56000/57600
	end case

	dcb.ByteSize = 8
	dcb.Parity = NOPARITY
	dcb.StopBits = ONESTOPBIT
	SetCommState(prt, &dcb)
	fail db_lst (0) if fail

	SetCommTimeouts (prt, &tim)
	fail db_lst (0) if fail
	fine
  end

  func	sl_brk
  is	cnt : int = 4
	SetCommBreak (prt)		; send break
	sl_put (0) while cnt--		; pause
	ClearCommBreak (prt)		; clear break
  end

  func	sl_err
  is	reply sl_rdy () eq slERR	; check for receive error
  end

  func	sl_rdy
  is	err : LONG
	sta : COMSTAT
;	reply slERR if ddVerr && ddFodt	;
	ClearCommError (prt, &err, &sta); get status
	reply ++ddVerr, slERR if err	; slERR - overrun
	reply slRDY if sta.cbInQue	; slRDY - data available
	fail				; 0     - not ready	
  end

  func	sl_get
  is	cha : int = 255
	cnt : LONG = 0
	ReadFile (prt, &cha, 1, &cnt, 0)
	fail db_lst (0) if fail || !cnt
;PUT("%o ", cha)
	reply cha 
  end

  func	sl_put
	cha : int
  is	cnt : LONG
	WriteFile (prt, &cha, 1, &cnt, 0)
	fail db_lst (0) if fail
	fine
  end

  func	sl_prg
	mod : int
  is	(mod eq slIPT) ? PURGE_RXCLEAR ?? PURGE_TXCLEAR
	PurgeComm (prt, that)
  end

  func	sl_flu
  is	FlushFileBuffers (prt)
  end
end file
code	ODT console boot

	dd_odt : (void) int
	ddFodt : int = 0

  init	ddAboo : [] WORD		; TU58 boot
  is	0012701, 0012702, 0010100, 0005212, 0105712,
	0100376, 0006300, 0001004, 0005012, 0005200,
	0005761, 0042700, 0010062, 0001363, 0005003,
	0105711, 0100376, 0116123, 0022703, 0101371,
	0005007
  end

	dd_pst : (*char, int) int

  func	dd_odt
  is	cha : int
 	dat : * WORD
	cnt : int
	str : [32] char
	adr : * char
	repeat
PUT(".")
;	   sl_brk ()
	   sl_put ('\r')
	   cha = sl_get ()
	   PUT("[%c]", cha) ;if cha ge 32
	   quit if cha eq '@'
	forever
	PUT("\n")
	adr = <*char>05000
	dat = ddAboo
	cnt = #ddAboo
	while cnt--
	   FMT(str, "%o/%o\r", adr++, *dat++)
	   dd_pst (str, 0)
	end
	dd_pst ("R6/5000\r", 0)
	dd_pst ("5000G", 'G')
  end

  func	dd_pst
	str : * char
	ter : int
  is	cha : int = 0
	ter = '@' if !ter
	while *str
	   PUT("%c", sl_get ()) while !sl_rdy ()
	   sl_put (*str++)
	end
	while cha ne ter
	   cha = sl_get ()
	   PUT("%c", cha)
	end
  end
code	primary bootstrap

	0012701
	0012702
	0010100
	0005212
	0105712
	0100376
	0006300
	0001004
	0005012
	0005200
	0005761
	0042700
	0010062
	0001363
	0005003
	0105711
	0100376
	0116123
	0022703
	0101371
	0005007


;	002000  012701  dd$boo:	mov   #176500,r1
;	002004  012702  	mov   #176504,r2
;	002010  010100  	mov   r1,r0
;	002012  005212  	inc   (r2)
;	002014  105712  10$:	tstb  (r2)
;	002016  100376  	bpl   10$
;	002020  006300  	asl   r0
;	002022  001004  	bne   20$
;	002024  005012  	clr   (r2)
;	002026  005200  	inc   r0
;	002030  005761  	tst   2(r1)
;	002034  042700  20$:	bic   #20,r0
;	002040  010062  	mov   r0,2(r2)
;	002044  001363  	bne   10$
;	002046  005003  	clr   r3
;	002050  105711  30$:	tstb  (r1)
;	002052  100376  	bpl   30$
;	002054  116123  	movb  2(r1),(r3)+
;	002060  022703  	cmp   #1000,r3
;	002064  101371  	bhi   30$
;	002066  005007  	clr   pc

