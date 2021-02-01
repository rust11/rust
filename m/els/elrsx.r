;	must use \n if not at start of line--killing output
;	null parameters
;	no parameters
;	VT100
file	elrsx - RSX extensions
include	elb:elmod
include	rid:medef
include	rid:stdef
include rid:rtutl

	rsCNX := 16

  type	rsTemt
  is	Pnam : * char
	Parg : * char
  end

  type	rsTdir
  is	Pemt : * rsTemt		; emt descriptor (see below)
	Vadr : elTwrd		; emt address + 2
	Vpsw : elTwrd		; emt PSW
	Vdir : elTwrd		; va of directive block
	Vdic : int		; directive code
	Vcnt : int		; directive byte count
	Apar : [rsCNX] elTwrd	; directive parameters
  end

	rs_dis : (*rsTdir)
	rs_nam : (*rsTdir)
	rs_flt : (*rsTdir)
	rs_spn : (*rsTdir)
data	emt list

;	Name	
;	! = end
;	, = skip parameter
;	- = don't skip to next parameter (used with h=high)
;	l = low byte
;	h = high byte
;	| = newline
;	0 = skip parameter if zero
;
;	* = skip unless all wanted
;	% = temporary skip class
;
;	. = Decimal	value
;	A = Address	inline  .blkw /n/
;     	D,= Device 	inline	.ascii /TT/<n>
;	F = FID
;	O = Octal	value
;	Q = QIO function
;	S = Spec
;     	T,= Name	inline	.rad50 /myname/
;	U = UIC			[m,g]

  init	rsAemt : [] rsTemt
  is
"qio",	"hQfun-lOmod0OlunlOefnOisbOast0|O p1O p2O p3O p4O p5O p6"; 0
"qiow",	"hQfun-lOmod0OlunlOefnOisbOast0|O p1O p2O p3O p4O p5O p6"; 2
	"glun",	"lOlunObuf"	; 4
	"alun",	"lOlunDdev"	; 6
	"altp",	""		; 8
