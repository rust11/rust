;	Accesses @#42, @#46
;	TRAPS, MMU, EMT vector
;	Low memory
file	extyp - expat xxdp commands
include rid:rider	; Rider/C header
include	rid:cldef
include	rid:dcdef
include rid:fidef	; files
include rid:mxdef	; maximums
include rid:tidef	; time
include rid:medef	; memory
include	rid:vfdef	; VF virtual file system
If Win			; Windows
include rid:stdef	; strings (stdef exhausts DECUS-C memory)
End
include	exb:exmod

	cf_xdp : cxTfun-
	cu_dsc : (*char, *char)- int
	cu_idx : ()-
	cuAfnd : [mxLIN] char-

  type	cuTxdp
  is	Hidx : * FILE		; index file handle
	Vxnf : int		; index not found dflag
	Afnd : [mxLIN] char	; search string
  end

	xdp : cuTxdp = {0}

	DIS(fmt,str) := fprintf (opt,fmt,str) ; display value
	DS2(fmt,s1,s2) := fprintf (opt,fmt,s1,s2)
	DS3(fmt,s1,s2,s3) := fprintf (opt,fmt,s1,s2,s3)
	TYP(fmt)     := fprintf (opt,fmt)     ; type string
	LIN	     := TYP("\n")	      ; newline	
;	lda.Vzer and lda.Vval
;	MMU test is weak
code	ld_anl - LDA analysis machine

;	PDP-11 absolute loader (LDA) formatted binary decoder.
;
;	The LDA format originated with PDP-11 papertape software. The
;	LDA format is used for DOS11 and XXDP executables.
;
;	This implementation supports the standard implementation with
;	an XXDP extension that accepts and ignores 5-byte headers.
;
;	Search for <call (r0)><nop><nop><nop>

data	Machine memory

  type	ldTlda
  is	Pobj : * vfTobj
	Plow : * byte
	Pmsg : * char		; error message
	Verr : int		; error seen
	Vcnt : LONG		;
				;
	Vlda : int		; is an LDA file
	Vval : WORD		; valid LDA file
	Vzer : WORD		; leading zeroes count

	Vadr : WORD		; detect /passes co-routine
	Vnxt : WORD		; next address
	Vwrd : WORD		; word at Vadr
	Vpas : WORD		; /pass address

	Vchk : WORD		; computed checksum
	Vlow : WORD		; lowest address seen
	Vhgh : WORD		; highest seen
	Vsta : WORD		; start address

	V46x : WORD		; 000046: .word
	V52x : WORD		; 000052: .word
	V200 : WORD		; 000200: .word
	V202 : WORD		; 000202: .word
	V210 : WORD		; 000210: .word

	Vemt : int		; number of emt codes seen
	Veml : int		; emt last
	Vems : int		; emt sequential
	Vspn : int		; EMT spin loop

	Vtrp : int		; number of trap codes seen
	Vtrl : int		; trap last
	Vtrs : int		; trap sequential

	Vmmu : int		; MMU accesses

	Vpad : WORD		; previous address
	Vpvl : WORD		; previous value

;	summary of all files

	Vrec : WORD		; longest record
	Vtop : WORD		; toppermost address
	Pnam : * char		; name of current file
	Atop : [mxSPC] char	; spec of longest
  end

  init	lda : ldTlda

	LOW(off) := low[off/2]

data	Machine instructions

	BYT := ld_byt ()
	WRD := ld_wrd ()
	ERR := lda.Verr
	CHK := lda.Vchk
	MSG(msg) := lda.Pmsg = msg

