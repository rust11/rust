header	rgdef - RUST registry access

	rg_ini	: (void) int
	rg_get	: (*char, *char, int) int	; get value
	rg_set	: (*char, *char) int		; set value
	rg_und	: (*char) int			; undefine name
	rg_nth	: (int, *char, int) int		; enumerate names

end header
