header	rtdir - RT11x file structure
;Error Crt rtdef If !Crt

  type	rtThdr
  is	Vtot : WORD		; total segments
	Vnxt : WORD		; next segment
	Vlst : WORD		; last segment in use
	Vext : WORD		; extra bytes per entry
	Vblk : WORD		; start block of first entry
  end
	rtEXT_ := (~(0776))	;  Vext valid mask (even && lt 512)

  type	rtTent			; RT11A
  is	Vsta : WORD		; status
	Anam : [3] WORD		; filename in rad50
	Vlen : WORD		; length
	Vtim : WORD		; time in 3 second units
	Vdat : WORD		; date
				; RT11X
	Vctl : WORD		; various
	Vuic : WORD		; UIC
	Vpro : WORD		; protection
  end
	rtRTX := 6		; extra bytes for RT11X
	rtRTA := #rtTent-rtRTX	; RT11A entry size

	rtTEN_ := 0400		; tentative file
	rtEMP_ := 01000		; empty entry
	rtPER_ := 02000		; permanent entry
	rtEND_ := 04000		; end of segment
	rtPRO_ := 0100000	; protected file

	rtTIM_ := 0100000	; Vtim flag
	rtREM_ := 03		; time remainder in Vctl
	rtBYT_ := 03774		; byte remainder in Vctl

  type	rtTscn
  is	Vseg : WORD			; next segment (keep this first)
	Vext : WORD			; extra bytes per entry
	Pnxt : * rtTent			; next entry
	Vacc : WORD			; block accumulator
					;
	Pent : * rtTent			; current entry
	Vblk : WORD			; start block of file
					;
	Vsel : WORD			; entry selection flags
	Pfil : * FILE			; access file
	Pbuf : * char			; buffer pointer
	Abuf : [1024] char		; segment buffer
	Aspc : [64] char		; directory specification
	Perr : * char			; message if error detected
  end

;	status returns

	rtIDF := 1			; invalid directory format
	rtDIO := 2			; directory I/O error

	rtWAI := 0			; wait I/O
	rtPOL := 1			; polled I/O
	rtEXA_ := 2			; exact transfer count

	rt_alc : () * rtTscn		; allocation
	rt_scn : (*rtTscn, *char, int, *char) *rtTscn	; scan RT-11 directory
	rt_nxt : (*rtTscn, *char) int	; next RT-11 entry
	rt_ent : (*rtTscn, *rtTent) int	; copy/edit entry
	rt_rew : (*rtTscn)		; rewind and rescan
	rt_fin : (*rtTscn)		; finish scan
	rt_dlc : (*rtTscn)		; deallocate scan

end header
