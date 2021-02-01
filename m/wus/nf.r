;	HELP
;	Boot type
;	/HALT
file	nf - nf windows server
include	rid:rider
include rid:cldef
include rid:codef
include rid:fidef
include	rid:medef
include	rid:stdef
include rid:drdef
include rid:eldef
include rid:nfdef
include rid:nfcab
include rid:imdef
include rid:tidef
include rid:lndef

	nfFlst : int = 0
	nfFinf : int = 0
	nfFlog : int = 0
	nfFvrb : int = 0
	nfFmnt : int = 0
	nfFhid : int = 0
	nfFdet : int = 0
	nfFmop : int = 1
	nfFhlt : int = 0
;	vaFdmp : int = 0
;	nfVreq : int = 0	;
;	nfVtra : int = 1;0	; trace things

	vaAser : [2] char = {0x60, 0x06}   ; server protocol
	vaAcli : [2] char = {0x60, 0x08}   ; client protocol
	nfAboo : [2] char = {0x60, 0x01}   ; Boot
	nfAmop : [2] char = {0x60, 0x02}   ; MOP

	rxANO := 04177		;
	rxN__ := 053600		;
;	rx_DR := 0262		; directory service
;	rx_IF := 0556		; information services

	nfETH := 14		; Ethernet header size
	nfVAB := 46		; VAB size

	nfINI := 0
	nfREA := 1
	nfWRI := 2


  type	nfThdr
  is	Adst : [6] char
	Asrc : [6] char
	Vpro : WORD
  end

	nfBUF := 2000

  type	nfTprv
  is	Psuc : * nfTprv
	Vvid : WORD
	Vnod : WORD
	Ihdr : nfThdr
	Abuf : [nfBUF] char
  end

	nfPprv : * nfTprv = <>
	nfVnod : WORD = 1
	nfAdev : [128] char 
	nfAmac : [6] char

	nf_cmd : (**char, *char) int
	nf_hlp : ()
	nf_eng : (*char) int
	nf_prv : (*nfThdr) *nfTprv
	nf_dev : (int, *char, int)
	nf_hdr : (*nfThdr)
	nf_itm : (*char, *char, int)
	nf_mop : (*char) int
	nf_boo : (*char) int
	nf_mac : (*char, *char) int

  func	nf_hlp
  is
	PUT("RUST Windows NF server NF.EXE\n")
	PUT("\n")
	PUT(".nf [device]/switches\n")
	PUT("\n")
	PUT("Device:\n")
	PUT("  Optional Ethernet device name\n")
	PUT("\n")
	PUT("Switches:\n")
	PUT ("  /DEtach   Run NF in detached process\n")
	PUT ("  /HAlt     Halt client before bootstrap\n")
	PUT ("  /HElp     Display this help\n")
	PUT ("  /HIde     Run without a terminal\n")
	PUT ("  /INfo     Display information and warning messages\n")
	PUT ("  /LIst     List available Ethernet devices\n")
	PUT ("  /LOg      Log operations\n")
	PUT ("  /NOMOp    Disable MOP BOOT operations\n")
;	PUT ("  /Maint    \n")
	PUT ("  /VErbose  Log operations in detail\n")
  end
code	main

  func	main
	cnt : int
	vec : ** char
  is	spc : [mxLIN] char = {0}
	im_ini ("NF")
	co_ctc (coENB)
	nf_cmd (vec, spc)
	im_exi () if fail
	co_det () if nfFdet
	co_dlc () if nfFhid
	nf_eng (spc)
  end

