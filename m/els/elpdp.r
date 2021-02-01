file	elpdp - PDP-11 engine
include	elb:elmod

;	o  RT-11/SJ and RSX need delays before interrupt are delivered.
;	o  11/03 does not have odd adress trap or PSW.
;	o  JMP R0	usually invalid.
;	o  JMP (R0)+    r0 may be advanced before jump
;	o  MOVB (SP)+   SP always increments by two
;	o  MOVB (PC)+   PC always increments by two
;	o  MFPS Rx	Sign extends to high register
;
;	Bus/MMU errors:
;
;	The emulator executes most instructions fully regardless of errors
;	Data is not stored if a MMU error occurs
;	Exceptions are issued after the instruction completes
;	The system is not perfect but seems to be good enough
	elVchk : int = 0

  func	el_chk
  is	elVchk = 0 if !elVsch
	++elVchk otherwise
	exit if elVchk lt 100
	PUT(".")
	elVchk = 0
  end

code	el_dis - instruction dispatch loop

ddd : int = 0

  type	elTdis : [] * elTfun
	elAxx____ : elTdis
	elA00xx__ : elTdis
	elA0000xx : elTdis
	elA0002xx : elTdis
	elA07xx__ : elTdis
	elA10xx__ : elTdis

; NOTE: Rebuild the "fast" versions after any substantial
; edits to el_dis.

	el_fst : () void		; fast mode
	wat := bgIwat

  proc	el_dis
  is	tbt : int 
 	el_fst () if !elVdbg		; not in debug mode
;	el_pri (0)			; low priority
  repeat
    repeat
	tbt = TBIT			; remember trace
	el_pol () if elVsch
	next PC += 2, INVADR(22) if PC & 1 ; odd address trap
      if !bgVfst			; in debug mode
	if SP lt bgVund			; stack underflow
	   if !bgVred			; once only
	   && (PS & 0360) ne 0340	; and interruptable
	   .. ++bgVred, el_dbg ("Stack"); (0360 catches tbit)
	else				; very expensive
	.. bgVred = 0			; out of red zone

	if ((wat.Venb&&wat.Vflg) && (*wat.Padr eq wat.Vmat))
	|| ((wat.Venb&&!wat.Vflg) && (*wat.Padr ne wat.Vval))
	   bgIwat.Vval = *bgIwat.Padr	;
	   el_dbg ("Watch")		;
	elif bgVfel			;
	   bgVfel = 0			;
	   el_dbg ("Felt")		;
	elif bgIbpt.Venb && SNAP(bgIbpt,PC,PS)
	   bgVstp = 0			;
	   el_dbg ("Break")		; note precedence over step(over)
	elif bgVovr && (PC eq bgVovp)	; step over
	   el_dbg ("over")		;
	elif bgVstp			; stepping
	   if --bgVstp eq
	   .. el_dbg ("step")		;
	elif bgVcnt eq 1		; counting
	   el_dbg ("Count")		;
	elif bgVcth			; ctrl/h seen by terminal
	   bgVcth = 0			; once only
	   el_dbg ("Console")		;
	else				;
	   ++bgVict			; count instruction
	.. --bgVcnt if bgVcnt		;
	hi_put ()			; store instruction
      end				;
	elVcur = PC			;
	OP = el_fwd (PC) 		; get the instruction
	PC += 2 			; skip it
	if !(elVsch & elABT_)		; 
	.. (elAxx____[(OP >> 12) & 0xf])() ; do it
	bgVprv = elVcur			; update it
	el_trp (veTRC) if tbt		;
     forever
   end
  end

code	el_fst - fast mode

;	Keyboard interrupts are handled by XXXXXX

  proc	el_fst
  is
      repeat
;el_chk ()
	el_pol () if elVsch
	elVcur = PC			; need this for MMU
	OP = el_fwd (PC)		;
	PC += 2 			; skip it
	if !(elVsch & elABT_)		; 
	.. (elAxx____[(OP >> 12) & 0xf])() ; do it
      forever
  end

code	instruction dispatchers

  proc	el_00xx__
  is	(elA00xx__[(OP >> 6) & 077])()
  end

  proc	el_0000xx
  is	(elA0000xx[OP & 077])()
  end

  proc	el_0002xx
  is	(elA0002xx[OP & 077])()
  end

  proc	el_07xx__
  is	(elA07xx__[(OP >> 6) & 077])()
  end

  proc	el_10xx__
  is	(elA10xx__[(OP >> 6) & 077])()
  end