;	"rqst",	"Ttsk,,,,Uuic"	; 10	spwn
	"rqst",	"Ttsk,,,,UuiclOevt-hOxstAastAstsAcmdOlenOvirTter|" ; 10	spwn
	"exec",	""		; 12	
	"schd",	""		; 14	
	"run",	"Ttsk,,,Uuic.smg.snt.rmg.rnt" 	; 16
	"sync",	""		; 18	
	"srra",	""		; 20
	"mrkt",	"!%lOefnOtmgOtntOast" ; 22
	"csrq",	"Ntsk"		; 24
	"cmkt",	"%"		; 26
	"exst",	"Osts"		; 28
	"clef",	"*lOefn"	; 30
	"setf",	"*lOefn"	; 32
	"decl",	""		; 34
	"rdef",	""		; 36	
	"rdaf",	"*Obuf"		; 38
	"wtse",	"*lOefn"	; 40
	"wtlo",	"*OgrpOmsk"	; 42
	"spnd",	""		; 44
	"rsum",	"Ntsk"		; 46
	"wsig",	"!%"		; 48
	"exit",	""		; 50
	"exif",	"lOefn"		; 52
	"crrg",	""		; 54
	"atrg",	""		; 56
	"dtrg",	""		; 58
	"gtim",	"Obuf"		; 60
	"gtsk",	"Obuf"		; 62
	"gprt",	"Oprt,Obuf"	; 64 ??
	"gcom",	""		; 66	
	"sref",	""		; 68
	"sdat",	""		; 70
	"sdrq",	""		; 72	
	"rcvd",	"Ttsk,Obuf"	; 74 ??
	"rcvx",	"Ttsk,Obuf"	; 76 ??
	"rcvs",	""		; 78	
	"rref",	""		; 80
	"abrt",	"Ntsk"		; 82
	"fix",	""		; 84	
	"ufix",	""		; 86	
	"extk",	".pgs"		; 88
	"dsbl",	""		; 90
	"enbl",	""		; 92
	"dscp",	""		; 94
	"encp",	""		; 96
	"dsar",	"!%"		; 98
	"enar",	"!%"		; 100
	"svdb",	""		; 102
	"svtk",	"AadrOlen"	; 104
	"srda",	""		; 106
	"spra",	""		; 108
	"sfpa",	""		; 110
	"gmcx",	""		; 112
	"astx",	"!%"		; 114
	"craw",	""		; 116
	"elaw",	""		; 118
	"map",	""		; 120
	"umap", ""		; 122
	"gssw",	""		; 124
	"gmcr",	"Abuf!"		; 126?rp.p5
	"cint",	""		; 128
	"stop",	""		; 130
	"ustp",	""		; 132
	"stse",	"lOefn"		; 134
	"stlo",	"OgrpOmsk"	; 136
	"rcst",	""		; 138
	"sdrc",	""		; 140
	"cnct",	""		; 142
	"elep",	""		; 144	
	"emst",	""		; 146
	"crvt",	""		; 148
	"elvt",	""		; 150
	"srfr",	""		; 152
	"scal",	""		; 154	
	"crgf",	""		; 156	
	"elgf",	""		; 158	
	"staf",	""		; 160	
	"rmaf",	""		; 162
	"spea",	""		; 164
	"srea",	"Aast"		; 166
	"gin",	""		; 168
	"smsg",	""		; 170
	"cli",	""		; 172
	"swst",	""		; 174
	"feat",	""		; 176
	"dic",	""		; 178
	"dic",	""		; 180
	"dic",	""		; 182
	"dic",	""		; 184
	"dic",	""		; 186
	"dic",	""		; 188
	"dic",	""		; 190
	"dic",	""		; 192
	"dic",	""		; 194
	"dic",	""		; 196
	"dic",	""		; 198
	"msds",	""		; 200
	"mvts",	""		; 202
	"cpcr",	""		; 204
	"name",	""		; 206
	"anon",	""		; unknown
  end
	rsEMX := 208
data	rsAfun - QIO functions

	ioFNA := 011
	ioRNA := 013

  type	rsTfun
  is	Pnam : * char
	Vflg : int
  end
	rsNAM_ := 1
	rsFID_ := 2
	rsALL_ := 4

  init	rsAfun : [] rsTfun
  is	"kil", 0		; 0	kill current i/o request
	"wlb", rsALL_		; 1	write logical block
	"rlb", rsALL_		; 2	read logical block
	"att", rsALL_		; 3	attach device
	"det", rsALL_		; 4	detach device
	"fn5", 0	;mnt	; 5	set on vms	
	"fn6", 0	;dsm	; 6	
	"fn7", 0	;clu	; 7	
	"fn8", 0		; 10	diagnostics
	"fna", rsNAM_		; 11	find name in directory
	"ulk", 0		; 12	unlock block - file primitive
	"rna", rsNAM_		; 13	remove file name from directory
	"ena", rsNAM_		; 14	enter file name in directory
	"acr", rsFID_		; 15	access file for read
	"acw", rsFID_		; 16	access file for read/write
	"ace", rsFID_		; 17	access for read/write/extend
	"dac", rsFID_		; 20	deaccess
	"rvb", rsALL_		; 21	read virtual block
	"wvb", rsALL_		; 22	write virtual block
	"ext", rsFID_		; 23	extend file
	"cre", rsFID_		; 24	create file
	"del", rsFID_		; 25	delete file
	"rat", rsFID_		; 26	read attributes
	"wat", rsFID_		; 27	write attributes
	"apc", 0		; 30	acp control (RSX11D only)
	"apv", 0		; 31	privileged acp control
  end
	rsFUN := 32		; maximum
