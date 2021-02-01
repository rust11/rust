file	rvpdp - reverse assemble
include rid:rider
include	rid:eldef
include	rid:rvpdp
include	rid:stdef

;???	Should conditionalise RT-11 emts
;???	CIS support?

  type	rvTins
  is	Pnam : *char
	Vopc : elTwrd
	Vmsk : elTwrd
	Vtyp : elTwrd
  end

;	types

	APP := st_end (rev->Pstr)
	REG := rv_reg (reg)
data	rvAins - instruction table

  init	rvAins : [] rvTins
  is	"call",		0004700, 0000077, rvUOP|rvCAL_
	"return",	0000207, 0000000, rvCTL|rvTER_
	"psh",		0010046, 0007700, rvSOP
	"pop",		0012600, 0000077, rvUOP|rvMOD_
;
	".ttyin",	0104340, 0000000, rvCTL
	".ttyou",	0104341, 0000000, rvCTL
	".dstat",	0104342, 0000000, rvCTL
	".fetch",	0104343, 0000000, rvCTL
	".csige",	0104344, 0000000, rvCTL
	".csisp",	0104345, 0000000, rvCTL
	".lock",	0104346, 0000000, rvCTL
	".unloc",	0104347, 0000000, rvCTL
	".exit",	0104350, 0000000, rvCTL
	".print",	0104351, 0000000, rvCTL
	".srese",	0104352, 0000000, rvCTL
	".qset",	0104353, 0000000, rvCTL
	".setto",	0104354, 0000000, rvCTL
	".rctrl",	0104355, 0000000, rvCTL
	".astx",	0104356, 0000000, rvCTL
	".hrese",	0104357, 0000000, rvCTL
;
	"halt",		0000000, 0000000, rvCTL
	"wait",		0000001, 0000000, rvCTL|rvRAR_
	"rti",		0000002, 0000000, rvCTL|rvTER_
	"bpt",		0000003, 0000000, rvCTL
	"iot",		0000004, 0000000, rvCTL
	"reset",	0000005, 0000000, rvCTL|rvRAR_
	"rtt",		0000006, 0000000, rvCTL|rvTER_
	"mfpt",		0000007, 0000000, rvCTL|rvRAR_
;			0000007
;			0000077
	"jmp",		0000100, 0000077, rvUOP|rvCAL_
	"rts",		0000200, 0000007, rvREG|rvTER_
;			0000210
;			0000227
	"spl",		0000230, 0000007, rvPRI|rvRAR_
	"nop",		0000240, 0000000, rvCTL
	"",		0000240, 0000017, rvCON	; ccc, clc etc
	"",		0000260, 0000017, rvCON	; scc, sec, etc
	"swab",		0000300, 0000077, rvUOP|rvMOD_
	"br",		0000400, 0000377, rvBRA
	"bne",		0001000, 0000377, rvBRA
	"beq",		0001400, 0000377, rvBRA
	"bge",		0002000, 0000377, rvBRA
	"blt",		0002400, 0000377, rvBRA
	"bgt",		0003000, 0000377, rvBRA
	"ble",		0003400, 0000377, rvBRA
	"jsr",		0004000, 0000777, rvRMD|rvCAL_
	"clr",		0005000, 0000077, rvUOP|rvMOD_
	"com",		0005100, 0000077, rvUOP|rvMOD_
	"inc",		0005200, 0000077, rvUOP|rvMOD_
	"dec",		0005300, 0000077, rvUOP|rvMOD_
	"neg",		0005400, 0000077, rvUOP|rvMOD_
	"adc",		0005500, 0000077, rvUOP|rvMOD_
	"sbc",		0005600, 0000077, rvUOP|rvMOD_
	"tst",		0005700, 0000077, rvUOP
	"ror",		0006000, 0000077, rvUOP|rvMOD_
	"rol",		0006100, 0000077, rvUOP|rvMOD_
	"asr",		0006200, 0000077, rvUOP|rvMOD_
	"asl",		0006300, 0000077, rvUOP|rvMOD_
	"mark",		0006400, 0000077, rvMRK|rvSPC_	
	"mfpi",		0006500, 0000077, rvUOP|rvMMU_|rvMOD_	
	"mtpi",		0006600, 0000077, rvUOP|rvMMU_
	"sxt",		0006700, 0000077, rvUOP|rvMOD_
	"csm",		0007000, 0000077, rvUOP|rvMMU_
;			0007001
;			0007177
	"tstset",	0007200, 0000077, rvUOP|rvSPC_|rvMOD_
	"wrtlck",	0007300, 0000077, rvUOP|rvSPC_|rvMOD_
