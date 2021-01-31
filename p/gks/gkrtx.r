file	gkrtx - display RTX context
include	rid:rider
include	rid:fidef
include rid:mxdef
include	rid:rsmod
include	rid:rtmod

  type	faTcab
  is 	Vsta : WORD		; =  status
	Vlun : WORD		; -> lun
	Vnam : WORD		; =  device-unit in RAD50
	Vfid : WORD		;\=  file ID
	Vseq : WORD		;/=  sequence number
	Vfna : [3] WORD		; = .rad50 /filnamtyp/
  end

  type	faTvab
  is	Vflg : WORD		; =  init flag (must be first)
	Vfun : WORD		; =  function
	Pqel : * rtTqel		; -> queue element
	Pcsw : * rtTchn		; -> channel
	Pcab : * faTcab		; -> cab address
	Vcid : WORD		; =  channel i/d
	Vchn : WORD		; =  channel number
	Vlun : WORD		;
	Vwlk : WORD		; =  sub-directory walk flags
	Pdev : * WORD		; -> ddn:
	Vbuf : * WORD		; -> filnam.typ or buffer
	Pdid : * WORD		; -> ca.fid (used as did)
	Vstk : WORD		; =  return stack
	Vcnt : WORD		; =  transfer byte count
	Vbbs : WORD		;
  end

  type	faTfap
  is	Vdsw : WORD		; DSW
	Vsta : char		; ISB
	Vinf : char
	Vlen : WORD		;
	Pvab : * faTvab		; VAB
	Pcab : * faTcab		; CAB
	Pnmb : * rsTnmb		; NMB
  end

	faWLK_ := 4		; sub-directory walk
	faSUB_ := 2  ;  sub wlk	; sub-directory
	rxSIG  := 29624		; .rad50 /rtx/

  func	gk_rtx
  is	fpp : ** faTfap = <*void>0254
	fap : * faTfap
	sig : * WORD = <*void>0256
	spc : [mxLIN] char
	fil : * FILE
	buf : * char = me_acc (512)

	if *sig ne rxSIG
	.. fine im_rep ("E-Not RTX", "")

	fap = *fpp

	cl_cmd ("File? ", spc)
	if !st_fnd ("w", spc)
	   fil = fi_opn (spc, "rb", "")
	else
	.. fil = fi_opn (spc, "wb", "")

	cu_rep (fap, "open")
	fi_rea (fil, buf, 512)
	cu_rep (fap, "read")
	fi_rea (fil, buf, 512)
	cu_rep (fap, "read", buf)
	fi_clo (fil, "")
	fine
   end

  func	cu_rep
	fap : * faTfap
	tit : * char
	buf : * char
  is	vab : * faTvab = fap->Pvab
	cab : * faTcab = fap->Pcab
	nmb : * rsTnmb = fap->Pnmb
	sta : int = fap->Vsta
	PUT("?RTX-I-%s ", tit)
	PUT("DSW=%o ", fap->Vdsw)
	PUT("IOSB=(%d,%d)\n", sta, fap->Vlen)
  end