code	el_swa - get source word address

;	Decode PDP-11 addresses
;
;	Autoincrement and autodecrement handled locally.
;	These only apply to registers which have a fixed address anyway.
;
;	An address value that can overflow needs to be truncated
;	when being stored in elV?wa or being passed to a fetch routine.

  proc	el_swa
  is	reg : LONG = (OP >> 6) & 7
	mod : LONG = (OP >> 9) & 7
	idx : LONG
	tmp : LONG = elPreg[reg]		; WORD
	case mod
	of 0  elVswa = elREG + (reg * 2)	; stores extended address
	of 1  elVswa = tmp
	of 2  elVswa = tmp
	      elPreg[reg] = (tmp + 2)
	of 3  elPreg[reg] = (tmp + 2)
	      elVswa = el_fwd (tmp)
	of 4  elPreg[reg] = elVswa = (tmp - 2) & elWRD_	
	of 5  elPreg[reg] = tmp - 2
	      elVswa = el_fwd ((tmp - 2) & elWRD_)
	of 6  idx = el_fpc ()
	      elVswa = (elPreg[reg] + idx) & elWRD_
	of 7  idx = el_fpc ()
	      elVswa = el_fwd ((elPreg[reg] + idx) & elWRD_)
	end case
  end

code	el_dwa - get destination word address

  proc	el_dwa
  is	reg : LONG = OP & 7
	mod : LONG = (OP >> 3) & 7
	idx : LONG
	tmp : LONG = elPreg[reg]
	case mod
	of 0  elVdwa = elREG + (reg * 2)
	of 1  elVdwa = tmp
	of 2  elVdwa = tmp
	      elPreg[reg] = (tmp + 2) 
	of 3  elPreg[reg] = (tmp + 2)
	      elVdwa = el_fwd (tmp)
	of 4  elPreg[reg] = elVdwa = (tmp - 2)  & elWRD_
	of 5  elPreg[reg] = tmp - 2
	      elVdwa = el_fwd ((tmp - 2) & elWRD_)
	of 6  idx = el_fpc ()
	      elVdwa = (elPreg[reg] + idx) & elWRD_
	of 7  idx = el_fpc ()
	      elVdwa = el_fwd ((elPreg[reg] + idx) & elWRD_)
	end case
  end

code	el_sba - get source byte address

;	SP and PC always inc/dec by word

  proc	el_sba
  is	reg : LONG = (OP >> 6) & 7
	mod : LONG = (OP >> 9) & 7
	stp : LONG = (reg lt 6) ? 1 ?? 2	; force word inc/dec
	idx : LONG
	tmp : LONG = elPreg[reg]
	case mod
	of 0  elVsba = elREG + (reg * 2)
	of 1  elVsba = tmp
	of 2  elVsba = tmp
	      elPreg[reg] = (tmp + stp) 
	of 3  elPreg[reg] = (tmp + 2)
	      elVsba = el_fwd (tmp)
	of 4  elPreg[reg] = elVsba = (tmp - stp) & elWRD_
	of 5  elPreg[reg] = tmp - 2
	      elVsba = el_fwd ((tmp - 2) & elWRD_)
	of 6  idx = el_fpc ()
	      elVsba = (elPreg[reg] + idx) & elWRD_
	of 7  idx = el_fpc ()
	      elVsba = el_fwd ((elPreg[reg] + idx) & elWRD_)
	end case
  end

  proc	el_dba
  is	reg : LONG = OP & 7
	mod : LONG = (OP >> 3) & 7
	stp : LONG = (reg lt 6) ? 1 ?? 2
	idx : LONG
	tmp : LONG = elPreg[reg]
	case mod
	of 0  elVdba = elREG + (reg * 2)
	of 1  elVdba = tmp
	of 2  elVdba = tmp
	      elPreg[reg] = (tmp + stp) 
	of 3  elPreg[reg] = (tmp + 2)
	      elVdba = el_fwd (tmp)
	of 4  elPreg[reg] = elVdba = (tmp - stp) & elWRD_
	of 5  elPreg[reg] = tmp - 2
	      elVdba = el_fwd ((tmp - 2) & elWRD_)
	of 6  idx = el_fpc ()
	      elVdba = (elPreg[reg] + idx) & elWRD_
	of 7  idx = el_fpc ()
	      elVdba = el_fwd ((elPreg[reg] + idx) & elWRD_)
	end case
  end

