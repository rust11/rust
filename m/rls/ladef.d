file	ladef - latin font definitions

data	character types

	laUNK  := 0		; unknown
	laCHA  := 1		; character
	laSUP  := 2		; superscript
	laNAM  := 3		; object name
	laOPR  := 4		; operator name

	laAuni : [] WORD extern
	laAkbd : [] WORD extern
	la_ini : () 
	la_rep : (**char, **char) int
	la_typ : (int) int
end file
