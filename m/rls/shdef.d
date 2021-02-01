header	shdef - shell
include	rid:mxdef

	_shSHE := ("c:\\bin\\she.exe")	;
	_shCMD := ("c:\\windows\\command.com /c ")

  type	shTshe : forward
  type	shTfun : (*shTshe) int		; protofunction
  type	shTusr : (*void) int		; user call back

  type	shTshe
  is	Pusr : * void			; user context
	Vflg : int			; some flags
	Plin : * char			; line buffer
	Pcmd : * char			; current command
	Prem : * char			; remainder of command
	Pprm : * shTfun			; prompt callback
	Pdis : * shTfun			; dispatch callback
	Plex : * shTfun			; lexical callback
	Phlp : * shTfun			; help callback
	Pset : * shTfun			; set callback
	Psho : * shTfun			; show callback
	Aprm : [mxLIN] char		; command prompt
	Vsts : int			; exit status

;	Additions for DF_ENG

	Vexp : int			; expansion flags
	Pexp : * char			; pointer to expansions
  end

	shMAN_ := BIT(0)		; manually driven
	shCTC_ := BIT(1)		; allow ctrl/c
	shSHE_ := BIT(2)		; this is a shell - dont abort
					;
	shCMD_ := BIT(27)		; passing command back
	shPRC_ := BIT(28)		; in shell procedure
	shEXI_ := BIT(29)		; exit command
	shTER_ := BIT(30)		; terminated by ctrl/c
	shABT_ := BIT(31)		; aborted
	shFIN_ := (shEXI_|shTER_|shABT_); finished

	sh_ini : (void) *shTshe		; init she
	sh_mai : (int, **char) int	; mainline
	sh_cmd : shTfun			; process command
	sh_exi : (void) void		; flag exit

	shPshe : * shTshe extern

  type	shTkwd
  is	Pfun : * (*char) void		; some function
	Pkwd : * char			; the keyword
  end

end header