code	ld_anl - LDA analysis engine

	ld_byt : ()-
	ld_wrd : ()-
	ld_det : (WORD, BYTE)-		; detection

  func	ld_ini
  is	lda.Plow = me_acc (512*3) if !lda.Plow
  end

  func	ld_exi
  is	me_dlc (lda.Plow)
  end

  func	ld_anl
	obj : * vfTobj
	nam : * char
  is	adr : WORD~
	val : BYTE
	len : int
	low : * WORD = <*WORD>lda.Plow

	++lda.Vcnt
	me_clr (low, 512*3)

	lda.Pobj = obj			; our pointer
	lda.Vval = 0			; not a valid file yet
	lda.Vlda = 0			; at least one valid record seen

	lda.Pnam = nam			; current file spec
	lda.Vlow = 0177777		; highest low 
	lda.Vhgh = 0			; lowest high
	lda.Vsta = 0			; image start, 0=>.cnf

	lda.Vadr = 0
	lda.Vpad = 0
	lda.Vpvl = 0

	lda.Vpas = 0
	lda.Vemt = 0
	lda.Veml = 0
	lda.Vems = 0
	lda.Vtrp = 0
	lda.Vtrl = 0
	lda.Vtrs = 0
	lda.Vspn = 0
	lda.Vmmu = 0

      repeat
	MSG("Error reading file")	   
	ERR = 0				; no errors yet
	lda.Vzer = 2			; number of zeroes
	repeat
	   fail if ERR			; oops
	   CHK = 0			; no checksum yet
					;
	   val = BYT			; looking for 1,0
	   --lda.Vzer if !val		; more than two zeroes?
	   fine if !lda.Vzer		; yes - we're into blank space

	   fail if val gt 1		; any non-zero must be 1
	   next if val ne 1		; waiting for unity
	   fail if BYT ne 0		;
					;
	   len = WRD & 0177777		; length
	   adr = WRD			; address

	   lda.Vrec = MAX(len, lda.Vrec); remember max record length

	   fail if ERR			; error detected 
	   fail if len lt 5		; invalid record 
					; maximum???
					;
	   len -= 6			; shave off header length
	   quit lda.Vsta = adr if eq	; transfer record
					;
	   while len-- gt		; parse the record data
	      val = BYT			; next byte
	      fail if ERR		; buffer first three blocks
	      ld_det (adr, val)		; go detect things
	      ++adr			;
	   end				;

	   BYT				; get checksum byte
	   fail if ERR			; I/O failed
					;
	   MSG("Checksum error")	; next error
	   if !CHK & 255		;
	      fail if st_fnd(".bi", nam); .bi? always fail
	      fine if !lda.Vval		; 
	   .. fail			;
	   ++lda.Vlda			; has LDA records
	   ++lda.Vval			;
	end

;	end of file

	++lda.Vhgh if lda.Vhgh & 1	; round up high addresses
	++lda.Vtop if lda.Vtop & 1	;
	lda.V46x = LOW(046)
	lda.V52x = LOW(052)
	lda.V200 = LOW(0200)
	lda.V202 = LOW(0202)
	lda.V210 = LOW(02100)
 	fine
     end
  end

code	ld_det - detect XXDP /passes routine

  func	ld_det
	ptr : WORD
	byt : BYTE
  is	low : * WORD~ = <*WORD>lda.Plow
	adr : WORD~
	val : WORD~
	cod : WORD

	lda.Plow[ptr] = byt if ptr lt 03000
	lda.Vlow = MIN(ptr, lda.Vlow)
	lda.Vhgh = MAX(ptr, lda.Vhgh)
	if ptr gt lda.Vtop
	   lda.Vtop = ptr
	.. st_cop (lda.Pnam, lda.Atop)
	 
	if !(ptr & 1)
	   lda.Vadr = ptr
	   lda.Vnxt = ptr + 1
	   lda.Vwrd = byt & 255
	.. exit

	adr = lda.Vadr
	val = lda.Vwrd | (byt&255)<<8
	if val eq 0104035 && adr ne 02100
	.. PUT("%o	%o	; LoaSup\n", adr, val)

	exit if ptr ne lda.Vnxt

	if (adr gt 046) && adr eq LOW(046)
	&& (val & ~7) eq 04710
	.. lda.Vpas = adr

	cod = val & 255
	if (val & ~255) eq 0104000
	   ++lda.Vemt if cod lt 50
	   ++lda.Vems if cod eq lda.Veml+1
	   lda.Veml = cod
	   if ctl.Qemt
	   .. PUT("%-6o:%-6o\n", adr, val)
	.. ++lda.Vspn if adr eq LOW(030)

	if (val & ~255) eq 0104400
	   ++lda.Vtrp
	   ++lda.Vtrs if cod eq lda.Vtrl+1
	.. lda.Vtrl = cod

	if lda.Vpad eq adr-2
	&& lda.Vpvl eq 0005037
	&& val eq 0177572
	.. ++lda.Vmmu

	lda.Vpad = adr		; remember previous address
	lda.Vpvl = val
  end

