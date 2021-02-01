header	htdef - hash trees

  type	htTnod 
  is	Pnam : * char			; name string
	Psym : * void			; symbol
	Vhsh : int			; hash value
	Plft : * htTnod			; left branch
	Prgt : * htTnod			; right branch
  end

	ht_ini	: (void) int
	ht_nam	: (*htTnod) * char	; get node name
	ht_sym	: (*htTnod) * void	; get node symbol
	ht_set	: (*htTnod, *void) void	; set node symbol
	ht_ins	: (*char) *htTnod	; insert new name
	ht_fnd	: (*char) *htTnod	; find name in tree
  type	htTcbk	: (*htTnod) void	; call back function
	ht_wlk	: (*htTcbk) void	; walk tree
	ht_anl	: (void) void		; analyse tree

end header
