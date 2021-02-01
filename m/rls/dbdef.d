header	dbdef - debug
include	rid:mxdef

If Win
data	dbwin - LastError support

	db_clr	: (void) int		; clear error
	db_lst	: (*char) int		; display last error, if any
	db_rep 	: (*char, int) int	; report message by code
	dbw_msg	: (nat) *char		; WM.. message to text
	dbw_err : (nat) *char		; error code to text

	db_prc : (*char, *char) LONG	; get procedure address

data	dbexc - Exception catcher

  type	dbTexc
  is	Pip  : * BYTE
	Psp  : * LONG
	Vcod : int
	Vflg : int
	Vadr : * LONG
	Aspc : [mxSPC] char
  end

  type	dbTprc : (*dbTexc) int
	db_ini : (void) int		; init default exception catcher
	db_exi : (void) void		; cancel exception catcher
	db_rev : dbTprc			; default exception handler
	db_hoo : (*dbTprc) int		; hook exceptions

data	dbwin - read/write memory

  type	dbTacc
  is	Hprc : * void
  end

	db_opn : (*dbTacc, *char, long, int) int
	db_clo : (*dbTacc)
	db_rea : (*dbTacc, *void, *void, size) int
	db_wri : (*dbTacc, *void, *void, size) int

	db_dis : (*dbTacc, *char, *void) *void
End

end header
