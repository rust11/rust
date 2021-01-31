header	timat - time math
include	rid:tidef

	ti_clr : (*tiTval)			; quad clear
	ti_mov : (*tiTval, *tiTval)		; quad move
	ti_add : (*tiTval, *tiTval, *tiTval)	; quad add 
	ti_sub : (*tiTval, *tiTval, *tiTval)	; quad subtract
	ti_cmp : (*tiTval, *tiTval) int		; compare
	ti_mul : (*tiTval, *tiTval, *tiTval)	; multiply
	ti_div : (*tiTval, *tiTval, *tiTval, *tiTval); divide

end header
