file	elmmu - memory management
include	elb:elmod
include	rid:dbdef
include	rid:prdef

code	memory management

	elV22b : int = 0	; 22bit enabled
	elVhwm : elTadr = elHWM	; start of I/O page as pa
	elVvio : elTadr = elVIO	; start of I/O page as va
	elVnmx : elTadr = _1m	; elNMX
	elVeow : elTadr = elREG	; end of world

	elApar : [] LONG = {0172340,0172240,0,0177640}
	elApdr : [] LONG = {0172300,0172200,0,0177600}
	elPpar : * elTwrd = 0
	elPpdr : * elTwrd = 0

	elVmmd : elTwrd = 0
	elVspm : elTwrd = 0
	elVsyn : elTwrd = 0	; elVmmu synch copy

code	el_mma - decode MMU address

; ????	Again, a table-driven approach is required

  func	el_mma
	adr : elTadr
	mod : int		; 0=read, 1=write
	val : * elTwrd		; used only for read (byte read???)
  is	adr = adr & 0xffff
	fail if elFlsi
	if ((adr ge <LONG>0172340) && (adr lt <LONG>0172360))  ; KIsAr0 
	|| ((adr ge <LONG>0172240) && (adr lt <LONG>0172260))  ; S
	|| ((adr ge <LONG>0177640) && (adr lt <LONG>0177660))  ; U
	|| ((adr ge <LONG>0172300) && (adr lt <LONG>0172320))  ; KIsDr0
	|| ((adr ge <LONG>0172200) && (adr lt <LONG>0172220))  ; S
	|| ((adr ge <LONG>0177600) && (adr lt <LONG>0177620))  ; U
	.. fine
	case adr & ~(1)
	of 0177570 fine			; Unibus switch register
	of 0177572 fine el_mmu (0)	; MMR0 - MMU Control Register
	of 0177574 fine 		; MMR1 - Inc/Dec Register
	of 0177576 fine			; MMR2 - Frozen PC 
	of 0172516 fine			; MMR3 - Enables Register
	of 0177766 fine *val = 0 if mod	; CPU error register
	of 0177772 fine			; PIRQ register
	of 0177546 fine			; Line Time Clock Register
	of 0177750 *val=0174021 if !mod ; Maintenance register
	of 0177746 fine			; cache control
	of 0177752 fine			; hit/miss register
	of 0177744 fine			; memory system error register
;	of 0177742 fine			; memory system something
	of other   fail
	end case
	fine
  end

code	el_psw - change psw and stack

  proc	el_psw
	val : elTwrd			; new PS
  is	exit PS = val if elFlsi		; LSI does none of this 
	elAstk[(PS>>14)&3] = SP		; save current stack
	PS = val			;
	SP = elAstk[(PS>>14)&3]		; get new stack
;####
;	if PS & 04000
;	.. el_dbg ("Reg")		; alternate register set

	elVspm = (PS>>14)&3		; get mask
	el_mmu (0)			; reset memory management
  end

code	el_mmu - setup/reset memory management

;	Called by PSW modify, interrupts and RTI
; ???	Clear error flags etc
; ???	Setup separate data space pointers

  proc	el_mmu
	mod : int			; 0=current, 1=>previous
  is	exit if !elFmap			; not mapped
	elVmmu = (MM0 & elMAP_) | elVpsr; check enabled
	exit if eq			; not on
	elV22b = MM3 & el22b_		; get 22bit mode
;	elVhwm = elV22b ? elQIO ?? elUIO; setup high water mark	

	elVsch |= elMMU_ if mod		; force update if previous mode
	mod = (PS>>12)&3 if mod		; previous
	mod = (PS>>14)&3 otherwise	;
	elVmmd = mod			;
	elPpar = MNW(elApar[mod])	; setup the pointers
	elPpdr = MNW(elApdr[mod])	;
  end

code	el_mmx - mmu exception

  proc	el_mmx
	cod : int
  is	exit if elVsch & elMMU_		; already did this
	elVsch |= elABT_|elMMU_|elMMX_	; need to switch things off
	exit if bgVhlt			; debugger active
	MM2 = elVcur			; save frozen pc
	MM0 |= 0100000			; set page abort
  end

code	el_vpx - virtual to physical conversion

;	The inner-loop of inner-loops
;	Doesn't handle I/D separation
;	Doesn't handle supervisor mode or register sets
;	Doesn't handle stack pages
;	Ignore page length overruns
;
;	Length determination assumes cache bypass bit is 0

  func	el_vpx
	va  : elTadr			; 16 bit va
	mod : elTwrd			; access mode
	()  : elTadr			; 22-bit pa + base
  is  	pa  : elTadr			;
	apr : elTadr
	off : elTadr
	len : elTadr
	blk : elTadr

	++bgVfel if bgVfen && (va eq bgVfad) ; feelpoint

	reply va if va ge elREG		; register area
	if !elFmap || !(elVmmu|elVpsr)	;
	   reply va if va lt elVvio	; not virtual I/O address
	   reply elVhwm|va		; relocate to our area
	end
					;
	apr = (va >> 13) & 7		; get the apr
	off = va & 017777		; extract offset
; ???
;	INVADR, MMUERR(0) if off gt len	; too high

	blk = va & 017700		;
;???
;	if elPpdr[apr] & 010		; negative extension
;	.. el_dbg ("Stk")		; for stacks

	len = (elPpdr[apr]>>2)&017700	; maximum displacement
	if blk gt len			; check errors
	|| !(elPpdr[apr] & mod)		;
	   MMUERR(0)			;
	.. reply elDUM			; dummy address
					;
	pa = (elPpar[apr]<<6)+off	; get the physical address
					;
	if pa ge elVnmx			; between non-existent memory
	&& pa lt elVhwm			; and high-water mark
	|| pa gt elVeow			; or past end-of-world
	.. INVADR(19)

	reply pa if elV22b			; Q-Bus (default)
	reply pa|(elQIO-elUIO) if pa ge elUIO	; Unibus
	reply pa				; rare
  end
end file


;	Default is D-space
;	Only (pc) references are I-space
;
;	0	n/a
;	17	yes
;	27	yes
;	37	first
;	47	yes
;	57	first
;	67	rel - first
;	77	@rel - first
