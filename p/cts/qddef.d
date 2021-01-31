header	qddef - quad integer arithmetic header

;	Quads are represented as four 16-bit (unsigned) words
;	PDP-11 reverse-ordering is used, as for longs:
;
;	quad:	.word	high-order	; quad sign bit is bit 15
;		.word	...
;		.word	..
;		.word	low-order	; quad bit 0 is bit 0

	qd_lqu : (long, *WORD)		; long to quad, unsigned
	qd_lqs : (long, *WORD)		; long to quad, signed
	qd_qtl : (*WORD, *long)		; quad to long (chopped)
	qd_clr : (*WORD)		; quad clear 
	qd_tst : (*WORD) int		; quad test 
	qd_neg : (*WORD)		; quad negate 
	qd_com : (*WORD)		; quad complement 
	qd_rol : (*WORD, int) int	; quad rotate left, with carry 
	qd_ror : (*WORD) int		; quad rotate right 
	qd_mov : (*WORD, *WORD)		; quad move
	qd_add : (*WORD, *WORD, *WORD)	; quad add 
	qd_sub : (*WORD, *WORD, *WORD)	; quad subtract res = rgt - lft
	qd_cmp : (*WORD, *WORD, *WORD) int   ; compare  res = sgn(lft - rgt)
	qd_mul : (*WORD, *WORD, *WORD)	     ; multiply
	qd_div : (*WORD, *WORD, *WORD, *WORD); divide   res/mod = (rgt /% lft)
					     ;		0 => zero divide

	qd_set : (*WORD, WORD, WORD, WORD, WORD); quad set
	qd_dmp : (*char, *WORD)			; dump as four hex WORDs
	qd_dec : (*WORD)			; display quad decimal
	qd_hex : (*WORD)			; display quad hex
	qd_put : (*char, *WORD, *char)		; format and display
	qd_fmt : (*char, *WORD, *char) *char	; formatted quad
	qd_str : (*WORD, *char, int) *char	; quad to decimal string

end header
