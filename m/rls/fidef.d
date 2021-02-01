header	fidef - file operations
include sci:stdio
include rid:tidef

  type	fiTpos : size		; pos: position in file
  type	fiTlen : size		; len: byte in use in file
				; ext: extent - maximum file size
If Pdp
  type	fiTblk : WORD		; logical block number and count
Else
  type	fiTblk : size		; logical block number and count
End

; ???	See mxdef.d
	fiLspc  := 128				; filespec size
	fiCmax  := 64				; maximum open files
						; windows stops at 60
						; fimod
	fi_opn	: (*char, *char, *char) *FILE	; open file
						; "r" "r+" "w" "b" "wb"
	fi_clo	: (*FILE, *char) int		; close file
	fi_chk	: (*FILE, *char) int		; check file
	fi_del	: (*char, *char) int		; delete file
	fi_ren	: (*char, *char, *char) int	; rename file
	fi_exs	: (*char, *char) int		; check file exists
	fi_mis	: (*char, *char) int		; check file missing
	fi_ver  : (*char, *char, int, int) int	; version a filespec
	fi_spc	: (*FILE) *char			; get known filespec
	fi_err(f,m) := (!fi_chk (f,m))		; inverted logic
						; fiatr
	fi_gtm	: (*char, *tiTval, *char) int	; get time
	fi_stm	: (*char, *tiTval, *char) int	; set time
	fi_gat	: (*char, *int, *char) int	; get attributes
	fi_sat	: (*char, int, int, *char) int	; set attributes
						;
	fl_opn(f,m) := fi_opn (f,m,"")		; default forms
	fl_clo(f)   := fi_clo (f,"")		;
	fl_chk(f)   := fi_chk (f,"")		;
	fl_err(f)   := (!fi_chk (f,""))		;
	fl_del(f)   := fi_del (f,"")		;
	fl_ren(o,n) := fi_ren (o,n,"")		;
						; fidef
	fi_def	: (*char, *char, *char) int	; apply default spec
	fi_loc	: (*char, *char) void		; translate to local spec
	fi_trn	: (*char, *char, int) int	; translate logical names
						; figet
	fi_get	: (*FILE, *char, int) int	; get line
	fi_put	: (*FILE, *char) int		; put line with nl
	fi_prt	: (*FILE, *char) int		; put line without nl
						; firea
	fi_gtb	: (*FILE) int			; get byte
	fi_ptb 	: (*FILE, int) int		;

	fi_rea	: (*FILE, *void, size) int	; read bytes => ok
	fi_wri	: (*FILE, *void, size) int	; write bytes => ok
If Dos
	fi_drd	: (*FILE, *void, size) int	; dos read bytes => ok
	fi_dwr	: (*FILE, *void, size) int	; dos write bytes => ok
Else
	fi_drd	:= fi_rea
	fi_dwr	:= fi_wri
End
	fi_ipt	: (*FILE, *void, size) size	; read bytes => bytes
	fi_opt	: (*FILE, *void, size) size	; write bytes => bytes
	fi_flu	: (*FILE) int			; flush output
						; fipos
	fi_see	: (*FILE, long) int		; seek
	fi_end	: (*FILE) int			; seek to end of file
	fi_pos	: (*FILE) long			; get position
	fi_len	: (*FILE) long			; get file length
	fi_siz	: (*char) long			; length of file by name
	fi_lim	: (*FILE, long) int		; set file limit
						; fitra
	fi_cop	: (*char, *char, *char, int) int; copy files by name
	fi_buf	: (*void, size) size		; allocate/deallocate buffer
	fi_tra	: (*FILE, *FILE, size) int	; transfer file => ok
	fi_kop	: (*FILE, *FILE, long) int	; transfer file fast

	fi_loa	: (*char, **void, *size, **FILE, *char) ; load file
	fi_sto	: (*char, *void, size, int, *char) ; store file
	fi_dlc	: (*void) int			; deallocate file buffer

	fi_rep  : (*char, *char, *char) int	; report error

	fi_prd	: (*FILE,*char,size,size,*size) int; padded/partial read
	 fiERR	:= 0  	; I/O error
	 fiSUC	:= 1	; All transferred
	 fiPAR	:= 2	; Partial transfer, padded
	 fiEOF	:= 3	; No transfer, no padding

	fiRON_ := BIT(0)
	fiHID_ := BIT(1)
	fiSYS_ := BIT(2)
	fiDIR_ := BIT(3)
	fiARC_ := BIT(4)
	fiNOR_ := BIT(5)
	fiTMP_ := BIT(7)

end header
end file

If Wdw
;	large I/O operations
	
;	fl_alc	: (long) *voidL			; allocate space
;	fl_dlc	: (*voidL)			; deallocate space
;	fl_lck	: (*voidL)			;
;	fl_ulk	: (*voidL)			;
						;
	fl_rea	: (*FILE, *voidL, long) int	; read bytes => ok
	fl_wri	: (*FILE, *voidL, long) int	; write bytes => ok
;	fl_drd	: (*FILE, *voidL, long) int	; dos read bytes => ok
;	fl_dwr	: (*FILE, *voidL, long) int	; dos write bytes => ok
	fl_ipt	: (*FILE, *voidL, long) long	; read bytes => bytes
	fl_opt	: (*FILE, *voidL, long) long	; write bytes => bytes

; ??????
	fl_buf	: (*void, long) long		; allocate/deallocate buffer
	fl_tra	: (*FILE, *FILE, long) int	; transfer file => ok
	fl_loa	: (*char, **voidL, *long, **FILE, *char) ; load file
	fl_sto	: (*char, *voidL,  long, int, *char) ; store file

End
end file

;	_NFILE	SYS_OPEN  FOPEN_MAX  OPEN_MAX	

#ifdef	FOPEN_MAX		; ansii C
	fiCmax	:= _NFILE	;
#else				;
#ifdef	_NFILE			; many
	fiCmax	:= _NFILE	;
#else				;
#ifdef	SYS_OPEN		; some
	fiCmax	:= _SYS_OPEN	;
#else				;
	fiCmax	:= 20		; all
#endif
#endif
#endif
end header