code	el_sra - get source register address

  proc	el_sra
  is	reg : elTwrd = (OP >> 6) & 7
 	elVswa = elREG + (reg * 2)
  end

  proc	el_dra
  is	reg : elTwrd = OP & 7
 	elVdwa = elREG + (reg * 2)
  end

code	el_fpc - fetch from pc

  func	el_fpc
	()  : elTwrd
  is	val : int	
	val = el_fwd (PC)
	PC += 2, PC &= 0177777		; skip it
	reply val & elWRD_
  end

code	el_psh - push stack

  proc	el_psh
	val : elTwrd
  is	el_dbg ("STK") if !SP
	SP -= 2
	el_swd (SP, val)
  end

code	el_pop - pop stack

  func	el_pop
	()  : elTwrd
  is	val : elTwrd
	val = el_fwd (SP)
	SP += 2
	reply val & elWRD_
  end

code	el_fmm - fetch memory block

  func	el_fmm
	adr : elTwrd
	dst : * void
	cnt : int
  is	ptr : * char =  dst
	while cnt--
	   *ptr++ = el_fbt (adr++)
	end
  end
code	PDP-11 instruction set

;	The basic PDP-11 instruction set is implemented using
;	a set of microcode-style macros. EIS etc is uglier.
;
;	SWF	Source Word Fetch
;	SWA	Source Word Address
;
;	S	Source
;	M	Mid
;	D	Destination
;	T	Temp
;
;	 B	Byte, Word, Long, Quad, Octa
;	  A	Address, Fetch, Store

  proc	el_movw
  is	.. SWF, DWA, CLV, RWNZ(SWV), DWS(SWV)
  proc	el_movb
  is	SBF, DBA, CLV, RBNZ(SBV), DBS(SBV)
	.. *DBH = ((SBV & 0x80) ? 0xff ?? 0) if REGMOD
  proc	el_cmpw
  is	SWF, DWF, TWV = SWV - DWV, CLV, RWNZ(TWV)
  	.. RXC(SWV lt DWV), RXV(0x8000 & ((SWV ^ DWV) & ((~DWV) ^ TWV)))
  proc	el_cmpb
  is	SBF, DBF, TBV = SBV - DBV, CLV, RBNZ(TBV)
  	.. RXC(SBV lt DBV), RXV(0x80 & ((SBV ^ DBV) & ((~DBV) ^ TBV)))
  proc	el_bitw
  is	.. SWF, DWF, TWV = DWV & SWV, CLV, RWNZ(TWV)
  proc	el_bitb
  is	.. SBF, DBF, TBV = DBV & SBV, CLV, RBNZ(TBV)
  proc	el_bicw
  is	.. SWF, DWF, TWV = DWV & (~SWV), CLV, RWNZ(TWV), TWS
  proc	el_bicb
  is	.. SBF, DBF, TBV = DBV & (~SBV), CLV, RBNZ(TBV), TBS
  proc	el_bisw
  is	.. SWF, DWF, TWV = DWV | SWV, CLV, RWNZ(TWV), TWS
  proc	el_bisb
  is	.. SBF, DBF, TBV = DBV | SBV, CLV, RBNZ(TBV), TBS
  proc	el_addw
  is	SWF, DWF, TWV = SWV + DWV, CLV, RWNZ(TWV)
  	.. RXC(TWV lt SWV), RXV(0x8000 & ((~SWV ^ DWV) & (SWV ^ TWV))), TWS
  proc	el_subw
  is	SWF, DWF, TWV = DWV - SWV, CLV, RWNZ(TWV)
  	.. RXC(DWV lt SWV), RXV(0x8000 & ((SWV ^ DWV) & (~SWV ^ TWV))), TWS
  proc	el_clrw
  is	.. DWA, CLC, CLV, CLN, SEZ, DWS(0)
  proc	el_clrb
  is	.. DBA, CLC, CLV, CLN, SEZ, DBS(0)
  proc	el_comw
  is	.. DWF, TWV = ~DWV, SEC, CLV, RWNZ(TWV), TWS
  proc	el_comb  ;note: pdp-11 does not complement high byte
  is	.. DBF, TBV = ~DBV, SEC, CLV, RBNZ(TBV), TBS
  proc	el_incw
  is	.. DWF, TWV = DWV+1, RXV(TWV eq 0x8000), RWNZ(TWV), TWS
  proc	el_incb
  is	.. DBF, TBV = DBV+1, RXV(TBV eq 0x80), RBNZ(TBV), TBS
  proc	el_decw
  is	.. DWF, TWV = DWV-1, RXV(TWV eq 077777), RWNZ(TWV), TWS
  proc	el_decb
  is	.. DBF, TBV = DBV-1, RXV(TBV eq 0177), RBNZ(TBV), TBS
  proc	el_negw	; V=1 if 0100000, C = !Z
  is	.. DWF, TWV = -DWV, RXV(TWV eq 0x8000), RWNZ(TWV), RXC(!ZBIT), TWS
  proc	el_negb
  is	.. DBF, TBV = -DBV, RXV(TBV eq 0x80), RBNZ(TBV), RXC(!ZBIT), TBS
  proc	el_adcw
  is	DWF, TWV = DWV + CBIT, RWNZ(TWV), RXV(CBIT && (TWV eq 0x8000))
	.. RXC(CBIT & ZBIT), TWS
  proc	el_adcb
  is	DBF, TBV = DBV + CBIT, RBNZ(TBV), RXV(CBIT && (TBV eq 0x80))
	.. RXC(CBIT & ZBIT), TBS
  proc	el_sbcw
  is	DWF, TWV = DWV - CBIT, RWNZ(TWV), RXV(CBIT && (TWV eq 077777))
	.. RXC(CBIT && (TWV eq 0177777)), TWS
  proc	el_sbcb
  is	DBF, TBV = DBV - CBIT, RBNZ(TBV), RXV(CBIT && (TBV eq 0177))
	.. RXC(CBIT && (TBV eq 0377)), TBS
  proc	el_tstw
  is	.. DWF, CLC, CLV, RWNZ(DWV)
  proc	el_tstb
  is	.. DBF, CLC, CLV, RBNZ(DBV)
  proc	el_rorw
  is	DWF, TWV = ((DWV >> 1) & 077777) | (CBIT << 15)
	.. RXC(DWV & 1), RWNZ(TWV), RXV(NBIT ^ CBIT), TWS
  proc	el_rorb
  is	DBF, TBV = ((DBV >> 1) & 0177) | (CBIT << 7)
	.. RXC(DBV & 1), RBNZ(TBV), RXV(NBIT ^ CBIT), TBS
  proc	el_rolw
  is	DWF, TWV = (DWV << 1) | CBIT, RXC(DWV & 0x8000)
	.. RWNZ(TWV), RXV(NBIT ^ CBIT), TWS
  proc	el_rolb
  is	DBF, TBV = (DBV << 1) | CBIT, RXC(DBV & 0x80)
	.. RBNZ(TBV), RXV(NBIT ^ CBIT), TBS
  proc	el_asrw
  is	DWF, TWV = ((DWV >> 1) & 077777) | (DWV & 0x8000)
	.. RXC(DWV & 1), RWNZ(TWV), RXV(NBIT ^ CBIT), TWS
  proc	el_asrb
  is	DBF, TBV = ((DBV >> 1) & 0177) | (DBV & 0x80)
	.. RXC(DBV & 1), RBNZ(TBV), RXV(NBIT ^ CBIT), TBS
  proc	el_aslw
  is	DWF, TWV = DWV << 1, RXC(DWV & 0x8000)
	.. RWNZ(TWV), RXV(NBIT ^ CBIT), TWS
  proc	el_aslb
  is	DBF, TBV = DBV << 1, RXC(DBV & 0x80)
	.. RBNZ(TBV), RXV(NBIT ^ CBIT), TBS
  proc	el_swab
  is	DWF, TWV = ((DWV>>8) & 0xff) | (DWV<<8), CLC, CLV
	.. RBNZ(TWV & 0xff), TWS
  proc	el_jsr
  is	exit (elFlsi ? INVINS ?? INVADR(15)) if REGMOD
	.. DWA, SRF, PSH(SWV), SWS(PC), PC = elVdwa
  proc	el_jmp
  is	exit (elFlsi ? INVINS ?? INVADR(16)) if REGMOD
	.. DWA, PC = elVdwa

  BRANCH := (PC += (OP & 0x80) ? ((OP|0xff00)*2) ?? ((OP&0xff)*2))
  proc	el_bra
  is	.. BRANCH
  proc	el_sob
  is	SRA, *SWP = *SWP - 1
	.. PC -= (OP & 077) * 2 if *SWP
  proc	el_bne
  is	.. BRANCH if !ZBIT
  proc	el_beq
  is	.. BRANCH if ZBIT
  proc	el_bge
  is	.. BRANCH if !(NBIT ^ VBIT)
  proc	el_blt
  is	.. BRANCH if (NBIT ^ VBIT)
  proc	el_bgt
  is	.. BRANCH if !(ZBIT | (NBIT ^ VBIT))
  proc	el_ble
  is	.. BRANCH if (ZBIT | (NBIT ^ VBIT))
  proc	el_bpl
  is	.. BRANCH if !NBIT
  proc	el_bmi
  is	.. BRANCH if NBIT
  proc	el_bhi
  is	.. BRANCH if !(CBIT | ZBIT)
  proc	el_blos
  is	.. BRANCH if (CBIT | ZBIT)
  proc	el_bvc
  is	.. BRANCH if !VBIT
  proc	el_bvs
  is	.. BRANCH if VBIT
  proc	el_bcc
  is	.. BRANCH if !CBIT
  proc	el_bcs
  is	.. BRANCH if CBIT
  proc	el_emt
  is	.. el_trp (veEMT)
  proc	el_trap
  is	.. el_trp (veTRP)

  proc	el_bpt
  is	.. el_trp (veBPT)
  proc	el_iot
  is	.. el_trp (veIOT)
  proc	el_reset
  is	.. el_rst ()
  proc	el_rts
  is	.. DRF, PC = DWV, DWS(POP)
  proc	el_ccc
  is	msk : elTwrd = OP & 017
  ..	PS &= (~msk)
  proc	el_scc
  is	msk : elTwrd = OP & 017
  ..	PS |= msk

  proc	el_xor
  is	.. SRF, DWF, TWV=SWV^DWV, CLV, RWNZ(TWV), DWS(TWV)
  proc	el_sxt
  is	.. DWA, TWV = ((NBIT) ? 0xffff ?? 0), CLV, RWZ(TWV), TWS
  proc	el_mark
  is	.. SP=PC+(OP&077)*2, PC=R5, R5=POP

  proc	el_tstset
  is	INVINS if elFlsi || REGMOD
  ..	DWF, R0=DWV, CLV, RWNZ(R0), DWS(R0)
  proc	el_wrtlck
  is	INVINS if elFlsi || REGMOD
  ..	DWA, CLV, RWNZ(R0), DWS(R0)
  proc	el_halt
  is	el_dbg ("\nHalt") if KERMOD || elVmai
	INVADR(17) otherwise
  end

  proc	el_wait
  is	exit if el_wai ()
	PC = PC - 2
  end	
