header	medef - rider memory operations
include	rid:rider				; need compiler flags
	meKrts	:= 1				; use RTS memmove/copy/set
	meKstd	?= 1 If Win			; define own malloc etc
	meKpag	:= 0				; paging is disabled
						;
	me_alc	: (size) *void			; allocate, return pointer
	me_acc	: (size) *void			; ditto and clear
	me_ral	: (*void, size) *void		; reallocate memory
	me_dlc	: (*void) void			; deallocate
	me_alg	: (*void, size, int) *void	; generic allocate
	 meCLR_	:= BIT(0)			; clear memory
	 meALC_	:= BIT(1)			; reply null for failure
	 meALN_ := BIT(2)			; page aligned allocate 
	me_scp	: (size, size, size) size	; scope buffer size
	me_ulk	: (*void) *void			; unlock (nop)
	me_lck	: (*void) *void			; lock (nop)
	me_fix	: (*void) *void			; fix 
	me_flt	: (*void) *void			; float
						;
	me_clr	: (*void, size) *void 		; clear memory
	me_set	: (*void, size, int) *void	; set memory
	me_cop	: (*void, *void, size) *void 	; copy memory
	me_mov	: (*void, *void, size) *void 	; move memory
	me_rep	: (*void, *void,size,int) *void	; replicate memory object
	me_dup	: (*void, size) *void		; clone memory object
	me_lnk	: (*void, size) *void		; make and link
	me_cmp  : (*void, *void, size) int	; compare memory
	me_fnd  : (*void,size,*void,size,**void) int ; compare memory

	mv_alc : (size) *void			; virtual allocate
	mv_dlc : (*void) void
	mv_dup : (*void, size) *void

If mgKpag
	mg_alc	: (size) *void			; global allocate
	mg_acc	: (size) *void			; global allocate & clear
	mg_ral	: (*void, size) *void		; global reallocate
	mg_dlc	: (*void) int			; global deallocate
	mg_alg	: (*void, size, int) *void	; generic allocate
	mg_dup	: (*void, size) *void		; clone memory object
	mg_lck	: (*void) *void			; lock
	mg_ulk	: (*void) *void			; unlock
	mg_fix	: (*void) *void			; fix in memory
	mg_flt	: (*void) *void			; float
Else
	mg_alc	:= me_alc			; dummy global routines
	mg_acc	:= me_acc
	mg_ral	:= me_ral
	mg_dlc	:= me_dlc
	mg_alg	:= me_alg
	mg_dup	:= me_dup
	mg_lck	:= me_lck
	mg_ulk	:= me_ulk
	mg_fix	:= me_lck
	mg_flt	:= me_ulk
End
	meValc	: size extern			; total bytes allocated

;	Retiring

	me_alp	: (**void, size) int		; allocate via pointer
	me_apc	: (**void, size) int		; ditto and clear
	me_dlp	: (**void) void			; deallocate & clear pointer

end header
end file
If Ztc
	ml_alc	:= me_alc
	ml_dlc	:= me_dlc
Else
	ml_alc	: (long) *voidL			; long allocate
	ml_dlc	: (*voidL) void			; long deallocate
End