code	trace RSX emt

  proc	rs_emt
	adr : elTwrd
	cod : elTwrd		; unused here
  is	dir : rsTdir		;
	emt : * rsTemt		; emt entry
	par : * elTwrd = dir.Apar
	ptr : elTwrd
	dic : elTwrd
	cnt : int
	idx : int = 0

	exit if (OP & 0377) ne 0377 ; ignore other EMTs
	dir.Vadr = adr		; EMT address (+2)
	dir.Vpsw = PS		;

	ptr = SP		; assume data on stack
	dic = el_fwd (ptr)	; get the dic/cnt
	if !(dic & 1)		; not on the stack
	   ptr = dic		; go indirect
	.. dic = el_fwd (ptr)	; go indirect
	dir.Vdir = ptr		; va of emt parameter block

	cnt = (dic>>8) & 0377	; count
	dic = (dic & 0376)	; isolate EMT code
	cnt = rsCNX if cnt gt rsCNX
	dic = rsEMX if dic gt rsEMX
	dir.Vcnt = cnt		;
	dir.Vdic = dic		;
				;
	while idx le cnt	; copy primary parameters
	   par[idx++] = el_fwd (ptr);
	   ptr += 2		; point at next
	end			;

	dir.Pemt = &rsAemt[dic/2]; get the code
				;
	exit if !rs_flt (&dir)	; filter it
	rs_dis (&dir)		; display it
  end
code	display emt

  func	rs_dis
	dir : * rsTdir
  is	par : * elTwrd = dir->Apar
	emt : * rsTemt = dir->Pemt
	arg : * char = emt->Parg
	fun : * rsTfun = <>
	nam : [6] char
	cnt : int = dir->Vcnt		; parameter count
	idx : int = 0
	val : int
	typ : int
	nln : int = 0			; newline pending
	cmd : [mxLIN] char
	cpt : elTwrd
	spn : int = 0

	el_sol ()			; force start-of-line
	PUT("%o%s\t",dir->Vadr,el_mod(dir->Vpsw)) ; address
	if elVall			; 
	.. PUT("%o\t", dir->Vdir&0xffff); display parameter block address
;	PUT("%o:%d.\t", dir->Vdic, dir->Vcnt)
	if st_sam (emt->Pnam, "rqst")
	   spn = (cnt eq 7) ? 0 ?? 1
	   PUT("%s\t", spn ? "rqst" ?? "spwn")
	else
	.. PUT("%s\t", emt->Pnam)

      while ++idx lt cnt		; walk through args
	if *arg eq '!'
	   quit if idx ne 1
	.. ++arg
	++arg if *arg eq '*'		; ignore filtering here
	++arg, ++nln if *arg eq '|'	;
	++par if *arg ne '-'		; skip to next parameter
	--idx, ++arg otherwise			;
					;
	if !*arg			; 					; no more named arguments
	   if *par&0xffff		;
	      PUT("\n\t\t\t"), nln=0 if nln
	   .. PUT("p%d=%o ",idx,*par&0xffff); display rest as "pn=octal"
	.. next				;
					;
	next ++arg if *arg eq ','	; skip parameter
	quit if *arg eq '!'		; that's all folks
					; "OstsDdev..."
	typ = *arg++			; get type character
	val = *par & 0xffff		;
	case typ
	of 'h'  val = (val>>8)&0xff	; high byte
	or 'l'  val = val &0xff		; low byte
		typ = *arg++		;
	end case			;

	me_cop (arg, nam, 3)		; get the 3-character name
	arg +=3, nam[3]=0		;
					;
	++arg if *arg eq '0'	; skip null parameters
