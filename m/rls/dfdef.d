header	dfdef - definition definitions
include	rid:mxdef

;	_dfROL	:= "@ini@:roll.def"
;	_dfSHE	:= "ini:she.def"
;	_dfANO := "[]"			; default anonomous section

  type	dfTdef				; user definition
  is	Psuc : * dfTdef			; successor
;	Psub : * dfTdef			; sublist
	Pnam : * char			; definition name
	Pbod : * char			; definition body
  end

  type	dfTctx
  is	Vflg : int			; control flags
	Proo : * dfTdef			; the first of it
	Pspc : * char			; disk file spec
	Popr : * char			; assignment operator (":=")
	Pbal : * char			; balancing set (e.g. " ' ()
	Vsep : int			; argument separator (space, comma)
	Palc : * (size) *void		; allocation routine
	Pdlc : * (*void) void		; deallocation routine
	Prep : * (*char, *char) int	; error report routine
	Pmsg : * char			; most recent message
	Aobj : [mxSPC] char		; its object (a copy)
;	Asec : [mxLIN] char		; current section name (if any)
	Vsig : int			; signal
;	Pstk : * char			; cli expansion stack
  end

	dfINI_	:= BIT(0)		; is initialized
	dfMOD_	:= BIT(1)		; something modified
	dfDYN_	:= BIT(2)		; dynamic - read before each change
	dfERR_	:= BIT(3)		; some error detected
	dfMUT_	:= BIT(4)		; mute - report no errors
	dfMEM_	:= BIT(5)		; memory only - no read/write
	dfSTA_	:= BIT(6)		; static - read-only
	dfEPH_	:= BIT(7)		; ephemeral - ignore missing file
	dfREA_	:= BIT(7)		; read in progress
	dfMRK_	:= BIT(8)		; error marked during read
	dfCOR_	:= BIT(9)		; definition file is corrupt
	dfCAS_	:= BIT(10)		; names are case sensitive
	dfUPD_  := BIT(11)		; update input file with changes

	df_alc  : () *dfTctx
	df_dlc	: (*dfTctx) void		; deallocate defs and context
	df_zap	: (*dfTctx) void		; deallocate definitions
						;
	df_ctx	: (*char, int) *dfTctx		; build definition context
						;
	df_idt	: (*dfTctx, *char) int		; identity (has " := ")
	df_def	: (*dfTctx, *char) int		; hand held definition?
	df_loo	: (*dfTctx, *char) * dfTdef	; lookup definition
	df_nth	: (*dfTctx, int) *dfTdef	; return nth definition
	df_rea	: (*dfTctx) int			; read definitions
	df_wri	: (*dfTctx) int			; write definitions
	df_lst	: (*dfTctx) void	;?	; list definitions	
						;
	df_ins	: (*dfTctx, *char, *char) int	; insert definition

	df_trn	: (*dfTctx, *char, *char, int)	; translate definition
	df_exp	: (*dfTctx, *dfTdef, *char, *char, int, int, int) int
						; expand definition
;	Internal

	df_rep	: (*dfTctx, *char, *char) void	; report errors
end header
