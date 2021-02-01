header	sbdef - storage buffer

  type	sbTcmp : * void ;(*char, *char) int; qsort compare routine

  type	sbTsto
  is	Psto : * char		; storage buffer
	Lsto : size		; buffer length
	Litm : size		; item size
	Vmax : int		; max item number
				; put
	Vcnt : int		; number of items stored
	Ptop : * char		; current top item stored
	Lrem : size		; remaining bytes
				; get
	Pcur : * char		; current item pointer
	Vcur : int		; current item number
				; index
	Pcmp : * void		; compare routine
	Pidx : * char		; sort index
	Vidx : int		; current index item
	Ptmp : * char		; temp for sort/reverse
  end

	sb_ini : (size, size, *sbTcmp) *sbTsto
	sb_dlc : (*sbTsto)
	sb_clr : (*sbTsto)
	sb_rew : (*sbTsto)
	sb_srt : (*sbTsto)
	sb_sto : (*sbTsto, *void)
	sb_nxt : (*sbTsto, *void)
	sb_srt : (*sbTsto)
	sb_rev : (*sbTsto)

end header
