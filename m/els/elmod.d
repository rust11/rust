header	elmod - PDP-11 emulator definitions
include	rid:rider
include	rid:mxdef
include	rid:fidef
include	rid:eldef
include	rid:rtmod
;nclude	rid:kbdef

MEMARR := 0

	DMP(x) := el_vrb (x)

data	cpu environment

  type	elTfun : (void) void

	elWRD_ := 0xffff	;
	elBYT_ := 0xff		;

	_1k   := (1024)		;     02000
	_4k   := (4   * _1k)	;    010000
	_8k   := (8   * _1k)	;    020000
	_64k  := (64  * _1k)	;   0200000   0160000
	_256k := (256 * _1k)	;  01000000   0760000
	_1m   := (_1k * _1k)	;  04000000
	_4m   := (4   * _1m)	; 020000000 017760000

	elVAS  := _64k		; virtual address space (unmapped as well)
	elUAS  := _256k		; unibus address space
	elQAS  := _4m		; qbus address space

	elVIO  := (elVAS - _8k)	;   0160000
	elUIO  := (elUAS - _8k)	;   0760000
	elQIO  := (elQAS - _8k)	; 017760000

	elPAS  := (elQAS)	; physical address space (compile all to change)
	elHWM  := (elPAS-_8k)	; high water mark (I/O base)
	elNMX  := (elPAS-elVAS)	; native to machine address, byte or word
	elMCH  := (elPAS-elVAS)	; pointer to the I/O page (64k page)

	elVhwm : elTadr+	; high water mark - start of I/O page
	elVvio : elTadr+	; VA of I/O page (28k or 30k)
	elVnmx : elTadr+	; non-existant memory address
	elVeow : elTadr+	; end-of-

	elREG  := (elPAS)	; register storage
	elDUM  := (elPAS+18)	; dummy location, just past registers and PS
	elMEM  := (elPAS+128)	; total memory to allocate (includes regs)

	mmRAC_ := 02				; read access
	mmWAC_ := 04				; write access
						;
	VPR(x) := el_vpx (x, mmRAC_)		; virtual to physical, read
	VPW(x) := el_vpx (x, mmWAC_)		; virtual to physical, write
	PNB(x) := (<*elTbyt>(elPmem + (x)))	; physical to native, byte
	PNW(x) := (<*elTwrd>(elPmem + (x)))	; physical to native, word
	MNB(x) := (<*elTbyt>(elPmch + (x)))	; machine to native, byte
	MNW(x) := (<*elTwrd>(elPmch + (x)))	; machine to native, word
	NMX(x) := ((x)-elNMX)			; native to machine, typeless
	MBX(x) := ((x & ~(1))-elVIO)		; machine to bus, typeless
	DEV(x) := (MBX(x)/2)			; device slot
	ODD(x) := ((x) & 1)			; check odd adress

	el_vpx : (elTadr, elTwrd) elTadr	;
	el_mma : (elTadr, int, *elTwrd) int

	el_fmw(x) := (*MNW(x))			; fetch machine word
	el_fmb(x) := (*MNB(x))			; fetch machine byte
	el_smw(x,y) := (*MNW(x)=(y))		; store machine word
	el_smb(x,y) := (*MNB(x)=(y))		; store machine byte

	OP  := elVopc		; opcode
	R0  := elPreg[0] 
	R1  := elPreg[1] 
	R2  := elPreg[2] 
	R3  := elPreg[3] 
	R4  := elPreg[4] 
	R5  := elPreg[5] 
	SP  := elPreg[6]
	PC  := elPreg[7]
	PS  := elPreg[8]

	elMM0  := 0177572	; MMU control
	elMAP_ := BIT(0)	; MMU enabled
	elMM1  := 0177574	; autoinc stuff
	elMM2  := 0177576	; trap address
	elMM3  := 0172516	; MMU SR3
	el22b_ := BIT(4)	; 22bit enabled
	MM0    := (*MNW(elMM0))
	MM1    := (*MNW(elMM1))
	MM2    := (*MNW(elMM2))
	MM3    := (*MNW(elMM3))

	elT_	:= BIT(4)
	elN_	:= BIT(3)
	elZ_	:= BIT(2)
	elV_	:= BIT(1)
	elC_	:= BIT(0)