;			0007400
;			0007777
	"mov",		0010000, 0007777, rvBOP|rvMOD_
	"cmp",		0020000, 0007777, rvBOP
	"bit",		0030000, 0007777, rvBOP
	"bic",		0040000, 0007777, rvBOP|rvMOD_
	"bis",		0050000, 0007777, rvBOP|rvMOD_
	"add",		0060000, 0007777, rvBOP|rvMOD_
;
	"mul",		0070000, 0000777, rvEIS|rvMOD_	
	"div",		0071000, 0000777, rvEIS|rvMOD_
	"ash",		0072000, 0000777, rvEIS|rvMOD_
	"ashc",		0073000, 0000777, rvEIS|rvMOD_
	"xor",		0074000, 0000777, rvEIS|rvMOD_
;
	"fadd",		0075000, 0000007, rvREG|rvFIS_
	"fsub",		0075010, 0000007, rvREG|rvFIS_
	"fmul",		0075020, 0000007, rvREG|rvFIS_
	"fdiv",		0075030, 0000007, rvREG|rvFIS_
;			0074040
;			0075777
	"med6x",	0076600, 0000000, rvCTL|rvSPC_
	"med74c",	0076601, 0000000, rvCTL|rvSPC_
;			0076602
;			0076677
	"xfc",		0076700, 0000077, rvUOP|rvSPC_
	"sob",		0077000, 0000777, rvSOB
	"bpl",		0100000, 0000377, rvBRA
	"bmi",		0100400, 0000377, rvBRA
	"bhi",		0101000, 0000377, rvBRA
	"blos",		0101400, 0000377, rvBRA
	"bvc",		0102000, 0000377, rvBRA
	"bvs",		0102400, 0000377, rvBRA
	"bcc",		0103000, 0000377, rvBRA	;bhis
	"bcs",		0103400, 0000377, rvBRA	;blo
;
	"emt",		0104000, 0000377, rvEMT
	"trap",		0104400, 0000377, rvEMT
;
	"clrb",		0105000, 0000077, rvUOP|rvBYT_|rvMOD_
	"comb",		0105100, 0000077, rvUOP|rvBYT_|rvMOD_
	"incb",		0105200, 0000077, rvUOP|rvBYT_|rvMOD_
	"decb",		0105300, 0000077, rvUOP|rvBYT_|rvMOD_
	"negb",		0105400, 0000077, rvUOP|rvBYT_|rvMOD_
	"adcb",		0105500, 0000077, rvUOP|rvBYT_|rvMOD_
	"sbcb",		0105600, 0000077, rvUOP|rvBYT_|rvMOD_
	"tstb",		0105700, 0000077, rvUOP|rvBYT_
	"rorb",		0106000, 0000077, rvUOP|rvBYT_|rvMOD_
	"rolb",		0106100, 0000077, rvUOP|rvBYT_|rvMOD_
	"asrb",		0106200, 0000077, rvUOP|rvBYT_|rvMOD_
	"aslb",		0106300, 0000077, rvUOP|rvBYT_|rvMOD_
	"mtps",		0106400, 0000077, rvUOP
	"mfpd",		0106500, 0000077, rvUOP|rvMMU_|rvMOD_
	"mtpd",		0106600, 0000077, rvUOP|rvMMU_
	"mfps",		0106700, 0000077, rvUOP|rvMOD_|rvRAR_
;			0107000
;			0107777
	"movb",		0110000, 0007777, rvBOP|rvBYT_|rvMOD_
	"cmpb",		0120000, 0007777, rvBOP
	"bitb",		0130000, 0007777, rvBOP
	"bicb",		0140000, 0007777, rvBOP|rvBYT_|rvMOD_
	"bisb",		0150000, 0007777, rvBOP|rvBYT_|rvMOD_
	"sub",		0160000, 0007777, rvBOP|rvBYT_|rvMOD_
