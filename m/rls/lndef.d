header	lndef - logical names

;	Earlier code had special cases for equivalence
;	names beginning with '@' and '_'.

	lnLIM	:= 30			; recursion limit

	ln_exi	: (void) void		; exit
	ln_def	: (*char,*char,int) int ; define
	ln_und	: (*char, int) int	; undefine
	ln_trn	: (*char,*char,int) int ; translate
	ln_rev	: (*char,*char,int) int ; reverse translate
	ln_nth	: (int, *char, *char, int) int ; nth

	lnPEN_	:= BIT(0)		; translate penultimate logical name


end header
end file

RST_C := 1				; RUST version

If RST_C
	_lnLOG	:= "@ini@"		; home directory
	_lnROO	:= "root"		; new root
					;
	_lnFIL	:= "@ini@:roll.def"	;
	_lnROL	:= "root:roll.def"	;
					;
	_lnDEF	:= "c:\\ini\\"		; only if root not found
	_lnRST	:= "c:\\rust\\"		; only if root not found
Else
	_lnLOG	:= "@ini@"		; home directory
	_lnFIL	:= "@ini@:roll.def"	;
	_lnDEF	:= "c:\\ini\\"		; only if root not found
End
