header dpdef - directory paths
If Pdp
include	rid:dprst
Else
include rid:dpwin
End

;	dprst.d - rust/rsx
;	dpwin.d - windows
;	dpdef.d	- generic

	dp_alc : (*dpTpth) *dpTpth	; allocate path
	dp_dlc : (*dpTpth)		; deallocate path
					;
	dp_scn : (*dpTpth, int, *char)	; setup to scan
	dpNAM_ := 1			; scan names only
	dp_rew : (*dpTpth)		; rewind
	dp_fin : (*dpTpth)		; close scan
					;
	dp_nxt : (*dpTpth, *dpTnam)	; next name 
	dp_obj : (*dpTpth,*dpTflt,*dpTobj) ; next object
	dp_flt : (*dpTpth,*dpTflt,*dpTobj); filter
					; dpTctl

	dp_roo : (*dpTpth, *char) int	; parse root
	dp_dev : (*dpTpth, *char) int	; check device
	dp_psh : (*dpTpth, *char) int	; add sub-directory
	dp_pop : (*dpTpth) int		; remove sub-directory
	dp_sel : (*dpTflt, int, *char)	; select file name
					;
	dp_rsx : (*char, *char) int	; translate [a.b]...
	dp_ter : (*char, *char, int) int; edit '\' terminator
	dpMHT_ := 1			; must have terminator
	dpRMT_ := 2			; remove terminator
	dpADT_ := 3			; add terminator

end header
