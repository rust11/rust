file	abwin - Windows abort control
include	rid:rider
include	rid:abdef

;???	Abort not implemented yet

	abPbrk	: * (void) void = <>	; break routine (dos only)
	abVboo  : int volatile = 0	; enables boot on abort (dos only)
					;
	abVcan	: int volatile = 0	; ne => some abort seen (dos only)
	abPcan	: * (void) void = <>	; abort for some other psp (dos only)
					;
	abVabt	: int volatile = 0	; ne => abort seen for this process
	abPabt	: * (void) void = <>	; abort routine for this process
	abVmod	: int = 1		; 1 => aborts enabled
	abVini	: int own = 0		; initialized

	abFcri	: int = 0		; 0 => pass critical errors 
	abVcri	: int = 0		; counts critical errors
	abPcri	: * (*void) int = <>	; critical error routine

code	ab_dsb - disable aborts

  proc	ab_dsb
  is	abVmod = 0			; disable aborts
	ab_ini ()			; force init
  end

code	ab_enb - enable aborts

  proc	ab_enb
  is	abVmod = 1			; enable aborts
	ab_ini ()			; force init
  end

code	ab_chk - check & clear

  func	ab_chk
	()  : int			; fine => aborted
  is	res : int = abVabt		;
	abVabt = 0			;
	abVcan = 0			;
	reply res			; fine => aborted
  end
code	abort internals

	ab_exi	: (void) void own	;
	abVerr	: int own = 0		; critical errors

code	ab_ini - init system stuff

  func	ab_ini
	()  : int			; fine/fail
  is	fine if abVini ne		; already initialized
	++abVini			; once only
	fine
  end

code	ab_exi - exit cleanup

  proc	ab_exi
  is	exit if abVini eq		; was not initialized
	abVini = 0			; switch them all off
  end
end file
code	_ab_brk - break ast

  stub	_ab_brk
	incw	cs:abVsem		; once only
	bne	30$			; already here
	pshw	<ax,bx,cx,dx,si,di,bp,ds,es>
	movw	cs:abVds,ds		; callers data segment
	incw	_abVabt			; count the abort
	incw	_abVcan			; and the cancel
	beqw	_abPbrk+2,10$		; has no routine
	jsbf	_abPbrk			; call them
  10$:	beqw	_abVboo,20$		; no boot 
	bltw	_abVabt,#7,20$		; not time
	jmpf	_ds_SofBoo		; calleth boot
  20$:	popw	<ax,bx,cx,dx,si,di,bp,ds,es>
  30$:	decw	cs:abVsem		;
	jmpfd	0,abPi1a		;

code	_ab_ctc - ctrl/c ast

  stub	_ab_ctc
	incw	cs:abVsem		; once only
	bne	50$			; already here
	pshw	<ax,bx,cx,dx,si,di,bp,ds,es>
	movw	cs:abVds,ds		; callers data segment
	movw	#1,_abVcan		; something was cancelled
	GetPsp$				; get current psp
	bnew	ax,_abVpsp,20$		; not our process
	beqw	_abPcan+2,10$		; no routine
	jsbf	_abPcan			; call cancel routine
  10$:	brb				;
  20$:	beqw	_abPabt+2,30$		; no
	jsbf	_abPabt			; call abort routine
  30$:	beqw	_abVmod,40$		; abort not enabled
	jsbf	_ab_exi			; call them for this
  40$:	popw	<ax,bx,cx,dx,si,di,bp,ds,es>
  50$:	decw	cs:abVsem		;
	jmpfd	0,abPi1a		;

  func	ab_ctc 				; signal routine
	frm : * abTint			; interrupt frame
	()  : int			; 0 => call previous
  is	abVcan = 1			; something is cancelled
	if ds_GetPsp () ne abVpsp	; not for us anyway
	   (*abPcan)() if abPcan ne <>	; got a function
	.. reply 0			; pass it on
	abVabt = 1			; disabled - remember it
	(*abPabt)() if abPabt ne <>	; got a function
	abort if abVmod ne		; ctrl/c is enabled
	reply 1				; call previous handler
  end

