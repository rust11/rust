
file	abvms - VMS abort control
include	rid:rider
include	rid:abdef
include	<iodef.h>
include	<ssdef.h>

;	ctrl/c		ctrl/c abort
;	ctrl/break	break
;	ctrl/y		
;	local		abort for this process
;	child		abort for child process 
;	abort		abort on signal
;	exit		exit on condition
;	callback	callback on condition

	abPabt	: * () void = <>	; the abort routine
	abVcan	: int volatile = 0	; 
	abVabt	: int volatile = 0	; ne => aborted
	abVmod	: int = 1		; 1 => aborts enabled
	abVini	: int own = 0		; initialized

data	locals

  type ascid
  is	Vlen : int			; simple descriptor
	Pstr : * char			;
  end

  type	iosb				; terminal IOSB
  is	Vcod	: short			; system code
	Vcnt 	: short			; data count
	Vxxx	: short			; who cares
	Vter	: short			; terminator count
  end

	abDipt	: ascid = {9, "sys$input"}
	abDopt	: ascid = {10, "sys$output"}

	abVcch	: int = 0		; control channel
	abVcef	: int = 0		;
	abScsb	: iosb = {0}		;

	abVoch	: int = 0		; output channel
	abVoef	: int = 0		; output event flag
	abSosb	: iosb = {0}		; output status block

	ab_que	: () void
	ab_ast	: () void
code	ab_ini - init abort

  func	ab_ini
	()  : int				; status
  is	sta : int = 1				; accumulate VMS status
	fine if abVini ne			; already done
	++abVini				; once only
	sta &= lib$get_ef (&abVoef)		; get some flags
	sta &= lib$get_ef (&abVcef)		;
	sta &= sys$assign (&abDipt, &abVcch,0,0); abort channel
	sta &= sys$assign (&abDopt, &abVoch,0,0); output channel
	reply sta				; fine if all succeeded
  end

code	ab_dsb - disable aborts

  proc	ab_dsb
  is	ab_ini ()			; force init
	exit if abVmod eq		; already disabled
	abVmod = 0			; are no longer
	ab_que (&ab_ast)		; start catching them
  end

code	ab_enb - enable aborts

  proc	ab_enb
  is	ab_ini ()			; force init
	exit if abVmod ne		; already enabled
	abVmod = 1			; are now
	ab_que (<>)			; stop catching them
  end

code	ab_chk - check & clear

  func	ab_chk
	()  : int			; fine => aborted
  is	res : int = abVabt		;
	abVabt = 0			;
	reply res			; fine => aborted
  end
code	ab_que - queue ctrl/c ast

  proc	ab_que
	ast : * () void			; ast, <> to clear
  is	sys$qio (abVcef, abVcch,
		 IO$_SETMODE|IO$M_CTRLCAST,
		 &abScsb, 0, 0,
		 ast, 0, 0, 0, 0, 0)
  end

code	ab_ast - ctrl/c ast

  proc	ab_ast
  is	ab_que (&ab_ast)		; queue the next
	++abVabt			; we haf aborted
	(*abPabt)() if abPabt ne <>	; got a routine
	sys$cancel (abVoch)		; cancel output
  end