code	psw

;	MTPS: User/Super modifies CCs. Kernel also modifies IPL.

  proc	el_mtps
  is	val : int
	DBF
	exit PS = (PS & ~0357) | (DBV & 0357) if KERMOD
	PS = (PS & ~017) | (DBV & 017)
  end

;	MFPS sign extends to word if register mode

  proc	el_mfps
  is	DBA, TBV=PS, CLV, RBNZ(TBV), DBS(TBV)
	.. *DBH = ((TBV & 0x80) ? 0xff ?? 0) if REGMOD

;	Kernel mode RTI/RTT modifies all PS states.
;	User/Super RTI/RTT ORs modes and register set
;	Note: NEWPS(x) :=(el_psw((x))) ;

  proc	el_rtt
  is	old : elTwrd = PS 
 	new : elTwrd
	PC = POP, new = POP
	new |= 0170000 if !KERMOD
	if new & elT_
	   elVsch |= elRTI_ if OP eq 2
	.. ;elVsch |= elRTT_ otherwise
	exit NEWPS(new) if elFlsi || KERMOD 
  ..	NEWPS ((new & ~(0340)) | (old & 0174340))

  proc	el_rti
  is	el_rtt ()
  end

  proc	el_spl
  is	INVINS if elFlsi
	exit if USPMOD		; kernel mode only
	NEWPS((PS & (~0x340)) | ((OP & 7) << 5))
  end