code	ld_wrd - get a word

  func	ld_wrd
  is	wrd : WORD
	byt : * byte~ = <*byte>&wrd
	*byt++ = BYT
	*byt++ = BYT
	reply wrd
  end


code	ld_byt - get a byte

;	supplies a stream of zeroes at EOF

  func	ld_byt
  is	val : WORD~
	fail if ERR
	val = vf_get (lda.Pobj)
	fail ++ERR if val eq 0177777
	val &= 255
	CHK += val
	reply val
  end
code	cm_xdp - XXDP analytic directory

	cuVlin : int-

  func	cm_xdp
	dcl : * dcTdcl
  is	fnd : * char = xdp.Afnd
	ld_ini ()

	*fnd = 0
	if ctl.Asch[0]			; doing a search
	   st_cop (ctl.Asch, fnd)	; get a copy
	   st_upr (fnd)
	   st_ins ("*", fnd)
	   st_app ("*", fnd)
PUT("fnd=[%s]\n", fnd)
	end

	cuVlin = ctl.Qpau ? 0 ?? -1	; /PAUSE? (-1 => no to cl_mor)

	cx_dis (dcl, &cf_xdp)		; do the files

	if ctl.Qana
	   PUT("Highest address: %s %o\n", lda.Atop, lda.Vtop)
	.. PUT("Longest record: %d bytes\n", lda.Vrec)

	if lda.Vcnt ne
	.. PUT("%d files\n", lda.Vcnt)

	ld_exi ()
  end

  func	cf_xdp
	src : * vfTobj
	ent : * vfTent
  is	opt : * FILE = ctl.Hopt
 	fmt : [mxSPC+3] char		; formatted spec
	dsc : [mxLIN] char
	fnd : * char = xdp.Afnd
	drs : int
	pas : int
	xmx : int
	dsp : int = 1

	fine if !cu_pau (<>,&cuVlin)	; ask for more, perhaps

	cu_fmt (ent->Anam, fmt)		; format file spec
	if !cu_dsc (ent->Anam, dsc)	; get the description
	.. fine if *fnd ;&& !dsc[0]	; doesn't match
	DIS("%13s ", fmt)		; display file name
	if dsc[0];cu_dsc (ent->Anam, dsc)	; get the description
	   TYP(" ") if dsc[0] ne '*'
	.. DIS("%s", dsc)
	LIN
	fine

	if !ld_anl (src, ent->Anam)	; some error
	&& lda.Vval			; valid structure seen
	.. DIS("%s\n", lda.Pmsg)	; error message

	if !ctl.Qana			; not /analyse
	   if !cu_dsc (ent->Anam, dsc)	; get the description
	   .. fine if *fnd ;&& !dsc[0]	; doesn't match
	end

	drs = lda.V210 eq 0104035	; seen DRS	
	pas = lda.Vpas			; seen /PASS
	xmx = lda.V52x & 010000		; XM image

	if !(ctl.Qpas|ctl.Qdrs|ctl.Qxmx); not selecting
	|| ctl.Qpas && pas		; want /pass, got /pass
	|| ctl.Qdrs && drs		; want drs, got drs
	|| ctl.Qxmx && xmx		; want drs, got drs
	else
	.. fine

	cu_fmt (ent->Anam, fmt)		; format file spec
	DIS("%13s ", fmt)		; display file name

	TYP(drs ? "D" ?? "-")
	TYP(pas ? "P" ?? "-")
	TYP(xmx ? "X" ?? "-")
	TYP(" ")

	if !ctl.Qana			; not /analyse
	   if dsc[0]
	      TYP(" ") if dsc[0] ne '*'
	   .. DIS("%s", dsc)
	   LIN
	   fine
	end

	DS3("%06o:%06o %06o ", lda.Vlow, lda.Vhgh, lda.Vsta)