;	elPRI_	:= 0340

	elMtbt(x) := ((x) & ~(elT_))	; clear the TBIT

	TBIT := ((PS & elT_) >> 4)
	NBIT := ((PS & elN_) >> 3)
	ZBIT := ((PS & elZ_) >> 2)
	VBIT := ((PS & elV_) >> 1)
	CBIT := (PS & elC_)

	CCC := (PS &= ~(elN_|elZ_|elV_|elC_))
	CLC := (PS &= (~elC_))
	CLV := (PS &= (~elV_))
	CLZ := (PS &= (~elZ_))
	CLN := (PS &= (~elN_))
	SEC := (PS |= elC_)
	SEV := (PS |= elV_)
	SEZ := (PS |= elZ_)
	SEN := (PS |= elN_)

	veBUS := 04
	veCPU := 010
	veBPT := 014
	veIOT := 020
	vePWF := 024
	veEMT := 030
	veTRP := 034
	veKBD := 060
	veTER := 064
	veCLK := 0100
	vePAR := 0114
	vePRQ := 0240
	veFPU := 0244
	veMMU := 0250
	veTRC := 0377	; trace 
data	memory & cpu

If MEMARR
	elPmem : [] elTbyt+	; [elMEM] - main memory (could be pointer)
Else
	elPmem : * elTbyt+	; [elMEM] - main memory (could be pointer)
End

	elApar : [] LONG+	; pars
	elApdr : [] LONG+	; pdrs
	elPpar : * elTwrd+
	elPpdr : * elTwrd+
	elVmmd : elTwrd+
	elVspm : elTwrd+

	elPmch : * elTbyt+	; direct access to machine (64kb page)
	elPreg : * elTwrd+	; direct access to registers
	el_psw : (elTwrd) void	; change PSW routine
	NEWPS(x) :=(el_psw((x)));
				;
	elVpss : elTwrd+	; saved psw
	elVpsr : elTwrd+	; psw restore required

	CURPRV := (elVpss=PS,elVsch|=elMMU_)
	CUR    := (elVpss&0140000)
	PRV    := ((elVpss<<2)&0140000)
	CURMOD := (PS=(elVpss&037777)|CUR, elVpsr=0, MMU)
	PRVMOD := (PS=(elVpss&037777)|PRV, elVpsr=1, MMU)

	elNAC  := 0		; no access
	elFTW  := 1		; fetch word
	elFTB  := 2		; fetch byte
	elSTW  := 3		; store word
	elSTB  := 4		; store byte

	elAstk : [4] elTwrd	; KSU stacks
	STK(mod) := (elAstk[((mod)>>14)&03])

	elAzer : [] char+	; [512] - to zero-extend disk writes

	elFlsi : int+		; PDP-11/03 flag
	elFeis : int+		; EIS flag
	elFmap : int+		; MMU flag
				;
	elVevn : elTadr+	; ~(1) for 11/03. ~(0) for others.
	elVopc : elTwrd+	; opcode
	elVsch : int+		; scheduled interrupts
	elVmmu : int+		; mmu enabled (elMMU_|elMTF_)
	elV22b : int+		; 22bit enabled
	elVprb : int+		; probing memory
	elVebd : int+		; emt before disk operation
	elVepc : elTadr+	; pc thereof
				;
	elVcur : elTadr+	; current instruction address
	elVswa : elTadr+	; source word address
	elVdwa : elTadr+	; dest   word address
	elVsba : elTadr+	; source byte address
	elVdba : elTadr+	; dest   byte address
	elVtwa : elTadr+	; temp   word address
	elVtba : elTadr+	; temp   byte address
	elVswv : elTwrd+	; source word value
	elVsbv : elTbyt+	; source byte value
	elVdwv : elTwrd+	; dest   word value
	elVdbv : elTbyt+	; dest   byte value
	elVtwv : elTwrd+	; temp   word value
	elVtbv : elTbyt+	; temp   byte value
	elVtlv : elTlng+	; temp	 long value
	elVslv : elTlng+	; source long value
	elVdlv : elTlng+	; dest	 long value
