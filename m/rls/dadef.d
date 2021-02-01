header	dadef - disassembler
include	rid:dbdef
include	rid:mxdef

  type	daTctl
  is	Pacc : * dbTacc		; target memory access
	Vbas : long		; first byte address
	Vadr : long		; past last byte
				;
	Vpre : int		; prefix character
	Vmrm : int		;
	Qmrm : int		;
	Vsib : int		;
	Qsib : int		;
	Vops : int		; operand size
	V32b : int		; is 32b operand
	Pbuf : * char		;
	Abuf : [mxLIN] char	;
  end

	da_dis : (*daTctl, long) int

end header
