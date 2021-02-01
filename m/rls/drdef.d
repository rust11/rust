header	drdef - directories
include	rid:mxdef
include rid:tidef

  type	drTent			; entry
  is	Psuc : * drTent		; next or null
	Pnam : * char		; filename
	Palt : * char		; alternate name
	Vatr : int		; file attributes
	Vsta : int		; flags - unused
	Vsiz : LONG		; file size in bytes
	Vext : LONG		; high order size
	Itim : tiTval		; file time (last write)
	Icre : tiTval		; creation time
	Iacc : tiTval		; access time
  end

  type	drTdir			; directory
  is	Ppth : * char		; directory path -- mxSPC string for edits
	Proo : * drTent		; first entry
	Pnxt : * drTent		; next entry
	Vatr : int		; filter attributes
	Vsrt : int		; sort criteria
	Vovr : int		; memory overflow
	Verr : int		; error count
	Vcnt : int		; number of entries
	Pext : * void		; local extensions
  end

	drNON	:= 0		; no sort
	drNAM	:= 1		; name
	drTYP	:= 2		; type
	drSIZ	:= 3		; size 
	drTIM	:= 4		; date/time
	drSRT_	:= 15		; sort flags
				;
	drREV_	:= BIT(5)	; reverse sort
	drEXC_	:= BIT(6)	; exclude filter
	drCAS_	:= BIT(7)	; case is significant
				;
	drPTH	:= 5		; path
	drDIR	:= 6		; directory
	drDRV	:= 7		; drive

	dr_val  : (*char) int
	dr_scn	: (*char, int, int) *drTdir
	dr_nxt	: (*drTdir) *drTent
	dr_dlc	: (*drTdir) void
	dr_spc	: (*char, *char, *char) *char
	dr_roo	: (*char) int

	dr_sho	: (*char, int) int
	dr_set	: (*char, int) int
	dr_avl	: (*char) int
	dr_mak	: (*char) int
	dr_rem	: (*char) int

  type	drTsiz	: size			; drive/directory sizes
	dr_fre	: (*char, *drTsiz) int	; get free space
;	dr_tot	: (*char, *drTsiz) int	; get total space

	dr_enu	: (*drTdir, *drTent, int, int) *drTent
	dr_don	: (*drTdir) void
	dr_mat	: (*drTdir, *char) int
	dr_pth	: (*char, *char) void

data	Dos/Windows file attributes

	drNOR_	:= 0		; normal file
	drRON_	:= BIT(0)	; read only
	drHID_	:= BIT(1)	; hidden
	drSYS_	:= BIT(2)	; system
	drVOL_	:= BIT(3) ;old	; volume label
	drLAB_	:= BIT(3) ;new	; volume label
	drDIR_	:= BIT(4)	; directory
	drARC_	:= BIT(5)	; archive
	drPER_	:= BIT(6)	;*peripheral device (returned only)
;		:= BIT(7)	; unused
	drSHR_	:= BIT(8)	;*shareable (netware)
				; Win32
	drTMP_  := BIT(8)	; temporary file
	drATM_	:= BIT(9)	; atomic_write
	drTRA_  := BIT(10)	; xaction_write
	drCMP_  := BIT(11)	; compressed file
				;
				; HAMMONDsoftware - drmod.r only
	drFST_	:= BIT(15)	; first file
				;
	drALL_	:= 0xffff	; all of them

end header