data	various

	el_ini : elTfun
	el_dis : elTfun
	el_ddt : () 
	el_dkx : elTfun		; disk scheduler

	elAcmd : [mxLIN] char+	; edited command
	elAsys : [mxSPC] char+	; system disk spec from command
	elPcmd : * char+	; command pointer
	elVcmd : int+		; command flags

	elPsig : *char+		; signature required before command
	elVsig : int+		; signature index (see el_sig)

	elVdbg : int+		; enable debugger and debug cycle
	elVmai : int+		; maintenance boot
	elVpau : int+		; pause screen output
	elVxdp : int+		; do XXDP things
	elVdos : int+		; do DOS/Batch things
	elVrsx : int+		; do RSX things
	elFold : int+		; old CPU (/twenty)
	elVemt : int+		; trace EMTs
	elVtrp : int+		; trace TRAPs
	elVall : int+		; trace all emts
	elVlog : int+		; log terminal output
	elPlog : *FILE+		; log file
	elFwri : int+		; enable disk writes (default)
	elVclk : int+		; 1 => clock enabled
	elFvrb : int+		; verbose 
	elFvtx : int+		; novt100
	elF7bt : int+		; 7-bit ascii
	elFdlx : int+		; extended DL:
	elFrsx : int+		; RSX boot
	elFupr : int+		; uppercase terminal
	elFsma : int+		; /smart
	elFiot : int+		; /noiot
	elFstp : int+		; /stop
	elFuni : int+		; /unibus
	elVhtz : int+		; /hertz
	elFy2k : int+		;
	elFltc : int+		; /noltc
	elFvrb : int+		; /verbose startup
	elFhog : int+		; /hog cpu

	ds_emt : (elTwrd, elTwrd) void ; dos/batch emt
	rs_emt : (elTwrd, elTwrd) void ; rsx emt
	xx_emt : (elTwrd, elTwrd) void ; xxdp emt
	xx_trp : (elTwrd, elTwrd) void ; xxdp trap

data	devices

	elCON  := 0		; controller
	elCON_ := BIT(0)	; controller flag
	elCLK  := 1		; clock
	elCLK_ := BIT(1)
	elKBD  := 2		; keyboard
	elKBD_ := BIT(2)
	elTER  := 3		; terminal
	elTER_ := BIT(3)	;
	elHDD  := 4		; HD: disk
	elDLD  := 5		; DL: disk
	elRKD  := 6		; RK: disk
	elDYD  := 7		; DY: disk
	elBST_ := BIT(8)	; boost priority
	elPRS_ := BIT(9)	; set priority

	elMMX_ := BIT(20)	; MMU address abort
	elCPU_ := BIT(21)	; CPU trap pending
	elBUS_ := BIT(22)	; BUS trap pending
	elPAS_ := BIT(23)	; passthru character
	elGEN_ := BIT(24)	; generic
	elEXI_ := BIT(25)	; exit
	elCTC_ := BIT(26)	; vrt ctrl-c pending
	elRTI_ := BIT(27)	; rti trace pending
	elRTT_ := BIT(28)	; rtt trace pending
	elBRK_ := BIT(29)	; console debug pending
	BRK := (elVsch|=elBRK_)	;
	elABT_ := BIT(30)	; Instruction was aborted
	ABT := (elVsch & elABT_);
	elMMU_ := BIT(31)	; MMU reset required on abort

  type	elTvec
  is	Vdev : int		; device id (thus bit mask)
	Vcsr : elTwrd		; CSR address
	Venb : elTwrd		; CSR interrupt enable
	Vrdy : elTwrd		; CSR ready
	Vvec : elTwrd		; vector address
	Vlat : int		; latency (in instructions)
	Vcnt : int		; latency countdown
	Vpri : int		; interrupt priority
  end

	elAvec : [] elTvec+

  type	elTdev
  is	Vtyp : int		; device type
	Vsts : int		; status
	Vuni : int		; device unit
	Vext : size		; extended size (actual disk size)
	Vsiz : size		; device size
	Vbas : size		; base block
	Pfil : * FILE		; file
	Anam : [mxSPC] char	; translated spec
	Aspc : [mxSPC] char	; untranslated spec
	V0   : LONG		; private 
	V1   : LONG		; private 
  end

	elAdsk : [] elTdev+

	rlCSR := 0174400
	rlBUF := 0174402
	rlBLK := 0174404
	rlCNT := 0174406
	rlEXT := 0174410
	rlVEC := 0160
	rlPRI := 0240

	rkSTA := 0177400
	rkERR := 0177402
	rkCSR := 0177404
	rkCNT := 0177406
	rkBUF := 0177410
	rkADR := 0177412
	rkDAT := 0177414
	rkVEC := 0220
	rkPRI := 0240
	rkRK5_ := 04000
	rkRDY_ := 0100

	dyCSR := 0177170
	dyBUF := 0177172
	dyVEC := 264
	dyPRI := 220

	dyVbuf : int+		; catch buffer accesses