; ???	probably never tested

  proc	el_csm
  is	sp  : elTwrd
	ps  : elTwrd
	INVINS if elFlsi || !(MM3 & 010) || KERMOD
	DWF, elAstk[1] = SP, ps = PS
	NEWPS (040000 | (ps & 0140000>>2) | (ps & 07757)), MMU
	; We just swapped to supervisor mode
	PSH(ps&0340), PSH(PC), PSH(DWV)
	PC = el_fwd (010)
  end

;	LSIINS := (INVINS if elFlsi)
;	DST address calculated first (in CM), then PSH
;	PM stack accessed regardless of MMU state
;	otherwise accesses CM memory if MMU not enabled
;	No PSH or POP for DST bus errors
;
;	Use ordinary register for register other than SP
; ???	MFPI same as MFPD when CM and PM are both user.

  proc	el_mfpi
  is	INVINS if elFlsi
	CURPRV, DWA, CLV
	TWV=STK(PRV)  if REGMOD && ((OP&07) eq 6) && (CUR ne PRV)
	PRVMOD, DWG, CURMOD, TWV=DWV  otherwise
  ..  	PSH(TWV), CLV, RWNZ(TWV) if !ABT

  proc	el_mtpi
  is	INVINS if elFlsi
	CURPRV, DWA, TWV=TOP, CLV
	STK(PRV)=TWV  if REGMOD && ((OP&07) eq 6) && (CUR ne PRV)
	PRVMOD, DWS(TWV), CURMOD  otherwise
	CLV, RWNZ(TWV) if !ABT
  ..	POP if !ABT && ((CUR ne PRV) || ((OP&07) ne 6))

