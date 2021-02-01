header	mtdef - metas
include	rid:dfdef

;	Metas defined during expansion are not stored???

	mtLEN := 4096		; default expansion buffer size

  type	mtTmet
  is	Pdef : * dfTctx		; definitions
	Pexp : * char		; expansion buffer
	Pnxt : * char		; next expansion
	Ptop : * char		; end of expansion buffer
	Vfre : size		; available space in expansion buffer
	Vexp : int		; >0 => expansions available
  end

	mt_ini	: (*char, size) *mtTmet
	mt_exi	: (void) void
	mt_def	: (*mtTmet, *char, *char) int
	mt_ref	: (*mtTmet, *char, *char) int
	mt_get	: (*mtTmet, *char) int
	mt_ins	: (*mtTmet, *char) int

;	ut_get	: (*mtTmet, *char) int
	mt_red	: (*char) int
	mt_scn	: (*char, *char) int
	mt_cma	: (*char) int
	mt_idt	: (*char, *char) int
	mt_jnk	: (*mtTmet) int
	mt_rep	: (*mtTmet, *char, *char) int
	mt_app	: (*char, *char) *char
	mt_bal	: (**char, **char) void
	mt_sym	: (int) int

end header
