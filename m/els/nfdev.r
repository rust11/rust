;See ???
infC := 1
file	nfdev - NF native directories/files ACP
include	elb:vpmod
include	rid:medef
include	rid:stdef
include rid:nfdef
include rid:nfcab
include rid:rtutl

	nfVtra : int = 0	; trace things
	nfVflg : int = 0	; flags

  init	nfAfun : [] int
  is	(nfREA | nfCSW_|nfDAT_)
	(nfWRI | nfCSW_|nfDAT_|nfSDA_)
	(nfCLO | nfCSW_|nfSPU_)
	(nfDEL | nfCSW_|nfFNA_|nfSPU_)
	(nfLOO | nfCSW_|nfFNA_|nfSPU_|nfDIR_)
	(nfENT | nfCSW_|nfFNA_|nfSPU_|nfDIR_)
	(nfREN | nfCSW_|nfFNA_|nfSPU_)
	(nfPUR | nfCSW_|nfSPU_)
	(nfINF | nfCSW_|nfFNA_|nfSPU_)
	(nfCLZ | nfCSW_|nfSPU_)
If infC
	(nfSIZ | nfCSW_|nfSPU_)
End
  end
	spREN := 5		; spfun rename code
	spINF := 8		; spfun info code

	nf_pre : (*vpTqel, *nfTvab, elTwrd) int
	nf_win : (*vpTqel, *nfTvab) int
	nf_pos : (*vpTqel, *nfTvab)

	REQ(x) := (x & 0xff)	; isolate request code
code	nf_iop - nf i/o processor

  func	nf_com
	qel : *vpTqel
	vab : *nfTvab
	cid : elTwrd
	flg : elTwrd
  is	vab->Vflg = flg			;
	nf_pre (qel, vab, cid)		; preprocess it
	fine if fail			; unrecognised operation
	nf_win (qel, vab)		; setup window
	nf_ser (vab)			; send to server
	nf_pos (qel, vab)		; post process it
	reply !vab->Vsta		;
  end

code	nf_iop - VRT entry point

  func	nf_iop
	qel : *vpTqel
	req : int
  is	vab : nfTvab = {0}		; clears Vnod etc
	nf_com (qel, &vab, 0, 0)
  end

code	RUST/SJ NFW: entry point

  func	nf_drv
	ioq : *rtTqel
	cid : elTwrd
	flg : elTwrd
  is	vab : nfTvab = {0}		; clears Vnod etc
	qel : vpTqel = {0}
	chn : * rtTchn
	chn = ADR(ioq->Vcsw)		; get the channel area
					;
	if flg & (nfINI_|nfINP_)	;
	.. cab_res (cabIRS)		; do an image reset
	flg &= (nfWLK_|nfSUB_|nfDSK_)	;
					;
	qel.Vcnt = ioq->Vcnt		;
	qel.Vqbu = ioq->Vbuf		;
	qel.Vcsw = ioq->Vcsw		;
	qel.Vfun = ioq->Vfun		;
	if !qel.Vfun			;
	   if !(flg & nfDSK_)		;
;	      chn = ADR(ioq->Vcsw)	; get the channel area
	      qel.Vblk = ioq->Vblk - chn->Vblk
	   else
	   .. qel.Vblk = ioq->Vblk	;
	   qel.Vqbl = qel.Vblk		;
	else				;
	.. qel.Vblk = ioq->Vblk		;

	vab.Vjid = ioq->Vuni>>3		; job id
	vab.Vjcn = chn->Vuse>>8		; job channel number

	fail if !nf_com (&qel, &vab, cid, flg);

	if nfVflg & nfDIR_		; lookup/enter
	|| REQ(vab.Vfun) eq nfINF
	.. ioq->Vcnt = qel.Vcnt		;
	fine
  end
code	nf_pre - preprocess i/o request

	rxXVX := 0114610

  func	nf_pre
	qel : * vpTqel
	vab : * nfTvab
	cid : elTwrd
  is	chn : * rtTchn
	buf : * elTwrd
	nam : * elTwrd			; filename in rad50
If infC
	inf : * elTwrd
