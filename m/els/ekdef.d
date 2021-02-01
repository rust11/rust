header	ekdef - threaded keyboard
include	rid:kbdef

  type	ekThoo : (*kbTcha) int

	ek_ini : (*ekThoo) void		; keyboard thread
	ek_get : (*kbTcha, int) int
	ek_can : (void) void
	ek_brk : (void) void

end header