;	HD:

	hdCSR := 0177110	; disk registers
	hdCNT := 0177112	; this is a byte count
	hdBLK := 0177114
	hdBUF := 0177116
	hdXX0 := 0177120	
	hdXX1 := 0177122	
	hdBAE := 0177124

	hdVEC := 0234
	hdPRI := 0240

	hdERR_ := 0100000	; csr flags
	hdUNI_ := 07000		; unit number
	hdCHG_ := 0400		; disk changed flag
	hdRDY_ := 0200		; disk ready
	hdENB_ := 0100		; interrupt enabled
	hdEXT_ := 060		; extended address
	hdFUN_ := 016		; 8 function codes
	hdACT_ := 01		; go

;	elDKS	:= dkCSR

;	Internal disk functions

	elRES  := 0		; reset
	elREA  := 1		; read
	elWRI  := 2		; write
	elSIZ  := 3		; size
	elSEE  := 4		; seek
	elNOP  := 5		; nothing

	elENB_ := 0100		; generic interrupt enable
	elRDY_ := 0200		; generic ready
	elACT_ := 01		; go

	elMP0 := 0172100	; memory parity
	elMP1 := 0172102	;
	elMP2 := 0172104	;
	elMP3 := 0172106	;
	elMP4 := 0172110	;
	elMP5 := 0172112	;
	elMP6 := 0172114	;
	elMP7 := 0172116	;

data	terminal

	elTKS	:= 0177560
	elTKB	:= 0177562
	elTPS	:= 0177564
	elTPB	:= 0177566
	elPSW	:= 0177776
	elLTC   := 0177546
	elLTC_ := BIT(6)

	TKS := (*MNB(elTKS))
	TKB := (*MNB(elTKB))
	TPS := (*MNB(elTPS))
	TPB := (*MNB(elTPB))
	DKS := (*MNB(elDKS))
	RLS := (*MNB(rlCSR))

	elVtks : int+		; requesting character
	elVtkb : int+		; have character
	elVtpp : int+		; output pending
	elVtkc : int+		; polling count

data	clock

	elVact : int+		;
	elVtik : int+		;
	elVpri : int+		;

data	VAP - V11 API

	vrSIG  := 0110706	; .word iot, vrSIG
	vrNFI  := 1		; VRT NF:/Vamp I/O processor
	vrMKD  := 2		; Make directory
	vrDEF  := 3		; Define logical
	vrNFW  := 4		; NF: windows driver
	vrDET  := 5		; V11 detect
	 vrPDP := 1		;  PDP-11 emulator
;	 vrVRT := 2		;  RT-11 emulator
	vrVCL  := 6		; V11 CLI reset
	vrPAU  := 7		; Pause
	vrEXI  := 8		; Exit to host
	vrHTZ  := 9		; Hertz
	vrTIM  := 10		; RT-11 time
	el_vap : (void) void	; V11 API

data	debugger

	bgVuni : int+		; bootstrap unit
	bgVhlt : int+		; cpu is halted (in debug)
	bgVstp : int+		; step mode
	bgVovr : int+		; step over flag
	bgVovp : int+		; step over address
	bgVcnt : int+		; step count
	bgVsto : int+		; step to
	bgVtop : int+		; step to pointer
	bgVict : int+		; instruction count
	bgVreg : int+		; show regs automatically
	bgVdsk : int+		; show disk operations
	bgVter : int+		; show VT100 operations
	bgVfst : int+		; fast mode

	bgVdbg : elTwrd+	; debug enable
	bgVbus : int+		; catch bus traps
	bgVcpu : int+		; catch cpu traps
	bgVcth : int+		; catch ctrl/y
				;
	bgVzed : int+		; zed variable
	bgVprv : int+		; previous address 
	bgVval : int+		; show values etc
	bgVtpb : int+		; last TPB - from elter

	bgVfen : elTwrd+	; feel enable
	bgVfad : elTwrd+	; feel address
	bgVfel : elTwrd+	; felt

	bgVund : elTwrd+	; stack underflow address
	bgVred : int+		; in stack red zone