;	next if (*par eq) && (idx gt 1)
	next if !val && (idx gt 1)
	PUT("\n\t\t\t"), nln=0 if nln
					;
	PUT("%s=", nam+1) if *nam eq ' '; display name
	PUT("%s=", nam)	  otherwise	; display name
	case typ			;
	of 'O'  PUT("%o ", val)		; octal
	of '.'  PUT("%d ", val)		; decimal
	of 'A'  PUT("%o ", (dir->Vdir+(idx*2))&0xffff) ; in-line buffer 
	of 'D'  me_cop(par, nam, 2)	; copy device name
		nam[2] = 0		; terminate string
		PUT("[%s", nam)	; display it
		val = par[1] & 0377	; get unit
		PUT("%d", val) if val
		PUT("] ")
		++par, ++idx		; skip next parameter
	of 'Q'  PUT("%o=", val)		; QIO
		if val ge rsFUN		; invalid
		   PUT("(???) ")
		else			;
		   fun = &rsAfun[val]	; get the I/O function
		.. PUT("(%s) ", fun->Pnam)
	of 'T'	rt_unp (par, nam, 2)	;
		PUT("%s ", nam)		;
	of 'U'	PUT("[%o,%o] ", (val>>8)&0xff, val&0xff) ; UIC
	of other 
	        PUT("%o ", *par&0xffff)
	end case
      end	
	rs_nam (dir) if fun && (fun->Vflg & rsNAM_)
	rs_spn (dir) if spn
	el_new ()
;;;	if dir->Vdic/2 eq 2
;;;	   PUT("dc0=%o\n", dir->Apar[2]+4)
;;;	.. bg_bpt (PC, PS)
  end
code	rs_flt - filter emts

  func	rs_flt
	dir : * rsTdir
  is	par : * elTwrd = dir->Apar
	emt : * rsTemt = dir->Pemt
	arg : * char = emt->Parg
	fun : * rsTfun = <>
	val : int

	fine if elVall eq 2

	if *arg eq 'h'
	&& par[0] eq 023		; qio extend
	.. fine

	if *arg eq 'h'			; qio
	&& par[7] eq 1			; count=1
	.. fail

	fail if *arg eq '!'
	fine if elVall			; want all
	fail if *arg eq '*'		; only if all
	fail if *arg eq '%'		; only if all
	fine if *arg++ ne 'h'
	fine if *arg++ ne 'Q'

	val = (dir->Apar[1]>>8)&0xffff
	fine if ge rsFUN		; invalid
	fun = &rsAfun[val]		; get the I/O function
	fail if fun->Vflg & rsALL_	;
	fine
  end
code	rs_nam - decode nam block

  type	rsTfid
  is	Vidx : elTwrd			; file index
	Vseq : elTwrd			; sequence
	Vres : elTwrd			; reserved
  end

  type	rsTnam
  is	Ifid : rsTfid			; file id
	Anam : [3] elTwrd		; rad50 name
	Atyp : [1] elTwrd		; rad50 type
	Aver : elTwrd			; version
	Vsta : elTwrd			; status word
	Vnxt : elTwrd			; Wildcard .FIND context
	Idid : rsTfid			; directory id
	Adev : [2] char			; ascii device name
	Vuni : elTwrd			; device unit
  end

  func	rs_nam
	dir : * rsTdir
  is	nam : rsTnam
	str : [32] char
	el_fmm (dir->Apar[11], &nam, #rsTnam)
;	PUT("\n\t\t\tnam=[")
	PUT("nam=[")
	if nam.Adev[0]		; have device
	.. PUT("%c%c%d:", nam.Adev[0],nam.Adev[1], nam.Vuni)
	if nam.Anam[0]
	   rt_unp (nam.Anam, str, 3)
	   PUT("%s.", str)
	   rt_unp (nam.Atyp, str, 1)
	   PUT("%s", str)
	end
	PUT("] ")
	PUT("fid=%o/%o did=%o/%o ",
	nam.Ifid.Vidx,nam.Ifid.Vseq,
	nam.Idid.Vidx,nam.Idid.Vseq)
  end
code	rs_spn - display spawn command

  func	rs_spn
	dir : * rsTdir
  is	nam : rsTnam
	lin : [mxLIN] char
	len : int = dir->Apar[11]
	PUT("\n\t\t\t")
	len = (len lt mxLIN-1) ? len ?? (mxLIN-1)
	el_fmm (dir->Apar[10], lin, len)
	lin[len] = 0
  	PUT("cmd=[%s]", lin)
  end
