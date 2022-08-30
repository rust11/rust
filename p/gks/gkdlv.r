file	gkdlv - report dlv input
include rid:rider
include	rid:dcdef
include	rid:mxdef
include	gkb:gkmod

  type	cuTrec
  is	Vcsr : WORD
	Vbuf : WORD
  end

	cuCNT := 100

  type	cuTctx
  is	Vcsr : WORD
	Vbuf : WORD
	Vget : int
	Vput : int
	Vcnt : int
	Vovr : int
	Arec : [cuCNT] cuTrec
	Aopt : [mxLIN] char
	Popt : * char
  end

	ctx	: cuTctx- = {0}

	cu_get 	: () *char-
	cu_put	: ()-

code	gk_dlv - report DLV input

	IE 	:= 0100
	RDY	:= 0200
	ctrlz	:= 032
	BYT(x)	:= (x & 255)

  func	gk_dlv
 	dcl : * dcTdcl
  is	csr : * WORD = ctl.Vcsr
	buf : * WORD = ctl.Vcsr + 2
	tks : * WORD = 0177560
	tkb : * WORD = 0177562
	tps : * WORD = 0177564
	tpb : * WORD = 0177566
	opt : * char = <>
	pee : [2] WORD
	sts : WORD
	val : WORD

	me_clr (&ctx, #cuTctx)

	if !csr
	.. fine im_rep ("E-CSR not specified", <>)

	if !me_pee (csr, &pee, 4)
	.. fine im_rep ("E-Invalid CSR address", <>)

	*csr = 0		; disable interrupts
	*tks = 0		;
	*tps = 0		;

     repeat
	if (sts = *csr) & RDY	; more input
	   val = *buf		;
	.. cu_put (sts, val)	; store it
				;
	if *tps & RDY		; output ready
	   if opt && *opt	; got output
	      *tpb = *opt++	;
	   else			;
	   .. opt = cu_get ()	; get next record, if any
	end			;
				;
	if csr eq tks && BYT(val) eq ctrlz
	|| csr ne tks && BYT(*tkb) eq ctrlz
	.. im_exi ()		;
     forever			;
  end

  func	cu_get
	()  : *char
  is	opt : * char = ctx.Aopt
	rec : * cuTrec = ctx.Arec + ctx.Vget

	fail if ctx.Vcnt eq

	FMT(opt, "(%o %o)", rec->Vcsr, rec->Vbuf)
	st_app ("* \r\n"), ctx.Vovr=0 if ctx.Vovr
	st_app ("  \r\n", opt) otherwise

	--ctx.Vcnt
	++ctx.Vget
	ctx.Vget = 0 if ctx.Vget eq cuCNT

	reply ctx.Aopt
  end

  func	cu_put
	csr : WORD
	buf : WORD
  is	rec : * cuTrec = ctx.Arec + ctx.Vput

	fail ++ctx.Vovr if ctx.Vcnt eq cuCNT
	ctx.Vovr = 0

	rec->Vcsr = csr
	rec->Vbuf = buf

	++ctx.Vcnt
	++ctx.Vput
	ctx.Vput = 0 if ctx.Vput eq cuCNT
	fine
  end