code	nf_cmd - parse command

  func	nf_cmd
	vec : ** char
	spc : * char
  is	cmd : [mxLIN] char
	par : int = 0
	ptr : * char
	cnt : int = 0
	fine if !vec[1]
	cl_lin (cmd)			; reconstruct command line
	ptr = cmd			
	*spc = 0
	while *ptr
	   next ++cnt, ++ptr if *ptr eq '/' ; count options
	   next if *ptr++ ne ' '	; not a space
	   next if *ptr eq ' '		; and another
	   next if *ptr eq '/'		; got an option
	   st_cop (ptr, spc)		; the spec
	   quit *--ptr = 0		; terminate options
	end
	if !*spc && (*cmd ne '/')	; ugh
	   st_cop (cmd, spc)
	.. *cmd = 0

	st_low (cmd)
	st_trm (cmd)

	if st_fnd ("/he", cmd)		; wants help
	|| st_fnd ("/?", cmd)		;
	   nf_hlp ()			;
	.. im_exi ()

	nfFlst=1, --cnt if st_fnd ("/li", cmd)
	nfFinf=1, --cnt if st_fnd ("/in", cmd)
	nfFlog=1, --cnt if st_fnd ("/lo", cmd)
	nfFvrb=1, --cnt if st_fnd ("/ve", cmd)
	nfFmnt=1, --cnt if st_fnd ("/ma", cmd)
	nfFdet=1, --cnt if st_fnd ("/de", cmd)
	nfFhid=1, --cnt if st_fnd ("/hi", cmd)
	nfFmop=0, --cnt if st_fnd ("/nomo", cmd)
	nfFhlt=1, --cnt if st_fnd ("/ha", cmd)
	nfFvrb |= nfFmnt	
	nfFlog |= nfFvrb	
	nfFinf |= nfFlog
	fine if !cnt
	fail im_rep ("E-Invalid command", <>) if cnt
  end
