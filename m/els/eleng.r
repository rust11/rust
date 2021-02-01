vrt$c := 0
;	inhibit clock for 100->102=0
;	force upper case terminal 
;	smart upper case for DOS
file	eleng - PDP-11 engine
include	elb:elmod
include	rid:medef
include	rid:fidef
include	rid:cldef
include	rid:imdef
include	rid:dbdef
include	rid:stdef
include	rid:mxdef
include	rid:ctdef
include rid:codef
include rid:tidef
include rid:wcdef
include rid:prdef
include rid:shdef
include rid:rtutl
include	rid:vtdef

	elVtps : int = 0	; ticks per second
	elVtct : int = 0	; tick counter

code	el_ini - init cpu

  proc	el_ini
  is	el_htz (elVhtz)
DMP("a")

If !MEMARR
	elPmem = me_alc (elMEM+512)		; allocate memory
	elPmem = <*void>(<LONG>(elPmem+511) & ~(511)) ; align to page 
End
	elVevn = ~(1) if elFlsi			; want LSI/11/03 emulation
	elPmch = PNB(elMCH)			; machine pointer
	elPreg = PNW(elREG)			; registers pointer
	bgVstp = 1 if elFstp			; no command
DMP("B")
	vt_ini ()				; start the terminal
DMP("C")
	el_aut ()				; automount
DMP("D")
	el_boo (0)				; boot hd0:
DMP("e")
	ti_sig (1, &el_clk)			; get a clock going
DMP("F")
  end

code	el_rst - reset cpu

;	Called by RESET instruction to reset CPU

  proc	el_rst
  is	vec : * elTvec = elAvec + 1
	elVsch = elVtks = elVtkb = 0
;	PIRQ=0
;	LTC=0
	MM0 &= ~(1)
	while vec->Vdev ne -1			; scan pending interrupts
	   if vec->Vcsr && vec->Venb		; has a CSR and enable
	   .. *MNW(vec->Vcsr) = 0		; clear it
	   ++vec
	end	
	TPB = 0, TPS = 0x80			;
  end

  func	el_pri
	pri : int
  is	
;;;	pr_pri (pri)
  end
code	el_boo - boot system

 	elAxdp : [] elTwrd = {0407,06,0,012}		; XXDP signature
	elAdos : [] elTwrd = {012700, 024, 016701, 0162}; DOSbatch signature

  proc	el_boo
	uni : int
  is	hom : [512] char
	dat : int
	tim : int
	era : int
DMP("M")
	bgVuni = uni			; save boot unit
	me_clr (elPmem, elMEM)		; clear all memory
	el_reset ()			; reset instruction
	PS = 0340			; block interrupts
	el_smw (hdCSR, uni << 9)	; setup the unit
	el_smw (rlCSR, uni << 8)	; 2 or 4 units
;	el_smw (rkTRK, uni << 12)	; 2 or 4 units
	el_exi () if !el_chd (uni, 1)	; no such file
	el_trn (uni, 0, 512, 1, elREA,1); read home block

	me_mov (PNB(0), hom, 512)	; save it

	el_trn (uni, 0, 512, 0, elREA,0); read boot block
	SP = 010000, PC = 0		; 
	PS = 0340, R0 = uni		;
     if elFsma				; want the smarts
	el_swd (1000, 0)		; terminate boot
					;
	if me_fnd ("BOOT-U",6,PNB(0),01000,<>);
	|| me_cmp(hom+0760,"DECRT11A",9); RT-11 system
	   PC = 2, el_swd (0, 0)	; signal RT-11 soft boot
	   el_tim (&tim, &dat, &era)	; RT-11 time/date
	   el_swd (05000, tim>>16)	; .word HOT
	   el_swd (05002, tim)		; .word LOT
	   el_swd (05004, dat)		; .word Y2K DATE
	   el_swd (05006, 021021)	; .RAD50 /ERA/
	   el_swd (05010, era)		; .word  Y2M date remainder
	   el_swd (05012, 0)		; fudged Y2M era
					;
	elif me_cmp (hom+0760, "DECFILE11A", 10)
	   elVrsx = 1			; RSX system
;	   elFdlx = 1			; needs DL extended address
	   elPsig = ">@ <EOF>\r\r\n>"	; output signature before command sent
					;
	elif me_cmp (elAdos,PNB(0),8)	;
	   elVdos = 1			; DOSbatch system
	   elFupr = 1			; uppercase terminal
	   el_ddt ()			; insert date/time
					;
	elif me_cmp (elAxdp,PNB(2),8)	;
