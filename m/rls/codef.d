header	codef - console definitions

	co_ctc : (int) int
	coCHK := 1
	coENB := 2
	coDSB := 3
If !Pdp
include rid:mxdef
include	rid:kbdef

	coVbrk : int extern
	co_att : (*void) int
	co_det : (void) int
 	co_dlc : (void) void
 type	coTget : (*kbTcha, int) int
	co_get : coTget
	co_prm : (*char, *char, size) int
	coPget : *coTget extern

;	Following are used for hand-held command input

  type	coTtxt : [mxLIN+1] char

  type	coTlin
  is	Vflg : int		;
	Pprm : * char		; prompt
	Lprm : int		; prompt length
				;
	Vpos : int		; position in line
	Vcnt : int		; chars in line
	Lbuf : int		; buffer length
	Abuf : [mxLIN+4] char	; composition buffer
				; history
	Vcur : int		; current line #
	Vfst : int		; first line
	Vlst : int		; last line
	Vuse : int		; number in use
	Lhis : int 		; length of history buffer
	Ahis : [64] coTtxt	; history array
  end

	co_lin : (**coTlin, *char) *coTlin
	co_edt : (*coTlin, *kbTcha) int
	co_cop : (*coTlin, *char) void
End

end header