; ???	instruction/data space not implemented

  proc	el_mfpd
  is	.. el_mfpi ()
  proc	el_mtpd
  is	.. el_mtpi ()
 
  proc	el_mfpt
  is	INVINS if elFlsi
	R0 = 5			; j11 processor type
  end
code	eis, fis, fpu, cis

  proc	el_mul
  is	val : long
	exit INVINS if !elFeis
	SRF, DWF
	val = <long><word>SWV * <long><word>DWV
	CCC, RLNZ(val)
  	RXC((val ge (1<<15)-1) || (val lt -(1<<15)))
	*RP0 = val>>16, *RP1 = val
  end

  proc	el_div		;TLV = src=reg=SLV / src2=DWV; 
  is	val : long
	div : long
	quo : long
	rem : long
	exit INVINS if !elFeis
	SRA, DWF, CCC
	div = <word>DWV
	val = *RP0<<16 | (*RP1 & 0xffff)
	exit SEC, SEV if !div
	exit SEC, SEV if (val eq 0x80000000) && (div eq 0xffff)
	exit CLC, SEV if ABS(<word>*RP0) gt ABS(<word>div)
	quo = val / div
	rem = val - (quo * div)
	RLNZ(quo)
	*RP0 = quo, *RP1 = rem
  end

  proc	el_ash
  is	cnt : int
	val : long
	prv : int = 0
	exit INVINS if !elFeis
	SRF, DWF, CCC
	cnt = DWV & 077
	val = SWV
	val |= 0xffff0000 if val & 0x8000
	if cnt & 040
	   val >>= -(cnt | ~(077))-1
	   prv = val&1
	   val >>=1
	else
	   while --cnt ge
	      prv =   val & 0100000, val<<=1
	.. .. SEV if (val & 0100000) ne prv
	SEC if prv
	RWNZ(val & 0xffff), SWS(val)
  end

  proc	el_ashc
  is	cnt : int
	val : long
	prv : long = 0
	exit INVINS if !elFeis
	SRA, DWF, CCC
	cnt = DWV & 077
	val = *RP0<<16 | (*RP1 & 0xffff)
	if cnt & 040
	   val >>= -(cnt | ~(077))-1
	   prv = val&1
	   val>>=1
	else
	   while --cnt ge
	      prv = val & 0x80000000, val<<=1
	.. .. SEV if (val & 0x80000000) ne prv
	SEC if prv
	SEN if val lt
	SEZ if val eq
	*RP0 = val>>16, *RP1 = val
  end

  proc	el_fis
  is	.. INVINS
  proc	el_fpu
  is	.. INVINS
  proc	el_cis
  is	.. INVINS