code	nf_eng - engine

  func	nf_eng
	spc : * char
  is	buf : [nfBUF] char = {0}
	prv : * nfTprv
	eth : * nfThdr = <*nfThdr>buf
	vab : * nfTvab = <*nfTvab>(buf + nfETH)
	nam : * nfTnam = <*nfTnam>vab
	rcv : nfThdr
	ptr : * char
	cnt : int
	vid : int = -1			; vid to catch repeats
					; see nfdef.d
	nfPbuf = (buf + nfETH + nfVAB)	;
					;
	st_cop (spc, buf)		; for the init
	nf_dev (nfINI, buf, 0)		; connect
	fail im_rep ("E-Connect failed [%s]", buf) if fail
	nf_mac (nfAdev, nfAmac)		; get local device
	fail im_rep ("E-Invalid connection device [%s]", buf) if fail

	repeat
	   nf_dev (nfREA, buf, 0)	; read next packet
					;
	   nf_hdr (eth) if nfFvrb	;
	   PUT("Rcv: "), nf_rep (vab, <*BYTE>buf, 0) if nfFlog
					;
	   me_cop (eth, &rcv, #nfThdr)	; copy things
	   me_cop (rcv.Asrc, eth->Adst, 6) ; flip src/dst
	   me_cop (rcv.Adst, eth->Asrc, 6) ;
	   if nfAmac[0]			; got an address
	   .. me_cop(nfAmac,eth->Asrc,6); use our address instead
	   eth->Vpro = 0x0860		; reply protocol

	   prv = nf_prv (&rcv)		; get prior packet
	   if vab->Vvid eq prv->Vvid	; same as previous?
	      im_rep ("I-Packet retry", <>) if nfFinf
	      me_cop (prv->Abuf, buf, 2000) ; yep - just send it back
	   else				;
	      vab->Vnod = prv->Vnod	; fill in node id
	      nf_ser (vab)		; process package
					;
	      nam->Vsts = nfSVR		; server status
	      nam->Vsys = osSHP		; SHAREplus
	      nam->Anam[0] = rxANO	; Server = "ANON"
	      nam->Anam[1] = rxN__	;
	      me_cop (buf,prv->Abuf,nfBUF); save it for repeats
	   .. prv->Vvid = vab->Vvid	;

	   PUT("Snd: "), nf_rep (vab, <*BYTE>buf, 1) if nfFlog

	   cnt = nfETH+nfVAB + vab->Vdbc; calculate length
	   nf_dev (nfWRI, buf, cnt)	; send packet back
	forever
  end

  func	nf_prv
	hdr : * nfThdr
	()  : * nfTprv
  is	prv : * nfTprv = nfPprv
	while prv
	   if me_cmp (hdr->Asrc, prv->Ihdr.Asrc, 6)
	   .. reply prv
	   prv = prv->Psuc
	end
	prv = me_acc (#nfTprv)
	me_cop (hdr, &prv->Ihdr, #nfThdr)
	prv->Psuc = nfPprv
	prv->Vnod = nfVnod++
	nfPprv = prv
	reply prv
  end
code	nf_dev - winpcap driver
include	rid:rider
include	rid:dbdef
include	rid:medef
include	rid:wimod
include	rid:imdef

  type	pcTcap : *void

  type	pcTtim
  is	Vhot : LONG
	Vlot : LONG
  end

  type	pcThdr		; pcap_pkthdr_t
  is	Itim : pcTtim	; struct timeval
	Vcap : LONG
	Vful : LONG
  end

  type	pcTcts
  is	Vrcv : LONG
	Vdrp : LONG
	Vxxx : LONG
  end

  type	pcTifs
  is	Psuc : * pcTifs
	Pnam : * char
	Pdsc : * char
	Padr : * void
	Vflg : unsigned int
  end

  type	pcTfnd : WINAPI* (**pcTifs, *char) int
  type	pcTopn : WINAPI* (*char, int, int, int, *char) *pcTcap
  type	pcTnex : WINAPI* (*pcTcap, **pcThdr, **char) int
  type	pcTsnd : WINAPI* (*pcTcap, *char, int) int
  type	pcTsts : WINAPI* (*pcTcap, *pcTcts) int
  type	pcTerr : WINAPI* (*pcTcap) *char

	pcPfnd : pcTfnd
	pcPopn : pcTopn
	pcPnex : pcTnex
	pcPsnd : pcTsnd
	pcPsts : pcTsts
	pcPerr : pcTerr

	nfPdev : * pcTcap = <>
	nf_adr : (**void, *void, *char) int
	nf_err : (*pcTcap, *char, *char)

  func	nf_dev
	fun : int
	buf : * char
	cnt : int
  is	err : [512] char
	lft : [mxLIN] char
	rgt : [mxLIN] char
	hdr : * pcThdr
	dat : * char
	res : int
	ifs : * pcTifs = {0}
	dev : * pcTcap = nfPdev
	dll : * void = <>
	src : [6] char
	ptr : * char
	min : int

   case	fun
   of nfINI
	db_hoo (db_rev)			; catch exceptions

	dll = LoadLibraryEx ("WPCAP.DLL", 0, 0) ; load WinPcap
	fail im_rep ("E-WinPcap library not installed", <>) if fail

	if !nf_adr (<*void>&pcPfnd, dll, "pcap_findalldevs")
	|| !nf_adr (<*void>&pcPopn, dll, "pcap_open_live")
	|| !nf_adr (<*void>&pcPnex, dll, "pcap_next_ex")
	|| !nf_adr (<*void>&pcPsnd, dll, "pcap_sendpacket")
	|| !nf_adr (<*void>&pcPsts, dll, "pcap_stats")
	|| !nf_adr (<*void>&pcPerr, dll, "pcap_geterr")
	.. fail

	if !(pcPfnd)(&ifs, err) eq -1
	   if !buf[0] || nfFlst
	   .. fail im_rep ("E-Error enumerating devices (%s)", err)
	else

	 ; List devices

	   if nfFlst
	      im_rep ("I-Devices available:", <>)
	      while ifs
	         if nf_mac (ifs->Pnam, nfAmac)
	            PUT("%s ", ifs->Pnam)
	            PUT("(%s)", ifs->Pdsc) if ifs->Pdsc
		    if nf_mac (ifs->Pnam, nfAmac)
	            .. nf_itm (" Station=", nfAmac, 6) 
		 .. PUT("\n")
		 ifs = ifs->Psuc
	      end
	   .. im_exi ()

	 ; Find specified device

	   if buf[0]
	      st_cop (buf, lft), st_upr (lft)
	      while ifs
	         st_cop (ifs->Pnam, rgt), st_upr (rgt)
	         quit if st_sam (lft, rgt)
	         ifs = ifs->Psuc
	      end
	      buf = ifs->Pnam if ifs
	   else

	 ; Select device

	      while ifs
	         quit if !st_fnd ("PPP", ifs->Pnam) ; avoid PPP devices
	         ifs = ifs->Psuc
	      end
	      fail im_rep ("E-No device located", <>) if !ifs
	      buf = ifs->Pnam
	      im_rep ("I-Selected device [%s]", buf) if nfFinf
	   end
	end

	; Open device

	st_cop (buf, nfAdev)
;	dev = (pcPopn)(buf, nfBUF, 1, 100, err)
	dev = (pcPopn)(buf, nfBUF, 1, -1, err)	; -1 for WINPCAP; 1 otherwise
	if dev eq
	   im_rep ("E-Winpcap error: %s", err)
	.. fail im_rep("E-Open network device failed [%s]", buf)

	nfPdev = dev			; thaz the device

     of nfREA
	repeat
PUT(".")
	   res = (pcPnex)(dev,&hdr,&dat); get a packet it
	   next if !res			; just a timeout
PUT("o")
;co_prm ("Wait?", 0, 0)
	   if res lt			;
	      nf_err (dev, "W-Error receiving packet", <>) if nfFvrb
	   .. next			;

	   next if hdr->Vcap ge nfBUF	; too big
	   me_cop (dat, buf, hdr->Vcap)	; get local copy
;???	   nf_hdr (<*nfThdr>buf) if nfFmnt

	   if buf[12] eq (vaAser[0])	; our server protocol 
	   && buf[13] eq (vaAser[1])	;
	   .. fine			;

	   next if !nfFmop		; mop enabled
	   if buf[12] eq nfAmop[0]	; and mop protocol
	   && buf[13] eq nfAmop[1]	;
	   .. next nf_mop (buf)		; do side salad

	   if buf[12] eq nfAboo[0]	; and boot protocol
	   && buf[13] eq nfAboo[1]	;
	   .. next nf_boo (buf)		; do side salad
	forever

     of nfWRI
	cnt = 60 if cnt lt 60		; minimum transfer size
	res = (pcPsnd)(dev, buf, cnt)	; send it
	fine if eq			;
	nf_err (dev, "W-Error sending packet", <>) if nfFvrb
	fail
     of other
 	fail
     end case
  end

code	nf_err - report error

  func	nf_err
	dev : * pcTcap
	msg : * char
	obj : * char
  is	;im_rep ("I-WinPcap error: [%s]\n", (pcPerr)(dev))
	im_rep (msg, obj)
  end

code	get dll routine address

  func	nf_adr
	ptr : **void
	dll : * void
	rou : * char
  is	*ptr = <*void>GetProcAddress (dll, rou)
	fine if ne
	im_rep ("E-Error locating library routine [%s]", rou)
	fail
  end
code	MOP online operation

;	MOP is the DEC Maintenance OPeration network protocol.
;	We support the Online and Boot messages.

	mp_vrb : (*char, *char, *char)
	mp_def : ()

  type	mpTmop
  is	Vcnt : WORD
	Vcod : char
	Vf00 : char
	Vrec : WORD
  end

  func	nf_mop
	buf : * char
  is	eth : * nfThdr = <*nfThdr>buf
	mop : * mpTmop = <*mpTmop>(buf + nfETH)
	mp_vrb ("MOP: ", buf, "Online message received\n")
  end

  func	mp_vrb
	tit : *char
	buf : * char
	msg : * char
  is	eth : * nfThdr = <*nfThdr>buf
	mop : * mpTmop = <*mpTmop>(buf + nfETH)
	exit if !nfFvrb
	PUT("%s", tit)
	nf_itm ("src=", eth->Asrc, 6)
	PUT(" cnt=%d cod=%d %s", mop->Vcnt, mop->Vcod, msg)
  end
code	MOP boot operations

;	nf7 = c:\rust\pdp\nf7
;	rt_dk = c:\rust\pdp\nf7
;	rt_sy = c:\rust\pdp\nf7
;	rls:nfcab.r cab_map "NF7"

  type	mpTboo
  is	Vcnt : WORD		; 22
	Vcod : char		; 8 = request program
	Vdev : char		; 1 = DEQNA
	Vver : char		; 1
	Vcla : char		; 1 => tertiary loader
	Vsid : char		; 0
	Af00 : [16] char	;
	Vcpu : char		; 0
  end

;	.=0	nop
;	.=2	br	36		; BOOT/foreign start
;	.=4	mov	r1,b$ocsr	; ROM boot start (r1=CSR)
;		br	36		;
;	.=12				;
;	.=?	bo$boo:			; BOOT/noforeign start
;	bo$boo:
;	.=2000	

  init	mpAboo : [] WORD;	. = 2000
  is	000240,		;	nop
	012706, 010000,	;	mov	#10000,sp
	012702, 003032,	;	mov	#20$,r2
	012703, 001000,	;	mov	#1000,r3	
	014243,		; 10$:	mov	-(r2),-(r3)
	005703,		;	tst	r3
	001375,		;	bne	10$
	000240,		;	nop
	000137, 000004	;	jmp	@#4
  end			; 20$:	.blkw	256.
	mpBOO := 13*2

	adAloc : [6] char = {0x08, 0x00, 0x2b, 0xAA, 0xBB, 0xDD}
	adAboo : [6] char = {0xAB, 0x00, 0x00, 0x01, 0x00, 0x00} ; 60-01
	adAmop : [6] char = {0xAB, 0x00, 0x00, 0x02, 0x00, 0x00} ; 60-02

  type	mpTloa
  is	Vcnt : WORD		; 
	Vcod : char		; code
	Vseq : char		; sequence number
	Aadr : [4] char		; load address
	Adat : [mpBOO+512] char ; load data
	Atrn : [4] char		; transfer address
  end
	boOPN  := 8		; MOP open code
	 boASS := 3		; broadcast assistant response
	boLOA  := 10		; MOP load code
	 boLGO := 0		; load and go response

	mpIloa : mpTloa = {0}	; load record
	mp_loa : (void) int	; load function

  func	nf_boo
	buf : * char
  is	eth : * nfThdr = <*nfThdr>buf
	boo : * mpTboo = <*mpTboo>(buf + nfETH)
	brd : int = 0
	cnt : int = 60
	loa : int = 0

	mpAboo[0] = 0 if nfFhlt		; bootstrap halt

	me_cmp (eth->Asrc, adAloc, 6)	; is this from us
	fine if fine			; yes - let's not loop

	brd = (eth->Adst[0]&0xFF) eq 0xAB ; broadcast message
	me_mov (eth->Asrc, eth->Adst, 6); turn message around
	me_mov (adAloc, eth->Asrc, 6)	;

	mp_vrb ("BOO: ", buf, "")
;	PUT("BOO: cnt=%d cod=%d ", boo->Vcnt, boo->Vcod) if nfFvrb
	case boo->Vcod			;
	of boOPN			; open
	   if brd			; broadcast
	      PUT("Broadcast message received") if nfFvrb
	      ti_wai (1000)		; ROM boot needs time to think
	      boo->Vcnt = 1		; must be one
	      boo->Vcod = boASS		; we can assist
	      cnt = 60			; minimum packet length
	   else				; not broadcast
	   .. loa = 1			; download bootstrap
	of boLOA			; shouldn't get here
	   loa = 1			; but might
	of other			; ignore unknowns
	   fine				;
	end case			;

	if loa				; load required
	   PUT("Send NF7: bootstrap\n") if nfFvrb
	   ti_wai (1000)		; wait one second for ROM boot
	   mp_loa ()			; setup the boot
	   me_cop (&mpIloa, buf+nfETH, #mpTloa)
	   cnt = nfETH + #mpTloa	; packet + boot data
	else				;
	.. PUT("\n") if nfFvrb

	nf_dev (nfWRI, buf, cnt)	; send it
	fine
  end

  func	mp_loa
  is	loa : * mpTloa = &mpIloa
	fil : * FILE
	dat : * WORD = <*WORD>(loa->Adat+0512)

	loa->Vcnt = #mpTloa - 2		; packet minus Vcnt
	loa->Vcod = boLGO		; load and go
	loa->Aadr[0] = 0		; load address
	loa->Aadr[1] = 02000 / 256	;
	loa->Atrn[0] = 0		; transfer address
	loa->Atrn[1] = 02000 / 256	;

	mp_def ()			; auto-assign NF7, RT_DK, RT_SY
	me_mov (mpAboo, loa->Adat, mpBOO)
	fil = fi_opn ("NF7:VOLUME.SYS", "rb+", "")
	if fail
	   im_rep ("W-Boot volume not found NF7:VOLUME.SYS", <>) if nfFinf
	.. fail

	fi_rea (fil, loa->Adat+mpBOO, 512)
	fi_clo (fil, "")
	if fail
	   im_rep ("W-Error reading boot volume NF7:", <>) if nfFinf
	.. fail

	if !dat[0200] && nfFinf
	.. im_rep ("W-No boot on volume NF7:", <>)
	fine
  end

;	Setup RUST default logical names

  func	mp_def
  is	res : [128] char
	if !ln_trn ("nf7", res, 0)
	   im_rep ("W-Defaulting NF7: to RUST:\\PDP\\NF7", <>) if nfFinf
	.. ln_def ("nf7", "rust:\\pdp\\nf7",0)
	if !ln_trn ("rt_dk", res, 0)
	   im_rep ("W-Defaulting RT_DK: to NF7:", <>) if nfFinf
	.. ln_def ("rt_dk", "nf7",0)
	if !ln_trn ("rt_sy", res, 0)
	   im_rep ("W-Defaulting RT_SY: to NF7:", <>) if nfFinf
	.. ln_def ("rt_sy", "nf7",0)
  end
code	display routines

  func	nf_hdr
	hdr : * nfThdr
  is	nf_itm ("\nDst: ", hdr->Adst, 6)
	nf_itm (" Src: ", hdr->Asrc, 6)
	nf_itm (" Pro: ", <*char>(&hdr->Vpro), 2)
	PUT("\n")
  end

  func	nf_itm
	hdr : * char
	bin : * char
 	cnt : int
  is	PUT("%s", hdr)
	while cnt--
	   PUT("%02x", *bin++ & 0xff)
	   PUT("-") if cnt
	end
  end
code	nf_mac - get mac address

  type	pkTinf
  is	Vcod : LONG
	Vlen : LONG
	Adat : [1024] char
  end
	pkCUR  := 0x01010102
	pkMED  := 0x00010103
	 pk802 := 0
	 pkWAN := 3
	 pkDIX := 5

  type	pkTopn : WINAPI* (*char) *void
  type	pkTreq : WINAPI* (*void, int, *pkTinf) *int
	pkPopn : pkTopn
	pkPreq : pkTreq

  func	nf_mac
	spc : * char
	mac : * char
  is	inf : pkTinf
	dev : * void
	dll : * void = <>

	dll = LoadLibraryEx ("PACKET.DLL", 0, 0) ; load Packet driver
	pass fail
	if !nf_adr (<*void>&pkPopn, dll, "PacketOpenAdapter")
	|| !nf_adr (<*void>&pkPreq, dll, "PacketRequest")
	.. fail
	dev = (*pkPopn)(spc)
	pass fail

	inf.Vcod = pkMED
	inf.Vlen = 6
	me_clr (inf.Adat, 1)
	(*pkPreq)(dev, 0, &inf)
	pass fail
;PUT("typ=%d ", inf.Adat[0])
	if inf.Adat[0] ne pk802	
	&& inf.Adat[0] ne pkDIX	
	.. fail

	inf.Vcod = pkCUR
	inf.Vlen = 6
	me_clr (inf.Adat, 6)
	(*pkPreq)(dev, 0, &inf)
	pass fail
	me_cop (inf.Adat, mac, 6)
  end
end file
code	nf_loc - get local address
include <windows.h>
include <wincon.h>
include <nb30.h>
include <stdlib.h>

	nfAloc : [16] char

	NDIS_STATUS = (0x17<<16)

  func	nf_loc
	nam : * char
  is	fil : HANDLE
	dat : [4096] char
	spc : [64] char = "\\\\.\\ndis"
	cod : long
	len : long
	ret : LONG
	sts : long
	st_app (nam, spc)

	fil = CreateFile (spc, GENERIC_READ,
	  FILE_SHARE_READ|FILE_SHARE_WRITE, 0,
	  OPEN_EXISTING, 0, 0)
	fail if fil eq INVALID_HANDLE_VALUE
a
exit
PUT("spc=[%s]\n", spc)
	fil = CreateFile (spc, GENERIC_WRITE, 
	  FILE_SHARE_READ|FILE_SHARE_WRITE, 0,
	  OPEN_EXISTING, 0, 0)

	fail if fil eq INVALID_HANDLE_VALUE
b
	sts = DeviceIoControl (fil, NDIS_STATUS,
	   &cod, 4, &dat, 4096, &ret, 0)
	CloseHandle (fil)
	fail if !sts
c
	PUT("%s\n", dat)
	fine
  end

  type	nfTnbi : WINAPI* (*void) int
	nfPnbi : * nfTnbi 

  type	nbTadp
  is	Ista : ADAPTER_STATUS
	Anam : [3] NAME_BUFFER
  end

  func	nf_nbi
	spc : * char
  is	adp : nbTadp = {0}
	ncb : NCB = {0}
	cod : BYTE
	nam : [50] char
	dll : * void = <>

a
;	dll = LoadLibraryEx ("NETBIOS.DLL", 0, 0) ; load WinPcap
;	fail im_rep ("E-NETBIOS library not installed", <>) if fail
b
;	if !nf_adr (<*void>&nfPnbi, dll, "netbios")
;	.. fail

c
	ncb.ncb_command = NCBRESET
;	cod = (*nfPnbi)(&ncb)
;;	cod = Netbios(&ncb)
;	if cod != NRC_GOODRET)
	me_clr (&ncb, #NCB)
	ncb.ncb_command = NCBASTAT
	st_cop ("*               ", <*char>ncb.ncb_callname)
	ncb.ncb_length = #adp
;	cod = (*nfPnbi)(&ncb)
;;	cod = Netbios(&ncb)
	me_cop (adp.Ista.adapter_address, nfAloc, 6)
  end
end file
code	nf_lox - get local address
If 0
include <windows.h>
include <wincon.h>
include <nb30.h>
include <stdlib.h>
include <time.h>

  type	nbTadp
  is	Ista : ADAPTER_STATUS
	Anam : [3] NAME_BUFFER
  end

  func	nf_lox
  is	adp : nbTadp = {0}
	ncb : NCB = {0}
	cod : BYTE
	nam : [50] char
	ncb.ncb_command = NCBRESET
	cod = Netbios (&ncb)
;	if cod != NRC_GOODRET)
	me_clr (&ncb, #NCB)
	ncb.ncb_command = NCBASTAT
	st_cop ("*               ", <*char>ncb.ncb_callname)
	ncb.ncb_length = #adp
	Netbios (&ncb)
	me_cop (adp.Ista.adapter_address, nfAloc, 6)
  end
End
  func	nf_dev
  is
	dll : * void = <>

	dll = LoadLibraryEx ("NETBIOS.DLL", 0, 0) ; load WinPcap
	fail im_rep ("E-NETBIOS library not installed", <>) if fail

	if !nf_adr (<*void>&nfPnbi, dll, "netbios")
	.. fail