DMP("j")
	   elVxdp = 1			; XXDP system
	   ;elFwri = 0 if elFwri eq -1	; default XXDP to nowrite
     ..	.. elVclk = 0			; disable the clock

DMP("k")
	el_dbg ("boo") if elFstp	;
DMP("l")
;???	el_flu ()
DMP("m")
  end

code	el_tim - get RT-11 time

  proc	el_tim
	clk : * int
	dat : * int
	era : * int
  is	val : tiTval
	ti_clk (&val)			; get current time
	rt_clk (&val, clk, elVhtz)	; setup the clock
	rt_dat (&val, dat, elFy2k)	; the date
	rt_era (&val, era) if era ne <>	; end
  end
code	el_bus - bus/address trap

  proc	el_bus
	lab : int			; label (ignored)
  is	exit if ABT			; already aborted instruction
	if bgVhlt
;	   exit if bg_prb (bgERR)	; probing address
	   exit if elVprb		; probing memory
	.. exit PUT("?V11-I-Invalid address\n"); bum address
	elVsch |= elABT_|elBUS_		; remember it
  end

code	el_cpu - invalid instruction

  proc	el_cpu
  is	exit if elFsma && (OP eq 0170011); SETD ignored for Unix
	elVsch |= elABT_|elCPU_		; remember it
  end

code	el_clk - clock interrupt

;	elVtik : int = 0			; tick catch up
	xxx : int = 0
	yyy : int = 0
	zzz : int = 0

  proc	el_clk
  is	exit if ++elVtct lt elVtps		; more to go
	elVtct = 0				;
;	++elVtik				; count ticks
	exit if bgVhlt				; debugger or whatever
	el_sch (elCLK) if elVclk		; got a clock
  end

  func	el_htz
	htz : int
  is	elVhtz = htz
	elVtps  = (htz eq 50) ? 20 ?? 16 	; millisecond period
  end
code	el_trp - trap dispatch

  proc	el_trp
	vec : elTwrd
  is	opc : elTwrd			; old pc
	ops : elTwrd			; old ps
	ps  : elTwrd			; new ps
	trc : int = 0			;
	++trc, vec = veBPT if vec eq veTRC ; handle trace trap
					;
	if elFiot && (vec eq veIOT)	; IOT
	&& el_fwd (PC) eq vrSIG		; virtual machine request
	.. exit PC += 2, el_vap ()	; skip signature, do it
					;
	if (vec eq veBPT) && !trc	; breakpoint (not trace trap)
	   exit if !elVdbg		; ignoring breakpoints (Alt-D)
	   if (elVmai || !*PNW(veBPT))	; maintenance or no vector
	   .. exit if el_dbg ("bpt")	;
	.. exit if elFsma && !*PNW(veBPT)
					;
	if (vec eq veBPT) && trc	;
	   exit if !elVdbg		; ignoring breakpoints (Alt-D)
	.. ;exit if el_dbg ("trace")	;
					;
	if vec eq veEMT			;
	   elVebd = OP 			; catch EMT before disk ops
	   elVepc = PC			;
	   if elVemt			; want things traced
	      rs_emt (PC, OP) if elVrsx	; RSX EMT trace
	      xx_emt (PC, OP) if elVxdp	; XXDP EMT trace
	.. .. ds_emt (PC, OP) if elVdos	; DOS EMT trace
					;
	if vec eq veTRP			;
	   elVebd = OP 			; catch TRAP before disk ops
	   elVepc = PC			;
	   if elVtrp			; want things traced
	.. .. xx_trp (PC, OP) if elVxdp	; XXDP TRAP trace
					;
	if bgVcpu || elVmai		; report stuff
	   case vec			;
	   of veBUS el_dbg ("Bus")	;
	   of veMMU el_dbg ("Mmu")	;
	   of veCPU el_dbg ("Cpu")	;
	.. end case			;
					;
	ops = PS, opc = PC		; save current pc/ps
	ops = elVpss if elVpsr		; in the middle of a CUR/PRV thing
	NEWPS(0)			; vectors are kernel
	PC = el_fwd (vec)		; get new state
	ps = el_fwd (vec+2)		; get the new pss
	ps = ps & ~(0030000)		; remove previous previous mode
	ps |= (ops>>2) & 0030000	; or in previous mode
; ??? won't work for supervisor mode interrupts...
	NEWPS(ps)			;
;  ??? needs an enable/disable "sanity" setting 
	SP = 20, el_dbg ("STK") if SP lt 20
	el_psh (ops)			; push machine state
	el_psh (opc)			;
  end
