file	eldat
include elb:elmod
include	rid:vtdef

data	flags etc 

	elFlsi : int = 0	; PDP-11/03 emulation
	elFeis : int = 1	; PDP-11/03 with EIS
	elFmap : int = 1	; Mapped emulation
	elVclk : int = 1	; line clock enabled
	elFvrt : int = 0	; VRT emulation
	elVmmu : int = 0	; MMU emulation
	elVmai : int = 0	; maintenance debug mode
	elFstp : int = 0	; stop before execution
	elVdbg : int = 1;0;1	; debugger
;	elVctc : int = 0	; ctc
	elVlog : int = 0	; log tt:
	elPlog : * FILE = <>	; log file
	elVpau : int = 0	; pause
	bgVdsk : int = 0	; disk trace
	elVtrp : int = 0	; emt trace
	elVemt : int = 0	; trap trace
	elVall : int = 0	; trace all emts
	elVxdp : int = 0	; xxdp emt trace
	elVdos : int = 0	; dos emt trace
	elVrsx : int = 0	; rsx system active (trace, command)
	elFold : int = 0	; old CPU (/twenty)
	elFwri : int = -1	; enable disk writes
	elFsma : int = 1	; smarts during boot
	elF7bt : int = 0	; seven bit terminal
	elFuni : int = 0	; unibus model
	elFy2k : int = 1	; y2k date
;	elFbpt : int = 1	; BPT enabled or ignored
	elFvrb : int = 0	; verbose boot
	elFvtx : int = 1	; vt100
	elFiot : int = 1	; IOT enabled
	elVhtz : int = 50	; assume 50 hertz
	elFdlx : int = 1	; DL: extended address
	elFrsx : int = 0	; RSX boot
	elVebd : int = 0	; emt before disk operation
	elVepc : elTadr = 0	; pc thereof
	elVprb : int = 0	; probing memory -- no error
	elFupr : int = 0	; upper-case terminal (for DOS)
	elFhog : int = 0	; hog cpu

	elFltc : int = 1	; line time clock

	elAsys : [mxSPC] char = {0} ; system disk spec (from command)
	elAcmd : [mxLIN] char = {0} ; command line buffer (edited)
	elPcmd : * char = <>        ; command line pointer
	elVcmd : int = 0	    ; command flags

	elPsig : * char = <>	; signature required before command
	elVsig : int = 0	;
data	cpu data

If MEMARR
elMAR := "Array"
	elPmem : [elMEM] elTbyt ;* elTbyt = <>	; main memory
Else
elMAR := "Pointer"
	elPmem : * elTbyt = <>	;* elTbyt = <>	; main memory
End
	elPmch : * elTbyt = <>	; direct access to machine (64k page)
	elPreg : * elTwrd = <>	; direct access to regs
;	elVpsw : elTwrd = 0	; PSW
	elVpsr : elTwrd = 0	; restore PSW flag
	elVpss : elTwrd = 0	; save PSW

	elAzer : [512] char = {0} ; to zero-extend disk writes
	elVevn : elTadr = ~(0)	; set to ~(0) for 11/03s
				;
	elVcur : elTadr = 0	; current instruction address
	elVopc : elTwrd = 0	; opcode
	elVsch : int = 0	; scheduled interrupts
				;
	elVswa : elTadr = 0	; source word address
	elVdwa : elTadr = 0	; dest   word address
	elVsba : elTadr = 0	; source byte address
	elVdba : elTadr = 0	; dest   byte address
	elVtwa : elTadr = 0	; temp   word address
	elVtba : elTadr = 0	; temp   byte address
	elVswv : elTwrd = 0	; source word value
	elVsbv : elTbyt = 0	; source byte value
	elVdwv : elTwrd = 0	; dest   word value
	elVdbv : elTbyt	= 0	; dest   byte value
	elVtwv : elTwrd = 0	; temp   word value
	elVtbv : elTbyt = 0	; temp   byte value

	elVtlv : elTlng = 0	; temp   long value
	elVdlv : elTlng	= 0	; dest   long value
	elVslv : elTlng = 0	; source long value
data	debugger data

	bgVuni : int = 0	; bootstrap unit
	bgVhlt : int = 0	; cpu is halted (in debug)
	bgVstp : int = 0	; step mode
	bgVcnt : int = 0	; step count
	bgVict : int = 0	; instruction count
	bgVreg : int = 0	; show regs automatically
	bgVval : int = 0	; show values (dec,asc,r50)
	bgVter : int = 0	; show terminal operations
	bgVfst : int = 1	; fast mode

;	bgVdbg : elTwrd = 1	; debug bpt enable
;	bgVbpt : elTwrd = 0 	; breakpoint enable
;	bgVbad : elTwrd = 0	; breakpoint address
	bgVbus : int = 0	; catch bus traps
	bgVcpu : int = 0	; catch cpu traps

	bgVcth : int = 0	; ctrl/h flag
;	bgVwat : elTwrd = 0	; watch enable
;	bgVwad : elTwrd = 0	; watch address
;	bgVwvl : elTwrd = 0	; watch value

	bgVfen : elTwrd		; feel enable
	bgVfad : elTwrd		; feel address
	bgVfel : elTwrd		; felt

	bgVzed : int = 0	; zed variable
	bgVprv : int = 0	; previous address
	bgVtpb : int = 0	; last TPB character (from elter)
	bgVund : elTwrd = 0;400	; stack underflow address
	bgVred : int = 0	; in stack red zone (see elpdp.r)

code	instruction history

	hiIsto : hiTsto = {0}	; history storage

  proc	hi_put
  is	sto : * hiTsto = &hiIsto
	idx : int = sto->Vput	;

	sto->Ahis[idx].Vloc = PC	; save the PC
	sto->Ahis[idx].Vmod = PS	; save the PS
	idx = 0 if ++idx ge hiLEN ;
	sto->Vput = sto->Vget = idx	;
	sto->Ahis[idx].Vloc = 0	;
	sto->Ahis[idx].Vmod = 0	;
  end

  func	hi_prv
	his : * elThis
  is	sto : * hiTsto = &hiIsto
	idx : int = sto->Vget - 1
	idx = hiLEN-1 if idx lt
	sto->Vget = idx
	his->Vloc = sto->Ahis[idx].Vloc
	his->Vmod = sto->Ahis[idx].Vmod
  end

  func	hi_nxt
	his : * elThis
  is	sto : * hiTsto = &hiIsto
	idx : int = sto->Vget + 1
	val : elTwrd 
	idx = 0 if idx ge hiLEN
	sto->Vget = idx
	his->Vloc = sto->Ahis[idx].Vloc
	his->Vmod = sto->Ahis[idx].Vmod
  end
