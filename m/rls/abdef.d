header	abdef - abort control

	ab_ini : (void) int		; initialize aborts
	ab_dsb : (void) void		; disable aborts
	ab_enb : (void) void		; enable aborts
	ab_chk : (void) int		; check (and clear) aborted

	abPbrk	: * () void extern	; break routine
	abVboo	: int volatile extern	; enable boot on 7 breaks
	abPcan	: * () void extern	; some other psp & ctrlc
	abVcan	: int volatile extern	; enable cancels

	abPabt	: * () void extern	; the abort routine
	abVabt	: int volatile extern	; ne => aborted
	abVmod	: int extern		; 1 => aborts enabled
					;
	abFcri	: int extern		; 1 => handle critical errors
	abVcri	: int extern		; counts critical errors
	abPcri	: * (*void) int extern	; user ast

end header