End
	spc : [16] char
	req : int = 0			; RT-11/QEL request
	flg : int = 0
	fun : int = 0			; VAB function
	spc[0] = 0

	vab->Vsta = 0			; clean up
	vab->Vdbc = 0
	chn = ADR(qel->Vcsw)		; get the channel area
	vab->Vcid = cid if cid		; explicit cid
	vab->Vcid = chn->Vblk otherwise	; get the channel id

	req = REQ(qel->Vfun)		; get the RT-11 ACP spfun code
	if req gt spINF			; out of range
	   fail				; ignore it
	elif req ne			; not read/write
	   ++req			; up the code
	elif qel->Vcnt & 0100000	; it's a write
	   ++req			; up the function
	.. qel->Vcnt = -qel->Vcnt	; negate the count
	if req eq spINF		;
	.. qel->Vblk -= chn->Vblk

	flg = nfAfun[req]		; get an operation
	nfVflg = flg			; store them
	vab->Vfun = flg
	fun = REQ(flg)			; just the request code
;PUT("req=%d flg=%o, fun=%d\n", REQ(qel->Vfun), flg&0xff, fun)

	if flg & nfFNA_			; got a filename
	   vab->Vblk = qel->Vblk	; get the block over
	   nam = vab->Afna + 1		; point to filename part
	   buf = <*elTwrd>ADR(qel->Vqbu); get the buffer

	   *nam++ = *buf++		; move in a name
	   *nam++ = *buf++		;
	   *nam++ = *buf++		;
	   if fun eq nfREN		; got a rename
	      *nam++ = *buf++		;
	      *nam++ = *buf++		;
	      *nam++ = *buf++		;
	   .. *nam++ = *buf++		;
If infC
	   if fun eq nfINF
	   .. vab->Vlen = qel->Vcnt	;
End
	   vab->Afna[0] = *buf++	; get the logical name

	   if *buf eq rxXVX		; old style
;	      if !vab->Vjid
;	      .. vab->Vjid = buf[1]&0xff	; get the job id
	      vab->Vjcn = buf[1]>>8	; job channel number
	   else
;	      vab->Vjid = chn->Vuse	; job id
	      vab->Vjcn = chn->Vuse>>8	; job channel number
	   .. chn->Vuse = 0		;

	   rt_unp (vab->Afna, spc, -4)	; 
	.. PUT("spec=[%s] ", spc) if nfVtra
	PUT("\n") if nfVtra
	   
	if fun eq nfENT			; got an enter
	.. vab->Vlen = qel->Vcnt	;
	fine if fun ne nfCLO		; not a close
	vab->Vlen = chn->Vuse		; supply final size
;	fail if chn->Vlen eq -1		; ignore non-file close
;	fail if chn->Vlen eq		; didn't write anything
	fine
  end
code	nf_win - setup transfer window

  func	nf_win
	qel : * vpTqel
	vab : * nfTvab
  is	chn : * rtTchn = ADR(qel->Vcsw)	;
	fine if !(nfVflg & nfDAT_)	;

	vab->Vblk = qel->Vqbl		; get the block again
	vab->Vrwc = qel->Vcnt		; request-wordcount
	vab->Vtwc = qel->Vcnt		; transfer word count
	nfPbuf = <*char>ADR(qel->Vqbu)	; fudge buffer address
	fine if !(nfVflg & nfSDA_)	; it's not sending data
	vab->Vdbc = vab->Vtwc * 2	; get the actual word count
	fine
  end
code	nf_pos - post process i/o request

  func	nf_pos
	qel : * vpTqel
	vab : * nfTvab
  is	chn : * rtTchn
	ptr : elTwrd
;???
	exit if vab->Vcid eq 0117740	; boot

	chn = ADR(qel->Vcsw)		;
	if nfVflg & nfSPU_		; directory operation
	&& vab->Vsta			; and has an error
	.. vab->Vsta = nfFNF		; 
	if vab->Vsta eq nfIOX		; hard stuff
	.. exit chn->Vcsw |= chHER_	; same for all
	if nfVflg & nfDIR_		; lookup/enter stuff
	  chn->Vcsw |= 0200		; force a close
	  chn->Vblk = vab->Vcid		; start block
	  chn->Vlen = vab->Vlen		;
	  qel->Vcnt = vab->Vlen		; rt-11 wants it there
	  if REQ(vab->Vfun) eq nfLOO	; lookup
	      chn->Vuse = vab->Vfmt	; (ch.use irrelevant for lookup)
	.. .. chn->Vcsw &= ~(0200)	; turn off enter flag

If infC
	if REQ(vab->Vfun) eq nfINF	;
	   chn->Vlen = vab->Vblk	; old - value returned in r0
	.. qel->Vcnt = vab->Vblk	; new - value returned in r0
End

	if nfVflg & nfSPU_		; need to setup special user?
	   el_fwd (sysptr) + spusr	; yep - get address
	   el_swd (that,vab->Vsta)	; set it
	.. exit				;
	exit if vab->Vsta ne nfEOF	; fine
	chn->Vcsw |= chEOF_		; set end of file
  end
 