data	prototypes

	vr_boo : (void) int		; AME boot
	vr_int : (elTwrd) int		; AME interrupt

	hiLEN := 256		; 256 instructions
  type	elThis
  is	Vloc : elTwrd
	Vmod : elTwrd
  end
  type	hiTsto
  is	Vput : int		; put index
	Vget : int		; get index
	Ahis : [hiLEN] elThis	; history array
  end
	hiIsto : hiTsto+	;
 	hi_put : elTfun
	hi_prv : (*elThis)
	hi_nxt : (*elThis)

	el_exi : elTfun
	el_hlp : ()
	el_win : ()
	el_dbg : (*char) int
	el_pri : (int)	
	el_mnt : (*elTdev, int, *char) int
	el_aut : (void) void
	el_chg : () void
	el_rmt : () void
	el_lsd : () void
	el_chd : (int, int) int
	el_trn : (int, LONG, int, int, int, int) *elTdev
	el_put : (int) void
	elVlst : int 
	el_new : () void		; in elter
	el_sol : () void		; ditto
	el_mod : (elTwrd) *char		; in eldbg
	el_vrb : (*char) int		; in elroo
	el_sig : (int) void

	el_tim : (*int, *int, *int) void
	el_boo : (int) void
	el_trp : (elTwrd) void
	el_wai : ()
	el_flg : ()

	el_evt : elTfun
	el_trc : elTfun
	el_bus : (int) void
	el_cpu : elTfun
	el_flu : (void)
	el_get : (void) int
	el_prm : (*char, *char) int
	el_tkb : elTfun
	el_tpb : elTfun
	el_pol : elTfun
	el_sch : (int) void
	el_clk : elTfun
	el_htz : (int) 
	el_bst : elTfun
	el_rst : elTfun
	vt_ini : (void) void
	vt_ast : (void) void

	el_fwd : (elTadr) elTwrd
	el_swd : (elTadr, elTwrd) void
	el_fbt : (elTadr) elTbyt
	el_sbt : (elTadr, elTbyt) void

	elNAC  := 0		; no access
	elFWD  := 1		; fetch word
	elFBT  := 2		; fetch byte
	elSWD  := 3		; store word
	elSBT  := 4		; store byte

	el_fpc : (void) elTwrd
	el_psh : (elTwrd) void
	el_pop : (void) elTwrd
	el_fmm : (elTwrd, *void, int) 
	PSH(x) := (el_psh ((x)))
	POP    := (el_pop ())
	TOP    := (el_fwd (SP))
	el_mmu : (int) void
	el_mmx : (int) void

	el_reset : (void) void

	vr_tim : (*tiTval, *int, *int) void
	vr_unp : (*elTwrd, *char, int) void
	vr_pck : (*char, *elTwrd, int) *char
	vr_pck_spc : (*char, *elTwrd, int, int) *char

	vrSPC := 64		; spec size

	nf_drv : (*rtTqel, elTwrd, elTwrd) int
code	el_dbg - debuggger

	bg_reg : elTfun
	bg_wrd : elTfun
	bg_byt : elTfun
	bg_mem : (elTadr)
	bg_dev : elTfun
	bg_dsk : elTfun
	bg_sho : elTfun
	bg_bpt : (elTwrd, int)

	bg_prb : (int) int
	bgPRB  := 0
	bgTST  := 1
	bgCLR  := 2
	bgERR  := 3

data	breakpoint, watchpoint etc triggers

  type	bgTtrg
  is	Venb : int		; trigger is enabled
	Vloc : elTwrd		; trigger location
	Vmod : int		; trigger mode (user/kernel/etc)
	Padr : * WORD		; physical address of value
	Vval : elTwrd		; associated value (watchpoint)
	Vmat : elTwrd		; match value (watchpoint)
	Vflg : elTwrd		; match flag (watchpoint)
  end