;
;	fpp
;
	"cfcc",		0170000, 0000000, rvCTL|rvFPU_		;cfcc
	"setf",		0170001, 0000000, rvCTL|rvFPU_		;setf
	"seti",		0170002, 0000000, rvCTL|rvFPU_		;seti
	"setd",		0170011, 0000000, rvCTL|rvFPU_		;setd
	"setl",		0170012, 0000000, rvCTL|rvFPU_		;setl
	"ldfps",	0170100, 0000077, rvUOP|rvFPU_		;ldfps	src
	"stfps",	0170200, 0000077, rvUOP|rvFPU_|rvMOD_	;stfps	dst
	"stst",		0170300, 0000077, rvUOP|rvFPU_|rvMOD_	;stst	dst
	"clrf",		0170400, 0000077, rvUOP|rvFPU_|rvMOD_	;clrf	fdst
	"tstf",		0170500, 0000077, rvUOP|rvFPU_		;tstf	fdst
	"absf",		0170600, 0000077, rvUOP|rvFPU_		
	"negf",		0170700, 0000077, rvUOP|rvFPU_|rvMOD_	;negf	fdst
	"mulf",		0171000, 0000377, rvFPS|rvFPU_		;mulf	fsrc,ac
	"modf",		0171400, 0000377, rvFPS|rvFPU_		;modf	fsrc,ac
	"addf",		0172000, 0000377, rvFPS|rvFPU_		;addf	fsrc,ac
	"ldf",		0172400, 0000377, rvFPS|rvFPU_		;ldf	src,ac
	"subf",		0173000, 0000377, rvFPS|rvFPU_		;subf	fsrc,ac
	"cmpf",		0173400, 0000377, rvFPS|rvFPU_		;cmpf	fsrc,ac
	"stf",		0174000, 0000377, rvFPD|rvFPU_|rvMOD_	;stf	ac,fdst
	"divf",		0174400, 0000377, rvFPS|rvFPU_		;divf	fsrc,ac
	"stexp",	0175000, 0000377, rvFPD|rvFPU_|rvMOD_	;stexp	ac,dst
	"stcfi",	0175400, 0000377, rvFPD|rvFPU_|rvMOD_	;stcfi	ac,dst
	"stcdf",	0176000, 0000377, rvFPD|rvFPU_|rvMOD_	;stcdf	ac,fdst
	"ldexp",	0176400, 0000377, rvFPS|rvFPU_		;ldexp	src,ac
	"ldcif",	0177000, 0000377, rvFPS|rvFPU_		;ldcif	src,ac
	"ldcdf",	0177400, 0000377, rvFPS|rvFPU_		;ldcdf	fsrc,ac
	".word",	0,	 0,	  rvWRD	; end list
  end

	rv_acc : (*rvTpdp, int) void
	rv_srg : (*rvTpdp, int) void
	rv_drg : (*rvTpdp, int) void
	rv_smd : (*rvTpdp, int) void
	rv_dmd : (*rvTpdp, int) void

	rv_oct : (*rvTpdp, int) void
	rv_str : (*rvTpdp, *char) void
	rv_con : (*rvTpdp, int) void
	rv_com : (*rvTpdp) void
	rv_tab : (*rvTpdp) void

	rv_arg : (*rvTpdp) WORD
	rv_dat : (*rvTpdp) WORD
	rv_rel : (*rvTpdp, WORD) WORD
	rv_reg : (int) *char
code	rv_pdp - reverse assemble PDP-11 instruction

  proc	rv_pdp
	rev : * rvTpdp
  is	ins : * rvTins = rvAins
	opc : int = rev->Vopc
	rev->Vlen = 1			; count bytes
	rev->Pstr = rev->Astr		; output buffer
	*rev->Pstr = 0			;
;	rv_tab (rev) if !(rev->Vflg & rvSKE_) ; first a tab
	ins = rvAins			; instruction table
	rev->Vdst = rev->Vloc		; default DST
      repeat				;
        while ins->Vtyp ne rvWRD
	   quit if (opc & (~ins->Vmsk)) eq ins->Vopc
	   ++ins			;
	end				;
;;;	quit if rv_spc (rev, ins)	; or special
	rev->Vtyp = ins->Vtyp & rvTYP_	; return that
	rev->Vatr = ins->Vtyp & ~rvTYP_	;
					;
	rv_str (rev, ins->Pnam)		; display name
	rv_con (rev, opc) if rev->Vtyp eq rvCON ; clc, clv etc
	rv_tab (rev)			;
	case rev->Vtyp			; general dispatch
	of rvCTL
	or rvCON  nothing
	of rvSOB  rv_srg (rev, opc)
		  opc = -(opc&077)
		  rv_com (rev)
	or rvBRA  opc = (<char>(opc))*2; sign extend byte
		  rv_rel (rev, opc)	;
	of rvSOP  rv_smd (rev, opc)
	of rvRMD  rv_srg (rev, opc)
		  rv_com (rev)
		  rv_dmd (rev, opc)
	of rvBOP  rv_smd (rev, opc)
		  rv_com (rev)
	or rvUOP  rv_dmd (rev, opc)
	of rvEIS  rv_dmd (rev, opc)
		  rv_com (rev)
		  rv_srg (rev, opc)
	of rvREG  rv_drg (rev, opc)
	of rvFPS  rv_dmd (rev, opc)
		  rv_com (rev)
		  rv_acc (rev, opc)
	of rvFPD  rv_acc (rev, opc)
		  rv_com (rev)
		  rv_dmd (rev, opc)

	of rvEMT  rv_oct (rev, opc&0377)
	of rvMRK  rv_oct (rev, opc&077)
	of rvPRI  rv_oct (rev, opc&07)
	of rvWRD  rv_oct (rev, opc) if !(rev->Vflg & rvSKE_)
		  rv_oct (rev, 0)   otherwise
	end case
      never
  end