data	PDP-11 dispatch tables

  init	elAxx____ : elTdis
  is	el_00xx__
	el_movw
	el_cmpw
	el_bitw
	el_bicw
	el_bisw
	el_addw
	el_07xx__
	el_10xx__
	el_movb
	el_cmpb
	el_bitb
	el_bicb
	el_bisb
	el_subw
	el_fpu
  end

  init	elA00xx__ : elTdis
  is	el_0000xx		;0000xx	; halt, ...
	el_jmp			;0001xx	; jmp
	el_0002xx		;0002xx	; nop, clc ...
	el_swab			;0003xx ; swab
	el_bra,el_bra,el_bra,el_bra
	el_bne,el_bne,el_bne,el_bne
	el_beq,el_beq,el_beq,el_beq
	el_bge,el_bge,el_bge,el_bge
	el_blt,el_blt,el_blt,el_blt
	el_bgt,el_bgt,el_bgt,el_bgt
	el_ble,el_ble,el_ble,el_ble,
	el_jsr,el_jsr,el_jsr,el_jsr,el_jsr,el_jsr,el_jsr,el_jsr
	el_clrw
	el_comw
	el_incw
	el_decw
	el_negw
	el_adcw
	el_sbcw
	el_tstw
	el_rorw
	el_rolw
	el_asrw
	el_aslw
	el_mark
	el_mfpi
	el_mtpi
	el_sxt
	el_csm
	el_tstset
	el_wrtlck
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu
  end

  init	elA0000xx : elTdis
  is	el_halt,el_wait,el_rti,el_bpt,el_iot,el_reset,el_rtt,el_mfpt; 00:07
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 10:17
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 20:27
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 30:37
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 40:47
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 50:57
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 60:67
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 60:77
  end

  init	elA0002xx : elTdis
  is	el_rts,el_rts,el_rts,el_rts,el_rts,el_rts,el_rts,el_rts
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 10:17
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu	; 20:27
	el_spl,el_spl,el_spl,el_spl,el_spl,el_spl,el_spl,el_spl ; 30:37
	el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc
	el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc,el_ccc
	el_scc,el_scc,el_scc,el_scc,el_scc,el_scc,el_scc,el_scc
	el_scc,el_scc,el_scc,el_scc,el_scc,el_scc,el_scc,el_scc
  end

  init	elA07xx__ : elTdis
  is	el_mul,el_mul,el_mul,el_mul,el_mul,el_mul,el_mul,el_mul
	el_div,el_div,el_div,el_div,el_div,el_div,el_div,el_div
	el_ash,el_ash,el_ash,el_ash,el_ash,el_ash,el_ash,el_ash
	el_ashc,el_ashc,el_ashc,el_ashc,el_ashc,el_ashc,el_ashc,el_ashc,
	el_xor,el_xor,el_xor,el_xor,el_xor,el_xor,el_xor,el_xor,
	el_fis,el_cis,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,
	el_cpu,	el_cpu,	el_cpu,	el_cpu,	el_cpu,	el_cpu,	el_cpu,
	el_sob,el_sob,el_sob,el_sob,el_sob,el_sob,el_sob,el_sob,
  end

  init	elA10xx__ : elTdis
  is	el_bpl,el_bpl,el_bpl,el_bpl,
	el_bmi,el_bmi,el_bmi,el_bmi,
	el_bhi,el_bhi,el_bhi,el_bhi,
	el_blos,el_blos,el_blos,el_blos,
	el_bvc,el_bvc,el_bvc,el_bvc,
	el_bvs,el_bvs,el_bvs,el_bvs,
	el_bcc,el_bcc,el_bcc,el_bcc,
	el_bcs,el_bcs,el_bcs,el_bcs,
	el_emt,el_emt,el_emt,el_emt,
	el_trap,el_trap,el_trap,el_trap,
	el_clrb
	el_comb
	el_incb
	el_decb
	el_negb
	el_adcb
	el_sbcb
	el_tstb
	el_rorb
	el_rolb
	el_asrb
	el_aslb
	el_mtps
	el_mfpd
	el_mtpd
	el_mfps
	el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu,el_cpu
  end
