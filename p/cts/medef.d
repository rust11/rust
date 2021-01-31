header	medef - memory operations

	me_alc	: (size) *void			; allocate, return pointer
	me_acc	: (size) *void			; ditto and clear
	me_alg	: (*void, size, int) *void	; generic allocate
	 meCLR_	:= BIT(0)			; clear memory
	 meALC_	:= BIT(1)			; reply null for failure
;	 meALN_ := BIT(2)			; page aligned allocate 
	me_dlc	: (*void) void			; deallocate
	me_scp	: (size, size, size) size	; scope a buffer

	me_clr	: (*void, size) *void 		; clear memory
	me_set	: (*void, size, int) *void	; set memory
	me_cop	: (*void, *void, size) *void 	; copy memory
	me_mov	: (*void, *void, size) *void 	; move memory
	me_rep	: (*void, *void, int) *void	; replicate memory object
	me_dup	: (*void, size) *void		; clone memory object
	me_cmp  : (*void, *void, size) int	; compare memory
	me_fnd  : (*void,size,*void,size,**void) int ; compare memory

;	CRT only

	me_map	: (size) * void+	; allocate with error return
	me_max	: (size) size		; get maximum empty size

	me_pee	: (*void, *void, int) int
	me_pok	: (*void, *void, int) int

  type	meTctx
  is	Vval : WORD
	Vadr : WORD
  end

	me_sav	: (*meTctx) void	; save memory context
	me_res	: (*meTctx) void	; restore memory context

end header