;	DIS("(46: %06o)", lda.V46x)
	DIS("(52: %06o)", lda.V52x)
;	DS2("(200: %06o %06o)", lda.V200, lda.V202)
	DIS("(200: %06o)", lda.V200)
	TYP(" ")

	TYP("S") if lda.Vspn
	DIS("E=%-4d", lda.Vemt) if lda.Vemt
;	DIS("/%-4d", lda.Vems) if lda.Vems
	TYP(" ") if lda.Vemt

	DIS("T=%-4d", lda.Vtrp) if lda.Vtrp
;	DIS("/%-4d", lda.Vtrs) if lda.Vtrs
	TYP(" ") if lda.Vtrp

	DIS("M=%-4d ", lda.Vmmu) if lda.Vmmu

	LIN
	fine
  end
code	cu_dsc - get an XXDP image description


  func	cu_dsc
	str : * char
	dsc : * char
  is	fnd : * char = xdp.Afnd
	mod : [mxLIN] char
	lin : [mxLIN] char
	ptr : * char
	len : int

	st_cop (str, mod)
	st_upr (mod)
	mod[4] = 0
	*dsc = 0
;PUT("mod=[%s]\n", mod)

	fail if !cu_idx ()		; open index file
	fi_see (xdp.Hidx, 0L)		; rewind the index

	repeat
;PUT("lin=[%s]\n", lin)
	   len = fi_get (xdp.Hidx, lin, mxLIN-1)
	   fail if eq EOF
	   next if len lt 10
	   quit if me_cmp (mod, lin, 4)
	end

	ptr = st_fnd (" ", lin)
	fail if eq
	st_cop (ptr+1, dsc)

	fine if !*fnd
;PUT("fnd=[%s] dsc=[%s]\n", fnd, dsc)
	reply st_wld (fnd, dsc)
  end

code	cu_idx - open XINDEX.TXT

  func	cu_idx
  is	spc : [mxSPC] char		;
	fine if xdp.Hidx ne		; already found it
	fail if xdp.Vxnf		; already displayed message
	cl_dir (spc)			; get image device spec
	st_app ("xindex.txt", spc)	; "dev:xindex.txt"
	xdp.Hidx = fi_opn (spc, "r", ""); open
	pass fine			;
	fail ++xdp.Vxnf			; index not found flag
  end
end file
code	cu_fnd - find XXDP diagnostics

	idx : * FILE = <>

  func	cu_fnd
	str : * char
	dsc : * char
  is	mod : [mxLIN] char
	lin : [mxLIN] char
	spc : [mxSPC] char
	ptr : * char
	len : int

	fail if !cu_idx ()

	st_cop (str, mod)
	st_upr (mod)
	st_ins ("*", mod)
	st_app ("*", mod)

	fi_see (idx, 0L)
	repeat
	   len = fi_get (idx, lin, mxLIN-1)
	   fail if len eq EOF
	   next if len lt 15
	   ptr = st_fnd (" ", lin)
	   next if eq
	   ++ptr
	   next if !me_cmp (mod, ptr, 4)
	end
	   ptr = st_fnd (" ", ptr)
	   fail if eq
	   st_cop (ptr, dsc)
	   fine
  end

