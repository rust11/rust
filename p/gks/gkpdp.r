;???;	GKPDP - FPP codes incomplete
file	gkpdp - display pdp-11 opcodes
include	rid:rider
include	rid:dcdef
include	rid:cldef

  type	gkTpdp
  is	Pstr : * char
	Pcod : * char
  end

  init	gkApdp : [] gkTpdp
  is	"halt",		"0000000"
	"wait",		"0000001"
	"rti",		"0000002"
	"bpt",		"0000003"
	"iot",		"0000004"
	"reset",	"0000005"
	"rtt",		"0000006"
	"mfpt",		"0000007"
	"...",		"0000010"
;	"x",		"0000077"
	"jmp",		"00001DD"
	"rts",		"000020R"
	"...",		"0000210"
;	"x",		"0000227"
	"spl",		"000023N"
	"nop",		"0000240"
	"ccc",		"0000241";, 0000017, rvKcon	; ccc, clc etc
	"scc",		"0000260";, 0000017, rvKcon	; scc, sec, etc
	"swab",		"00003DD"
	"br",		"00004XX"
	"bne",		"00010XX"
	"beq",		"00014XX"
	"bge",		"00020XX"
	"blt",		"00024XX"
	"bgt",		"00030XX"
	"ble",		"00034XX"
	"jsr",		"00040DD"
	"clr",		"00050DD"
	"com",		"00051DD"
	"inc",		"00052DD"
	"dec",		"00053DD"
	"neg",		"00054DD"
	"adc",		"00055DD"
	"sbc",		"00056DD"
	"tst",		"00057DD"
	"ror",		"00060DD"
	"rol",		"00061DD"
	"asr",		"00062DD"
	"asl",		"00063DD"
	"mark",		"00064NN"
	"mfpi",		"00065SS"
	"mtpi",		"00066DD"
	"sxt",		"00067DD"
	"csm",		"0007000"
	"...",		"0007001"
;	"x",		"0007177"
	"tstset",	"00072DD"
	"wrtlck",	"00073DD"
	"...",		"0007400"
;	"x",		"0007777"
	"mov",		"001SSDD"
	"cmp",		"002SSDD"
	"bit",		"003SSDD"
	"bic",		"004SSDD"
	"bis",		"005SSDD"
	"add",		"006SSDD"
	"mul",		"0070RSS"
	"div",		"0071RSS"
	"ash",		"0072RSS"
	"ashc",		"0073RSS"
	"xor",		"0074RDD"
	"fadd",		"007500R"
	"fsub",		"007501R"
	"fmul",		"007502R"
	"fdiv",		"007503R"
	"...",		"0074040"
;	"x",		"0075777"
	"med6x",	"0076600"
	"med74c",	"0076601"
	"...",		"0076602"
;	"x",		"0076677"
	"xfc",		"00767DD"
	"sob",		"0077RNN"
	"bpl",		"01000XX"
	"bmi",		"01004XX"
	"bhi",		"01010XX"
	"blos",		"01014XX"
	"bvc",		"01020XX"
	"bvs",		"01024XX"
	"bcc/hs",	"01030XX"
	"bcs/lo",	"01034XX"
	"emt",		"01040NN"
	"trap",		"01044NN"
	"clrb",		"01050DD"
	"comb",		"01051DD"
	"incb",		"01052DD"
	"decb",		"01053DD"
	"negb",		"01054DD"
	"adcb",		"01055DD"
	"sbcb",		"01056DD"
	"tstb",		"01057DD"
	"rorb",		"01060DD"
	"rolb",		"01061DD"
	"asrb",		"01062DD"
	"aslb",		"01063DD"
	"mtps",		"01064SS"	; ???
	"mfpd",		"01065SS"
	"mtpd",		"01066DD"
	"mfps",		"01067DD"
	"...",		"0107000"
;	"x",		"0107777"
	"movb",		"011SSDD"
	"cmpb",		"012SSDD"
	"bitb",		"013SSDD"
	"bicb",		"014SSDD"
	"bisb",		"015SSDD"
	"sub",		"016SSDD"
	<>,		<>
	"cfcc",		"0170000"	;, 0000000, rvKctl	;cfcc
	"setf",		"0170001"	;, 0000000, rvKctl	;setf
	"seti",		"0170002"	;, 0000000, rvKctl	;seti
	"setd",		"0170011"	;, 0000000, rvKctl	;setd
	"setl",		"0170012"	;, 0000000, rvKctl	;setl
	"ldfps",	"01701SS"	;, 0000077, rvKuop	;ldfps	src
	"stfps",	"01702DD"	;, 0000077, rvKuop	;stfps	dst
	"stst",		"01703DD"	;, 0000077, rvKuop	;stst	dst
	"clrf",		"01704DD"	;, 0000077, rvKuop	;clrf	fdst
	"tstf",		"01705DD"	;, 0000077, rvKuop	;tstf	fdst
	"absf",		"0170600"	;, 0000077, rvKuop	
	"negf",		"0170700"	;, 0000077, rvKuop	;negf	fdst
	"mulf",		"0171000"	;, 0000377, rvKfps	;mulf	fsrc,ac
	"modf",		"0171400"	;, 0000377, rvKfps	;modf	fsrc,ac
	"addf",		"0172000"	;, 0000377, rvKfps	;addf	fsrc,ac
	"ldf",		"0172400"	;, 0000377, rvKfps	;ldf	src,ac
	"subf",		"0173000"	;, 0000377, rvKfps	;subf	fsrc,ac
	"cmpf",		"0173400"	;, 0000377, rvKfps	;cmpf	fsrc,ac
	"stf",		"0174000"	;, 0000377, rvKfpd	;stf	ac,fdst
	"divf",		"0174400"	;, 0000377, rvKfps	;divf	fsrc,ac
	"stexp",	"0175000"	;, 0000377, rvKfpd	;stexp	ac,dst
	"stcfi",	"0175400"	;, 0000377, rvKfpd	;stcfi	ac,dst
	"stcdf",	"0176000"	;, 0000377, rvKfpd	;stcdf	ac,fdst
	"ldexp",	"0176400"	;, 0000377, rvKfps	;ldexp	src,ac
	"ldcif",	"0177000"	;, 0000377, rvKfps	;ldcif	src,ac
;	"ldcdf",	"0177400"	;, 0000377, rvKfps	;ldcdf	fsrc,ac
	<>,	<>
	<>,	<>
  end

  func	gk_pdp
	dcl : * dcTdcl
  is	pdp : * gkTpdp = gkApdp
	nxt : * gkTpdp = pdp	; next area
	bas : * gkTpdp		; current area
	tot : int = 0
	idx : int
	row : int
	col : int
	dep : int
    repeat
	bas = pdp = nxt
	tot = 0
	++tot, ++pdp while pdp->Pstr ne	; count total for group
	nxt = pdp + 1			; next group
	dep = tot / 5			; column depths

	row = 0
      repeat
	col = 0
	while col lt 5
	   idx = (dep * col) + row
	   pdp = bas + idx
	   PUT("%7s%8s", pdp->Pstr, pdp->Pcod)
	   ++col
	   quit if idx ge tot-1
	end
	PUT("\n")
	quit if idx ge tot-1
	++row
      end
	quit if nxt->Pstr eq		;no more groups
	co_prm ("?PDP-I-More? ", <>)
    end
	fine
  end