;
;	if SNAP(bgIbpt,PC,PS)
;
	SNAP(x,y,z) := x.Venb && (x.Vloc eq y) && (x.Vmod eq (z & elCUR_))

	bg_set : (*bgTtrg, elTwrd, int) ; set trigger

	bgIbpt : bgTtrg+		; breakpoint
	bgIwat : bgTtrg+		; watchpoint
	bgIfel : bgTtrg+		; feelpoint
code	PDP-11 microcode

;	All Fetch/Store operations have two parts.
;	First, the 16-bit VA is decoded into an internal PA (physical address)
;	Second, that PA is used with a fetch/store routine.
;
;	PA Address decode routines

	SWA := el_swa ()			; source word address
	DWA := el_dwa ()			; dest word address
	SBA := el_sba ()			; source byte address
	DBA := el_dba ()			; dest byte address
	SRA := el_sra ()			; source reg address
	DRA := el_dra ()			; dest reg address
						;
	RP0 := <*elTwrd>(elPmem + elVswa)	; eis reg pointer 0
	RP1 := <*elTwrd>(elPmem + (elVswa | 2))	; eis reg pointer 1
	DBH := <*elTbyt>(elPmem + elVdba + 1)	; hi byte special
						; MOVB SXT register only
	SWP := PNW(elVswa)			; source word pointer
						; SOB  register only
						; MOVB SXT register only
						;
	SWV := elVswv				; source word value
	SBV := elVsbv				;
	DWV := elVdwv				;
	DBV := elVdbv				;
	TWV := elVtwv				;
	TBV := elVtbv				;
	TLV := elVtlv				;
	SLV := elVslv				;
	DLV := elVdlv				;

;	Get routines return the value from a PA

	SWG := (SWV = el_fwd (elVswa))		; source word get
	SBG := (SBV = el_fbt (elVsba))		;
	SRG := SWG				; register
						;
	DWG := (DWV = el_fwd (elVdwa))		;
	DBG := (DBV = el_fbt (elVdba))		;
	DRG := DWG				;

;	Fetch routines combine Address and Get operations

	SWF := (SWA, SWG)			; fetch = address & get
	SBF := (SBA, SBG)			;
	SRF := (SRA, SRG)			; register
	DWF := (DWA, DWG)			;
	DBF := (DBA, DBG)			;
	DRF := (DRA, DRG)			;

;	Store routines combine Address and Store

	SWS(v) := (el_swd (elVswa, (v)))	; store
	SBS(v) := (el_sbt (elVsba, (v)))	;
	DWS(v) := (el_swd (elVdwa, (v)))	;
	DBS(v) := (el_sbt (elVdba, (v)))	;
	TWS := (DWS(TWV))			; store temp
	TBS := (DBS(TBV))			;

;	Test routines

	RLN(v) := (((v) & BIT(31)) ? SEN ?? CLN); long negative
	RWN(v) := (((v) & BIT(15)) ? SEN ?? CLN); word negative
	RBN(v) := (((v) & BIT(7)) ? SEN ?? CLN)	; 
	RLZ(v) := ((v) ? CLZ ?? SEZ)		; zero
	RWZ(v) := ((v) ? CLZ ?? SEZ)		; zero
	RBZ(v) := ((v) ? CLZ ?? SEZ)		;
	RLNZ(v) := (RLN(v), RLZ(v))		; negative/zero
	RWNZ(v) := (RWN(v), RWZ(v))		;
	RBNZ(v) := (RBN(v), RBZ(v))		;
						;
	RXV(v) := ((v) ? SEV ?? CLV)		; overflow
	RXC(v) := ((v) ? SEC ?? CLC)		; carry

;	Other

	KERMOD := (!(PS & 0140000))		; kernel mode
	USPMOD := (PS & 0140000)		; user/supervisor mode
	REGMOD := (!(OP & 070))			; check register mode
	INVADR(x) := el_bus (x)			; invalid address
	INVINS := el_cpu ()			; generate invalid instruction
	BRANCH := el_bra ()			; force branch
	MMUERR(x) := el_mmx (x)			; MMU error
	MMU    := el_mmu (0)			; MMU reset
	MMUPRV := el_mmu (1)			;
end header
