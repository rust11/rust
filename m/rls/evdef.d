header	evdef - environment variables

	ev_ins	: (void) int
	ev_get	: (*char, *char, int) int	; get value
	ev_set	: (*char, *char) int		; set value

;	ev_rea	: (*char,*char,*char,*char,int)	; GetPrivateProfile
;	ev_wri	: (*char, *char, *char, *char)	; WritePrivateProfile

	evUNK	:= 0				; unknown
	evRST 	:= 1				; RUST 
	evFST	:= 2				; first signal
	evLOG	:= 2				; logical names
	evCMD	:= 3				; command definitions
	evDEV	:= 4				; device definitions
	evLST	:= 4				; last signal

 	ev_sig	: (int) int			; signal change
	ev_chk	: (int) int			; check change

end header
