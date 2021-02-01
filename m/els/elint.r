rac$c=1 ; race condition thing
;	inhibit clock for 100->102=0
;	force upper case terminal 
;	smart upper case for DOS
file	elint - interrupts
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
;	Need to improve interrupt priority blocking
code	el_sch - schedule interrupt

  proc	el_sch
	dev : int
  is	vec : * elTvec = elAvec + dev 
	if !((dev eq elCLK) && vec->Vcnt)	; already active
	    vec->Vcnt = vec->Vlat		; setup the latency
	else
;PUT("%x %d ", elVsch, vec->Vcnt), xxx=0 if xxx ge 1; 100
;PUT("%x ", elVsch), xxx=0 if xxx gt 10
	end
	elVsch |= BIT(dev)|elCON_		; flag interrupt pending
  end

code	el_wai - pause during wait

;	WAIT must handle interrupt latency

  func	el_wai
  is	fine
	pr_slp (1)
  end
code	el_pol - poll interrupts

	CLR(p) := (elVsch &= (~(p)))
	TST(p) := (elVsch & p)
	SET(p) := (elVsch |= p)

  proc	el_pol
  is	vec : * elTvec = elAvec + 1
	val : int
	pri : int

	CLR(elGEN_)				; clear generic
	vt_ast ()
        el_tkb ()				; check keyboard
	CLR(elPAS_)				; clear pass thru character

;	elMMX_ must be first in list below because the flag must be
;	clear to permit el_psh to use el_swd to build the interrupt frame.

	if TST(elABT_|elBRK_|elMMU_|elCPU_|elMMX_)
	   CLR(elMMX_), el_trp(veMMU) if TST(elMMX_) ; MMU exception
	   CLR(elBUS_), el_trp(veBUS) if TST(elBUS_)
	   CLR(elCPU_), el_trp(veCPU) if TST(elCPU_)
	   CLR(elBRK_), el_dbg("brk") if TST(elBRK_)

	   if elMMU_
	      el_dbg("psr ") if elVpsr		; MMU reset
	      PS=elVpss, elVpsr=0 if elVpsr	; restore PSW
	   .. el_mmu (0)			; reset mmu
	   CLR(elABT_|elMMU_)
	.. exit if !elVsch
				
;	Any I/O page access sets the controller update flag

	if TST(elCON_)				; controller schedule
	   CLR(elCON_)				; clear it
;???;	ELINT - rac$c race condition test
If rac$c
	   SET(elGEN_)				; followup for race conditions
End
	   el_dkx ()				; disks
	   el_tkb () if elVtks			; keyboard
	.. el_tpb (), elVtpp=0 if elVtpp	; terminal

;	Psuedo-latency for PDP-11 drivers

	exit if !elVsch				; no devices scheduled
	pri = PS & 0340				; get PS priority
	pri = 0340 if (elFlsi && (pri & 200))	; max it out for LSIs

;	process devices 

	while vec->Vdev ne -1			; scan pending interrupts
	   if elVsch & BIT(vec->Vdev)		;
	      --vec->Vcnt if vec->Vcnt		; count it
	      if vec->Vcnt			; latency not done
	      || vec->Vpri le pri		; blocked by priority
		 SET(elCON_)			; repeat after next instruction
	      .. next ++vec			; wait another

	      elVsch &= (~BIT(vec->Vdev))	; clear pending flag
;#### clock interrupt can be lost if stepping
	      if vec->Vvec eq veCLK		; this is the clock?
	         if elFlsi||(*MNW(elLTC)&elENB_); clock enabled
	         && elVclk && !(bgVstp||bgVovr) ; enabled and not stepping
	         && *PNW(veCLK)			; and they have kernel vector
	         .. el_trp (vec->Vvec)		; interrupt them
						;
; ??? causes clock to run fast
;	         if elVtik && elFsma		; and it's running late
;	         .. --elVtik, el_sch (elCLK)	; catch up if necessary
						;
	      elif vec->Vcsr			; has a CSR
	      && *MNW(vec->Vcsr) & vec->Venb	; still enabled
		 if !vec->Vrdy			; ready not required
		 || *MNW(vec->Vcsr) & vec->Vrdy	; or is ready
	   .. .. .. el_trp (vec->Vvec)		;
	   ++vec
	end	

;	RTT and RTI trace traps

	if TST(elRTI_|elRTT_)			; rti/rtt + trace
	   if TST(elRTI_)			;
	      CLR(elRTI_), el_trp (veTRC)	; trace trap
	   elif TST(elRTT_)			; rtt
	.. .. CLR(elRTT_), elVsch |= elRTI_	; rti on next cycle

;!	el_flg ()
  end
code	el_flg - display sticky controller flags

  type	elTflg
  is	Pstr : * char
	Vval : int
  end
	elAflg : [] elTflg

  func	el_flg
  is	flg : int = elVsch
	ptr : * elTflg = elAflg
	cnt : int = 32
fine
;	fine if !(elVsch & !(elCLK_))
	PUT("?V11-E-Sticky controller flags %x ", elVsch)
	while cnt
	   PUT("%s ", ptr->Pstr) if ptr->Vval & flg
	   ++ptr, --cnt
	end
	PUT("\n")
;	el_dbg ("Flg")
  end

  init	elAflg : [] elTflg
  is	"CON",	BIT(0)
	"CLK",	BIT(1)
	"KBD",	BIT(2)
	"TER",	BIT(3)
	"HDD",	BIT(4)
	"DLD",	BIT(5)
	"RKD",	BIT(6)
	"DYD",	BIT(7)
	"B08",	BIT(8)
	"B09",	BIT(9)
	"B10",	BIT(10)
	"B11",	BIT(11)
	"B12",	BIT(12)
	"B13",	BIT(13)
	"B14",	BIT(14)
	"B15",	BIT(15)
	"B16",	BIT(16)
	"B17",	BIT(17)
	"B18",	BIT(18)
	"B19",	BIT(19)
	"B20",	BIT(20)
	"CPU",	BIT(21)
	"BUS",	BIT(22)
	"PAS",	BIT(23)
	"GEN",	BIT(24)
	"EXI",	BIT(25)
	"CTC",	BIT(26)
	"RTI",	BIT(27)
	"RTT",	BIT(28)
	"BRK",	BIT(29)
	"ABT",	BIT(30)
	"MMU",	BIT(31)
  end