code	modes

  proc	rv_acc
	rev : * rvTpdp
	ins : int
  is	FMT(APP, "ac%d", (ins>>6)&3)
  end

  proc	rv_srg
	rev : * rvTpdp
	ins : int
  is	rv_drg (rev, ins>>6)
  end

  proc	rv_drg
	rev : * rvTpdp
	opc : int
  is	reg : int = opc & 7
	st_cop (REG, APP)
  end

  proc	rv_smd
	rev : * rvTpdp
	ins : int
  is	rv_dmd (rev, ins>>6)
  end

  proc	rv_dmd
	rev : * rvTpdp
	opc : int
  is	reg : int = opc & 7
	mod : int = (opc>>3) & 7
	str : * char = APP
	val : int = 0
	mod |= 010 if reg eq 7
	val = rv_dat (rev) if (mod ge 012) && (mod ne 014) && (mod ne 015)
;	val = 0 if (rev->Vflg & rvSKE_)

	case mod
	of 0   FMT(str, "%s", REG)
;		rev->Vres = rev
	of 1   FMT(str, "(%s)", REG)
	of 2   FMT(str, "(%s)+", REG)
	       FMT(str, "(%s)+", REG)
	of 3   FMT(str, "@(%s)+", REG)
	of 5   *str++ = '@'
	or 4   FMT(str, "-(%s)", REG)
	of 7   *str++ = '@'
	or 6   FMT(str, "%o(%s)", rv_dat (rev), REG)
	of 010 FMT(str, "pc")
	of 011 FMT(str, "@pc=%o", rv_arg (rev))
	of 012 FMT(str, "#%o", val)
	of 013 FMT(str, "@#%o", val)
	of 014 FMT(str, "-(pc)")
	of 015 FMT(str, "@-(pc)")
	of 016 rv_rel (rev, val)
	of 017 FMT(str, "@"), rv_rel (rev, val)
	end case
  end
	rvAset : [] *char = {"scc", "sen", "sez", "sev", "sec"}
	rvAclr : [] *char = {"ccc", "cln", "clz", "clv", "clc"}

  proc	rv_con
	rev : *rvTpdp
	opc : int
  is	arr : ** char = (opc&020) ? rvAset ?? rvAclr
	msk : int = 010
	fst : int = 1
	exit FMT(APP, *arr) if (opc&017) eq 017
	while msk
	  ++arr
	  if msk & opc
	     FMT(APP,"!") if !fst
	  .. fst=0, FMT(APP,*arr)
	  msk >>= 1
	end
  end

  proc	rv_oct
	rev : * rvTpdp
	val : int
  is	FMT(APP,"%o", val)
  end

  proc	rv_str
	rev : * rvTpdp
	str : * char
  is	st_app (str, rev->Pstr) if str
  end

  proc	rv_com
	rev : * rvTpdp
  is	st_app (",", rev->Pstr)
  end

  proc	rv_tab
	rev : * rvTpdp
  is	str : * char = rev->Pstr
	len : int = st_len (str)
	cnt : int = 8 - (len % 8)
	st_app (" ", str) while cnt--
  end

  func	rv_rel
	rev : * rvTpdp
	rel : WORD
	()  : WORD
  is	val : WORD
	val = (rev->Vloc + rev->Vrel + (rev->Vlen*2) + rel) & 0177777
	val = 0 if (rev->Vflg & rvSKE_)
	FMT(APP, "%o", val)
	rev->Vdst = val
  end

  func	rv_arg
	rev : * rvTpdp
	()  : WORD
  is	val : WORD = rev->Adat[rev->Vlen]
	rev->Vdst = val
	reply val
  end

  func	rv_dat
	rev : * rvTpdp
	()  : WORD
  is	val : WORD = rev->Adat[rev->Vlen++]
	rev->Vdst = val
	reply 0 if rev->Vflg & rvSKE_
	reply val
  end

  init	rvAreg : [] * char
  is	"r0", "r1", "r2", "r3", "r4", "r5", "sp", "pc"
  end

  func	rv_reg
	reg : int 
	()  : * char
  is	reply rvAreg[reg&7]
  end
