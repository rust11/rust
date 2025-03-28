header	fidef - file operations

If Pdp
  type	fiTblk : WORD		; logical block number and count
Else
  type	fiTblk : size		; logical block number and count
End

	fiLspc  := 16				; filespec size
	fiCmax  := 14				; maximum open files

;	fi_def	: (*char, *char, *char) int	; apply default spec
;	fi_get	: (*FILE, *char, int) int	; get line
;	fi_put	: (*FILE, *char) int		; put line with nl

	fi_opn	: (*char, *char, *char) *FILE	; open file
						; "r" "r+" "w" "b" "wb"
	fi_img  : () * FILE			; open image channel
;	fi_clo	: (*FILE, *char) int		; close file
;	fi_chk	: (*FILE, *char) int		; check file
;	fi_del	: (*char, *char) int		; delete file
;	fi_ren	: (*char, *char, *char) int	; rename file
;	fi_exs	: (*char, *char) int		; check file exists
;	fi_mis	: (*char, *char) int		; check file missing
;	fi_spc	: (*FILE) *char			; get known filespec
;	fi_err(f,m) := (!fi_chk (f,m))		; inverted logic
						; fiatr
;	fi_gtm	: (*char, *tiTval, *char) int	; get time
;	fi_stm	: (*char, *tiTval, *char) int	; set time
;	fi_gat	: (*char, *int, *char) int	; get attributes
;	fi_sat	: (*char, int, int, *char) int	; set attributes

;	fi_def	: (*char, *char, *char) int	; apply default spec
;	fi_loc	: (*char, *char) void		; translate to local spec
;	fi_trn	: (*char, *char, int) int	; translate logical names
						; figet
;	fi_get	: (*FILE, *char, int) int	; get line
;	fi_put	: (*FILE, *char) int		; put line with nl
;	fi_prt	: (*FILE, *char) int		; put line without nl
						; firea
;	fi_rea	: (*FILE, *void, size) int	; read bytes => ok
;	fi_wri	: (*FILE, *void, size) int	; write bytes => ok
;	fi_ipt	: (*FILE, *void, size) size	; read bytes => bytes
;	fi_opt	: (*FILE, *void, size) size	; write bytes => bytes
						; fipos
	fi_see	: (*FILE, long) int		; seek
;	fi_end	: (*FILE) int			; seek to end of file
	fi_pos	: (*FILE) long			; get position
	fi_len	: (*FILE) long			; get file length
	fi_siz	: (*char) long			; length of file by name
						; fitra
;	fi_rep  : (*char, *char, *char) int	; report error

;	CRT extensions
;
;	extended file operations

  type	fxText
  is	Verr : char		; returns (signed) error code
	Vflg : char		; flags - unused
	Pspc : * char		; full spec - unused
	Vseq : word		; sequence number
	Valc : WORD		; allocation (size)
  end

	fx_opn	: (*char, *char, *char, *fxText) *FILE	; extended open
;	fx_del	: (*char, *char, *fxText) int		; extended delete
;	fx_ren	: (*char, *char, *char, *fxText) int	; extended rename
;	fx_clo	: (*FILE, *char,*fxText) int		; extended close

	fi_spc : (*FILE) *char				; get file spec

end header
                                                                                                                                                                                                                                                                                                                                                                                                                                                              